import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final stopwatch = Stopwatch()..start();

  if (kReleaseMode) {
    try {
      await sentry.SentryFlutter.init((options) {
        options.tracesSampleRate = 0.2;
        options.environment = kReleaseMode ? 'production' : 'development';
        options.beforeSend = (event, hint) {
          if (event.request?.data != null) {
            final data = Map<String, dynamic>.from(event.request!.data as Map);
            data.removeWhere(
              (key, value) =>
                  key.toLowerCase().contains('password') ||
                  key.toLowerCase().contains('token') ||
                  key.toLowerCase().contains('pin'),
            );
            event.request = event.request!.copyWith(data: data);
          }
          return event;
        };
      }, appRunner: () => _runApp(stopwatch));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Sentry initialization failed: $e');
      }
      await _runApp(stopwatch);
    }
  } else {
    await _runApp(stopwatch);
  }
}

Future<void> _runApp(Stopwatch stopwatch) async {
  final initStartTime = stopwatch.elapsedMilliseconds;

  WidgetsFlutterBinding.ensureInitialized();
  _logIfDebug(
    'WidgetsBinding initialized',
    stopwatch.elapsedMilliseconds - initStartTime,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  GlobalErrorHandler.initialize();

  // EasyLocalization ni avval initialize qilish
  // Bu blocking bo'lishi mumkin, lekin zarur
  // Timeout qo'shish - cheksiz kutishni oldini olish uchun
  final easyLocalizationStart = stopwatch.elapsedMilliseconds;
  try {
    await EasyLocalization.ensureInitialized().timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        if (kDebugMode) {
          AppLogger.warning(
            'EasyLocalization initialization timeout - continuing anyway',
          );
        }
      },
    );
    _logIfDebug(
      'EasyLocalization initialized',
      stopwatch.elapsedMilliseconds - easyLocalizationStart,
      isSuccess: true,
    );
  } catch (e) {
    // EasyLocalization xatolik bo'lsa ham app ishlashini davom ettirish
    if (kDebugMode) {
      AppLogger.warning('EasyLocalization init error: $e - continuing anyway');
    }
  }

  // App ni darhol ishga tushirish - ServiceLocator background'da init bo'ladi
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

  if (kDebugMode) {
    AppLogger.info('🚀 App started in ${stopwatch.elapsedMilliseconds}ms');
  }

  // Background initialization ni keyinroq boshlash
  // Bir necha frame kutish - UI to'liq render bo'lguncha
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Future.delayed(const Duration(milliseconds: 100), () {
      _initializeInBackground(stopwatch);
    });
  });
}

/// UI thread'ni bloklamaslik uchun event loop'ga bir marta "yield" qilish.
/// Bu especially debug'da "Skipped frames" va `onPreDraw` spamini kamaytirishga yordam beradi.
Future<void> _yieldToUi() async {
  // SchedulerBinding orqali schedule qilish - frame'larni ko'proq o‘tkazib yubormaslik uchun
  await SchedulerBinding.instance.endOfFrame;
}

