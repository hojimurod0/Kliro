/// Базовый класс для исключений приложения
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Исключение сервера (ошибки HTTP)
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

/// Исключение сети (нет подключения, таймаут)
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Исключение парсинга (неверный формат JSON)
class ParsingException extends AppException {
  const ParsingException(super.message);
}

/// Исключение валидации
class ValidationException extends AppException {
  const ValidationException(super.message);
}

