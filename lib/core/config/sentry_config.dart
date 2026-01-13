import 'dart:async';
import 'package:flutter/foundation.dart';
import '../utils/sentry_stub.dart'
    if (dart.library.io) 'package:sentry_flutter/sentry_flutter.dart' as sentry;

/// Sentry configuration and initialization
class SentryConfig {
  SentryConfig._();

  /// Initialize Sentry in release mode
  /// Returns true if initialization was successful
  static Future<bool> initialize(Future<void> Function() appRunner) async {
    if (!kReleaseMode) {
      await appRunner();
      return false;
    }

    try {
      await sentry.SentryFlutter.init(
        (options) {
          options.tracesSampleRate = 0.2;
          options.environment = kReleaseMode ? 'production' : 'development';
          options.beforeSend = (event, hint) {
            return _filterSensitiveData(event, hint);
          };
        },
        appRunner: appRunner,
      );
      return true;
    } catch (e) {
      debugPrint('⚠️ Sentry initialization failed: $e');
      await appRunner();
      return false;
    }
  }

  /// Filter sensitive data from Sentry events
  static dynamic _filterSensitiveData(dynamic event, dynamic hint) {
    if (event?.request?.data != null) {
      final data = Map<String, dynamic>.from(event.request?.data as Map);
      // Remove sensitive data
      data.removeWhere(
        (key, value) =>
            key.toLowerCase().contains('password') ||
            key.toLowerCase().contains('token') ||
            key.toLowerCase().contains('pin'),
      );
      event = event.copyWith(
        request: event.request?.copyWith(data: data),
      );
    }
    return event;
  }
}
