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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Настройка системного UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // КРИТИЧНО: EasyLocalization должен быть инициализирован ДО runApp
  // Optimizatsiya: useOnlyLangCode: true - faqat til kodini ishlatish (kamroq fayl yuklaydi)
  // Bu main thread'ni kamroq bloklaydi va ANR muammosini kamaytiradi
  await EasyLocalization.ensureInitialized();

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
      // useOnlyLangCode: false - locale'ni to'liq ko'rsatish uchun (uz_CYR uchun uz-CYR.json ishlatiladi)
      useOnlyLangCode: false,
      // Fallback translation'larni yuklash - agar tarjima topilmasa, fallback locale'dan foydalanadi
      useFallbackTranslations: true,
      child: const App(),
    ),
  );

  // Инициализация в фоне после показа UI
  // Используем unawaited, чтобы не блокировать main thread
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Запускаем в отдельном микротаске для неблокирующего выполнения
    Future.microtask(() => _initializeInBackground());
  });
}

// Оптимизированная инициализация всех сервисов в фоне
// Используем isolate для тяжелых операций, чтобы не блокировать main thread
Future<void> _initializeInBackground() async {
  try {
    // 1. Сначала настраиваем base URL для API (критично!) - синхронная операция
    ApiConfigService.configureBaseUrl();

    // 2. EasyLocalization уже инициализирован в runApp, не нужно повторно инициализировать
    // await EasyLocalization.ensureInitialized(); // УДАЛЕНО - дублирование

    // 3. Параллельная инициализация некритичных сервисов
    // Они не зависят друг от друга, поэтому можем запустить параллельно
    final nonCriticalFutures = _initializeNonCriticalServices();

    // 4. Инициализируем AuthService (нужен для DioClient)
    await AuthService.instance.init();

    // 5. Только после настройки base URL и AuthService создаем ServiceLocator с API клиентами
    await ServiceLocator.init();

    // 6. Ждем завершения некритичных сервисов (не блокируем main thread)
    await nonCriticalFutures;
  } catch (e) {
    debugPrint('Initialization error: $e');
  }
}

// Некритичные сервисы инициализируются параллельно
// Возвращаем Future, чтобы можно было await в основном потоке
Future<void> _initializeNonCriticalServices() async {
  await Future.wait([
    RootService().init().catchError((e) {
      debugPrint('RootService init error: $e');
    }),
    ThemeController.instance.init().catchError((e) {
      debugPrint('ThemeController init error: $e');
    }),
    // initializeDateFormatting() может быть тяжелой операцией
    // Запускаем асинхронно, чтобы не блокировать main thread
    initializeDateFormatting().catchError((e) {
      debugPrint('Date formatting init error: $e');
    }),
  ]);
}
