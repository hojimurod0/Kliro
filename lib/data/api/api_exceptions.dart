import 'dart:io';

import 'package:dio/dio.dart';

class ApiException extends DioException {
  ApiException({
    required super.requestOptions,
    super.response,
    super.type,
    super.error,
    super.message,
  });

  factory ApiException.fromDioError(DioException error) {
    if (error.type == DioExceptionType.unknown &&
        error.error is SocketException) {
      return ApiException(
        requestOptions: error.requestOptions,
        type: DioExceptionType.unknown,
        message: 'Нет подключения к сети',
      );
    }

    return ApiException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: error.error,
      message: error.message ?? 'Неизвестная ошибка запроса',
    );
  }
}
