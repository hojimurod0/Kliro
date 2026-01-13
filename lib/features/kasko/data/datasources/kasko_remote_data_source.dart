import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/retry_helper.dart';
import '../models/car_model.dart';
import '../models/car_page_model.dart';
import '../models/calculate_request.dart';
import '../models/calculate_response.dart';
import '../models/car_price_request.dart';
import '../models/car_price_response.dart';
import '../models/check_payment_request.dart';
import '../models/check_payment_response.dart';
import '../models/image_upload_response.dart';
import '../models/payment_link_request.dart';
import '../models/payment_link_response.dart';
import '../models/rate_model.dart';
import '../models/save_order_request.dart';
import '../models/save_order_response.dart';

abstract class KaskoRemoteDataSource {
  Future<List<CarModel>> getCars();
  Future<CarPageModel> getCarsPaginated({
    required int page,
    required int size,
  });
  Future<List<CarModel>> getCarsMinimal(); // Faqat brand, model, position uchun
  Future<List<RateModel>> getRates();
  Future<CarPriceResponse> calculateCarPrice(CarPriceRequest request);
  Future<CalculateResponse> calculatePolicy(CalculateRequest request);
  Future<SaveOrderResponse> saveOrder(SaveOrderRequest request);
  Future<PaymentLinkResponse> getPaymentLink(PaymentLinkRequest request);
  Future<CheckPaymentResponse> checkPaymentStatus(CheckPaymentRequest request);
  Future<ImageUploadResponse> uploadImage({
    required File file,
    required String orderId,
    required String imageType,
  });
}

class KaskoRemoteDataSourceImpl implements KaskoRemoteDataSource {
  KaskoRemoteDataSourceImpl(this._dio);

  final Dio _dio;
  static const bool _enableRatesDebugLogs = false;

