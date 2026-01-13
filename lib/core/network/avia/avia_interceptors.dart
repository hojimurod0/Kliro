import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    // Avval AuthService'dan token olish (source of truth - har doim yangi token)
    String? token;
    
    if (_authService != null) {
      try {
        token = await _authService!.getAccessToken();
        
        // Debug: /user/humans so'rovi uchun token ichidagi user_id'ni ko'rsatish
        if (options.path.contains('/user/humans') && token != null && token.isNotEmpty) {
          try {
            // JWT token'ni decode qilish (payload qismini olish)
            final parts = token.split('.');
            if (parts.length == 3) {
              // Base64 decode qilish
              final payload = parts[1];
              // Padding qo'shish (agar kerak bo'lsa)
              String normalizedPayload = payload;
              switch (payload.length % 4) {
                case 1:
                  normalizedPayload += '===';
                  break;
                case 2:
                  normalizedPayload += '==';
                  break;
                case 3:
                  normalizedPayload += '=';
                  break;
              }
              final decoded = utf8.decode(base64.decode(normalizedPayload));
              final payloadMap = json.decode(decoded) as Map<String, dynamic>;
              final userId = payloadMap['user_id'] ?? payloadMap['userId'] ?? payloadMap['sub'];
              debugPrint('🔍 DEBUG: /user/humans request - Token user_id: $userId');
              debugPrint('🔍 DEBUG: Token payload keys: ${payloadMap.keys.toList()}');
            }
          } catch (e) {
            debugPrint('⚠️ DEBUG: Could not decode token: $e');
          }
        }
      } catch (e) {
        // Игнорируем ошибки получения токена
      }
    }
    
    // Agar AuthService'dan token topilmasa, cached tokenni ishlatish
    if ((token == null || token.isEmpty) && _accessToken != null && _accessToken!.isNotEmpty) {
      token = _accessToken;
    }

    // Добавляем токен в заголовки если он есть
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401: Token eskirgan -> avval refresh qilish, keyin retry
    if (err.response?.statusCode == 401 && _authService != null) {
      final requestOptions = err.requestOptions;
      
      // Agar bu refresh token yoki login request bo'lsa, loop'ga tushmaslik uchun
      if (requestOptions.path.contains('/auth/refresh') || 
          requestOptions.path.contains('/auth/login')) {
        await _authService!.logout();
        handler.next(err);
        return;
      }
      
      // Token refresh qilish
      final newToken = await _authService!.refreshToken();
      
      if (newToken != null && newToken.isNotEmpty) {
        // Yangi token bilan request'ni qayta yuborish
        requestOptions.headers['Authorization'] = 'Bearer $newToken';
        updateToken(newToken);
        
        try {
          // Original request'ni yangi token bilan qayta yuborish
          // RequestOptions'dan BaseOptions yaratish
          final baseOptions = BaseOptions(
            baseUrl: requestOptions.baseUrl,
            connectTimeout: requestOptions.connectTimeout,
            receiveTimeout: requestOptions.receiveTimeout,
            sendTimeout: requestOptions.sendTimeout,
            headers: requestOptions.headers,
            responseType: requestOptions.responseType,
            contentType: requestOptions.contentType,
          );
          final dio = Dio(baseOptions);
          final response = await dio.fetch(requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Retry ham muvaffaqiyatsiz bo'lsa, logout
          await _authService!.logout();
          handler.next(err);
          return;
        }
      } else {
        // Token refresh muvaffaqiyatsiz -> logout
        await _authService!.logout();
        handler.next(err);
        return;
      }
    }
    
    handler.next(err);
  }
}

/// Interceptor для логирования запросов и ответов
class AviaLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('Query: ${options.queryParameters}');
    }
    if (options.data != null) {
      debugPrint('Data: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    
    // Payment-permission va check-price endpoint'lari uchun to'liq response'ni log qilish
    final path = response.requestOptions.path;
    if (path.contains('payment-permission') || path.contains('check-price')) {
      debugPrint('📋 Response Data: ${response.data}');
      
      // Payment permission uchun alohida log
      if (path.contains('payment-permission')) {
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          debugPrint('🔍 Payment Permission Details:');
          debugPrint('   - can_pay: ${data['can_pay']}');
          debugPrint('   - allowed: ${data['allowed']}');
          debugPrint('   - reason: ${data['reason']}');
          // Agar data ichida bo'lsa
          if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
            final innerData = data['data'] as Map<String, dynamic>;
            debugPrint('   - data.can_pay: ${innerData['can_pay']}');
            debugPrint('   - data.allowed: ${innerData['allowed']}');
            debugPrint('   - data.reason: ${innerData['reason']}');
          }
        }
      }
      
      // Check price uchun alohida log
      if (path.contains('check-price')) {
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          debugPrint('🔍 Price Check Details:');
          debugPrint('   - price: ${data['price']}');
          debugPrint('   - currency: ${data['currency']}');
          debugPrint('   - price_changed: ${data['price_changed']}');
          debugPrint('   - old_price: ${data['old_price']}');
          // Agar data ichida bo'lsa
          if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
            final innerData = data['data'] as Map<String, dynamic>;
            debugPrint('   - data.price: ${innerData['price']}');
            debugPrint('   - data.currency: ${innerData['currency']}');
            debugPrint('   - data.price_changed: ${innerData['price_changed']}');
            debugPrint('   - data.old_price: ${innerData['old_price']}');
          }
        }
      }
    }
    
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    debugPrint('Error: ${err.message}');
    // Log response body to see server error details
    if (err.response?.data != null) {
      debugPrint('❌ Response Body: ${err.response?.data}');
    }
    handler.next(err);
  }
}

