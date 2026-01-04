import 'package:dio/dio.dart';

import '../../constants/constants.dart';
import '../../services/auth/auth_service.dart';
import '../interceptor/language_interceptor.dart';
import '../interceptor/logging_interceptor.dart';

class DioClient {
  DioClient({
    required AuthService authService,
  })  : _authService = authService,
        _dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.effectiveBaseUrl,
            connectTimeout: ApiConstants.connectTimeout,
            receiveTimeout: ApiConstants.receiveTimeout,
            responseType: ResponseType.json,
            contentType: 'application/json',
          ),
        ) {
    _dio.interceptors.addAll([
      LanguageInterceptor(), // Добавляем язык в заголовки перед другими interceptors
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _authService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // 401: Token eskirgan -> avval refresh qilish, keyin retry
          if (error.response?.statusCode == 401) {
            final requestOptions = error.requestOptions;
            
            // Agar bu refresh token yoki login request bo'lsa, loop'ga tushmaslik uchun
            if (requestOptions.path.contains('/auth/refresh') || 
                requestOptions.path.contains('/auth/login')) {
              await _authService.logout();
              handler.next(error);
              return;
            }
            
            // Token refresh qilish
            final newToken = await _authService.refreshToken();
            
            if (newToken != null && newToken.isNotEmpty) {
              // Yangi token bilan request'ni qayta yuborish
              requestOptions.headers['Authorization'] = 'Bearer $newToken';
              
              try {
                // Original request'ni yangi token bilan qayta yuborish
                final response = await _dio.fetch(requestOptions);
                handler.resolve(response);
                return;
              } catch (e) {
                // Retry ham muvaffaqiyatsiz bo'lsa, logout
                await _authService.logout();
                handler.next(error);
                return;
              }
            } else {
              // Token refresh muvaffaqiyatsiz -> logout
              await _authService.logout();
              handler.next(error);
              return;
            }
          }
          handler.next(error);
        },
      ),
      LoggingInterceptor(),
    ]);
  }

  final AuthService _authService;
  final Dio _dio;

  Dio get client => _dio;
}
