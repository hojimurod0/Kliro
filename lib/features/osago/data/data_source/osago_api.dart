import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../utils/osago_utils.dart';
import '../models/calc_request.dart';
import '../models/calc_response.dart';
import '../models/check_request.dart';
import '../models/check_response.dart';
import '../models/create_request.dart';
import '../models/create_response.dart';
import '../models/vehicle_model.dart';

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

      // Debug: API dan kelgan amount ni log qilish
      print(
        '[OSAGO_API] amount_uzs from API: $amountUzs (type: ${amountUzs.runtimeType})',
      );
      print('[OSAGO_API] Full calcData: $calcData');

      // Извлекаем имя владельца из calc response
      String? ownerName;
      String? numberDriversId;
      VehicleModel? vehicleModel;
      String? modelName;
      int? issueYear;

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

      // Извлекаем данные из data.juridik (juridik находится на уровне data, а не calc)
      final juridik = dataMap['juridik'] as Map<String, dynamic>?;
      String? brandName;
      DateTime? ownerBirthDate;
      if (juridik != null) {
        // Извлекаем имя владельца
        if (ownerName == null || ownerName.isEmpty) {
          ownerName = juridik['name'] as String?;
        }
        // Извлекаем модель машины
        modelName = juridik['modelName'] as String?;
        // Извлекаем год выпуска
        final year = juridik['issueYear'];
        if (year != null) {
          issueYear = year is int ? year : int.tryParse(year.toString());
        }
        // Извлекаем дату рождения из PINFL
        final pinfl = juridik['pinfl'] as String?;
        if (pinfl != null && pinfl.isNotEmpty) {
          // Используем OsagoUtils для парсинга даты из PINFL
          ownerBirthDate = _parseBirthDateFromPinfl(pinfl);
        }
      }

      // Создаем VehicleModel с данными из juridik и requestsData
      if (requestsData != null) {
        try {
          // Определяем дату рождения: сначала из PINFL, если нет - используем текущую дату
          final birthDate = ownerBirthDate ?? DateTime.now();

          // Создаем временный Map для VehicleModel
          final vehicleData = <String, dynamic>{
            'gos_number': requestsData['gos_number'] ?? '',
            'tech_sery': requestsData['tech_sery'] ?? '',
            'tech_number': requestsData['tech_number'] ?? '',
            'owner__pass_seria': requestsData['owner__pass_seria'] ?? '',
            'owner__pass_number': requestsData['owner__pass_number'] ?? '',
            'owner_birth_date': _formatOsagoDate(birthDate),
            'brand': brandName ?? '', // Brand из juridik, если есть
            'model': modelName ?? '', // Используем modelName из juridik
          };

          vehicleModel = VehicleModel.fromJson(vehicleData);
        } catch (e) {
          // E'tiborsiz qoldiramiz
        }
      }

      // Agar vehicle dataMap['vehicle'] da bo'lsa, undan foydalanish
      if (vehicleModel == null && dataMap.containsKey('vehicle')) {
        final vehicleData = dataMap['vehicle'] as Map<String, dynamic>?;
        if (vehicleData != null) {
          try {
            vehicleModel = VehicleModel.fromJson(vehicleData);
            // Обновляем model из juridik, если есть
            if (modelName != null && modelName.isNotEmpty) {
              vehicleModel = vehicleModel.copyWith(model: modelName);
            }
          } catch (e) {
            // E'tiborsiz qoldiramiz
          }
        }
      } else if (vehicleModel != null) {
        // Обновляем model и brand из juridik
        try {
          vehicleModel = vehicleModel.copyWith(
            model: modelName ?? vehicleModel.model,
            brand: brandName ?? vehicleModel.brand,
          );
        } catch (e) {
          // E'tiborsiz qoldiramiz
        }
      }

      return CalcResponse(
        sessionId: sessionId,
        amount: amountUzs.toDouble(),
        currency: 'UZS',
        provider: null,
        vehicle: vehicleModel,
        insurance: null,
        availableProviders: const [],
        ownerName: ownerName,
        numberDriversId: numberDriversId,
        issueYear: issueYear,
      );
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  Future<CreateResponse> create(CreateRequest data) async {
    try {
      final jsonData = data.toJson();
      
      // Debug: number_drivers_id va provider ni log qilish
      print('[OSAGO_API] Create Request: provider=${jsonData['provider']}, number_drivers_id=${jsonData['number_drivers_id']}');
      
      // Debug: Sanani tekshirish
      if (jsonData['drivers'] != null && (jsonData['drivers'] as List).isNotEmpty) {
        final firstDriver = (jsonData['drivers'] as List).first;
        if (firstDriver is Map) {
          print('[OSAGO_API] Driver birthday format: ${firstDriver['driver_birthday']}');
          print('[OSAGO_API] Driver license: seria=${firstDriver['license__seria']}, number=${firstDriver['license__number']}');
        }
      }
      
      // To'liq JSON ni log qilish (debug uchun)
      print('[OSAGO_API] Create Request JSON (before sending): $jsonData');
      
      final response = await _dio.post(
        ApiPaths.osagoCreate,
        data: jsonData,
      );
      final responseData = _ensureMap(response.data);
      // Backenddan kelgan javobni to'liq log qilish
      // (xususan, drivers va requestsData ni ko'rish uchun)
      // Eslatma: bu faqat debug uchun, productionda o'chirish mumkin
      // ignore: avoid_print
      print('[OSAGO_API] Create raw response: $responseData');
      final success = responseData['success'] == true;
      if (!success) {
        // Agar success=false bo'lsa, haydovchi ma'lumotlari va requestsData ni alohida log qilamiz
        final dataMap = responseData['data'] as Map<String, dynamic>?;
        Map<String, dynamic>? requestsData;
        List<dynamic>? drivers;
        if (dataMap != null) {
          final rd = dataMap['requestsData'];
          if (rd is Map<String, dynamic>) {
            requestsData = rd;
            final d = requestsData['drivers'];
            if (d is List) {
              drivers = d;
            }
          }
        }
        // ignore: avoid_print
        print(
          '[OSAGO_API] Create error: message=${responseData['message']}, '
          'requestsData=$requestsData, drivers=$drivers',
        );
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

  /// PINFL dan tug'ilgan sanani olish
  DateTime? _parseBirthDateFromPinfl(String? pinfl) {
    return OsagoUtils.parseBirthDateFromPinfl(pinfl);
  }

  /// Sana formatini API uchun (dd.MM.yyyy)
  String _formatOsagoDate(DateTime date) {
    final formatter = DateFormat('dd.MM.yyyy');
    return formatter.format(date);
  }
}
