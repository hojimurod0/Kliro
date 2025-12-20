import 'package:dio/dio.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../../core/errors/app_exception.dart';
import '../models/calc_request.dart';
import '../models/calc_response.dart';
import '../models/check_request.dart';
import '../models/check_response.dart';
import '../models/create_request.dart';
import '../models/create_response.dart';
import '../models/purpose_request.dart';
import '../models/purpose_response.dart';
import '../models/details_request.dart';
import '../models/country_model.dart';
import '../models/purpose_model.dart';
import '../models/tarif_request.dart';
import '../models/tarif_response.dart';

class TravelApi {
  TravelApi(this._dio);

  final Dio _dio;

  Future<CalcResponse> calc(CalcRequest data) async {
    try {
      final response = await _dio.post(
        ApiPaths.travelCalc,
        data: data.toJson(),
      );
      final responseData = _ensureMap(response.data);
      final success = responseData['success'] == true;
      if (!success) {
        throw ValidationException(
          responseData['message'] as String? ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }
      // ✅ YANGI FORMAT: result to'g'ridan-to'g'ri response'da
      // Response format: {result: {apex: {programs: []}}, success: true}
      // Session ID request'dan olinadi
      final result = responseData['result'] as Map<String, dynamic>?;
      if (result != null) {
        // Session ID ni request'dan qo'shamiz
        final jsonWithSessionId = {
          ...responseData,
          'session_id': data.sessionId,
        };
        // ✅ programId ni data'dan olish (agar mavjud bo'lsa)
        final programId = data.programId;
        return CalcResponse.fromJson(jsonWithSessionId, programId: programId);
      }
      
      // Eski format uchun fallback
      final dataMap = responseData['data'] as Map<String, dynamic>?;
      if (dataMap != null) {
        return CalcResponse.fromJson(dataMap, programId: data.programId);
      }
      
      throw const AppException(message: 'Missing response data');
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  Future<CreateResponse> create(CreateRequest data) async {
    try {
      final response = await _dio.post(
        ApiPaths.travelCreate,
        data: data.toJson(),
      );
      final responseData = _ensureMap(response.data);
      final success = responseData['success'] == true;
      if (!success) {
        throw ValidationException(
          responseData['message'] as String? ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }
      // ✅ YANGI FORMAT: result to'g'ridan-to'g'ri response'da
      // Response format: {result: {provider: "apex", response: {...}, session_id: "..."}, success: true}
      final result = responseData['result'] as Map<String, dynamic>?;
      if (result != null) {
        return CreateResponse.fromJson(responseData);
      }
      
      // Eski format uchun fallback
      final dataMap = responseData['data'] as Map<String, dynamic>?;
      if (dataMap != null) {
        return CreateResponse.fromJson(dataMap);
      }
      
      throw const AppException(message: 'Missing response data');
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  Future<CheckResponse> check(CheckRequest data) async {
    try {
      final response = await _dio.post(
        ApiPaths.travelCheck,
        data: data.toJson(),
      );
      final responseData = _ensureMap(response.data);
      final success = responseData['success'] == true;
      if (!success) {
        throw ValidationException(
          responseData['message'] as String? ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }
      final dataMap = responseData['data'] as Map<String, dynamic>?;
      if (dataMap == null) {
        throw const AppException(message: 'Missing response data');
      }
      return CheckResponse.fromJson(dataMap);
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  Future<PurposeResponse> createPurpose(PurposeRequest data) async {
    try {
      final response = await _dio.post(
        ApiPaths.travelPurpose,
        data: data.toJson(),
      );
      final responseData = _ensureMap(response.data);
      return PurposeResponse.fromJson(responseData);
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  Future<void> sendDetails(DetailsRequest data) async {
    try {
      final response = await _dio.post(
        ApiPaths.travelDetails,
        data: data.toJson(),
      );
      final responseData = _ensureMap(response.data);
      final success = responseData['success'] == true;
      if (!success) {
        throw ValidationException(
          responseData['message'] as String? ?? 'Request failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  Future<List<CountryModel>> getCountries() async {
    try {
      final response = await _dio.get(ApiPaths.travelCountry);
      final responseData = response.data;

      if (responseData is List) {
        return responseData
            .map((item) => CountryModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      if (responseData is Map<String, dynamic>) {
        List<dynamic>? countries;

        // Проверяем result.country (формат: {result: {country: [...]}})
        if (responseData.containsKey('result') &&
            responseData['result'] is Map<String, dynamic>) {
          final result = responseData['result'] as Map<String, dynamic>;
          if (result.containsKey('country') && result['country'] is List) {
            countries = result['country'] as List;
          }
        }

        // Проверяем result как список
        if (countries == null &&
            responseData.containsKey('result') &&
            responseData['result'] is List) {
          countries = responseData['result'] as List;
        }

        // Проверяем data
        if (countries == null &&
            responseData.containsKey('data') &&
            responseData['data'] is List) {
          countries = responseData['data'] as List;
        }

        // Проверяем countries
        if (countries == null &&
            responseData.containsKey('countries') &&
            responseData['countries'] is List) {
          countries = responseData['countries'] as List;
        }

        if (countries != null) {
          return countries
              .map(
                (item) => CountryModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
      }

      throw const AppException(message: 'Неверный формат ответа сервера');
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  Future<List<PurposeModel>> getPurposes() async {
    try {
      final response = await _dio.get(ApiPaths.travelPurposes);
      final responseData = response.data;

      if (responseData is List) {
        return responseData
            .map((item) => PurposeModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      if (responseData is Map<String, dynamic>) {
        List<dynamic>? purposes;

        // Проверяем result.purpose (формат: {result: {purpose: [...]}})
        if (responseData.containsKey('result') &&
            responseData['result'] is Map<String, dynamic>) {
          final result = responseData['result'] as Map<String, dynamic>;
          if (result.containsKey('purpose') && result['purpose'] is List) {
            purposes = result['purpose'] as List;
          }
        }

        // Проверяем result как список
        if (purposes == null &&
            responseData.containsKey('result') &&
            responseData['result'] is List) {
          purposes = responseData['result'] as List;
        }

        // Проверяем data
        if (purposes == null &&
            responseData.containsKey('data') &&
            responseData['data'] is List) {
          purposes = responseData['data'] as List;
        }

        // Проверяем purposes
        if (purposes == null &&
            responseData.containsKey('purposes') &&
            responseData['purposes'] is List) {
          purposes = responseData['purposes'] as List;
        }

        if (purposes != null) {
          return purposes
              .map(
                (item) => PurposeModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
      }

      throw const AppException(message: 'Неверный формат ответа сервера');
    } on DioException catch (error) {
      // 404 xatolikni maxsus qayta ishlash (endpoint mavjud emas)
      if (error.response?.statusCode == 404) {
        return []; // Bo'sh ro'yxat qaytaradi, bloc fallback ma'lumotlardan foydalanadi
      }
      _handleDioError(error);
    }
  }

  Future<TarifResponse> getTarifs(TarifRequest data) async {
    try {
      final response = await _dio.post(
        ApiPaths.travelTarifs,
        data: data.toJson(),
      );
      final responseData = _ensureMap(response.data);
      
      // Проверяем success и error в ответе
      if (responseData.containsKey('success') && responseData['success'] == false) {
        final errorMessage = responseData['error'] as String? ?? 
                           responseData['message'] as String? ?? 
                           'Tariflar topilmadi';
        throw ValidationException(
          errorMessage,
          statusCode: response.statusCode,
        );
      }
      
      return TarifResponse.fromJson(responseData);
    } on DioException catch (error) {
      // Обрабатываем ошибки 400 с детальным сообщением
      if (error.response?.statusCode == 400) {
        final responseData = error.response?.data;
        if (responseData is Map<String, dynamic>) {
          final errorMessage = responseData['error'] as String? ?? 
                             responseData['message'] as String? ?? 
                             'Tariflar topilmadi';
          throw ValidationException(
            errorMessage,
            statusCode: 400,
          );
        }
      }
      _handleDioError(error);
    }
  }

  Map<String, dynamic> _ensureMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const AppException(message: 'Malformed server response');
  }

  Never _handleDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    String? serverMessage;
    if (responseData is Map<String, dynamic>) {
      // Проверяем разные поля для сообщения об ошибке
      serverMessage = responseData['error'] as String? ??
                     responseData['message'] as String? ??
                     responseData['detail'] as String?;
    } else if (responseData is String) {
      serverMessage = responseData;
    }
    final fallbackMessage = error.message ?? 'Request failed';
    final message = serverMessage ?? fallbackMessage;
    if (statusCode == 401) {
      throw UnauthorizedException(message: message, statusCode: statusCode);
    }
    if (statusCode == 400) {
      throw ValidationException(
        message,
        statusCode: statusCode,
      );
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      throw NetworkException(message: message, statusCode: statusCode);
    }
    throw AppException(
      message: message,
      statusCode: statusCode,
      details: responseData,
    );
  }
}
