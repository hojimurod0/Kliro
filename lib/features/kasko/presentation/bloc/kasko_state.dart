import 'package:equatable/equatable.dart';

import '../../domain/entities/car_entity.dart';
import '../../domain/entities/calculate_entity.dart';
import '../../domain/entities/car_price_entity.dart';
import '../../domain/entities/check_payment_entity.dart';
import '../../domain/entities/image_upload_entity.dart';
import '../../domain/entities/payment_link_entity.dart';
import '../../domain/entities/rate_entity.dart';
import '../../domain/entities/save_order_entity.dart';

abstract class KaskoState extends Equatable {
  const KaskoState();

  @override
  List<Object?> get props => [];
}

class KaskoInitial extends KaskoState {
  const KaskoInitial();
}

class KaskoLoading extends KaskoState {
  const KaskoLoading();
}

class KaskoCarsLoaded extends KaskoState {
  final List<CarEntity> cars;

  const KaskoCarsLoaded(this.cars);

  @override
  List<Object?> get props => [cars];
}

class KaskoCarsPageLoaded extends KaskoState {
  final List<CarEntity> cars;
  final int pageNumber;
  final int totalPages;
  final int totalElements;
  final bool hasMore;
  final bool isPaginating;

  const KaskoCarsPageLoaded({
    required this.cars,
    required this.pageNumber,
    required this.totalPages,
    required this.totalElements,
    required this.hasMore,
    this.isPaginating = false,
  });

  @override
  List<Object?> get props => [
        cars,
        pageNumber,
        totalPages,
        totalElements,
        hasMore,
        isPaginating,
      ];

  KaskoCarsPageLoaded copyWith({
    List<CarEntity>? cars,
    int? pageNumber,
    int? totalPages,
    int? totalElements,
    bool? hasMore,
    bool? isPaginating,
  }) {
    return KaskoCarsPageLoaded(
      cars: cars ?? this.cars,
      pageNumber: pageNumber ?? this.pageNumber,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      hasMore: hasMore ?? this.hasMore,
      isPaginating: isPaginating ?? this.isPaginating,
    );
  }
}

class KaskoRatesLoaded extends KaskoState {
  final List<RateEntity> rates;
  final RateEntity? selectedRate;

  const KaskoRatesLoaded(this.rates, {this.selectedRate});

  @override
  List<Object?> get props => [rates, selectedRate];
}

class KaskoCarPriceCalculated extends KaskoState {
  final CarPriceEntity carPrice;

  const KaskoCarPriceCalculated(this.carPrice);

  @override
  List<Object?> get props => [carPrice];
}

class KaskoPolicyCalculated extends KaskoState {
  final CalculateEntity calculateResult;
  // Tariflar - calculate response'da keladi
  final List<RateEntity> rates;

  const KaskoPolicyCalculated(this.calculateResult, {this.rates = const []});

  @override
  List<Object?> get props => [calculateResult, rates];
}

/// Состояние: сохранение заказа в процессе
class KaskoSavingOrder extends KaskoState {
  const KaskoSavingOrder();
}

/// Состояние: заказ успешно сохранен
class KaskoOrderSaved extends KaskoState {
  final SaveOrderEntity order;

  const KaskoOrderSaved(this.order);

  @override
  List<Object?> get props => [order];
}

class KaskoPaymentLinkCreated extends KaskoState {
  final PaymentLinkEntity paymentLink;
  final int orderId;

  const KaskoPaymentLinkCreated(this.paymentLink, {required this.orderId});

  @override
  List<Object?> get props => [paymentLink, orderId];
}

class KaskoPaymentChecked extends KaskoState {
  final CheckPaymentEntity paymentStatus;

  const KaskoPaymentChecked(this.paymentStatus);

  @override
  List<Object?> get props => [paymentStatus];
}

class KaskoImageUploaded extends KaskoState {
  final ImageUploadEntity imageUpload;

  const KaskoImageUploaded(this.imageUpload);

  @override
  List<Object?> get props => [imageUpload];
}

class KaskoError extends KaskoState {
  final String message;

  const KaskoError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State: Validatsiya xatolari
class KaskoValidationError extends KaskoState {
  final Map<String, String> errors; // Field name -> Error message

  const KaskoValidationError(this.errors);

  @override
  List<Object?> get props => [errors];
}

/// State: Validatsiya muvaffaqiyatli
class KaskoValidationSuccess extends KaskoState {
  const KaskoValidationSuccess();
}

