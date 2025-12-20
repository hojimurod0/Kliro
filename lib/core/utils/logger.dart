import 'package:flutter/foundation.dart';

// Conditional import for Sentry
import 'sentry_stub.dart' as stub;
import 'sentry_stub.dart'
    if (dart.library.io) 'package:sentry_flutter/sentry_flutter.dart' as sentry;

/// Production-ready logger class
/// Debug mode da debugPrint ishlatadi, release mode da logging service ga yuboradi
class AppLogger {
  AppLogger._();

  /// Debug level logging - faqat debug mode da ko'rsatiladi
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      if (error != null) {
        debugPrint('🔵 DEBUG: $message');
        debugPrint('Error: $error');
        if (stackTrace != null) {
          debugPrint('Stack trace: $stackTrace');
        }
      } else {
        debugPrint('🔵 DEBUG: $message');
      }
    }
  }

  /// Info level logging
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('ℹ️ INFO: $message');
    }
    // Production da analytics service ga yuborish mumkin
  }

  /// Warning level logging
  static void warning(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('⚠️ WARNING: $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
    }
    // Production da warning tracking service ga yuborish mumkin
  }

  /// Error level logging
  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      debugPrint('❌ ERROR: $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
    // Production da error tracking service (Sentry/Crashlytics) ga yuborish
    if (kReleaseMode && error != null) {
      try {
        // Use conditional import - try sentry, fallback to stub
        try {
          // Try sentry (will use stub if not available)
          sentry.Sentry.captureException(
            error,
            stackTrace: stackTrace,
            hint: sentry.Hint.withMap({'message': message}),
          );
        } catch (e) {
          // If sentry fails, use stub directly
          if (kDebugMode) {
            debugPrint('⚠️ Sentry capture failed, using stub: $e');
          }
          stub.Sentry.captureException(
            error,
            stackTrace: stackTrace,
            hint: stub.Hint.withMap({'message': message}),
          );
        }
      } catch (e) {
        // Sentry xatolik bo'lsa ham, ilova ishlashini davom ettirish
        if (kDebugMode) {
          debugPrint('⚠️ Sentry error: $e');
        }
      }
    }
  }

  /// Success level logging
  static void success(String message) {
    if (kDebugMode) {
      debugPrint('✅ SUCCESS: $message');
    }
  }

  /// Network request logging
  static void network(String method, String path, [Map<String, dynamic>? data]) {
    if (kDebugMode) {
      debugPrint('🌐 NETWORK: $method $path');
      if (data != null) {
        debugPrint('Data: $data');
      }
    }
  }

  /// Network response logging
  static void networkResponse(int statusCode, String path, [dynamic data]) {
    if (kDebugMode) {
      if (statusCode >= 200 && statusCode < 300) {
        debugPrint('✅ RESPONSE[$statusCode]: $path');
      } else {
        debugPrint('❌ RESPONSE[$statusCode]: $path');
      }
      if (data != null) {
        debugPrint('Response: $data');
      }
    }
  }

  /// Sensitive ma'lumotlarni yashirish
  static String sanitize(String? data) {
    if (data == null || data.isEmpty) {
      return 'N/A';
    }
    // Telefon raqamlari, email, tokenlar va boshqalarni yashirish
    return data
        .replaceAll(RegExp(r'\b\d{4,}\b'), '****') // Uzun raqamlarni yashirish
        .replaceAll(RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), '***@***.***') // Email
        .replaceAll(RegExp(r'Bearer\s+\S+'), 'Bearer ***'); // Tokenlar
  }
}

