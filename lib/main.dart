import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/dio/singletons/service_locator.dart';
import 'core/services/auth/auth_service.dart';
import 'core/services/config/api_config_service.dart';
import 'core/services/locale/root_service.dart';
import 'core/services/theme/theme_controller.dart';
import 'package:easy_localization/easy_localization.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Настройка системного UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Показываем UI сразу, инициализация в фоне
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('uz'),
        Locale('uz', 'CYR'),
        Locale('ru'),
        Locale('en'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      saveLocale: true,
      startLocale: const Locale('en'),
      child: const App(),
    ),
  );

  // Инициализация в фоне после показа UI
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeInBackground();
  });
}

// Упрощенная инициализация всех сервисов в фоне
Future<void> _initializeInBackground() async {
  try {
    // Быстрые операции
    ApiConfigService.configureBaseUrl();
    await EasyLocalization.ensureInitialized();

    // Тяжелые операции параллельно
    await Future.wait([AuthService.instance.init(), ServiceLocator.init()]);

    // Некритичные сервисы в фоне
    _initializeNonCriticalServices();
  } catch (e) {
    debugPrint('Initialization error: $e');
  }
}

// Некритичные сервисы инициализируются параллельно
void _initializeNonCriticalServices() {
  Future.wait([
    RootService().init().catchError((e) {
      debugPrint('RootService init error: $e');
    }),
    ThemeController.instance.init().catchError((e) {
      debugPrint('ThemeController init error: $e');
    }),
    initializeDateFormatting().catchError((e) {
      debugPrint('Date formatting init error: $e');
    }),
  ]);
}
