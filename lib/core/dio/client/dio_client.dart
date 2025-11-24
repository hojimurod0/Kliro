import 'package:dio/dio.dart';

import '../../constants/constants.dart';
import '../../errors/app_exception.dart';
import '../../services/auth/auth_service.dart';
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
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _authService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _authService.clearSession();
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
