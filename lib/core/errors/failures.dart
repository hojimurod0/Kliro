import 'package:equatable/equatable.dart';

/// Базовый класс для ошибок домена
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() => message;
}

/// Ошибка сервера
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

/// Ошибка сети
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Ошибка парсинга
class ParsingFailure extends Failure {
  const ParsingFailure(super.message);
}

/// Ошибка валидации
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Ошибка кэша
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

