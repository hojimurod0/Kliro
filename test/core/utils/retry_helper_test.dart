import 'package:flutter_test/flutter_test.dart';
import 'package:klero/core/errors/app_exception.dart';
import 'package:klero/core/utils/retry_helper.dart';

void main() {
  group('RetryHelper', () {
    test('should succeed on first attempt', () async {
      int attempts = 0;
      final result = await RetryHelper.retry(
        operation: () async {
          attempts++;
          return 'success';
        },
        maxRetries: 3,
      );
      expect(result, equals('success'));
      expect(attempts, equals(1));
    });

    test('should retry on failure and succeed', () async {
      int attempts = 0;
      final result = await RetryHelper.retry(
        operation: () async {
          attempts++;
          if (attempts < 2) {
            throw const NetworkException(message: 'Network error');
          }
          return 'success';
        },
        maxRetries: 3,
      );
      expect(result, equals('success'));
      expect(attempts, equals(2));
    });

    test('should throw after max retries', () async {
      int attempts = 0;
      await expectLater(
        RetryHelper.retry(
          operation: () async {
            attempts++;
            throw const NetworkException(message: 'Network error');
          },
          maxRetries: 3,
        ),
        throwsA(isA<NetworkException>()),
      );
      expect(attempts, equals(3));
    });

    test('should not retry non-retryable errors', () async {
      int attempts = 0;
      await expectLater(
        RetryHelper.retry(
          operation: () async {
            attempts++;
            throw const ValidationException('Invalid input');
          },
          maxRetries: 3,
        ),
        throwsA(isA<ValidationException>()),
      );
      expect(attempts, equals(1));
    });
  });
}

