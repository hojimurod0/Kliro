import 'package:easy_localization/easy_localization.dart';
import '../errors/exceptions.dart';

/// Error message helper - foydalanuvchiga tushunarli xabarlar beradi
class ErrorMessageHelper {
  ErrorMessageHelper._();

  /// Exception dan foydalanuvchiga tushunarli xabar olish
  static String getMessage(AppException exception) {
    if (exception is NetworkException) {
      return _getNetworkErrorMessage(exception);
    } else if (exception is ServerException) {
      return _getServerErrorMessage(exception);
    } else if (exception is ValidationException) {
      return _getValidationErrorMessage(exception);
    } else if (exception is ParsingException) {
      return _getParsingErrorMessage(exception);
    } else {
      return _getGenericErrorMessage(exception);
    }
  }

  /// Network xatoliklari uchun xabar
  static String _getNetworkErrorMessage(NetworkException exception) {
    final message = exception.message.toLowerCase();
    
    if (message.contains('vaqti tugadi') || message.contains('timeout')) {
      return 'error.network_timeout'.tr();
    } else if (message.contains('aloqasi yo\'q') || message.contains('connection')) {
      return 'error.no_internet'.tr();
    } else {
      return 'error.connection_problem'.tr();
    }
  }

  /// Server xatoliklari uchun xabar
  static String _getServerErrorMessage(ServerException exception) {
    final statusCode = exception.statusCode;
    final message = exception.message;

    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return 'error.bad_request'.tr();
        case 401:
          return 'error.unauthorized'.tr();
        case 403:
          return 'error.forbidden'.tr();
        case 404:
          return 'error.not_found'.tr();
        case 500:
        case 502:
        case 503:
          return 'error.server_error'.tr();
        case 410:
          // Backend sometimes uses 410 for "request is processing"
          if (message.toLowerCase().contains('обрабатывается') ||
              message.toLowerCase().contains('processing') ||
              message.toLowerCase().contains('in progress')) {
            return 'error.processing'.tr();
          }
          return message.isNotEmpty ? _localizeMessage(message) : 'error.server_error_generic'.tr();
        default:
          return message.isNotEmpty ? _localizeMessage(message) : 'error.server_error_generic'.tr();
      }
    }

    return message.isNotEmpty ? _localizeMessage(message) : 'error.server_error_generic'.tr();
  }

  /// Validation xatoliklari uchun xabar
  static String _getValidationErrorMessage(ValidationException exception) {
    final message = exception.message;
    
    // O'zbek tilidagi xabarlarni to'g'ridan-to'g'ri qaytarish
    if (message.isNotEmpty) {
      return _localizeMessage(message);
    }
    
    return 'error.validation'.tr();
  }

  /// Parsing xatoliklari uchun xabar
  static String _getParsingErrorMessage(ParsingException exception) {
    return 'error.parsing'.tr();
  }

  /// Umumiy xatolik xabari
  static String _getGenericErrorMessage(AppException exception) {
    final message = exception.message;
    
    if (message.isNotEmpty) {
      return _localizeMessage(message);
    }
    
    return 'error.unknown'.tr();
  }

  /// Retry uchun tavsiya xabari
  static String getRetryMessage(AppException exception) {
    if (exception is NetworkException) {
      return 'error.retry_network'.tr();
    } else if (exception is ServerException) {
      final statusCode = exception.statusCode;
      if (statusCode != null && statusCode >= 500) {
        return 'error.retry_server'.tr();
      }
    }
    return 'error.retry_generic'.tr();
  }

  /// Xatolik turini aniqlash
  static bool isRetryable(AppException exception) {
    if (exception is NetworkException) {
      return true; // Network xatoliklari retry qilinishi mumkin
    } else if (exception is ServerException) {
      final statusCode = exception.statusCode;
      final message = exception.message.toLowerCase();

      // Backend sometimes returns 410 for "request is processing" (non-standard usage).
      // We treat it as retryable only for those specific "processing" messages.
      if (statusCode == 410 &&
          (message.contains('обрабатывается') ||
              message.contains('processing') ||
              message.contains('in progress'))) {
        return true;
      }
      // 5xx xatoliklar retry qilinishi mumkin
      return statusCode != null && statusCode >= 500 && statusCode < 600;
    }
    return false; // Boshqa xatoliklar retry qilinmaydi
  }

  /// Xabarni lokalizatsiya qilish va typo larni to'g'irlash
  static String _localizeMessage(String message) {
    // API dan kelishi mumkin bo'lgan typo ni to'g'irlash
    var normalizedMessage = message.replaceAll('hotel.coomon', 'hotel.common');

    // Agar bu kalit so'z bo'lsa tarjima qilish, matn bo'lsa o'zini qaytarish
    return normalizedMessage.tr();
  }
}

