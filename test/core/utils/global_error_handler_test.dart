import 'package:flutter_test/flutter_test.dart';
import 'package:klero/core/errors/app_exception.dart';
import 'package:klero/core/utils/global_error_handler.dart';

void main() {
  group('GlobalErrorHandler', () {
    test('should return user-friendly message for NetworkException', () {
      const error = NetworkException(message: 'Connection failed');
      final message = GlobalErrorHandler.getUserFriendlyMessage(error);
      expect(message, isNotEmpty);
    });

    test('should return user-friendly message for ServerException', () {
      final error = ServerException(
        message: 'Server error',
        statusCode: 500,
      );
      final message = GlobalErrorHandler.getUserFriendlyMessage(error);
      expect(message, isNotEmpty);
    });

    test('should return user-friendly message for ValidationException', () {
      const error = ValidationException('Invalid input');
      final message = GlobalErrorHandler.getUserFriendlyMessage(error);
      expect(message, equals('Invalid input'));
    });

    test('should return default message for unknown error', () {
      final error = Exception('Unknown error');
      final message = GlobalErrorHandler.getUserFriendlyMessage(error);
      expect(message, isNotEmpty);
    });
  });
}

