import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'app.dart';
import 'core/init/app_initializer.dart';
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
            // Sensitive data filtering
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
      debugPrint('⚠️ Sentry initialization failed: $e');
      await _runApp(stopwatch);
    }
  } else {
    await _runApp(stopwatch);
  }
}
    
Future<void> _runApp(Stopwatch stopwatch) async {
  await AppInitializer.initialize(stopwatch);

  try {
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
  } catch (e) {
    // If EasyLocalization fails (e.g. Channel Error), run a fallback app
    // so the user sees an error instead of a white screen freeze.
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Critical Initialization Error',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to initialize app settings: $e\n\nPlease try reinstalling the app.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 
  