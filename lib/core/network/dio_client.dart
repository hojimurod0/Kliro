import 'package:dio/dio.dart';
import '../constants/config.dart';
import '../errors/exceptions.dart';
import 'dio_logging_interceptor.dart';

/// Клиент для HTTP запросов
class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: Duration(seconds: AppConfig.connectionTimeout),
        receiveTimeout: Duration(seconds: AppConfig.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Добавляем логирование если включено
    if (AppConfig.enableLogging) {
      _dio.interceptors.add(DioLoggingInterceptor());
    }

    // Обработка ошибок
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: const NetworkException(message: 'Таймаут подключения'),
              ),
            );
          }

          if (error.type == DioExceptionType.connectionError) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: const NetworkException(message: 'Нет подключения к интернету'),
              ),
            );
          }

          if (error.response != null) {
            final statusCode = error.response!.statusCode;
            final message = error.response!.data?['message'] ?? 
                          error.response!.data?['error'] ?? 
                          'Ошибка сервера';
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: ServerException(message: message, statusCode: statusCode),
                response: error.response,
              ),
            );
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// GET запрос
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST запрос
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT запрос
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE запрос
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    if (error.error is AppException) {
      return error.error as AppException;
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const NetworkException(message: 'Таймаут подключения');
    }

    if (error.type == DioExceptionType.connectionError) {
      return const NetworkException(message: 'Нет подключения к интернету');
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message = error.response!.data?['message'] ?? 
                     error.response!.data?['error'] ?? 
                     'Ошибка сервера';
      return ServerException(message: message, statusCode: statusCode);
    }

    return NetworkException(message: error.message ?? 'Неизвестная ошибка сети');
  }
}

