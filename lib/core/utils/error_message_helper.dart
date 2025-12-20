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
      return 'So\'rov vaqti tugadi. Internet aloqasini tekshiring va qayta urinib ko\'ring.';
    } else if (message.contains('aloqasi yo\'q') || message.contains('connection')) {
      return 'Internet aloqasi yo\'q. Internet aloqasini tekshiring.';
    } else {
      return 'Internet aloqasi bilan muammo. Qayta urinib ko\'ring.';
    }
  }

  /// Server xatoliklari uchun xabar
  static String _getServerErrorMessage(ServerException exception) {
    final statusCode = exception.statusCode;
    final message = exception.message;

    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return 'Noto\'g\'ri so\'rov. Ma\'lumotlarni tekshiring.';
        case 401:
          return 'Kirish rad etildi. Iltimos, qayta kiring.';
        case 403:
          return 'Ruxsat berilmadi.';
        case 404:
          return 'Ma\'lumot topilmadi.';
        case 500:
        case 502:
        case 503:
          return 'Server bilan muammo. Iltimos, keyinroq urinib ko\'ring.';
        case 410:
          // Backend sometimes uses 410 for "request is processing"
          if (message.toLowerCase().contains('обрабатывается') ||
              message.toLowerCase().contains('processing') ||
              message.toLowerCase().contains('in progress')) {
            return 'So\'rov qayta ishlanmoqda. Iltimos, biroz kuting...';
          }
          return message.isNotEmpty ? message : 'Server xatosi yuz berdi.';
        default:
          return message.isNotEmpty ? message : 'Server xatosi yuz berdi.';
      }
    }

    return message.isNotEmpty ? message : 'Server xatosi yuz berdi.';
  }

  /// Validation xatoliklari uchun xabar
  static String _getValidationErrorMessage(ValidationException exception) {
    final message = exception.message;
    
    // O'zbek tilidagi xabarlarni to'g'ridan-to'g'ri qaytarish
    if (message.isNotEmpty) {
      return message;
    }
    
    return 'Ma\'lumotlar noto\'g\'ri. Iltimos, tekshiring.';
  }

  /// Parsing xatoliklari uchun xabar
  static String _getParsingErrorMessage(ParsingException exception) {
    return 'Ma\'lumotlarni qayta ishlashda xatolik yuz berdi. Qayta urinib ko\'ring.';
  }

  /// Umumiy xatolik xabari
  static String _getGenericErrorMessage(AppException exception) {
    final message = exception.message;
    
    if (message.isNotEmpty) {
      return message;
    }
    
    return 'Xatolik yuz berdi. Iltimos, qayta urinib ko\'ring.';
  }

  /// Retry uchun tavsiya xabari
  static String getRetryMessage(AppException exception) {
    if (exception is NetworkException) {
      return 'Internet aloqasini tekshiring va qayta urinib ko\'ring.';
    } else if (exception is ServerException) {
      final statusCode = exception.statusCode;
      if (statusCode != null && statusCode >= 500) {
        return 'Server bilan muammo. Bir necha soniyadan keyin qayta urinib ko\'ring.';
      }
    }
    return 'Qayta urinib ko\'ring.';
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
}
