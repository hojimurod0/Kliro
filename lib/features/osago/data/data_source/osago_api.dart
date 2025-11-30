import 'package:dio/dio.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/calc_request.dart';
import '../models/calc_response.dart';
import '../models/check_request.dart';
import '../models/check_response.dart';
import '../models/create_request.dart';
import '../models/create_response.dart';

class OsagoApi {
  OsagoApi(this._dio);

  final Dio _dio;

  Future<CalcResponse> calc(CalcRequest data) async {
    try {
      final response = await _dio.post(ApiPaths.osagoCalc, data: data.toJson());
      final responseData = _ensureMap(response.data);
      final success = responseData['success'] == true;
      if (!success) {
        throw ValidationException(
          message: responseData['message'] as String? ?? 'Request failed',
          details: responseData,
          statusCode: response.statusCode,
        );
      }
      final dataMap = responseData['data'] as Map<String, dynamic>?;
      if (dataMap == null) {
        throw const AppException(message: 'Missing response data');
      }
      final calcData = dataMap['calc'] as Map<String, dynamic>?;
      final sessionId = dataMap['session_id'] as String?;
      if (sessionId == null) {
        throw const AppException(message: 'Missing session_id');
      }
      final amountUzs = calcData?['amount_uzs'] as num?;
      if (amountUzs == null) {
        throw const AppException(message: 'Missing amount_uzs');
      }
      
      // Извлекаем имя владельца из calc response
      String? ownerName;
      String? numberDriversId;
      
      // requestsData ni to'g'ridan-to'g'ri dataMap dan olamiz (calc ichida emas)
      // Logga ko'ra: data.requestsData.number_drivers_id = 5
      final requestsData = dataMap['requestsData'] as Map<String, dynamic>?;
      if (requestsData != null) {
        // Извлекаем number_drivers_id из requestsData
        final requestsNumberDriversId = requestsData['number_drivers_id'];
        if (requestsNumberDriversId != null) {
          final idStr = requestsNumberDriversId.toString().trim();
          // Validate: faqat '0' yoki '5' qabul qilinadi
          if (idStr == '0' || idStr == '5') {
            numberDriversId = idStr;
          }
        }
        final requestsOwnerName = requestsData['owner_name'] as String?;
        if (requestsOwnerName != null && requestsOwnerName.isNotEmpty) {
          ownerName = requestsOwnerName;
        }
      }
      
      // Проверяем различные возможные пути к имени
      if (calcData != null) {
        // Вариант 1: calc.juridik.name
        final juridik = calcData['juridik'] as Map<String, dynamic>?;
        if (juridik != null) {
          if (ownerName == null || ownerName.isEmpty) {
            ownerName = juridik['name'] as String?;
          }
        }
        // Вариант 2: calc.requestsData (agar yuqorida topilmagan bo'lsa)
        final calcRequestsData = calcData['requestsData'] as Map<String, dynamic>?;
        if (calcRequestsData != null) {
          if (ownerName == null || ownerName.isEmpty) {
            ownerName = calcRequestsData['owner_name'] as String?;
          }
          // Извлекаем number_drivers_id из calc.requestsData (agar yuqorida topilmagan bo'lsa)
          if (numberDriversId == null || numberDriversId.isEmpty) {
            final calcRequestsNumberDriversId = calcRequestsData['number_drivers_id'];
            if (calcRequestsNumberDriversId != null) {
              final idStr = calcRequestsNumberDriversId.toString().trim();
              if (idStr == '0' || idStr == '5') {
                numberDriversId = idStr;
              }
            }
          }
        }
        // Вариант 3: calc.name (прямо в calc)
        if (ownerName == null || ownerName.isEmpty) {
          ownerName = calcData['name'] as String?;
        }
      }
      
      return CalcResponse(
        sessionId: sessionId,
        amount: amountUzs.toDouble(),
        currency: 'UZS',
        provider: null,
        vehicle: null,
        insurance: null,
        availableProviders: const [],
        ownerName: ownerName,
        numberDriversId: numberDriversId,
      );
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  Future<CreateResponse> create(CreateRequest data) async {
    try {
      final response = await _dio.post(
        ApiPaths.osagoCreate,
        data: data.toJson(),
      );
      final responseData = _ensureMap(response.data);
      final success = responseData['success'] == true;
      if (!success) {
        throw ValidationException(
          message: responseData['message'] as String? ?? 'Request failed',
          details: responseData,
          statusCode: response.statusCode,
        );
      }
      final dataMap = responseData['data'] as Map<String, dynamic>?;
      if (dataMap == null) {
        throw const AppException(message: 'Missing response data');
      }
      
      // Извлекаем данные из объекта response, если он есть
      final responseObj = dataMap['response'] as Map<String, dynamic>?;
      final amountUzs = responseObj?['amount_uzs'] as num?;
      
      // Создаем модифицированную карту для парсинга
      final modifiedDataMap = Map<String, dynamic>.from(dataMap);
      
      // Если session_id отсутствует в ответе, используем его из запроса
      if (!modifiedDataMap.containsKey('session_id')) {
        modifiedDataMap['session_id'] = data.sessionId;
      }
      
      // Добавляем amount из response, если он есть
      if (amountUzs != null) {
        modifiedDataMap['amount'] = amountUzs.toDouble();
      }
      
      // Добавляем currency, если его нет
      if (!modifiedDataMap.containsKey('currency')) {
        modifiedDataMap['currency'] = 'UZS';
      }
      
      try {
        return CreateResponse.fromJson(modifiedDataMap);
      } catch (e) {
        // Если парсинг не удался, выбрасываем более понятную ошибку
        throw AppException(
          message: 'Javobni qayta ishlashda xatolik: ${e.toString()}',
          details: modifiedDataMap,
        );
      }
    } on DioException catch (error) {
      _handleDioError(error);
    } on AppException {
      rethrow;
    } catch (error) {
      throw AppException(
        message: 'Noma\'lum xatolik yuz berdi: ${error.toString()}',
        details: error,
      );
    }
  }

  Future<CheckResponse> check(CheckRequest data) async {
    try {
      final response = await _dio.post(
        ApiPaths.osagoCheck,
        data: data.toJson(),
      );
      final responseData = _ensureMap(response.data);
      final success = responseData['success'] == true;
      if (!success) {
        throw ValidationException(
          message: responseData['message'] as String? ?? 'Request failed',
          details: responseData,
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
      serverMessage = responseData['message'] as String?;
    } else if (responseData is String) {
      serverMessage = responseData;
    }
    final fallbackMessage = error.message ?? 'Request failed';
    final message = serverMessage ?? fallbackMessage;
    if (statusCode == 401) {
      throw UnauthorizedException(message: message, statusCode: statusCode);
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
