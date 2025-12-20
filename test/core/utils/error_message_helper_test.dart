import 'package:flutter_test/flutter_test.dart';
import 'package:klero/core/errors/app_exception.dart';
import 'package:klero/core/utils/error_message_helper.dart';

void main() {
  group('ErrorMessageHelper', () {
    test('should return network error message for NetworkException', () {
      final exception = const NetworkException(
        message: 'Connection timeout',
      );
      final message = ErrorMessageHelper.getMessage(exception);
      expect(message, isNotEmpty);
      expect(message, contains('Internet'));
    });

    test('should return server error message for ServerException', () {
      final exception = ServerException(
        message: 'Server error',
        statusCode: 500,
      );
      final message = ErrorMessageHelper.getMessage(exception);
      expect(message, isNotEmpty);
    });

    test('should return validation error message for ValidationException', () {
      const exception = ValidationException('Invalid input');
      final message = ErrorMessageHelper.getMessage(exception);
      expect(message, equals('Invalid input'));
    });

    test('should identify retryable errors', () {
      final networkException = const NetworkException(
        message: 'Connection failed',
      );
      expect(ErrorMessageHelper.isRetryable(networkException), isTrue);

      final serverException = ServerException(
        message: 'Server error',
        statusCode: 500,
      );
      expect(ErrorMessageHelper.isRetryable(serverException), isTrue);

      final validationException = const ValidationException('Invalid input');
      expect(ErrorMessageHelper.isRetryable(validationException), isFalse);
    });
  });
}

