import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/params/auth_params.dart';
import '../models/auth_tokens_model.dart';
import '../models/google_auth_redirect_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendRegisterOtp(SendOtpParams params);
  Future<void> confirmRegisterOtp(ConfirmOtpParams params);
  Future<AuthTokensModel> finalizeRegistration(RegistrationFinalizeParams params);
  Future<AuthTokensModel> login(LoginParams params);
  Future<void> sendForgotPasswordOtp(ForgotPasswordParams params);
  Future<void> resetPassword(ResetPasswordParams params);
  Future<GoogleAuthRedirectModel> getGoogleRedirect(String redirectUrl);
  Future<AuthTokensModel> completeGoogleRegistration(GoogleCompleteParams params);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<void> sendRegisterOtp(SendOtpParams params) async {
    await _postVoid(
      ApiPaths.registerSendOtp,
      data: _contactPayload(params),
    );
  }

  @override
  Future<void> confirmRegisterOtp(ConfirmOtpParams params) async {
    await _postVoid(
      ApiPaths.confirmOtp,
      data: {
        ..._contactPayload(params),
        'otp': params.otp,
      },
    );
  }

  @override
  Future<AuthTokensModel> finalizeRegistration(
    RegistrationFinalizeParams params,
  ) async {
    return _postData<AuthTokensModel>(
      ApiPaths.finalizeRegistration,
      data: {
        ..._contactPayload(params),
        'region_id': params.regionId,
        'password': params.password,
        'password_confirmation': params.confirmPassword,
        'first_name': params.firstName,
        'last_name': params.lastName,
      },
      parser: (json) => AuthTokensModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<AuthTokensModel> login(LoginParams params) {
    return _postData<AuthTokensModel>(
      ApiPaths.login,
      data: {
        ..._contactPayload(params),
        'password': params.password,
      },
      parser: (json) => AuthTokensModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<void> sendForgotPasswordOtp(ForgotPasswordParams params) {
    return _postVoid(
      ApiPaths.forgotPassword,
      data: _contactPayload(params),
    );
  }

  @override
  Future<void> resetPassword(ResetPasswordParams params) {
    return _postVoid(
      ApiPaths.resetPassword,
      data: {
        ..._contactPayload(params),
        'otp': params.otp,
        'password': params.password,
        'password_confirmation': params.confirmPassword,
      },
    );
  }

  @override
  Future<GoogleAuthRedirectModel> getGoogleRedirect(String redirectUrl) async {
    try {
      // Backend Google OAuth URL'ni POST metod bilan olish
      // Backend HTML response (Google OAuth sahifasi) qaytarishi mumkin
      final response = await _dio.post(
        ApiPaths.googleLogin,
        queryParameters: {
          'redirect_url': redirectUrl,
        },
        options: Options(
          // HTML response'ni qabul qilish uchun
          responseType: ResponseType.plain, // String sifatida olish
          validateStatus: (status) => status != null && status < 500, // 4xx status'larni ham qabul qilish
        ),
      );
      
      // Agar response JSON bo'lsa (backend JSON qaytarsa)
      if (response.data is Map<String, dynamic>) {
        try {
          return GoogleAuthRedirectModel.fromJson(
            response.data as Map<String, dynamic>,
          );
        } catch (e) {
          // JSON parse qilishda xato bo'lsa, HTML response sifatida handle qilamiz
        }
      }
      
      // Agar response String (HTML) bo'lsa
      // Backend Google OAuth sahifasini to'g'ridan-to'g'ri qaytarayotgan bo'lishi mumkin
      if (response.data is String) {
        final responseData = response.data as String;
        
        // JSON string bo'lishi mumkin
        try {
          final jsonData = responseData.trim();
          if (jsonData.startsWith('{') || jsonData.startsWith('[')) {
            final parsed = jsonDecode(jsonData) as Map<String, dynamic>;
            return GoogleAuthRedirectModel.fromJson(parsed);
          }
        } catch (e) {
          // JSON emas, HTML bo'lishi mumkin
        }
        
        // HTML response bo'lsa, request URL ni o'zi Google OAuth URL sifatida qaytaramiz
        // Backend bu URL'ni Google OAuth sahifasiga redirect qiladi yoki to'g'ridan-to'g'ri ko'rsatadi
        if (responseData.contains('<!doctype html>') || 
            responseData.contains('accounts.google.com') ||
            responseData.contains('signin') ||
            responseData.contains('google.com')) {
          // Request URL ni o'zi Google OAuth URL sifatida qaytaramiz
          final requestUrl = response.requestOptions.uri.toString();
          
          if (kDebugMode) {
            AppLogger.debug(
              '✅ Backend HTML response qaytardi (Google OAuth sahifasi). '
              'Request URL ni ishlatamiz: $requestUrl',
            );
          }
          
          return GoogleAuthRedirectModel(
            url: requestUrl,
            sessionId: null,
          );
        }
      }
      
      // Agar status code 302, 301 (Redirect) bo'lsa
      if (response.statusCode == 302 || response.statusCode == 301) {
        final location = response.headers.value('location');
        if (location != null && location.isNotEmpty) {
          if (kDebugMode) {
            AppLogger.debug('✅ Redirect Location topildi: $location');
          }
          return GoogleAuthRedirectModel(
            url: location,
            sessionId: null,
          );
        }
      }
      
      // Fallback: request URL ni qaytarish
      // Bu backend Google OAuth sahifasini ko'rsatadigan URL bo'ladi
      final requestUrl = response.requestOptions.uri.toString();
      
      if (kDebugMode) {
        AppLogger.debug(
          '⚠️ Response format aniqlanmadi, request URL ni qaytaramiz: $requestUrl',
        );
      }
      
      return GoogleAuthRedirectModel(
        url: requestUrl,
        sessionId: null,
      );
    } catch (e, stackTrace) {
      // Xatolik yuz bersa, xatoni log qilish va request URL ni qaytarish
      AppLogger.error(
        'getGoogleRedirect xatolik',
        e.toString(),
        stackTrace,
      );
      
      // Fallback: request URL ni qaytarish
      try {
        final baseUrl = ApiConstants.effectiveBaseUrl;
        final cleanBaseUrl = baseUrl.endsWith('/') 
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl;
        final path = ApiPaths.googleLogin.startsWith('/')
            ? ApiPaths.googleLogin
            : '/${ApiPaths.googleLogin}';
        final uri = Uri.parse('$cleanBaseUrl$path').replace(queryParameters: {
          'redirect_url': redirectUrl,
        });
        
        final requestUrl = uri.toString();
        
        if (kDebugMode) {
          AppLogger.debug('⚠️ Fallback: Request URL ni qaytaramiz: $requestUrl');
        }
        
        return GoogleAuthRedirectModel(
          url: requestUrl,
          sessionId: null,
        );
      } catch (fallbackError) {
        AppLogger.error(
          'getGoogleRedirect fallback xatolik',
          fallbackError.toString(),
          StackTrace.current,
        );
        rethrow;
      }
    }
  }

  @override
  Future<AuthTokensModel> completeGoogleRegistration(
    GoogleCompleteParams params,
  ) {
    return _postData<AuthTokensModel>(
      ApiPaths.googleComplete,
      data: {
        'session_id': params.sessionId,
        'region_id': params.regionId,
        'first_name': params.firstName,
        'last_name': params.lastName,
      },
      parser: (json) => AuthTokensModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> _postVoid(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw const AppException(message: 'Malformed server response');
      }
      final apiResponse = ApiResponse.fromJson(
        responseData,
        (_) => null,
      );
      if (!apiResponse.success) {
        throw ValidationException(
          apiResponse.message ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }
      // Void response - no need to return anything
    } on DioException catch (error) {
      _handleDioError(error);
      // _handleDioError always throws, so this is unreachable
    }
  }

  Future<T> _postData<T>(
    String path, {
    Map<String, dynamic>? data,
    required T Function(Object? json) parser,
  }) async {
    return _request(
      () => _dio.post(path, data: data),
      parser: parser,
    );
  }

  Future<T> _getData<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) parser,
  }) {
    return _request(
      () => _dio.get(path, queryParameters: queryParameters),
      parser: parser,
    );
  }

  Future<T> _request<T>(
    Future<Response<dynamic>> Function() action, {
    required T Function(Object? json) parser,
    bool expectResult = true,
  }) async {
    try {
      final response = await action();
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const AppException(message: 'Malformed server response');
      }
      final apiResponse = ApiResponse.fromJson(
        data,
        parser,
      );
      if (!apiResponse.success) {
        throw ValidationException(
          apiResponse.message ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }
      if (!expectResult) {
        return apiResponse.result as T;
      }
      final result = apiResponse.result;
      if (result == null) {
        throw const AppException(message: 'Missing response payload');
      }
      return result as T;
    } on DioException catch (error) {
      _handleDioError(error);
      // _handleDioError always throws, so this is unreachable
    }
  }

  Never _handleDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    
    // Timeout xatolarini alohida handle qilish
    if (error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionTimeout) {
      throw NetworkException(
        message: 'Serverga ulanib bo\'lmadi. Internet aloqasini tekshiring yoki keyinroq urinib ko\'ring.',
        statusCode: statusCode,
        details: error.response?.data,
      );
    }
    
    // Connection xatolari
    if (error.type == DioExceptionType.connectionError) {
      throw NetworkException(
        message: 'Serverga ulanib bo\'lmadi. Server ishlamayotgan bo\'lishi mumkin yoki internet aloqasi yo\'q.',
        statusCode: statusCode,
        details: error.response?.data,
      );
    }
    
    final message =
        _extractMessage(error.response?.data) ?? error.message ?? 'Noma\'lum xatolik';
    
    if (statusCode == 401) {
      throw UnauthorizedException(
        message: message,
        statusCode: statusCode,
        details: error.response?.data,
      );
    }
    
    throw NetworkException(
      message: message,
      statusCode: statusCode,
      details: error.response?.data,
    );
  }

  Map<String, dynamic> _contactPayload(ContactParams params) {
    final payload = <String, dynamic>{};
    if (params.email != null) {
      payload['email'] = params.email;
    }
    if (params.phone != null) {
      // Telefon raqamini server formatiga moslashtirish
      // Server +998 formatini kutadi (ro'yxatdan o'tganda ham shu format ishlatilgan)
      String phone = params.phone!;
      // + bilan boshlanmasa, qo'shamiz
      if (!phone.startsWith('+')) {
        if (phone.startsWith('998')) {
          phone = '+$phone';
        } else {
          phone = '+998$phone';
        }
      }
      payload['phone'] = phone;
    }
    return payload;
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
      final error = data['error'];
      if (error is String && error.isNotEmpty) {
        return error;
      }
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        final firstValue = errors.values.cast<List?>().firstWhere(
          (value) => value != null && value.isNotEmpty,
          orElse: () => null,
        );
        if (firstValue != null) {
          final firstMessage = firstValue.first;
          if (firstMessage is String && firstMessage.isNotEmpty) {
            return firstMessage;
          }
        }
      }
    }
    return null;
  }
}


