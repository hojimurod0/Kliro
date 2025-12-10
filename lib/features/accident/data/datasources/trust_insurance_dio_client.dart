import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/dio/interceptor/logging_interceptor.dart';

class TrustInsuranceDioClient {
  late final Dio _dio;
  final String baseUrl;
  final String username;
  final String password;

  TrustInsuranceDioClient({
    required this.baseUrl,
    required this.username,
    required this.password,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
        contentType: 'application/json',
      ),
    );

    // Добавляем Basic Auth
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (username.isNotEmpty && password.isNotEmpty) {
            final credentials = '$username:$password';
            final base64Credentials = base64Encode(utf8.encode(credentials));
            options.headers['Authorization'] = 'Basic $base64Credentials';
          } else {
            // Warning: Credentials not configured
            debugPrint('⚠️ WARNING: Trust Insurance credentials not configured!');
            debugPrint('Please set TRUST_LOGIN and TRUST_PASSWORD environment variables');
            debugPrint('or update TrustInsuranceConfig in constants.dart');
          }
          handler.next(options);
        },
      ),
    );

    // Добавляем логирование
    _dio.interceptors.add(LoggingInterceptor());
  }

  Dio get client => _dio;
}

