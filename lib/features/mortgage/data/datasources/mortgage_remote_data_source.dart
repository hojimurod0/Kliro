import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/mortgage_filter.dart';
import '../models/mortgage_model.dart';
import '../models/mortgage_page_model.dart';

abstract class MortgageRemoteDataSource {
  Future<MortgagePageModel> getMortgages({
    required int page,
    required int size,
    MortgageFilter filter,
  });
}

class MortgageRemoteDataSourceImpl implements MortgageRemoteDataSource {
  MortgageRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<MortgagePageModel> getMortgages({
    required int page,
    required int size,
    MortgageFilter filter = MortgageFilter.empty,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'size': size,
        ...filter.toQueryParameters(),
      };

      print('[MortgageRemoteDataSource] Fetching mortgages:');
      print('  - URL: ${ApiPaths.getMortgages}');
      print('  - Base URL: ${ApiConstants.effectiveBaseUrl}');
      print('  - Page: $page, Size: $size');
      print('  - Query params: $query');

      developer.log(
        'Fetching mortgages page=$page size=$size query=$query',
        name: 'MortgageRemoteDataSource',
      );

      final response = await _dio.get(
        ApiPaths.getMortgages,
        queryParameters: query,
      );

      print('[MortgageRemoteDataSource] Response received:');
      print('  - Status: ${response.statusCode}');
      print('  - Data type: ${response.data.runtimeType}');

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const AppException(message: 'Server notogri malumot qaytardi');
      }

      print('[MortgageRemoteDataSource] Parsing ApiResponse...');

      final apiResponse = ApiResponse.fromJson(
        data,
        (json) => json as Map<String, dynamic>,
      );

      print('[MortgageRemoteDataSource] ApiResponse parsed:');
      print('  - Success: ${apiResponse.success}');
      print('  - Message: ${apiResponse.message}');
      print('  - Result type: ${apiResponse.result.runtimeType}');

      if (!apiResponse.success) {
        print(
          '[MortgageRemoteDataSource] API returned error: ${apiResponse.message}',
        );
        throw ValidationException(
          apiResponse.message ?? 'Sorov bajarilmadi',
          statusCode: response.statusCode,
        );
      }

      final result = apiResponse.result;
      print('[MortgageRemoteDataSource] Result extracted:');
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
          name: 'MortgageRemoteDataSource',
        );
        return MortgagePageModel(
          content: const <MortgageModel>[],
          totalPages: 0,
          totalElements: 0,
          number: 0,
          size: size,
          first: true,
          last: true,
          numberOfElements: 0,
        );
      }

      print('[MortgageRemoteDataSource] Parsing result: ${result.keys}');
      print('[MortgageRemoteDataSource] Result type: ${result.runtimeType}');

      final parsed = MortgagePageModel.fromJson(result);

      print('[MortgageRemoteDataSource] Parsed successfully:');
      print('  - Total items: ${parsed.content.length}');
      print('  - Page: ${parsed.number}');
      print('  - Total pages: ${parsed.totalPages}');
      print('  - Total elements: ${parsed.totalElements}');
      print('  - Is last: ${parsed.last}');

      if (parsed.content.isNotEmpty) {
        print(
          '[MortgageRemoteDataSource] First item: ${parsed.content.first.bankName} - ${parsed.content.first.description}',
        );
      }

      developer.log(
        'API success items=${parsed.content.length} page=${parsed.number} isLast=${parsed.last}',
        name: 'MortgageRemoteDataSource',
      );
      return parsed;
    } on DioException catch (error) {
      final mapped = _mapDioError(error);
      developer.log(
        'Dio error',
        name: 'MortgageRemoteDataSource',
        error: mapped,
        stackTrace: error.stackTrace,
      );
      throw mapped;
    } catch (error, stackTrace) {
      if (error is AppException) {
        developer.log(
          'Known AppException',
          name: 'MortgageRemoteDataSource',
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      }
      developer.log(
        'Unknown error',
        name: 'MortgageRemoteDataSource',
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

