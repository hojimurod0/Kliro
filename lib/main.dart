import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/dio/singletons/service_locator.dart';
import 'core/dio/singletons/service_locator_state.dart';
import 'core/services/auth/auth_service.dart';
import 'core/services/config/api_config_service.dart';
import 'core/services/locale/root_service.dart';
import 'core/services/theme/theme_controller.dart';
import 'core/utils/logger.dart';
import 'core/utils/global_error_handler.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

import 'core/utils/sentry_stub.dart'
    if (dart.library.io) 'package:sentry_flutter/sentry_flutter.dart' as sentry;

Future<void> main() async {
  if (kReleaseMode) {
    try {
      await sentry.SentryFlutter.init(
        (options) {
          options.tracesSampleRate = 0.2;
          options.environment = kReleaseMode ? 'production' : 'development';
          options.beforeSend = (event, hint) {
            if (event.request?.data != null) {
              final data =
                  Map<String, dynamic>.from(event.request!.data as Map);
              data.removeWhere((key, value) =>
                  key.toLowerCase().contains('password') ||
                  key.toLowerCase().contains('token') ||
                  key.toLowerCase().contains('pin'));
              event.request = event.request!.copyWith(data: data);
            }
            return event;
          };
        },
        appRunner: () => _runApp(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Sentry initialization failed: $e');
      }
      await _runApp();
    }
  } else {
    await _runApp();
  }
}

Future<void> _runApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  GlobalErrorHandler.initialize();

  await EasyLocalization.ensureInitialized();

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
      useOnlyLangCode: false,
      useFallbackTranslations: true,
      child: const App(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    Future.microtask(() => _initializeInBackground());
  });
}

Future<void> _initializeInBackground() async {
  try {
    AppLogger.info('Background initialization started');

    ApiConfigService.configureBaseUrl();
    AppLogger.debug('API base URL configured');

    final nonCriticalFutures = _initializeNonCriticalServices();

    AppLogger.debug('Initializing AuthService...');
    await AuthService.instance.init();
    AppLogger.success('AuthService initialized');

    AppLogger.debug('Initializing ServiceLocator...');
    await ServiceLocator.init();
    AppLogger.success('ServiceLocator initialized');

    await nonCriticalFutures;
    AppLogger.success('Background initialization completed');
  } catch (e, stackTrace) {
    AppLogger.error(
      'Background initialization failed',
      e,
      stackTrace,
    );
    ServiceLocatorStateController.instance.setError(e);
  }
}

Future<void> _initializeNonCriticalServices() async {
  await Future.wait([
    RootService().init().catchError((e) {
      AppLogger.warning('RootService init error', e);
    }),
    ThemeController.instance.init().catchError((e) {
      AppLogger.warning('ThemeController init error', e);
    }),
    initializeDateFormatting().catchError((e) {
      AppLogger.warning('Date formatting init error', e);
    }),
  ]);
  AppLogger.debug('Non-critical services initialized');
}


