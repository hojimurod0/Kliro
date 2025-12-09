import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/car_entity.dart';
import '../../domain/entities/calculate_entity.dart';
import '../../domain/entities/car_price_entity.dart';
import '../../domain/entities/check_payment_entity.dart';
import '../../domain/entities/image_upload_entity.dart';
import '../../domain/entities/payment_link_entity.dart';
import '../../domain/entities/rate_entity.dart';
import '../../domain/entities/save_order_entity.dart';
import '../../domain/repositories/kasko_repository.dart';
import '../datasources/kasko_remote_data_source.dart';
import '../models/car_model.dart';
import '../models/car_price_request.dart';
import '../models/car_price_response.dart';
import '../models/calculate_request.dart';
import '../models/calculate_response.dart';
import '../models/check_payment_request.dart';
import '../models/check_payment_response.dart';
import '../models/image_upload_response.dart';
import '../models/payment_link_request.dart';
import '../models/payment_link_response.dart';
import '../models/rate_model.dart';
import '../models/save_order_request.dart';
import '../models/save_order_response.dart';

class KaskoRepositoryImpl implements KaskoRepository {
  KaskoRepositoryImpl(this._remoteDataSource);

  final KaskoRemoteDataSource _remoteDataSource;

  @override
  Future<List<CarEntity>> getCars() async {
    try {
      final models = await _remoteDataSource.getCars();
      return models.map(_mapCarModelToEntity).toList();
    } catch (e) {
      throw AppException(message: 'Failed to get cars: ${e.toString()}');
    }
  }

