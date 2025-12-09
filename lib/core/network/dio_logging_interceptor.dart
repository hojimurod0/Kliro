import 'package:dio/dio.dart';

/// Интерцептор для логирования HTTP запросов
class DioLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('┌─────────────────────────────────────────────────────────────');
    print('│ REQUEST: ${options.method} ${options.uri}');
    print('│ Headers: ${options.headers}');
    if (options.data != null) {
      print('│ Body: ${options.data}');
    }
    print('└─────────────────────────────────────────────────────────────');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('┌─────────────────────────────────────────────────────────────');
    print('│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    print('│ Data: ${response.data}');
    print('└─────────────────────────────────────────────────────────────');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('┌─────────────────────────────────────────────────────────────');
    print('│ ERROR: ${err.requestOptions.method} ${err.requestOptions.uri}');
    print('│ Status: ${err.response?.statusCode}');
    print('│ Message: ${err.message}');
    if (err.response?.data != null) {
      print('│ Data: ${err.response?.data}');
    }
    print('└─────────────────────────────────────────────────────────────');
    super.onError(err, handler);
  }
}