  @override
  Future<List<CarModel>> getCars() async {
    try {
      // MUHIM: Raw JSON string olish uchun ResponseType.plain ishlatamiz
      // Bu Dio'ning avtomatik JSON parsing'ini o'chirib qo'yadi
      final response = await RetryHelper.retry(
        operation: () => _dio.get(
          ApiPaths.kaskoCars,
          options: Options(
            responseType: ResponseType.plain, // Raw string olish
          ),
        ),
        maxRetries: 3,
        delay: const Duration(seconds: 1),
      );

      final responseString = response.data as String?;

      // Response tekshiruvi
      if (responseString == null || responseString.isEmpty) {
        throw const ApiException(message: 'Server response is null or empty');
      }

      // MUHIM: Katta JSON parsing'ni isolate'ga ko'chirish
      // Bu main thread'ni bloklamaydi va UI qotib qolmaydi
      // JSON string'ni Dart obyektlariga o'girish isolate'da bajariladi
      try {
        return await compute(_parseCarsDataFromJson, responseString);
      } catch (e) {
        // compute() funksiyasidan kelgan exception'larni catch qilish
        if (e is FormatException) {
          throw ApiException(message: 'Invalid JSON format: ${e.message}');
        }
        throw AppException(
          message: 'Failed to parse cars data: ${e.toString()}',
        );
      }
    } on DioException catch (error) {
      _handleDioError(error);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: 'Failed to fetch cars data: ${e.toString()}');
    }
  }

  @override
  Future<CarPageModel> getCarsPaginated({
    required int page,
    required int size,
  }) async {
    try {
      // Pagination parametrlarini query'ga qo'shish
      final queryParameters = <String, dynamic>{
        'page': page,
        'size': size,
      };

      final response = await RetryHelper.retry(
        operation: () => _dio.get(
          ApiPaths.kaskoCars,
          queryParameters: queryParameters,
          options: Options(
            responseType: ResponseType.json, // Pagination uchun JSON response
          ),
        ),
        maxRetries: 3,
        delay: const Duration(seconds: 1),
      );

      final responseData = response.data;

      // Response tekshiruvi
      if (responseData == null) {
        throw const ApiException(message: 'Server response is null or empty');
      }

      // Agar API pagination qo'llab-quvvatlasa, CarPageModel qaytaramiz
      if (responseData is Map<String, dynamic>) {
        // API pagination formatini tekshirish
        if (responseData.containsKey('content') ||
            responseData.containsKey('total_pages') ||
            responseData.containsKey('total_elements')) {
          // Server-side pagination
          return CarPageModel.fromJson(responseData);
        }
      }

      // Agar API pagination qo'llab-quvvatlamasa, client-side pagination
      // Barcha ma'lumotlarni olamiz va client-side pagination qilamiz
      final allCars = await getCars();
      final totalElements = allCars.length;
      final totalPages = (totalElements / size).ceil();
      final startIndex = page * size;
      final endIndex = (startIndex + size).clamp(0, totalElements);
      final paginatedCars = allCars.sublist(
        startIndex.clamp(0, totalElements),
        endIndex,
      );

      return CarPageModel(
        content: paginatedCars,
        totalPages: totalPages,
        totalElements: totalElements,
        number: page,
        size: size,
        first: page == 0,
        last: page >= totalPages - 1,
        numberOfElements: paginatedCars.length,
      );
    } on DioException catch (error) {
      _handleDioError(error);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Failed to fetch cars data with pagination: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<CarModel>> getCarsMinimal() async {
    // Minimal endpoint - faqat brand, model, position uchun
    // Agar backend qo'llab-quvvatlamasa, hozirgi API'dan kelgan ma'lumotlardan faqat kerakli qismlarni olamiz
    try {
      final response = await RetryHelper.retry(
        operation: () => _dio.get(
          ApiPaths.kaskoCarsMinimal,
          options: Options(responseType: ResponseType.plain),
        ),
        maxRetries: 3,
        delay: const Duration(seconds: 1),
      );

      final responseString = response.data as String?;

      if (responseString == null || responseString.isEmpty) {
        throw const ApiException(message: 'Server response is null or empty');
      }

      try {
        return await compute(_parseCarsDataFromJson, responseString);
      } catch (e) {
        if (e is FormatException) {
          throw ApiException(message: 'Invalid JSON format: ${e.message}');
        }
        throw AppException(
          message: 'Failed to parse cars minimal data: ${e.toString()}',
        );
      }
    } on DioException catch (error) {
      // Agar minimal endpoint yo'q bo'lsa (404), to'liq API'dan olamiz va faqat kerakli qismlarni qaytaramiz
      if (error.response?.statusCode == 404) {
        // Fallback: to'liq API'dan olamiz va faqat unique brand, model, position kombinatsiyalarini qaytaramiz
        final allCars = await getCars();
        // Faqat unique brand, model, position kombinatsiyalarini qaytaramiz
        final uniqueCars = <String, CarModel>{};
        for (final car in allCars) {
          final key = '${car.brand}_${car.model}_${car.name}';
          if (!uniqueCars.containsKey(key)) {
            uniqueCars[key] = car;
          }
        }
        return uniqueCars.values.toList();
      }
      _handleDioError(error);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Failed to fetch cars minimal data: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<RateModel>> getRates() async {
    try {
      if (_enableRatesDebugLogs) {
        debugPrint('🌐 Starting GET request to: ${ApiPaths.kaskoRates}');
      }

      // MUHIM: Raw JSON string olish uchun ResponseType.plain ishlatamiz
      // RetryHelper qo'shildi - network xatoliklarda avtomatik qayta urinish
      final response = await RetryHelper.retry(
        operation: () => _dio.get(
          ApiPaths.kaskoRates,
          options: Options(
            responseType: ResponseType.plain, // Raw string olish
          ),
        ),
        maxRetries: 3,
        delay: const Duration(seconds: 1),
      );

      if (_enableRatesDebugLogs) {
        debugPrint('✅ GET response received, status: ${response.statusCode}');
      }

      final responseString = response.data as String?;

      if (_enableRatesDebugLogs) {
        debugPrint('📄 Response string length: ${responseString?.length ?? 0}');
        debugPrint(
          '📄 Response string preview: ${responseString?.substring(0, responseString.length > 200 ? 200 : responseString.length)}',
        );
      }

      // Response tekshiruvi
      if (responseString == null || responseString.isEmpty) {
        if (_enableRatesDebugLogs) {
          debugPrint('❌ Response is null or empty');
        }
        throw const ApiException(message: 'Server response is null or empty');
      }

      // MUHIM: Parsing'ni isolate'ga ko'chirish
      // JSON string'ni Dart obyektlariga o'girish isolate'da bajariladi
      try {
        if (_enableRatesDebugLogs) {
          debugPrint('🔄 Starting JSON parsing in isolate...');
        }
        final rates = await compute(_parseRatesDataFromJson, responseString);
        if (_enableRatesDebugLogs) {
          debugPrint('✅ Parsing completed, got ${rates.length} rates');
        }
        return rates;
      } catch (e) {
        if (_enableRatesDebugLogs) {
          debugPrint('❌ Parsing error: $e');
        }
        // compute() funksiyasidan kelgan exception'larni catch qilish
        if (e is FormatException) {
          throw ApiException(message: 'Invalid JSON format: ${e.message}');
        }
        throw ApiException(
          message: 'Failed to parse rates data: ${e.toString()}',
        );
      }
    } on DioException catch (error) {
      if (_enableRatesDebugLogs) {
        AppLogger.debug('DioException: ${error.message}');
        AppLogger.debug('DioException type: ${error.type}');
        AppLogger.debug('DioException response: ${error.response?.data}');
      }
      _handleDioError(error);
    } on ApiException catch (e) {
      if (_enableRatesDebugLogs) {
        AppLogger.debug('ApiException: ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (_enableRatesDebugLogs) {
        AppLogger.debug('Unknown error: $e');
      }
      throw ApiException(
        message: 'Failed to fetch rates data: ${e.toString()}',
      );
    }
  }

  @override
  Future<CarPriceResponse> calculateCarPrice(CarPriceRequest request) async {
    try {
      // MUHIM: Raw JSON string olish uchun ResponseType.plain ishlatamiz
      // Bu Dio'ning avtomatik JSON parsing'ini o'chirib qo'yadi
      final response = await RetryHelper.retry(
        operation: () => _dio.post(
          ApiPaths.kaskoCarPrice,
          data: request.toJson(),
          options: Options(
            responseType: ResponseType.plain, // Raw string olish
          ),
        ),
        maxRetries: 3,
        delay: const Duration(seconds: 1),
      );

      final responseString = response.data as String?;

      // Response tekshiruvi
      if (responseString == null || responseString.isEmpty) {
        throw const ApiException(message: 'Server response is null or empty');
      }

      // MUHIM: Parsing'ni isolate'ga ko'chirish
      // JSON string'ni Dart obyektlariga o'girish isolate'da bajariladi
      try {
        return await compute(_parseCarPriceResponseFromJson, responseString);
      } catch (e) {
        // compute() funksiyasidan kelgan exception'larni catch qilish
        if (e is FormatException) {
          throw ApiException(message: 'Invalid JSON format: ${e.message}');
        }
        throw ApiException(
          message: 'Failed to parse car price response: ${e.toString()}',
        );
      }
    } on DioException catch (error) {
      _handleDioError(error);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: 'Failed to calculate car price: ${e.toString()}',
      );
    }
  }

  @override
  Future<CalculateResponse> calculatePolicy(CalculateRequest request) async {
    try {
      final response = await RetryHelper.retry(
        operation: () => _dio.post(
          ApiPaths.kaskoCalculate,
          data: request.toJson(),
        ),
        maxRetries: 3,
        delay: const Duration(seconds: 1),
      );
      final responseData = _ensureMap(response.data);

      // Nested struktura tekshiruvi
      if (responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          return CalculateResponse.fromJson(data);
        }
        throw const ApiException(message: 'Response data field is not a Map');
      }

      return CalculateResponse.fromJson(responseData);
    } on DioException catch (error) {
      _handleDioError(error);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to calculate policy: ${e.toString()}',
      );
    }
  }

  @override
  Future<SaveOrderResponse> saveOrder(SaveOrderRequest request) async {
    try {
      // Debug: Request ma'lumotlarini ko'rsatish
      AppLogger.debug(
          'SaveOrder Request: ${AppLogger.sanitize(request.toJson().toString())}');

      final response = await RetryHelper.retry(
        operation: () => _dio.post(
          ApiPaths.kaskoSave,
          data: request.toJson(),
        ),
        maxRetries: 3,
        delay: const Duration(seconds: 1),
      );
      final responseData = _ensureMap(response.data);

      // Debug: Response ma'lumotlarini ko'rsatish
      AppLogger.debug(
          'SaveOrder Response: ${AppLogger.sanitize(responseData.toString())}');

      // Nested struktura tekshiruvi - сначала проверяем 'response', потом 'data'
      Map<String, dynamic>? dataToParse;

      if (responseData.containsKey('response')) {
        final responseObj = responseData['response'];
        if (responseObj is Map<String, dynamic>) {
          dataToParse = responseObj;
          AppLogger.debug('SaveOrder response found in "response" field');
        }
      } else if (responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          dataToParse = data;
          AppLogger.debug('SaveOrder response found in "data" field');
        }
      }

      if (dataToParse != null) {
        final result = SaveOrderResponse.fromJson(dataToParse);
        AppLogger.debug('Parsed SaveOrderResponse: orderId=${result.orderId}');
        return result;
      }

      // Fallback - пытаемся парсить сам responseData
      AppLogger.debug('Using fallback parsing from responseData');
      final fallbackResult = SaveOrderResponse.fromJson(responseData);
      AppLogger.debug('Fallback parsed: orderId=${fallbackResult.orderId}');
      return fallbackResult;
    } on DioException catch (error) {
      _handleDioError(error);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to save order: ${e.toString()}');
    }
  }

  @override
  Future<PaymentLinkResponse> getPaymentLink(PaymentLinkRequest request) async {
    try {
      final response = await RetryHelper.retry(
        operation: () => _dio.post(
          ApiPaths.kaskoPaymentLink,
          data: request.toJson(),
        ),
        maxRetries: 3,
        delay: const Duration(seconds: 1),
      );
      final responseData = _ensureMap(response.data);

      // Nested struktura tekshiruvi - сначала проверяем 'response', потом 'data'
      Map<String, dynamic>? dataToParse;

      if (responseData.containsKey('response')) {
        final responseObj = responseData['response'];
        if (responseObj is Map<String, dynamic>) {
          dataToParse = responseObj;
        }
      } else if (responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          dataToParse = data;
        }
      }

      if (dataToParse != null) {
        AppLogger.debug('PaymentLink response found in nested structure');
        try {
          final result = PaymentLinkResponse.fromJson(dataToParse);
          AppLogger.debug(
              'Parsed PaymentLinkResponse: contractId=${result.contractId}');
          return result;
        } catch (e, stackTrace) {
          AppLogger.error('PaymentLinkResponse parsing error', e, stackTrace);
          rethrow;
        }
      }

      // Fallback - пытаемся парсить сам responseData
      AppLogger.debug('Using fallback parsing from responseData');
      try {
        return PaymentLinkResponse.fromJson(responseData);
      } catch (e, stackTrace) {
        AppLogger.error(
            'PaymentLinkResponse fallback parsing error', e, stackTrace);
        rethrow;
      }
    } on DioException catch (error) {
      _handleDioError(error);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to get payment link: ${e.toString()}',
      );
    }
  }

  @override
  Future<CheckPaymentResponse> checkPaymentStatus(
    CheckPaymentRequest request,
  ) async {
    try {
      final response = await RetryHelper.retry(
        operation: () => _dio.post(
          ApiPaths.kaskoCheckPayment,
          data: request.toJson(),
        ),
        maxRetries: 3,
        delay: const Duration(seconds: 1),
      );
      final responseData = _ensureMap(response.data);

      // Nested struktura tekshiruvi
      if (responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          return CheckPaymentResponse.fromJson(data);
        }
        throw const ApiException(message: 'Response data field is not a Map');
      }

      return CheckPaymentResponse.fromJson(responseData);
    } on DioException catch (error) {
      _handleDioError(error);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to check payment status: ${e.toString()}',
      );
    }
  }

  @override
  Future<ImageUploadResponse> uploadImage({
    required File file,
    required String orderId,
    required String imageType,
  }) async {
    try {
      // Filename ni to'g'ri olish (Windows va Unix uchun)
      final filename = file.path.split(Platform.pathSeparator).last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: filename),
        'order_id': orderId,
        'image_type': imageType,
      });

      final response = await _dio.post(
        ApiPaths.kaskoImageUpload,
        data: formData,
      );

      final responseData = response.data;

      // Response tekshiruvi
      if (responseData == null) {
        throw const ApiException(message: 'Server response is null');
      }

      // Map tekshiruvi
      if (responseData is! Map<String, dynamic>) {
        throw ApiException(
          message:
              'Unexpected response format for uploadImage. Expected Map, got ${responseData.runtimeType}',
        );
      }

      // Nested struktura tekshiruvi
      if (responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          return ImageUploadResponse.fromJson(data);
        }
        throw const ApiException(message: 'Response data field is not a Map');
      }

      return ImageUploadResponse.fromJson(responseData);
    } on DioException catch (error) {
      _handleDioError(error);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to upload image: ${e.toString()}');
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

    // 401 - Unauthorized
    if (statusCode == 401) {
      throw UnauthorizedException(message: message, statusCode: statusCode);
    }

    // Network xatoliklar
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      throw NetworkException(message: message, statusCode: statusCode);
    }

    // Server xatoliklar (500, 502, 503, va hokazo)
    if (statusCode != null && statusCode >= 500) {
      throw ServerException(
        message: message,
        statusCode: statusCode,
        details: responseData,
      );
    }

    // API xatoliklar (400, 404, va hokazo)
    if (statusCode != null && statusCode >= 400) {
      throw ApiException(
        message: message,
        statusCode: statusCode,
        details: responseData,
      );
    }

    // Boshqa xatoliklar
    throw AppException(
      message: message,
      statusCode: statusCode,
      details: responseData,
    );
  }
}

