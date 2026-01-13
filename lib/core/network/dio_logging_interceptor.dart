import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Интерцептор для логирования HTTP запросов
class DioLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('┌─────────────────────────────────────────────────────────────');
    debugPrint('│ REQUEST: ${options.method} ${options.uri}');
    debugPrint('│ Headers: ${options.headers}');
    if (options.data != null) {
      debugPrint('│ Body: ${options.data}');
    }
    debugPrint('└─────────────────────────────────────────────────────────────');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('┌─────────────────────────────────────────────────────────────');
    debugPrint('│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    debugPrint('│ Data: ${response.data}');
    debugPrint('└─────────────────────────────────────────────────────────────');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('┌─────────────────────────────────────────────────────────────');
    debugPrint('│ ERROR: ${err.requestOptions.method} ${err.requestOptions.uri}');
    debugPrint('│ Status: ${err.response?.statusCode}');
    debugPrint('│ Message: ${err.message}');
    if (err.response?.data != null) {
      debugPrint('│ Data: ${err.response?.data}');
    }
    debugPrint('└─────────────────────────────────────────────────────────────');
    super.onError(err, handler);
  }
}

