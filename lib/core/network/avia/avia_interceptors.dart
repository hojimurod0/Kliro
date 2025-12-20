import 'package:dio/dio.dart';
import '../../../core/services/auth/auth_service.dart';

/// Interceptor для автоматического добавления токена авторизации
class AviaAuthInterceptor extends Interceptor {
  String? _accessToken;
  final AuthService? _authService;

  AviaAuthInterceptor({
    String? accessToken,
    AuthService? authService,
  })  : _accessToken = accessToken,
        _authService = authService;

  void updateToken(String? token) {
    _accessToken = token;
  }

  /// Check if user has a valid token
  bool get hasToken {
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      return true;
    }
    // Could also check AuthService here if needed
    return false;
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
class AviaLoggingInterceptor extends Interceptor {
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
    
    // Payment-permission va check-price endpoint'lari uchun to'liq response'ni log qilish
    final path = response.requestOptions.path;
    if (path.contains('payment-permission') || path.contains('check-price')) {
      print('📋 Response Data: ${response.data}');
      
      // Payment permission uchun alohida log
      if (path.contains('payment-permission')) {
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          print('🔍 Payment Permission Details:');
          print('   - can_pay: ${data['can_pay']}');
          print('   - allowed: ${data['allowed']}');
          print('   - reason: ${data['reason']}');
          // Agar data ichida bo'lsa
          if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
            final innerData = data['data'] as Map<String, dynamic>;
            print('   - data.can_pay: ${innerData['can_pay']}');
            print('   - data.allowed: ${innerData['allowed']}');
            print('   - data.reason: ${innerData['reason']}');
          }
        }
      }
      
      // Check price uchun alohida log
      if (path.contains('check-price')) {
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          print('🔍 Price Check Details:');
          print('   - price: ${data['price']}');
          print('   - currency: ${data['currency']}');
          print('   - price_changed: ${data['price_changed']}');
          print('   - old_price: ${data['old_price']}');
          // Agar data ichida bo'lsa
          if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
            final innerData = data['data'] as Map<String, dynamic>;
            print('   - data.price: ${innerData['price']}');
            print('   - data.currency: ${innerData['currency']}');
            print('   - data.price_changed: ${innerData['price_changed']}');
            print('   - data.old_price: ${innerData['old_price']}');
          }
        }
      }
    }
    
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
      '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    print('Error: ${err.message}');
    // Log response body to see server error details
    if (err.response?.data != null) {
      print('❌ Response Body: ${err.response?.data}');
    }
    handler.next(err);
  }
}

