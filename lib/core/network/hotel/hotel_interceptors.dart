import 'package:dio/dio.dart';
import '../../../core/services/auth/auth_service.dart';

/// Interceptor для автоматического добавления токена авторизации
class HotelAuthInterceptor extends Interceptor {
  String? _accessToken;
  final AuthService? _authService;

  HotelAuthInterceptor({
    String? accessToken,
    AuthService? authService,
  })  : _accessToken = accessToken,
        _authService = authService;

  void updateToken(String? token) {
    _accessToken = token;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Сначала проверяем сохраненный токен
    String? token = _accessToken;

    // Если токена нет, пытаемся получить из AuthService
    if ((token == null || token.isEmpty) && _authService != null) {
      try {
        token = await _authService!.getAccessToken();
      } catch (e) {
        // Игнорируем ошибки получения токена
      }
    }

    // Добавляем токен в заголовки если он есть
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}

/// Interceptor для логирования запросов и ответов
class HotelLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
    if (options.queryParameters.isNotEmpty) {
      print('Query: ${options.queryParameters}');
    }
    if (options.data != null) {
      print('Data: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
      '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    print('Error: ${err.message}');
    handler.next(err);
  }
}