// ============================================================================
// Top-level parsing funksiyalari - compute() uchun kerak
// Bu funksiyalar alohida isolate'da bajariladi va main thread'ni bloklamaydi
// ============================================================================

/// Cars ma'lumotlarini JSON string'dan parse qilish (isolate'da bajariladi)
/// Bu funksiya top-level bo'lishi kerak, chunki compute() faqat top-level
/// yoki static funksiyalarni qabul qiladi
///
/// MUHIM: Bu funksiya isolate'da bajariladi va main thread'ni bloklamaydi
///
/// [jsonString] - Server'dan kelgan raw JSON string
///
/// Throws [FormatException] agar JSON noto'g'ri formatda bo'lsa
/// Throws [Exception] agar ma'lumotlar formati noto'g'ri bo'lsa
List<CarModel> _parseCarsDataFromJson(String jsonString) {
  // Avval JSON string'ni Dart obyektiga o'girish (isolate'da)
  // Bu yerda FormatException chiqishi mumkin, agar JSON noto'g'ri bo'lsa
  final responseData = jsonDecode(jsonString) as dynamic;
  // Nested struktura bilan ishlash: cars -> car_models -> car_positions
  List<CarModel> cars = [];

  if (responseData is Map<String, dynamic>) {
    // 'cars' kaliti bor bo'lsa (yangi nested format)
    if (responseData.containsKey('cars')) {
      final carsData = responseData['cars'];
      if (carsData is List) {
        for (final carData in carsData) {
          if (carData is Map<String, dynamic>) {
            final brandName = carData['name'] as String?;
            final carModels = carData['car_models'] as List?;

            if (carModels != null &&
                brandName != null &&
                brandName.isNotEmpty) {
              for (final modelData in carModels) {
                if (modelData is Map<String, dynamic>) {
                  final modelName = modelData['name'] as String?;
                  final carPositions = modelData['car_positions'] as List?;

                  if (carPositions != null &&
                      modelName != null &&
                      modelName.isNotEmpty) {
                    for (final positionData in carPositions) {
                      if (positionData is Map<String, dynamic>) {
                        final positionId = positionData['id'] as int?;
                        final positionName = positionData['name'] as String?;

                        if (positionId != null &&
                            positionName != null &&
                            positionName.isNotEmpty) {
                          // Har bir position uchun alohida CarModel yaratish
                          // positionId = car_position.id (bu car_id sifatida ishlatiladi)
                          cars.add(
                            CarModel(
                              id: positionId,
                              name: positionName, // position name
                              brand: brandName, // brand name
                              model: modelName, // model name
                              year: null,
                            ),
                          );
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }

      if (cars.isNotEmpty) {
        return cars;
      }
    }

    // 'data' kaliti bor bo'lsa (eski format)
    if (responseData.containsKey('data')) {
      final data = responseData['data'];
      if (data is List) {
        return data
            .where((item) => item is Map<String, dynamic>)
            .map((json) => CarModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    }
  }
  // Agar response.data to'g'ridan-to'g'ri List bo'lsa (eski format)
  else if (responseData is List) {
    return responseData
        .where((item) => item is Map<String, dynamic>)
        .map((json) => CarModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  if (cars.isEmpty) {
    throw Exception(
      'Invalid response format. Expected nested structure with cars->car_models->car_positions or List/Map with data key',
    );
  }

  return cars;
}

/// Rates ma'lumotlarini JSON string'dan parse qilish (isolate'da bajariladi)
///
/// MUHIM: Bu funksiya isolate'da bajariladi va main thread'ni bloklamaydi
///
/// [jsonString] - Server'dan kelgan raw JSON string
///
/// Throws [FormatException] agar JSON noto'g'ri formatda bo'lsa
/// Throws [Exception] agar ma'lumotlar formati noto'g'ri bo'lsa
List<RateModel> _parseRatesDataFromJson(String jsonString) {
  // Debug loglar _enableRatesDebugLogs orqali boshqariladi
  if (KaskoRemoteDataSourceImpl._enableRatesDebugLogs) {
    debugPrint('🔄 _parseRatesDataFromJson: Starting to parse JSON string...');
    debugPrint('📄 JSON string length: ${jsonString.length}');
    debugPrint(
      '📄 JSON string preview: ${jsonString.substring(0, jsonString.length > 500 ? 500 : jsonString.length)}',
    );
  }

  // Avval JSON string'ni Dart obyektiga o'girish (isolate'da)
  // Bu yerda FormatException chiqishi mumkin, agar JSON noto'g'ri bo'lsa
  final responseData = jsonDecode(jsonString) as dynamic;
  if (KaskoRemoteDataSourceImpl._enableRatesDebugLogs) {
    debugPrint('✅ JSON decoded successfully, type: ${responseData.runtimeType}');
  }

  // Agar response.data to'g'ridan-to'g'ri List bo'lsa
  if (responseData is List) {
    if (KaskoRemoteDataSourceImpl._enableRatesDebugLogs) {
      debugPrint('📋 Response is a List directly, length: ${responseData.length}');
    }
    return responseData
        .where((item) => item is Map<String, dynamic>)
        .map((json) => RateModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Agar response.data Map bo'lsa
  if (responseData is Map<String, dynamic>) {
    if (KaskoRemoteDataSourceImpl._enableRatesDebugLogs) {
      debugPrint('📋 Response is a Map, keys: ${responseData.keys.toList()}');
    }

    // MUHIM: 'tarif' kalitini birinchi o'rinda tekshirish (yangi API format)
    // Format: {result: true, tarif: [{id: 1, name: "Basic", percent: 1}, ...]}
    if (responseData.containsKey('tarif')) {
      if (KaskoRemoteDataSourceImpl._enableRatesDebugLogs) {
        debugPrint('✅ Found "tarif" key in response');
      }
      final tarif = responseData['tarif'];
      if (KaskoRemoteDataSourceImpl._enableRatesDebugLogs) {
        debugPrint('📋 "tarif" type: ${tarif.runtimeType}');
      }

      if (tarif is List) {
        if (KaskoRemoteDataSourceImpl._enableRatesDebugLogs) {
          debugPrint('✅ "tarif" is a List with ${tarif.length} items');
        }

        final rates = tarif.where((item) => item is Map<String, dynamic>).map((
          json,
        ) {
          // API'dan kelgan format: {id, name, percent}
          // RateModel formatiga moslashtirish
          final Map<String, dynamic> rateJson = Map<String, dynamic>.from(json);

          if (KaskoRemoteDataSourceImpl._enableRatesDebugLogs) {
            debugPrint(
              '📋 Parsing rate: id=${rateJson['id']}, name="${rateJson['name']}", percent=${rateJson['percent']}',
            );
          }

          // description yo'q bo'lsa, default qo'yish
          if (!rateJson.containsKey('description') ||
              rateJson['description'] == null) {
            rateJson['description'] = '';
          }

          // min_premium va max_premium yo'q bo'lsa, null qo'yish
          if (!rateJson.containsKey('min_premium')) {
            rateJson['min_premium'] = null;
          }
          if (!rateJson.containsKey('max_premium')) {
            rateJson['max_premium'] = null;
          }

          // franchise yo'q bo'lsa, 0 qo'yish
          if (!rateJson.containsKey('franchise')) {
            rateJson['franchise'] = 0;
          }

          // Agar API 'price' maydonini yuborsa, uni min_premium sifatida ishlatish
          // Bu foydalanuvchiga so'mda narxni ko'rsatish uchun kerak
          if (rateJson['min_premium'] == null &&
              rateJson.containsKey('price') &&
              rateJson['price'] != null) {
            final price = rateJson['price'];
            if (price is num) {
              rateJson['min_premium'] = price.toDouble();
            } else {
              final parsed = double.tryParse(price.toString());
              if (parsed != null) {
                rateJson['min_premium'] = parsed;
              }
            }
          }

          // percent field'i bor bo'lsa, uni saqlash
          // (percent allaqachon API'dan keladi: {id: 1, name: "Basic", percent: 1})

          final rateModel = RateModel.fromJson(rateJson);
          if (KaskoRemoteDataSourceImpl._enableRatesDebugLogs) {
            debugPrint(
              '✅ Parsed RateModel: id=${rateModel.id}, name="${rateModel.name}", percent=${rateModel.percent}, description="${rateModel.description}"',
            );
          }
          return rateModel;
        }).toList();

        if (KaskoRemoteDataSourceImpl._enableRatesDebugLogs) {
          debugPrint(
            '✅✅✅ Successfully parsed ${rates.length} rates from "tarif" key',
          );
        }
        return rates;
      } else {
        if (KaskoRemoteDataSourceImpl._enableRatesDebugLogs) {
          debugPrint('⚠️⚠️⚠️ "tarif" is not a List, type: ${tarif.runtimeType}');
        }
      }
    } else {
      if (KaskoRemoteDataSourceImpl._enableRatesDebugLogs) {
        debugPrint(
          '⚠️⚠️⚠️ "tarif" key not found in response. Available keys: ${responseData.keys.toList()}',
        );
      }
    }

    // 'data' kaliti bor bo'lsa (eski format)
    if (responseData.containsKey('data')) {
      if (KaskoRemoteDataSourceImpl._enableRatesDebugLogs) {
        debugPrint('📋 Found "data" key (fallback to old format)');
      }
      final data = responseData['data'];
      if (data is List) {
        return data
            .where((item) => item is Map<String, dynamic>)
            .map((json) => RateModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      if (data is Map<String, dynamic>) {
        // Agar data bitta object bo'lsa, uni listga o'girish
        return [RateModel.fromJson(data)];
      }
    }

    // 'results' kaliti bor bo'lsa
    if (responseData.containsKey('results')) {
      if (KaskoRemoteDataSourceImpl._enableRatesDebugLogs) {
        debugPrint('📋 Found "results" key');
      }
      final results = responseData['results'];
      if (results is List) {
        return results
            .where((item) => item is Map<String, dynamic>)
            .map((json) => RateModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    }
  }

  if (KaskoRemoteDataSourceImpl._enableRatesDebugLogs) {
    debugPrint(
      '❌❌❌ Failed to parse rates. Response type: ${responseData.runtimeType}',
    );
    if (responseData is Map<String, dynamic>) {
      debugPrint('❌ Available keys: ${responseData.keys.toList()}');
    }
  }

  throw Exception(
    'Invalid response format. Expected List or Map with tarif/data/results key, got ${responseData.runtimeType}. Available keys: ${responseData is Map<String, dynamic> ? responseData.keys.toList() : "N/A"}',
  );
}

/// Car price response'ni JSON string'dan parse qilish (isolate'da bajariladi)
///
/// MUHIM: Bu funksiya isolate'da bajariladi va main thread'ni bloklamaydi
///
/// [jsonString] - Server'dan kelgan raw JSON string
///
/// Throws [FormatException] agar JSON noto'g'ri formatda bo'lsa
/// Throws [Exception] agar ma'lumotlar formati noto'g'ri bo'lsa
CarPriceResponse _parseCarPriceResponseFromJson(String jsonString) {
  // Avval JSON string'ni Dart obyektiga o'girish (isolate'da)
  // Bu yerda FormatException chiqishi mumkin, agar JSON noto'g'ri bo'lsa
  final responseData = jsonDecode(jsonString) as dynamic;

  // API response struktura: {result: true, price: 280000000}
  if (responseData is Map<String, dynamic>) {
    // Faqat price maydoni keladi
    final price = responseData['price'];
    if (price == null) {
      throw Exception('Price field is missing in response');
    }

    // Price ni double ga o'girish
    final priceValue =
        (price is num) ? price.toDouble() : double.tryParse(price.toString());
    if (priceValue == null) {
      throw Exception('Invalid price format in response: $price');
    }

    return CarPriceResponse(
      price: priceValue,
      carId: null, // API response'da yo'q
      year: null, // API response'da yo'q
      currency: null,
    );
  }

  throw Exception(
    'Invalid response format. Expected Map, got ${responseData.runtimeType}',
  );
}
