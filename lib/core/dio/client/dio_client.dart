import 'package:dio/dio.dart';

import '../../constants/constants.dart';
import '../../errors/app_exception.dart';
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
          // 401 xatolik - token yangilash yoki logout
          if (error.response?.statusCode == 401) {
            // Token refresh mexanizmi (agar mavjud bo'lsa)
            final refreshToken = await _authService.getRefreshToken();
            if (refreshToken != null && refreshToken.isNotEmpty) {
              try {
                // Token yangilash logikasi shu yerda bo'lishi mumkin
                // Hozircha faqat session ni tozalaymiz
                await _authService.clearSession();
              } catch (e) {
                // Token yangilash muvaffaqiyatsiz bo'lsa, session ni tozalaymiz
                await _authService.clearSession();
              }
            } else {
              // Refresh token yo'q bo'lsa, session ni tozalaymiz
              await _authService.clearSession();
            }
            
            handler.next(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                error: const UnauthorizedException(message: 'Unauthorized'),
                type: error.type,
              ),
            );
            return;
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