  @override
  Future<List<CarEntity>> getCarsMinimal() async {
    try {
      final models = await _remoteDataSource.getCarsMinimal();
      return models.map(_mapCarModelToEntity).toList();
    } catch (e) {
      throw AppException(
        message: 'Failed to get cars minimal: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<RateEntity>> getRates() async {
    try {
      final models = await _remoteDataSource.getRates();
      return models.map(_mapRateModelToEntity).toList();
    } catch (e) {
      throw AppException(message: 'Failed to get rates: ${e.toString()}');
    }
  }

  @override
  Future<CarPriceEntity> calculateCarPrice({
    required int carId, // Bu aslida car_position_id
    required int tarifId,
    required int year,
  }) async {
    try {
      final request = CarPriceRequest(
        carPositionId: carId, // car_position_id ni yuborish
        tarifId: tarifId,
        year: year,
      );
      final response = await _remoteDataSource.calculateCarPrice(request);
      // API response'da faqat price keladi, carId va year ni request'dan olamiz
      return _mapCarPriceResponseToEntity(response, carId: carId, year: year);
    } catch (e) {
      throw AppException(
        message: 'Failed to calculate car price: ${e.toString()}',
      );
    }
  }

  @override
  Future<CalculateEntity> calculatePolicy({
    required int carId,
    required int year,
    required double price,
    required DateTime beginDate,
    required DateTime endDate,
    required int driverCount,
    required double franchise,
    int? selectedRateId,
  }) async {
    try {
      final request = CalculateRequest(
        carId: carId,
        year: year,
        price: price,
        beginDate: _formatDate(beginDate),
        endDate: _formatDate(endDate),
        driverCount: driverCount,
        franchise: franchise,
      );
      final response = await _remoteDataSource.calculatePolicy(request);
      return _mapCalculateResponseToEntity(
        response,
        selectedRateId: selectedRateId,
      );
    } catch (e) {
      throw AppException(
        message: 'Failed to calculate policy: ${e.toString()}',
      );
    }
  }

  @override
  Future<SaveOrderEntity> saveOrder({
    required int carId,
    required int year,
    required double price,
    required DateTime beginDate,
    required DateTime endDate,
    required int driverCount,
    required double franchise,
    required double premium,
    required String ownerName,
    required String ownerPhone,
    required String ownerPassport,
    required String carNumber,
    required String vin,
    required String birthDate,
    required int tarifId,
    required int tarifType,
  }) async {
    try {
      // Извлекаем серию и номер паспорта (первые 2 символа - серия, остальные - номер)
      final passportSeries = ownerPassport.length >= 2 
          ? ownerPassport.substring(0, 2).toUpperCase()
          : '';
      final passportNumber = ownerPassport.length > 2 
          ? ownerPassport.substring(2)
          : ownerPassport;

      // Извлекаем телефон без +998
      String phone = ownerPhone;
      if (phone.startsWith('+998')) {
        phone = phone.substring(4);
      } else if (phone.startsWith('998')) {
        phone = phone.substring(3);
      }

      // Преобразуем дату рождения из формата DD/MM/YYYY в DD-MM-YYYY
      String formattedBirthDate = birthDate;
      if (birthDate.contains('/')) {
        formattedBirthDate = birthDate.replaceAll('/', '-');
      }

      // Разделяем VIN на серию (первые 3 символа) и номер (остальные)
      final vinSeria = vin.length >= 3 ? vin.substring(0, 3) : vin;
      final vinNumber = vin.length > 3 ? vin.substring(3) : '';

      // Преобразуем цену в строку
      final priceString = price.toInt().toString();

      // Формируем запрос с новой структурой
      final request = SaveOrderRequest(
        sugurtalovchi: Sugurtalovchi(
          passportSeries: passportSeries,
          passportNumber: passportNumber,
          birthday: formattedBirthDate,
          phone: phone,
        ),
        car: CarData(
          carNomer: carNumber,
          seria: vinSeria,
          number: vinNumber,
          priceOfCar: priceString,
        ),
        beginDate: _formatDateDDMMYYYY(beginDate),
        liability: price.toInt(),
        premium: premium.toInt(),
        tarifId: tarifId,
        tarifType: tarifType,
      );
      final response = await _remoteDataSource.saveOrder(request);
      return _mapSaveOrderResponseToEntity(response);
    } catch (e) {
      throw AppException(message: 'Failed to save order: ${e.toString()}');
    }
  }

  @override
  Future<PaymentLinkEntity> getPaymentLink({
    required String orderId,
    String? contractId,
    required double amount,
    required String returnUrl,
    required String callbackUrl,
  }) async {
    try {
      final request = PaymentLinkRequest(
        orderId: orderId,
        contractId: contractId,
        amount: amount,
        returnUrl: returnUrl,
        callbackUrl: callbackUrl,
      );
      final response = await _remoteDataSource.getPaymentLink(request);
      return _mapPaymentLinkResponseToEntity(response);
    } catch (e) {
      throw AppException(
        message: 'Failed to get payment link: ${e.toString()}',
      );
    }
  }

  @override
  Future<CheckPaymentEntity> checkPaymentStatus({
    required String orderId,
    required String transactionId,
  }) async {
    try {
      final request = CheckPaymentRequest(
        orderId: orderId,
        transactionId: transactionId,
      );
      final response = await _remoteDataSource.checkPaymentStatus(request);
      return _mapCheckPaymentResponseToEntity(response);
    } catch (e) {
      throw AppException(
        message: 'Failed to check payment status: ${e.toString()}',
      );
    }
  }

  @override
  Future<ImageUploadEntity> uploadImage({
    required String filePath,
    required String orderId,
    required String imageType,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw AppException(message: 'File does not exist: $filePath');
      }
      final response = await _remoteDataSource.uploadImage(
        file: file,
        orderId: orderId,
        imageType: imageType,
      );
      return _mapImageUploadResponseToEntity(response);
    } catch (e) {
      throw AppException(message: 'Failed to upload image: ${e.toString()}');
    }
  }

  // Mappers: DTO → Entity
  CarEntity _mapCarModelToEntity(CarModel model) {
    return CarEntity(
      id: model.id,
      name: model.name,
      brand: model.brand,
      model: model.model,
      year: model.year,
    );
  }

  RateEntity _mapRateModelToEntity(RateModel model) {
    return RateEntity(
      id: model.id,
      name: model.name,
      description: model.description,
      minPremium: model.minPremium,
      maxPremium: model.maxPremium,
      franchise: model.franchise,
      percent: model.percent,
    );
  }

  CarPriceEntity _mapCarPriceResponseToEntity(
    CarPriceResponse response, {
    required int carId,
    required int year,
  }) {
    return CarPriceEntity(
      price: response.price,
      carId: carId, // Request'dan olinadi
      year: year, // Request'dan olinadi
      currency: response.currency,
    );
  }

  CalculateEntity _mapCalculateResponseToEntity(
    CalculateResponse response, {
    int? selectedRateId,
  }) {
    // API response format: {result: true, tarif_1: 2310000, tarif_2: 3464000, tarif_3: 5774000, konstruktor: 0}
    // Tanlangan tarif ID'siga mos premium'ni olish
    double? calculatedPremium;
    if (selectedRateId != null) {
      switch (selectedRateId) {
        case 1:
          calculatedPremium = response.tarif1;
          break;
        case 2:
          calculatedPremium = response.tarif2;
          break;
        case 3:
          calculatedPremium = response.tarif3;
          break;
        default:
          calculatedPremium =
              response.tarif1 ?? response.tarif2 ?? response.tarif3;
      }
    } else {
      // Agar tanlangan tarif yo'q bo'lsa, birinchi tarifni ishlatish
      calculatedPremium = response.tarif1 ?? response.tarif2 ?? response.tarif3;
    }

    return CalculateEntity(
      premium: calculatedPremium ?? response.premium ?? 0.0,
      carId: response.carId ?? 0,
      year: response.year ?? 0,
      price: response.price ?? 0.0,
      beginDate: response.beginDate != null
          ? _parseDate(response.beginDate!)
          : DateTime.now(),
      endDate: response.endDate != null
          ? _parseDate(response.endDate!)
          : DateTime.now().add(const Duration(days: 365)),
      driverCount: response.driverCount ?? 0,
      franchise: response.franchise ?? 0.0,
      currency: response.currency,
      // Tariflarni map qilish
      rates: (response.rates ?? []).map(_mapRateModelToEntity).toList(),
    );
  }

  SaveOrderEntity _mapSaveOrderResponseToEntity(SaveOrderResponse response) {
    debugPrint('🔄 Mapping SaveOrderResponse to Entity:');
    debugPrint('  📦 orderId: ${response.orderId}');
    debugPrint('  📄 contractId: ${response.contractId}');
    debugPrint('  💰 premium: ${response.premium}');
    debugPrint('  🚗 carId: ${response.carId}');
    debugPrint('  🔵 clickUrl (url): ${response.url}');
    debugPrint('  🟢 paymeUrl: ${response.paymeUrl}');
    debugPrint('  📄 urlShartnoma: ${response.urlShartnoma}');
    
    final entity = SaveOrderEntity(
      orderId: response.orderId ?? '',
      contractId: response.contractId,
      premium: response.premium ?? 0.0,
      carId: response.carId ?? 0,
      ownerName: response.ownerName ?? '',
      ownerPhone: response.ownerPhone ?? '',
      status: response.status,
      clickUrl: response.url, // Click URL из поля 'url'
      paymeUrl: response.paymeUrl, // Payme URL
      urlShartnoma: response.urlShartnoma, // Contract document URL
    );
    
    debugPrint('✅ Mapped entity:');
    debugPrint('  orderId: ${entity.orderId}');
    debugPrint('  contractId: ${entity.contractId}');
    debugPrint('  clickUrl: ${entity.clickUrl}');
    debugPrint('  paymeUrl: ${entity.paymeUrl}');
    return entity;
  }

  PaymentLinkEntity _mapPaymentLinkResponseToEntity(
    PaymentLinkResponse response,
  ) {
    debugPrint('🔄 Mapping PaymentLinkResponse to Entity:');
    debugPrint('  🔵 clickUrl: ${response.clickUrl}');
    debugPrint('  🔵 url (fallback for click): ${response.url}');
    debugPrint('  🟢 paymeUrl: ${response.paymeUrl}');
    debugPrint('  🟢 payme_url (fallback for payme): ${response.paymeUrlOld}');
    debugPrint('  📦 orderId: ${response.orderId}');
    debugPrint('  📄 contractId: ${response.contractId}');
    debugPrint('  💰 amount: ${response.amount}, amountUzs: ${response.amountUzs}');
    
    try {
      final entity = PaymentLinkEntity(
        // Используем url как Click URL, если clickUrl не указан
        clickUrl: response.clickUrl ?? response.url,
        // Используем payme_url как Payme URL, если paymeUrl не указан
        paymeUrl: response.paymeUrl ?? response.paymeUrlOld,
        paymentUrl: response.paymentUrl ?? response.url ?? response.paymeUrlOld,
        orderId: response.orderId,
        contractId: response.contractId,
        amount: response.amountUzs ?? response.amount ?? 0.0,
      );
      debugPrint('✅ PaymentLinkEntity yaratildi:');
      debugPrint('  🔵 clickUrl: ${entity.clickUrl}');
      debugPrint('  🟢 paymeUrl: ${entity.paymeUrl}');
      debugPrint('  💰 amount: ${entity.amount}');
      return entity;
    } catch (e, stackTrace) {
      debugPrint('❌ PaymentLinkEntity mapping error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  CheckPaymentEntity _mapCheckPaymentResponseToEntity(
    CheckPaymentResponse response,
  ) {
    return CheckPaymentEntity(
      orderId: response.orderId,
      transactionId: response.transactionId,
      status: response.status,
      isPaid: response.isPaid,
      amount: response.amount,
    );
  }

  ImageUploadEntity _mapImageUploadResponseToEntity(
    ImageUploadResponse response,
  ) {
    return ImageUploadEntity(
      imageUrl: response.imageUrl,
      orderId: response.orderId,
      imageType: response.imageType,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateDDMMYYYY(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  DateTime _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      throw AppException(message: 'Invalid date format: $dateString');
    }
  }
}
