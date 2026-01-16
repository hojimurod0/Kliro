import 'package:dio/dio.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/params/auth_params.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile(UpdateProfileParams params);
  Future<UserProfileModel> changeRegion(ChangeRegionParams params);
  Future<void> changePassword(ChangePasswordParams params);
  Future<void> updateContact(UpdateContactParams params);
  Future<void> confirmUpdateContact(ConfirmUpdateContactParams params);
  Future<void> logout();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<UserProfileModel> getProfile() {
    return _getData<UserProfileModel>(
      ApiPaths.getProfile,
      parser: (json) {
        if (json is! Map<String, dynamic>) {
          AppLogger.warning('📥 PROFILE_DS: JSON is not a Map');
          return UserProfileModel.fromJson({} as Map<String, dynamic>);
        }
        
        AppLogger.debug('📥 PROFILE_DS: Parsing profile JSON');
        AppLogger.debug('📥 PROFILE_DS: JSON keys: ${json.keys.toList()}');
        AppLogger.debug('📥 PROFILE_DS: JSON email value: ${json['email']}');
        AppLogger.debug('📥 PROFILE_DS: JSON phone value: ${json['phone']}');
        AppLogger.debug('📥 PROFILE_DS: JSON first_name value: ${json['first_name']}');
        AppLogger.debug('📥 PROFILE_DS: JSON last_name value: ${json['last_name']}');
        
        final profile = UserProfileModel.fromJson(json);
        AppLogger.debug('📥 PROFILE_DS: Parsed profile.email: ${profile.email ?? "null"}');
        AppLogger.debug('📥 PROFILE_DS: Parsed profile.phone: ${profile.phone ?? "null"}');
        return profile;
      },
    );
  }

  @override
  Future<UserProfileModel> updateProfile(UpdateProfileParams params) async {
    // Update profile API returns {status: "profile updated"} instead of full profile
    // So we need to update first, then fetch the updated profile
    await _postVoid(
      ApiPaths.updateProfile,
      data: {'first_name': params.firstName, 'last_name': params.lastName},
    );
    // Fetch the updated profile after successful update
    return getProfile();
  }

  @override
  Future<UserProfileModel> changeRegion(ChangeRegionParams params) {
    return _postData<UserProfileModel>(
      ApiPaths.changeRegion,
      data: {'region_id': params.regionId},
      parser: (json) => UserProfileModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<void> changePassword(ChangePasswordParams params) {
    return _postVoid(
      ApiPaths.changePassword,
      data: {
        'old_password': params.oldPassword,
        'new_password': params.newPassword,
      },
    );
  }

  @override
  Future<void> updateContact(UpdateContactParams params) {
    return _postVoid(ApiPaths.updateContact, data: _contactPayload(params));
  }

  @override
  Future<void> confirmUpdateContact(ConfirmUpdateContactParams params) {
    return _postVoid(ApiPaths.confirmUpdateContact, data: {'otp': params.otp});
  }

  @override
  Future<void> logout() {
    return _postVoid(ApiPaths.logout);
  }

  Future<void> _postVoid(String path, {Map<String, dynamic>? data}) async {
    await _request(
      () => _dio.post(path, data: data),
      parser: (_) => null,
      expectResult: false,
    );
  }

  Future<T> _postData<T>(
    String path, {
    Map<String, dynamic>? data,
    required T Function(Object? json) parser,
  }) {
    return _request(() => _dio.post(path, data: data), parser: parser);
  }

  Future<T> _getData<T>(
    String path, {
    required T Function(Object? json) parser,
  }) {
    return _request(() => _dio.get(path), parser: parser);
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
      final apiResponse = ApiResponse.fromJson(data, parser);
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
    final message =
        _extractMessage(error.response?.data) ?? error.message ?? 'Unknown';
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

  Map<String, dynamic> _contactPayload(UpdateContactParams params) {
    final payload = <String, dynamic>{};
    if (params.email != null) {
      payload['email'] = params.email;
    }
    if (params.phone != null) {
      payload['phone'] = params.phone;
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
