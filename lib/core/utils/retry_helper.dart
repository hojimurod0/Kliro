import 'dart:async';
import '../errors/exceptions.dart';
import 'error_message_helper.dart';
import 'logger.dart';

/// Retry mexanizmi uchun helper class
class RetryHelper {
  RetryHelper._();

  /// Retry qilinadigan operatsiyani bajaradi
  /// 
  /// [operation] - bajariladigan operatsiya
  /// [maxRetries] - maksimal retry soni (default: 3)
  /// [delay] - har bir retry orasidagi kechikish (default: 1 soniya)
  /// [onRetry] - har bir retry da chaqiriladigan callback
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    void Function(int attempt)? onRetry,
  }) async {
    int attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        
        // Agar retry qilinmaydigan xatolik bo'lsa, darhol throw qilish
        if (e is AppException && !ErrorMessageHelper.isRetryable(e)) {
          AppLogger.error(
            'Non-retryable error occurred',
            e,
          );
          rethrow;
        }
        
        // Agar oxirgi urinish bo'lsa, xatolikni throw qilish
        if (attempt >= maxRetries) {
          AppLogger.error(
            'Max retries ($maxRetries) reached',
            e,
          );
          rethrow;
        }
        
        // Retry callback ni chaqirish
        if (onRetry != null) {
          onRetry(attempt);
        }
        
        AppLogger.warning(
          'Retry attempt $attempt/$maxRetries after ${delay.inSeconds}s',
          e,
        );
        
        // Kechikish
        await Future.delayed(delay * attempt); // Exponential backoff
      }
    }
    
    // Bu kodga hech qachon yetib kelmaydi, lekin compiler uchun kerak
    throw Exception('Unexpected error in retry helper');
  }

  /// Exponential backoff bilan retry
  /// Har bir retry da kechikish ikki baravar oshadi
  static Future<T> retryWithExponentialBackoff<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    void Function(int attempt)? onRetry,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;
    
    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        
        // Agar retry qilinmaydigan xatolik bo'lsa, darhol throw qilish
        if (e is AppException && !ErrorMessageHelper.isRetryable(e)) {
          AppLogger.error(
            'Non-retryable error occurred',
            e,
          );
          rethrow;
        }
        
        // Agar oxirgi urinish bo'lsa, xatolikni throw qilish
        if (attempt >= maxRetries) {
          AppLogger.error(
            'Max retries ($maxRetries) reached',
            e,
          );
          rethrow;
        }
        
        // Retry callback ni chaqirish
        if (onRetry != null) {
          onRetry(attempt);
        }
        
        AppLogger.warning(
          'Retry attempt $attempt/$maxRetries with ${delay.inSeconds}s delay',
          e,
        );
        
        // Exponential backoff
        await Future.delayed(delay);
        delay = Duration(seconds: delay.inSeconds * 2);
      }
    }
    
    throw Exception('Unexpected error in retry helper');
  }

  /// Timeout bilan retry
  static Future<T> retryWithTimeout<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    Duration timeout = const Duration(seconds: 30),
    void Function(int attempt)? onRetry,
  }) async {
    return retry(
      operation: () async {
        return await operation().timeout(
          timeout,
          onTimeout: () {
            throw const NetworkException(message: 'So\'rov vaqti tugadi');
          },
        );
      },
      maxRetries: maxRetries,
      delay: delay,
      onRetry: onRetry,
    );
  }
}

