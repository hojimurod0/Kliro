import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../models/auto_credit_model.dart';
import '../models/pagination_filter.dart';

abstract class AutoCreditRemoteDataSource {
  Future<List<AutoCredit>> fetchAutoCredits({
    required PaginationFilter pagination,
    String? bank,
    double? rateFrom,
    int? termMonthsFrom,
    double? amountFrom,
    String? opening,
    String? search,
    String? sort,
    String? direction,
  });
}

class AutoCreditRemoteDataSourceImpl implements AutoCreditRemoteDataSource {
  AutoCreditRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<AutoCredit>> fetchAutoCredits({
    required PaginationFilter pagination,
    String? bank,
    double? rateFrom,
    int? termMonthsFrom,
    double? amountFrom,
    String? opening,
    String? search,
    String? sort,
    String? direction,
  }) async {
    final query = <String, dynamic>{
      'page': pagination.page,
      'size': pagination.size,
      if (bank != null && bank.isNotEmpty) 'bank': bank,
      if (rateFrom != null) 'rate_from': rateFrom,
      if (termMonthsFrom != null) 'term_months_from': termMonthsFrom,
      if (amountFrom != null) 'amount_from': amountFrom,
      if (opening != null && opening.isNotEmpty) 'opening': opening,
      if (search != null && search.isNotEmpty) 'search': search,
      if (sort != null && sort.isNotEmpty) 'sort': sort,
      if (direction != null && direction.isNotEmpty) 'direction': direction,
    };

    developer.log(
      'Fetching auto credits page=${pagination.page} size=${pagination.size} query=$query',
      name: 'AutoCreditRemoteDataSource',
    );

    try {
      final response = await _dio.get(
        ApiPaths.getAutoCredits,
        queryParameters: query,
      );

      if (response.data is! Map<String, dynamic>) {
        throw const AppException(message: 'Server noto\'g\'ri ma\'lumot berdi');
      }

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json! as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.result == null) {
        throw ValidationException(
          apiResponse.message ?? 'So\'rov bajarilmadi',
          statusCode: response.statusCode,
        );
      }

      final result = apiResponse.result!;
      final data = result['data'] as List<dynamic>?;

      if (data == null) {
        return [];
      }

      return data
          .map((item) => AutoCredit.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw _mapDioError(error);
    } catch (error, stackTrace) {
      if (error is AppException) rethrow;
      developer.log(
        'Unknown error while fetching auto credits',
        name: 'AutoCreditRemoteDataSource',
        error: error,
        stackTrace: stackTrace,
      );
      throw AppException(message: error.toString());
    }
  }

  AppException _mapDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return NetworkException(
        message: 'Serverga ulanib bo\'lmadi. Internetni tekshiring.',
        statusCode: statusCode,
        details: error.response?.data,
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkException(
        message: 'Server ishlamayapti yoki internet mavjud emas.',
        statusCode: statusCode,
        details: error.response?.data,
      );
    }

    final message = _extractMessage(error.response?.data) ??
        error.message ??
        'Noma\'lum xatolik yuz berdi';

    if (statusCode == 401) {
      return UnauthorizedException(
        message: message,
        statusCode: statusCode,
        details: error.response?.data,
      );
    }

    return NetworkException(
      message: message,
      statusCode: statusCode,
      details: error.response?.data,
    );
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
      final error = data['error'];
      if (error is String && error.isNotEmpty) return error;
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            final first = value.first;
            if (first is String && first.isNotEmpty) return first;
          }
        }
      }
    }
    return null;
  }
}
