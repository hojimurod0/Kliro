import 'package:dio/dio.dart';

import '../../core/constants/constants.dart';
import '../../core/dio/interceptor/language_interceptor.dart';
import 'api_exceptions.dart';

class ApiClient {
  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: _resolveBaseUrl(),
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
                contentType: Headers.jsonContentType,
                responseType: ResponseType.json,
              ),
            ) {
    _dio.interceptors.addAll([
      LanguageInterceptor(), // Добавляем язык в заголовки
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
      InterceptorsWrapper(
        onError: (error, handler) {
          handler.reject(ApiException.fromDioError(error));
        },
      ),
    ]);
  }

  final Dio _dio;

  static String _resolveBaseUrl() {
    const envBaseUrl = String.fromEnvironment('BANK_BASE_URL', defaultValue: '');
    if (envBaseUrl.isNotEmpty) {
      return envBaseUrl;
    }
    return ApiConstants.effectiveBaseUrl;
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get(
      path,
      queryParameters: _cleanQuery(queryParameters),
    );
  }

  Map<String, dynamic>? _cleanQuery(Map<String, dynamic>? query) {
    if (query == null) return null;
    final cleaned = Map<String, dynamic>.from(query)
      ..removeWhere(
        (key, value) => value == null || (value is String && value.isEmpty),
      );
    return cleaned.isEmpty ? null : cleaned;
  }
}

