import 'package:dio/dio.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_response.dart';
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
    return _getData<GoogleAuthRedirectModel>(
      ApiPaths.googleLogin,
      queryParameters: {
        'redirect_url': redirectUrl,
      },
      parser: (json) =>
          GoogleAuthRedirectModel.fromJson(json as Map<String, dynamic>),
    );
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
          message: apiResponse.message ?? 'Request failed',
          details: responseData,
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
          message: apiResponse.message ?? 'Request failed',
          details: data,
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


