import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/transfer_app_filter.dart';
import '../models/transfer_app_model.dart';

abstract class TransferAppRemoteDataSource {
  Future<List<TransferAppModel>> getTransferApps({
    TransferAppFilter filter,
  });
}

class TransferAppRemoteDataSourceImpl implements TransferAppRemoteDataSource {
  TransferAppRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<TransferAppModel>> getTransferApps({
    TransferAppFilter filter = TransferAppFilter.empty,
  }) async {
    try {
      final query = filter.toQueryParameters();
      developer.log(
        'Requesting transfer apps -> $query',
        name: 'TransferAppRemoteDataSource',
      );

      final response = await _dio.get(
        ApiPaths.getTransferApps,
        queryParameters: query,
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const AppException(
          message: 'Server noto‘g‘ri maʼlumot qaytardi',
        );
      }

      final apiResponse = ApiResponse.fromJson(
        data,
        (json) => json,
      );

      if (!apiResponse.success) {
        throw ValidationException(
          message: apiResponse.message ?? 'So‘rov bajarilmadi',
          details: apiResponse.result,
          statusCode: response.statusCode,
        );
      }

      final rawItems = _extractItems(apiResponse.result);
      developer.log(
        'Transfer apps loaded: ${rawItems.length}',
        name: 'TransferAppRemoteDataSource',
      );

      return rawItems.map(TransferAppModel.fromJson).toList();
    } on DioException catch (error) {
      throw _mapDioError(error);
    } on AppException {
      rethrow;
    } catch (error, stackTrace) {
      developer.log(
        'Unexpected error while fetching transfer apps',
        name: 'TransferAppRemoteDataSource',
        error: error,
        stackTrace: stackTrace,
      );
      throw AppException(message: error.toString());
    }
  }

  List<Map<String, dynamic>> _extractItems(Object? result) {
    if (result is List) {
      return result.whereType<Map<String, dynamic>>().toList();
    }
    if (result is Map<String, dynamic>) {
      final content = result['content'];
      if (content is List) {
        return content.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }

  AppException _mapDioError(DioException error) {
    final statusCode = error.response?.statusCode;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return NetworkException(
        message: 'Serverga ulanib bo‘lmadi. Internetni tekshiring.',
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
        'Nomaʼlum xato yuz berdi';

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
      if (message is String && message.isNotEmpty) {
        return message;
      }
      final error = data['error'];
      if (error is String && error.isNotEmpty) {
        return error;
      }
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            final first = value.first;
            if (first is String && first.isNotEmpty) {
              return first;
            }
          }
        }
      }
    }
    return null;
  }
}

