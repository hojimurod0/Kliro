import 'package:equatable/equatable.dart';

/// Base exception for all API/infrastructure errors.
class AppException extends Equatable implements Exception {
  const AppException({
    required this.message,
    this.statusCode,
    this.details,
  });

  final String message;
  final int? statusCode;
  final Object? details;

  @override
  List<Object?> get props => [message, statusCode, details];

  @override
  String toString() => 'AppException($statusCode): $message';
}

class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.statusCode,
    super.details,
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    required super.message,
    super.statusCode,
    super.details,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.statusCode,
    super.details,
  });
}

class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.details,
  });
}

class ApiException extends AppException {
  const ApiException({
    required super.message,
    super.statusCode,
    super.details,
  });
}

