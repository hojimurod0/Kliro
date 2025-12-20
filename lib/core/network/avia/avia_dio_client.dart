import 'package:dio/dio.dart';
import '../../constants/constants.dart';
import '../../errors/exceptions.dart';
import '../../services/auth/auth_service.dart';
import 'avia_interceptors.dart';

/// Dio клиент для Avia API
class AviaDioClient {
  late final Dio _dio;
  final AuthService? _authService;

  AviaDioClient({
    String? baseUrl,
    String? accessToken,
    AuthService? authService,
  }) : _authService = authService {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConstants.effectiveBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Добавляем interceptors
    _dio.interceptors.addAll([
      AviaAuthInterceptor(
        accessToken: accessToken,
        authService: _authService ?? AuthService.instance,
      ),
      AviaLoggingInterceptor(),
    ]);
  }

  /// Обновить токен авторизации
  void updateToken(String? token) {
    final authInterceptor =
        _dio.interceptors.whereType<AviaAuthInterceptor>().firstOrNull;
    if (authInterceptor != null) {
      authInterceptor.updateToken(token);
    }
  }

  /// Get Dio client (for accessing interceptors)
  Dio get client => _dio;

  /// GET запрос
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException(message: 'So\'rov vaqti tugadi');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException(message: 'Internet aloqasi yo\'q');
      }
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        String message = 'Server xatosi';
        Map<String, dynamic>? details;

        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] as String? ??
              responseData['error'] as String? ?? 
              'Server xatosi';

          // 422 xatolikda existing_booking_id ni olish (duplicate booking)
          if (statusCode == 422) {
            final dataMap = responseData['data'];

            if (dataMap is Map<String, dynamic>) {
              final existingBookingId = dataMap['existing_booking_id'];
              if (existingBookingId != null) {
                details = {'existing_booking_id': existingBookingId.toString()};
              }
            }
          }
        } else if (responseData is String) {
          message = responseData;
        }

        throw ServerException(
          message: message,
          statusCode: statusCode,
          details: details,
        );
      }
      throw NetworkException(message: e.message ?? 'Noma\'lum xatolik');
    }
  }

  /// POST запрос
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException(message: 'So\'rov vaqti tugadi');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException(message: 'Internet aloqasi yo\'q');
      }
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        String message = 'Server xatosi';
        Map<String, dynamic>? details;

        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] as String? ??
              responseData['error'] as String? ??
              'Server xatosi';

          // 422 xatolikda existing_booking_id ni olish (duplicate booking)
          if (statusCode == 422) {
            final dataMap = responseData['data'];

            if (dataMap is Map<String, dynamic>) {
              final existingBookingId = dataMap['existing_booking_id'];
              if (existingBookingId != null) {
                details = {'existing_booking_id': existingBookingId.toString()};
              }
            }
          }
        } else if (responseData is String) {
          message = responseData;
        }

        throw ServerException(
          message: message,
          statusCode: statusCode,
          details: details,
        );
      }
      throw NetworkException(message: e.message ?? 'Noma\'lum xatolik');
    }
  }

  /// PUT запрос
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException(message: 'So\'rov vaqti tugadi');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException(message: 'Internet aloqasi yo\'q');
      }
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        String message = 'Server xatosi';
        Map<String, dynamic>? details;

        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] as String? ??
              responseData['error'] as String? ??
              'Server xatosi';

          // 422 xatolikda existing_booking_id ni olish (duplicate booking)
          if (statusCode == 422) {
            final dataMap = responseData['data'];

            if (dataMap is Map<String, dynamic>) {
              final existingBookingId = dataMap['existing_booking_id'];
              if (existingBookingId != null) {
                details = {'existing_booking_id': existingBookingId.toString()};
              }
            }
          }
        } else if (responseData is String) {
          message = responseData;
        }

        throw ServerException(
          message: message,
          statusCode: statusCode,
          details: details,
        );
      }
      throw NetworkException(message: e.message ?? 'Noma\'lum xatolik');
    }
  }

  /// DELETE запрос
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException(message: 'So\'rov vaqti tugadi');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException(message: 'Internet aloqasi yo\'q');
      }
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        String message = 'Server xatosi';
        Map<String, dynamic>? details;

        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] as String? ??
              responseData['error'] as String? ??
              'Server xatosi';

          // 422 xatolikda existing_booking_id ni olish (duplicate booking)
          if (statusCode == 422) {
            final dataMap = responseData['data'];

            if (dataMap is Map<String, dynamic>) {
              final existingBookingId = dataMap['existing_booking_id'];
              if (existingBookingId != null) {
                details = {'existing_booking_id': existingBookingId.toString()};
              }
            }
          }
        } else if (responseData is String) {
          message = responseData;
        }

        throw ServerException(
          message: message,
          statusCode: statusCode,
          details: details,
        );
      }
      throw NetworkException(message: e.message ?? 'Noma\'lum xatolik');
    }
  }
}