Future<void> _initializeInBackground(Stopwatch stopwatch) async {
  try {
    final bgInitStart = stopwatch.elapsedMilliseconds;
    AppLogger.info('Background initialization started');

    // API config ni avval sozlash (synchronous, tez)
    ApiConfigService.configureBaseUrl();
    _logIfDebug(
      'API base URL configured',
      stopwatch.elapsedMilliseconds - bgInitStart,
    );
    await _yieldToUi();

    // SharedPreferences ni bir marta olish va ikkala service'ga pass qilish
    // Bu muhim optimizatsiya - SharedPreferences.getInstance() sekin ishlaydi
    final sharedPrefsStart = stopwatch.elapsedMilliseconds;
    // Timeout qo'shish - cheksiz kutishni oldini olish uchun
    final sharedPreferences = await SharedPreferences.getInstance().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        AppLogger.warning('SharedPreferences initialization timeout');
        throw TimeoutException('SharedPreferences initialization timeout');
      },
    );
    _logIfDebug(
      'SharedPreferences loaded',
      stopwatch.elapsedMilliseconds - sharedPrefsStart,
    );
    await _yieldToUi();

    // Non-critical servicelarni parallel ishga tushirish
    final nonCriticalStart = stopwatch.elapsedMilliseconds;
    final nonCriticalFutures = _initializeNonCriticalServices();

    // Critical servicelarni optimizatsiya qilingan tartibda ishga tushirish
    // AuthService va ServiceLocator ketma-ket, chunki ServiceLocator AuthService'ga depend qiladi
    // Lekin ularni tezroq ishga tushirish uchun minimal kutish
    final authServiceStart = stopwatch.elapsedMilliseconds;
    AppLogger.debug('Initializing AuthService...');
    await AuthService.instance.initWithPrefs(sharedPreferences);
    _logIfDebug(
      'AuthService initialized',
      stopwatch.elapsedMilliseconds - authServiceStart,
      isSuccess: true,
    );
    await _yieldToUi();

    // ServiceLocator ni darhol ishga tushirish - AuthService tayyor bo'lgach
    final serviceLocatorStart = stopwatch.elapsedMilliseconds;
    AppLogger.debug('Initializing ServiceLocator...');

    // ServiceLocator'ni parallel ishga tushirish - non-critical servicelar bilan birga
    final serviceLocatorFuture =
        ServiceLocator.initWithPrefs(sharedPreferences).catchError((e) {
      AppLogger.error('ServiceLocator init error', e);
      // Xatolik bo'lsa ham app ishlashini davom ettirish
      ServiceLocatorStateController.instance.setError(e);
    });

    // ServiceLocator va non-critical servicelarni birga kutish
    await Future.wait([
      serviceLocatorFuture,
      nonCriticalFutures,
    ], eagerError: false);
    await _yieldToUi();

    _logIfDebug(
      'ServiceLocator initialized',
      stopwatch.elapsedMilliseconds - serviceLocatorStart,
      isSuccess: true,
    );
    _logIfDebug(
      'Non-critical services initialized',
      stopwatch.elapsedMilliseconds - nonCriticalStart,
    );

    final totalTime = stopwatch.elapsedMilliseconds - bgInitStart;
    AppLogger.success(
      '✅ Background initialization completed in ${totalTime}ms',
    );

    if (kDebugMode && totalTime > 3000) {
      AppLogger.warning(
        '⚠️ Background initialization took ${totalTime}ms - consider optimization',
      );
    }
  } catch (e, stackTrace) {
    AppLogger.error('Background initialization failed', e, stackTrace);
    ServiceLocatorStateController.instance.setError(e);
  }
}

Future<void> _initializeNonCriticalServices() async {
  // Bu servicelar parallel ishlaydi va xatolik bo'lsa ham app ishlashini davom ettirishi kerak
  // eagerError: false - bitta xatolik boshqalarini to'xtatmaydi
  // Parallel ham mumkin, lekin debug'da jank ko'p bo'lsa,
  // event loop'ga yield qilib ketma-ketroq bajarish UI'ni silliq qiladi.
  await RootService().init().catchError((e) {
    AppLogger.warning('RootService init error', e);
    return null;
  });
  await _yieldToUi();

  await ThemeController.instance.init().catchError((e) {
    AppLogger.warning('ThemeController init error', e);
    return null;
  });
  await _yieldToUi();

  await initializeDateFormatting().catchError((e) {
    AppLogger.warning('Date formatting init error', e);
    return null;
  });

  if (kDebugMode) {
    AppLogger.debug('Non-critical services initialized');
  }
}

/// Debug mode'da log qilish uchun helper metod
void _logIfDebug(String message, int time, {bool isSuccess = false}) {
  if (!kDebugMode) return;

  // scheduleMicrotask bu yerda foyda bermaydi, aksincha start paytida microtask queue'ni
  // ko'paytirib debug'da "qotib qolish" (jank)ga sabab bo'lishi mumkin.
  if (isSuccess) {
    AppLogger.success('$message: ${time}ms');
  } else {
    AppLogger.debug('$message: ${time}ms');
  }
}
