import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/logger.dart';
import '../errors/app_exception.dart';
import 'snackbar_helper.dart';

// Conditional import for Sentry
import 'sentry_stub.dart'
    if (dart.library.io) 'package:sentry_flutter/sentry_flutter.dart' as sentry;

/// Global error handler for Flutter application
/// Handles all uncaught errors and exceptions
class GlobalErrorHandler {
  GlobalErrorHandler._();

  /// Initialize global error handlers
  static void initialize() {
    // Flutter framework errors (UI errors)
    FlutterError.onError = (FlutterErrorDetails details) {
      // In debug/profile we keep Flutter's default error presentation
      // (red error screen / console output) for fast development feedback.
      // In release we avoid presenting framework errors to the UI layer
      // and rely on logging + Sentry reporting instead.
      if (!kReleaseMode) {
        try {
          FlutterError.presentError(details);
        } catch (e) {
          // Agar presentError xatolik bersa, faqat log qilamiz
          debugPrint('⚠️ Error presenting Flutter error: $e');
        }
      }

      // Log error
      try {
        AppLogger.error(
          'Flutter Error: ${details.exception}${details.library != null ? ' (${details.library})' : ''}',
          details.exception,
          details.stack,
        );
      } catch (e) {
        // Agar logger xatolik bersa, faqat debugPrint ishlatamiz
        debugPrint('⚠️ Error logging Flutter error: $e');
        debugPrint('Original error: ${details.exception}');
        debugPrint('Stack trace: ${details.stack}');
      }

      // Send to Sentry in production
      if (kReleaseMode) {
        try {
          sentry.Sentry.captureException(
            details.exception,
            stackTrace: details.stack,
            hint: sentry.Hint.withMap({
              'library': details.library,
              'context': details.context?.toString(),
            }),
          );
        } catch (e) {
          // Sentry not available or error
          if (kDebugMode) {
            debugPrint('⚠️ Sentry error: $e');
          }
        }
      }
    };

    // Dart isolate errors (async errors)
    PlatformDispatcher.instance.onError = (error, stack) {
      // Log error
      try {
        AppLogger.error(
          'Dart Error: $error',
          error,
          stack,
        );
      } catch (e) {
        // Agar logger xatolik bersa, faqat debugPrint ishlatamiz
        debugPrint('⚠️ Error logging Dart error: $e');
        debugPrint('Original error: $error');
        debugPrint('Stack trace: $stack');
      }

      // Send to Sentry in production
      if (kReleaseMode) {
        try {
          sentry.Sentry.captureException(
            error,
            stackTrace: stack,
          );
        } catch (e) {
          // Sentry not available or error
          if (kDebugMode) {
            debugPrint('⚠️ Sentry error: $e');
          }
        }
      }

      // Return true to indicate error was handled
      return true;
    };
  }

  /// Handle AppException and show user-friendly message
  static String getUserFriendlyMessage(dynamic error) {
    if (error is AppException) {
      return _getAppExceptionMessage(error);
    }

    if (error is NetworkException) {
      return 'common.errors.network_error'.tr();
    }

    if (error is UnauthorizedException) {
      return 'common.errors.unauthorized'.tr();
    }

    if (error is ServerException) {
      return 'common.errors.server_error'.tr();
    }

    if (error is ValidationException) {
      return error.message;
    }

    // Default error message
    return 'common.errors.unknown_error'.tr();
  }

  /// Get user-friendly message for AppException
  static String _getAppExceptionMessage(AppException error) {
    return switch (error) {
      NetworkException _ => 'common.errors.network_error'.tr(),
      UnauthorizedException _ => 'common.errors.unauthorized'.tr(),
      ServerException _ => 'common.errors.server_error'.tr(),
      ValidationException _ => error.message,
      ApiException _ => error.message,
      ParsingException _ => 'common.errors.parsing_error'.tr(),
      _ => error.message,
    };
  }

  /// Show error dialog to user
  static void showErrorDialog(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    // Context mounted ekanligini tekshiramiz
    if (!context.mounted) {
      debugPrint('⚠️ Cannot show error dialog: context is not mounted');
      return;
    }

    try {
      final message = getUserFriendlyMessage(error);

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: Text('common.errors.error_title'.tr()),
          content: Text(message),
          actions: [
            if (onDismiss != null)
              TextButton(
                onPressed: () {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    onDismiss();
                  }
                },
                child: Text('common.dismiss'.tr()),
              ),
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    onRetry();
                  }
                },
                child: Text('common.retry'.tr()),
              ),
            TextButton(
              onPressed: () {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text('common.close'.tr()),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('⚠️ Error showing error dialog: $e');
    }
  }

  /// Show error snackbar (tepadan chiqadigan)
  static void showErrorSnackBar(
    BuildContext context,
    dynamic error, {
    Duration duration = const Duration(seconds: 4),
  }) {
    // Context mounted ekanligini tekshiramiz
    if (!context.mounted) {
      debugPrint('⚠️ Cannot show error snackbar: context is not mounted');
      return;
    }

    try {
      final message = getUserFriendlyMessage(error);
      // Use SnackbarHelper for consistent top-positioned snackbars with translations
      SnackbarHelper.showError(context, message, duration: duration);
    } catch (e) {
      debugPrint('⚠️ Error showing error snackbar: $e');
    }
  }
}
