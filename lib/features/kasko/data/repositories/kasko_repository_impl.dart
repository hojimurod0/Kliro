import 'dart:io';

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
      return _mapCalculateResponseToEntity(response);
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
  }) async {
    try {
      final request = SaveOrderRequest(
        carId: carId,
        year: year,
        price: price,
        beginDate: _formatDate(beginDate),
        endDate: _formatDate(endDate),
        driverCount: driverCount,
        franchise: franchise,
        premium: premium,
        ownerName: ownerName,
        ownerPhone: ownerPhone,
        ownerPassport: ownerPassport,
        carNumber: carNumber,
        vin: vin,
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
    required double amount,
    required String returnUrl,
    required String callbackUrl,
  }) async {
    try {
      final request = PaymentLinkRequest(
        orderId: orderId,
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

  CalculateEntity _mapCalculateResponseToEntity(CalculateResponse response) {
    return CalculateEntity(
      premium: response.premium,
      carId: response.carId,
      year: response.year,
      price: response.price,
      beginDate: _parseDate(response.beginDate),
      endDate: _parseDate(response.endDate),
      driverCount: response.driverCount,
      franchise: response.franchise,
      currency: response.currency,
      // Tariflarni map qilish
      rates: response.rates.map(_mapRateModelToEntity).toList(),
    );
  }

  SaveOrderEntity _mapSaveOrderResponseToEntity(SaveOrderResponse response) {
    return SaveOrderEntity(
      orderId: response.orderId,
      premium: response.premium,
      carId: response.carId,
      ownerName: response.ownerName,
      ownerPhone: response.ownerPhone,
      status: response.status,
    );
  }

  PaymentLinkEntity _mapPaymentLinkResponseToEntity(
    PaymentLinkResponse response,
  ) {
    return PaymentLinkEntity(
      paymentUrl: response.paymentUrl,
      orderId: response.orderId,
      amount: response.amount,
    );
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

  DateTime _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      throw AppException(message: 'Invalid date format: $dateString');
    }
  }
}
