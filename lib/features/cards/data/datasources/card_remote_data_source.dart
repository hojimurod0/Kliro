import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/card_filter.dart';
import '../models/card_offer_page_model.dart';

abstract class CardRemoteDataSource {
  Future<CardOfferPageModel> getCardOffers({
    required int page,
    required int size,
    CardFilter filter,
  });

  Future<CardOfferPageModel> getCreditCardOffers({
    required int page,
    required int size,
    CardFilter filter,
  });
}

class CardRemoteDataSourceImpl implements CardRemoteDataSource {
  CardRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<CardOfferPageModel> getCardOffers({
    required int page,
    required int size,
    CardFilter filter = CardFilter.empty,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'size': size,
      ...filter.toQueryParameters(),
    };

    developer.log(
      'Fetching cards page=$page size=$size query=$query',
      name: 'CardRemoteDataSource',
    );

    try {
      final response = await _dio.get(
        ApiPaths.getCards,
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

      return CardOfferPageModel.fromJson(apiResponse.result!);
    } on DioException catch (error) {
      throw _mapDioError(error);
    } catch (error, stackTrace) {
      if (error is AppException) rethrow;
      developer.log(
        'Unknown error while fetching cards',
        name: 'CardRemoteDataSource',
        error: error,
        stackTrace: stackTrace,
      );
      throw AppException(message: error.toString());
    }
  }

  @override
  Future<CardOfferPageModel> getCreditCardOffers({
    required int page,
    required int size,
    CardFilter filter = CardFilter.empty,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'size': size,
      ...filter.toQueryParameters(),
    };

    try {
      final response = await _dio.get(
        ApiPaths.getCreditCards,
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

      return CardOfferPageModel.fromJson(apiResponse.result!);
    } on DioException catch (error) {
      throw _mapDioError(error);
    } catch (error, stackTrace) {
      if (error is AppException) rethrow;
      developer.log(
        'Unknown error while fetching credit cards',
        name: 'CardRemoteDataSource',
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

    final message =
        _extractMessage(error.response?.data) ??
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
