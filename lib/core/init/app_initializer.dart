import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import '../dio/singletons/service_locator.dart';
import '../dio/singletons/service_locator_state.dart';
import '../services/auth/auth_service.dart';
import '../services/config/api_config_service.dart';
import '../services/locale/root_service.dart';
import '../services/theme/theme_controller.dart';
import '../utils/logger.dart';
import '../utils/global_error_handler.dart';

class AppInitializer {
  static Future<void> initialize(Stopwatch stopwatch) async {
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

    await _initEasyLocalization(stopwatch);
    
    // Initialize critical services BEFORE runApp() to ensure they're ready on first run
    await _initializeCriticalServices(stopwatch);
    
    // Non-critical services can initialize in background after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
       Future.microtask(() => _initializeNonCriticalServicesInBackground(stopwatch));
    });
  }

  static Future<void> _initEasyLocalization(Stopwatch stopwatch) async {
    final start = stopwatch.elapsedMilliseconds;
    try {
      await EasyLocalization.ensureInitialized().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          if (kDebugMode) {
            AppLogger.warning('EasyLocalization init timeout -> skipping');
          }
        },
      );
      _logIfDebug(
        'EasyLocalization initialized',
        stopwatch.elapsedMilliseconds - start,
        isSuccess: true,
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.warning('EasyLocalization init error: $e');
      }
    }
  }

  /// Initialize critical services BEFORE runApp() - ensures they're ready on first run
  static Future<void> _initializeCriticalServices(Stopwatch stopwatch) async {
    try {
      final criticalInitStart = stopwatch.elapsedMilliseconds;
      AppLogger.info('Critical services initialization started');

      ApiConfigService.configureBaseUrl();

      final sharedPrefsStart = stopwatch.elapsedMilliseconds;
      final sharedPreferences = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('SharedPreferences init timeout');
        },
      );
      
      _logIfDebug(
        'SharedPreferences loaded',
        stopwatch.elapsedMilliseconds - sharedPrefsStart,
      );

      // Initialize AuthService and ServiceLocator synchronously
      await _initAuthAndServiceLocator(sharedPreferences, stopwatch);

      // Initialize ThemeController BEFORE runApp() to ensure theme is ready on first run
      final themeStart = stopwatch.elapsedMilliseconds;
      await ThemeController.instance.init().catchError((e) {
        AppLogger.warning('ThemeController init error: $e');
        return null;
      });
      _logIfDebug(
        'ThemeController initialized',
        stopwatch.elapsedMilliseconds - themeStart,
        isSuccess: true,
      );

      final totalTime = stopwatch.elapsedMilliseconds - criticalInitStart;
      AppLogger.success('✅ Critical services initialized in ${totalTime}ms');
    } catch (e, stackTrace) {
      AppLogger.error('Critical services initialization failed', e, stackTrace);
      ServiceLocatorStateController.instance.setError(e);
      // Don't rethrow - let app continue with error state
    }
  }

  /// Initialize non-critical services in background after first frame
  static Future<void> _initializeNonCriticalServicesInBackground(Stopwatch stopwatch) async {
    try {
      AppLogger.info('Non-critical services background initialization started');
      await _initializeNonCriticalServices(stopwatch);
      AppLogger.success('✅ Non-critical services initialized');
    } catch (e, stackTrace) {
      AppLogger.error('Non-critical services initialization failed', e, stackTrace);
      // Non-critical, so we don't set error state
    }
  }

  static Future<void> _initAuthAndServiceLocator(
      SharedPreferences prefs, Stopwatch stopwatch) async {
    
    // Auth Service
    final authStart = stopwatch.elapsedMilliseconds;
    await AuthService.instance.initWithPrefs(prefs);
    _logIfDebug(
      'AuthService initialized', 
      stopwatch.elapsedMilliseconds - authStart, 
      isSuccess: true
    );
    
    // Service Locator (depends on Auth)
    final slStart = stopwatch.elapsedMilliseconds;
    try {
      await ServiceLocator.initWithPrefs(prefs);
       _logIfDebug(
        'ServiceLocator initialized', 
        stopwatch.elapsedMilliseconds - slStart, 
        isSuccess: true
      );
    } catch (e) {
       AppLogger.error('ServiceLocator init error', e);
       ServiceLocatorStateController.instance.setError(e);
    }
  }

  static Future<void> _initializeNonCriticalServices(Stopwatch stopwatch) async {
      await Future.wait([
        RootService().init().catchError((e) => null),
        // ThemeController is now initialized in critical services
        initializeDateFormatting().catchError((e) => null),
      ]);
      
      if (kDebugMode) {
        AppLogger.debug('Non-critical services initialized');
      }
  }

  static void _logIfDebug(String message, int time, {bool isSuccess = false}) {
    if (!kDebugMode) return;
    if (isSuccess) {
      AppLogger.success('$message: ${time}ms');
    } else {
      AppLogger.debug('$message: ${time}ms');
    }
  }
}
