import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/microcredit_filter.dart';
import '../models/microcredit_model.dart';
import '../models/microcredit_page_model.dart';

abstract class MicrocreditRemoteDataSource {
  Future<MicrocreditPageModel> getMicrocredits({
    required int page,
    required int size,
    MicrocreditFilter filter,
  });
}

class MicrocreditRemoteDataSourceImpl implements MicrocreditRemoteDataSource {
  MicrocreditRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<MicrocreditPageModel> getMicrocredits({
    required int page,
    required int size,
    MicrocreditFilter filter = MicrocreditFilter.empty,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'size': size,
        ...filter.toQueryParameters(),
      };

      print('[MicrocreditRemoteDataSource] Fetching microcredits:');
      print('  - URL: ${ApiPaths.getMicrocredits}');
      print('  - Base URL: ${ApiConstants.effectiveBaseUrl}');
      print('  - Page: $page, Size: $size');
      print('  - Query params: $query');

      developer.log(
        'Fetching microcredits page=$page size=$size query=$query',
        name: 'MicrocreditRemoteDataSource',
      );

      final response = await _dio.get(
        ApiPaths.getMicrocredits,
        queryParameters: query,
      );

      print('[MicrocreditRemoteDataSource] Response received:');
      print('  - Status: ${response.statusCode}');
      print('  - Data type: ${response.data.runtimeType}');

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const AppException(message: 'Server notogri malumot qaytardi');
      }

      print('[MicrocreditRemoteDataSource] Parsing ApiResponse...');

      final apiResponse = ApiResponse.fromJson(
        data,
        (json) => json as Map<String, dynamic>,
      );

      print('[MicrocreditRemoteDataSource] ApiResponse parsed:');
      print('  - Success: ${apiResponse.success}');
      print('  - Message: ${apiResponse.message}');
      print('  - Result type: ${apiResponse.result.runtimeType}');

      if (!apiResponse.success) {
        print(
          '[MicrocreditRemoteDataSource] API returned error: ${apiResponse.message}',
        );
        throw ValidationException(
          message: apiResponse.message ?? 'Sorov bajarilmadi',
          statusCode: response.statusCode,
          details: data,
        );
      }

      final result = apiResponse.result;
      print('[MicrocreditRemoteDataSource] Result extracted:');
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
          name: 'MicrocreditRemoteDataSource',
        );
        return MicrocreditPageModel(
          content: const <MicrocreditModel>[],
          totalPages: 0,
          totalElements: 0,
          number: 0,
          size: size,
          first: true,
          last: true,
          numberOfElements: 0,
        );
      }

      print('[MicrocreditRemoteDataSource] Parsing result: ${result.keys}');
      print('[MicrocreditRemoteDataSource] Result type: ${result.runtimeType}');

      final parsed = MicrocreditPageModel.fromJson(result);

      print('[MicrocreditRemoteDataSource] Parsed successfully:');
      print('  - Total items: ${parsed.content.length}');
      print('  - Page: ${parsed.number}');
      print('  - Total pages: ${parsed.totalPages}');
      print('  - Total elements: ${parsed.totalElements}');
      print('  - Is last: ${parsed.last}');

      if (parsed.content.isNotEmpty) {
        print(
          '[MicrocreditRemoteDataSource] First item: ${parsed.content.first.bankName} - ${parsed.content.first.description}',
        );
      }

      developer.log(
        'API success items=${parsed.content.length} page=${parsed.number} isLast=${parsed.last}',
        name: 'MicrocreditRemoteDataSource',
      );
      return parsed;
    } on DioException catch (error) {
      final mapped = _mapDioError(error);
      developer.log(
        'Dio error',
        name: 'MicrocreditRemoteDataSource',
        error: mapped,
        stackTrace: error.stackTrace,
      );
      throw mapped;
    } catch (error, stackTrace) {
      if (error is AppException) {
        developer.log(
          'Known AppException',
          name: 'MicrocreditRemoteDataSource',
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      }
      developer.log(
        'Unknown error',
        name: 'MicrocreditRemoteDataSource',
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

