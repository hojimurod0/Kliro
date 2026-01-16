import 'dart:async';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/app_locale_config.dart';
import 'core/config/sentry_config.dart';
import 'core/init/app_initializer.dart';
import 'core/services/locale/locale_service.dart';
import 'core/widgets/error_fallback_app.dart';

Future<void> main() async {
  final stopwatch = Stopwatch()..start();

  await SentryConfig.initialize(() => _runApp(stopwatch));
}

Future<void> _runApp(Stopwatch stopwatch) async {
  await AppInitializer.initialize(stopwatch);

  try {
    final startLocale = await LocaleService.getStartLocale();

    runApp(
      AppLocaleConfig.createLocalizedApp(
        startLocale: startLocale,
        child: const App(),
      ),
    );
  } catch (e) {
    // If initialization fails, show error fallback app
    runApp(ErrorFallbackApp(error: e));
  } 
}
   