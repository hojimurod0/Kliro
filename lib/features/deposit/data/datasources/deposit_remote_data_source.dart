import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/deposit_filter.dart';
import '../models/deposit_model.dart';
import '../models/deposit_page_model.dart';

abstract class DepositRemoteDataSource {
  Future<DepositPageModel> getDeposits({
    required int page,
    required int size,
    DepositFilter filter,
  });
}

class DepositRemoteDataSourceImpl implements DepositRemoteDataSource {
  DepositRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<DepositPageModel> getDeposits({
    required int page,
    required int size,
    DepositFilter filter = DepositFilter.empty,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'size': size,
        ...filter.toQueryParameters(),
      };

      print('[DepositRemoteDataSource] Fetching deposits:');
      print('  - URL: ${ApiPaths.getDeposits}');
      print('  - Base URL: ${ApiConstants.effectiveBaseUrl}');
      print('  - Page: $page, Size: $size');
      print('  - Query params: $query');

      developer.log(
        'Fetching deposits page=$page size=$size query=$query',
        name: 'DepositRemoteDataSource',
      );

      final response = await _dio.get(
        ApiPaths.getDeposits,
        queryParameters: query,
      );

      print('[DepositRemoteDataSource] Response received:');
      print('  - Status: ${response.statusCode}');
      print('  - Data type: ${response.data.runtimeType}');

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const AppException(message: 'Server notogri malumot qaytardi');
      }

      print('[DepositRemoteDataSource] Parsing ApiResponse...');

      final apiResponse = ApiResponse.fromJson(
        data,
        (json) => json as Map<String, dynamic>,
      );

      print('[DepositRemoteDataSource] ApiResponse parsed:');
      print('  - Success: ${apiResponse.success}');
      print('  - Message: ${apiResponse.message}');
      print('  - Result type: ${apiResponse.result.runtimeType}');

      if (!apiResponse.success) {
        print(
          '[DepositRemoteDataSource] API returned error: ${apiResponse.message}',
        );
        throw ValidationException(
          message: apiResponse.message ?? 'Sorov bajarilmadi',
          statusCode: response.statusCode,
          details: data,
        );
      }

      final result = apiResponse.result;
      print('[DepositRemoteDataSource] Result extracted:');
      print('  - Type: ${result.runtimeType}');
      if (result is Map<String, dynamic>) {
        print('  - Keys: ${result.keys}');
        if (result.containsKey('content')) {
          print('  - Content type: ${result['content'].runtimeType}');
          if (result['content'] is List) {
            print(
              '  - Content length: ${(result['content'] as List).length}',
            );
          }
        }
      }
      if (result is! Map<String, dynamic>) {
        developer.log(
          'API result invalid, returning empty payload',
          name: 'DepositRemoteDataSource',
        );
        return DepositPageModel(
          content: const <DepositModel>[],
          totalPages: 0,
          totalElements: 0,
          number: 0,
          size: size,
          first: true,
          last: true,
          numberOfElements: 0,
        );
      }

      print('[DepositRemoteDataSource] Parsing result: ${result.keys}');
      print('[DepositRemoteDataSource] Result type: ${result.runtimeType}');

      final parsed = DepositPageModel.fromJson(result);

      print('[DepositRemoteDataSource] Parsed successfully:');
      print('  - Total items: ${parsed.content.length}');
      print('  - Page: ${parsed.number}');
      print('  - Total pages: ${parsed.totalPages}');
      print('  - Total elements: ${parsed.totalElements}');
      print('  - Is last: ${parsed.last}');

      if (parsed.content.isNotEmpty) {
        print(
          '[DepositRemoteDataSource] First item: ${parsed.content.first.bankName} - ${parsed.content.first.description}',
        );
      }

      developer.log(
        'API success items=${parsed.content.length} page=${parsed.number} isLast=${parsed.last}',
        name: 'DepositRemoteDataSource',
      );
      return parsed;
    } on DioException catch (error) {
      final mapped = _mapDioError(error);
      developer.log(
        'Dio error',
        name: 'DepositRemoteDataSource',
        error: mapped,
        stackTrace: error.stackTrace,
      );
      throw mapped;
    } catch (error, stackTrace) {
      if (error is AppException) {
        developer.log(
          'Known AppException',
          name: 'DepositRemoteDataSource',
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      }
      developer.log(
        'Unknown error',
        name: 'DepositRemoteDataSource',
        error: error,
        stackTrace: stackTrace,
      );
      throw AppException(message: error.toString());
    }
  }

  AppException _mapDioError(DioException error) {
    final statusCode = error.response?.statusCode;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return NetworkException(
        message: 'Serverga ulanib bolmadi. Internet aloqasini tekshiring.',
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
        'Nomalum xatolik yuz berdi';

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

