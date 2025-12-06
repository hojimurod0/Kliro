import 'package:equatable/equatable.dart';

import '../../domain/entities/car_entity.dart';
import '../../domain/entities/rate_entity.dart';

abstract class KaskoEvent extends Equatable {
  const KaskoEvent();

  @override
  List<Object?> get props => [];
}

class FetchCars extends KaskoEvent {
  final bool forceRefresh;

  const FetchCars({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class FetchCarsMinimal extends KaskoEvent {
  final bool forceRefresh;

  const FetchCarsMinimal({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class FetchRates extends KaskoEvent {
  final bool forceRefresh;

  const FetchRates({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Событие для сохранения выбранного бренда автомобиля
/// car_brand_id может быть строкой (название бренда) или числом (ID бренда)
class SelectCarBrand extends KaskoEvent {
  final String carBrandId; // ID или название бренда
  final String? carBrandName; // Название бренда для отображения

  const SelectCarBrand({
    required this.carBrandId,
    this.carBrandName,
  });

  @override
  List<Object?> get props => [carBrandId, carBrandName];
}

/// Событие для сохранения выбранной модели автомобиля
/// car_model_id может быть строкой (название модели) или числом (ID модели)
class SelectCarModel extends KaskoEvent {
  final String carModelId; // ID или название модели
  final String? carModelName; // Название модели для отображения

  const SelectCarModel({
    required this.carModelId,
    this.carModelName,
  });

  @override
  List<Object?> get props => [carModelId, carModelName];
}

/// Событие для сохранения выбранной позиции автомобиля (комплектация)
/// car_position_id - это ID позиции (используется как carId в API)
class SelectCarPosition extends KaskoEvent {
  final int carPositionId; // ID позиции (car_position_id)
  final String? carPositionName; // Название позиции для отображения
  final CarEntity? carEntity; // Полная информация об автомобиле

  const SelectCarPosition({
    required this.carPositionId,
    this.carPositionName,
    this.carEntity,
  });

  @override
  List<Object?> get props => [carPositionId, carPositionName, carEntity];
}

/// Событие для сохранения выбранного года выпуска автомобиля
class SelectYear extends KaskoEvent {
  final int year;

  const SelectYear(this.year);

  @override
  List<Object?> get props => [year];
}

/// Событие для сохранения выбранного тарифа
class SelectRate extends KaskoEvent {
  final RateEntity rate;

  const SelectRate(this.rate);

  @override
  List<Object?> get props => [rate];
}

class CalculateCarPrice extends KaskoEvent {
  final int carId; // Bu aslida car_position_id
  final int tarifId;
  final int year;

  const CalculateCarPrice({
    required this.carId,
    required this.tarifId,
    required this.year,
  });

  @override
  List<Object?> get props => [carId, tarifId, year];
}

class CalculatePolicy extends KaskoEvent {
  final int carId;
  final int year;
  final double price;
  final DateTime beginDate;
  final DateTime endDate;
  final int driverCount;
  final double franchise;

  const CalculatePolicy({
    required this.carId,
    required this.year,
    required this.price,
    required this.beginDate,
    required this.endDate,
    required this.driverCount,
    required this.franchise,
  });

  @override
  List<Object?> get props => [
    carId,
    year,
    price,
    beginDate,
    endDate,
    driverCount,
    franchise,
  ];
}

class SaveOrder extends KaskoEvent {
  final int carId;
  final int year;
  final double price;
  final DateTime beginDate;
  final DateTime endDate;
  final int driverCount;
  final double franchise;
  final double premium;
  final String ownerName;
  final String ownerPhone;
  final String ownerPassport;
  final String carNumber;
  final String vin;

  const SaveOrder({
    required this.carId,
    required this.year,
    required this.price,
    required this.beginDate,
    required this.endDate,
    required this.driverCount,
    required this.franchise,
    required this.premium,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerPassport,
    required this.carNumber,
    required this.vin,
  });

  @override
  List<Object?> get props => [
    carId,
    year,
    price,
    beginDate,
    endDate,
    driverCount,
    franchise,
    premium,
    ownerName,
    ownerPhone,
    ownerPassport,
    carNumber,
    vin,
  ];
}

class SaveDocumentData extends KaskoEvent {
  final String carNumber;
  final String vin;
  final String passportSeria;
  final String passportNumber;

  const SaveDocumentData({
    required this.carNumber,
    required this.vin,
    required this.passportSeria,
    required this.passportNumber,
  });

  @override
  List<Object?> get props => [carNumber, vin, passportSeria, passportNumber];
}

class CreatePaymentLink extends KaskoEvent {
  final String orderId;
  final double amount;
  final String returnUrl;
  final String callbackUrl;

  const CreatePaymentLink({
    required this.orderId,
    required this.amount,
    required this.returnUrl,
    required this.callbackUrl,
  });

  @override
  List<Object?> get props => [orderId, amount, returnUrl, callbackUrl];
}

class CheckPayment extends KaskoEvent {
  final String orderId;
  final String transactionId;

  const CheckPayment({required this.orderId, required this.transactionId});

  @override
  List<Object?> get props => [orderId, transactionId];
}

class UploadImage extends KaskoEvent {
  final String filePath;
  final String orderId;
  final String imageType;

  const UploadImage({
    required this.filePath,
    required this.orderId,
    required this.imageType,
  });

  @override
  List<Object?> get props => [filePath, orderId, imageType];
}

/// Event: Shaxsiy ma'lumotlarni validatsiya qilish
class ValidatePersonalData extends KaskoEvent {
  final String birthDate;
  final String ownerName;
  final String passportSeries;
  final String passportNumber;
  final String phoneNumber;

  const ValidatePersonalData({
    required this.birthDate,
    required this.ownerName,
    required this.passportSeries,
    required this.passportNumber,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [
        birthDate,
        ownerName,
        passportSeries,
        passportNumber,
        phoneNumber,
      ];
}

/// Event: Shaxsiy ma'lumotlarni BLoC'da saqlash
class SavePersonalData extends KaskoEvent {
  final String birthDate;
  final String ownerName;
  final String ownerPhone;
  final String ownerPassport;

  const SavePersonalData({
    required this.birthDate,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerPassport,
  });

  @override
  List<Object?> get props => [
        birthDate,
        ownerName,
        ownerPhone,
        ownerPassport,
      ];
}
