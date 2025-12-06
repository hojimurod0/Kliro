import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/car_entity.dart';
import '../../domain/entities/rate_entity.dart';
import '../../domain/entities/car_price_entity.dart';
import '../../domain/entities/calculate_entity.dart';
import '../../domain/entities/save_order_entity.dart';
import '../../domain/entities/payment_link_entity.dart';
import '../../domain/entities/check_payment_entity.dart';
import '../../domain/entities/image_upload_entity.dart';
import '../../domain/repositories/kasko_repository.dart';

/// KASKO Insurance Provider - State Management with ChangeNotifier
class KaskoProvider extends ChangeNotifier {
  KaskoProvider(this._repository);

  final KaskoRepository _repository;

  // ========== Loading States ==========
  bool _isLoadingCars = false;
  bool _isLoadingRates = false;
  bool _isLoadingCarPrice = false;
  bool _isLoadingPolicy = false;
  bool _isSavingOrder = false;
  bool _isCreatingPayment = false;
  bool _isCheckingPayment = false;
  bool _isUploadingImage = false;

  // ========== Data States ==========
  List<CarEntity> _cars = [];
  List<RateEntity> _rates = [];
  CarPriceEntity? _carPrice;
  CalculateEntity? _policyCalculation;
  SaveOrderEntity? _savedOrder;
  PaymentLinkEntity? _paymentLink;
  CheckPaymentEntity? _paymentStatus;
  ImageUploadEntity? _uploadResult;

  // ========== Error States ==========
  String? _errorMessage;
  AppException? _lastError;

  // ========== Getters ==========
  bool get isLoadingCars => _isLoadingCars;
  bool get isLoadingRates => _isLoadingRates;
  bool get isLoadingCarPrice => _isLoadingCarPrice;
  bool get isLoadingPolicy => _isLoadingPolicy;
  bool get isSavingOrder => _isSavingOrder;
  bool get isCreatingPayment => _isCreatingPayment;
  bool get isCheckingPayment => _isCheckingPayment;
  bool get isUploadingImage => _isUploadingImage;

  List<CarEntity> get cars => _cars;
  List<RateEntity> get rates => _rates;
  CarPriceEntity? get carPrice => _carPrice;
  CalculateEntity? get policyCalculation => _policyCalculation;
  SaveOrderEntity? get savedOrder => _savedOrder;
  PaymentLinkEntity? get paymentLink => _paymentLink;
  CheckPaymentEntity? get paymentStatus => _paymentStatus;
  ImageUploadEntity? get uploadResult => _uploadResult;

  String? get errorMessage => _errorMessage;
  AppException? get lastError => _lastError;

  bool get hasError => _errorMessage != null;
  bool get hasCars => _cars.isNotEmpty;
  bool get hasRates => _rates.isNotEmpty;

  // ========== Clear Error ==========
  void clearError() {
    _errorMessage = null;
    _lastError = null;
    notifyListeners();
  }

  // ========== Fetch Cars ==========
  /// Mashinalarni yuklash. Agar allaqachon yuklangan bo'lsa, qayta yuklamaydi.
  /// [forceRefresh] = true bo'lsa, cache'ni e'tiborsiz qoldirib qayta yuklaydi.
  Future<void> fetchCars({bool forceRefresh = false}) async {
    // Agar ma'lumotlar allaqachon yuklangan bo'lsa va forceRefresh false bo'lsa, qayta yuklamaymiz
    if (_cars.isNotEmpty && !forceRefresh) {
      return;
    }

    _isLoadingCars = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cars = await _repository.getCars();
      _cars = cars;
      _isLoadingCars = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoadingCars = false;
      _errorMessage = e.toString();
      _lastError = e is AppException ? e : AppException(message: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  // ========== Fetch Rates ==========
  /// Tariflarni yuklash. Agar allaqachon yuklangan bo'lsa, qayta yuklamaydi.
  /// [forceRefresh] = true bo'lsa, cache'ni e'tiborsiz qoldirib qayta yuklaydi.
  Future<void> fetchRates({bool forceRefresh = false}) async {
    // Agar ma'lumotlar allaqachon yuklangan bo'lsa va forceRefresh false bo'lsa, qayta yuklamaymiz
    if (_rates.isNotEmpty && !forceRefresh) {
      return;
    }

    _isLoadingRates = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rates = await _repository.getRates();
      _rates = rates;
      _isLoadingRates = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoadingRates = false;
      _errorMessage = e.toString();
      _lastError = e is AppException ? e : AppException(message: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  // ========== Calculate Car Price ==========
  Future<void> calculateCarPrice({
    required int carId,
    required int tarifId,
    required int year,
  }) async {
    _isLoadingCarPrice = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.calculateCarPrice(
        carId: carId,
        tarifId: tarifId,
        year: year,
      );
      _carPrice = result;
      _isLoadingCarPrice = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoadingCarPrice = false;
      _errorMessage = e.toString();
      _lastError = e is AppException ? e : AppException(message: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  // ========== Calculate Policy ==========
  Future<void> calculatePolicy({
    required int carId,
    required int year,
    required double price,
    required DateTime beginDate,
    required DateTime endDate,
    required int driverCount,
    required double franchise,
  }) async {
    _isLoadingPolicy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.calculatePolicy(
        carId: carId,
        year: year,
        price: price,
        beginDate: beginDate,
        endDate: endDate,
        driverCount: driverCount,
        franchise: franchise,
      );
      _policyCalculation = result;
      _isLoadingPolicy = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoadingPolicy = false;
      _errorMessage = e.toString();
      _lastError = e is AppException ? e : AppException(message: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  // ========== Save Order ==========
  Future<void> saveOrder({
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
    _isSavingOrder = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.saveOrder(
        carId: carId,
        year: year,
        price: price,
        beginDate: beginDate,
        endDate: endDate,
        driverCount: driverCount,
        franchise: franchise,
        premium: premium,
        ownerName: ownerName,
        ownerPhone: ownerPhone,
        ownerPassport: ownerPassport,
        carNumber: carNumber,
        vin: vin,
      );
      _savedOrder = result;
      _isSavingOrder = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isSavingOrder = false;
      _errorMessage = e.toString();
      _lastError = e is AppException ? e : AppException(message: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  // ========== Create Payment Link ==========
  Future<void> createPayment({
    required String orderId,
    required double amount,
    required String returnUrl,
    required String callbackUrl,
  }) async {
    _isCreatingPayment = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getPaymentLink(
        orderId: orderId,
        amount: amount,
        returnUrl: returnUrl,
        callbackUrl: callbackUrl,
      );
      _paymentLink = result;
      _isCreatingPayment = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isCreatingPayment = false;
      _errorMessage = e.toString();
      _lastError = e is AppException ? e : AppException(message: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  // ========== Verify Payment ==========
  Future<void> verifyPayment({
    required String orderId,
    required String transactionId,
  }) async {
    _isCheckingPayment = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.checkPaymentStatus(
        orderId: orderId,
        transactionId: transactionId,
      );
      _paymentStatus = result;
      _isCheckingPayment = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isCheckingPayment = false;
      _errorMessage = e.toString();
      _lastError = e is AppException ? e : AppException(message: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  // ========== Upload Image ==========
  Future<void> uploadImage({
    required String filePath,
    required String orderId,
    required String imageType,
  }) async {
    _isUploadingImage = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.uploadImage(
        filePath: filePath,
        orderId: orderId,
        imageType: imageType,
      );
      _uploadResult = result;
      _isUploadingImage = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isUploadingImage = false;
      _errorMessage = e.toString();
      _lastError = e is AppException ? e : AppException(message: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  // ========== Reset State ==========
  void reset() {
    _cars = [];
    _rates = [];
    _carPrice = null;
    _policyCalculation = null;
    _savedOrder = null;
    _paymentLink = null;
    _paymentStatus = null;
    _uploadResult = null;
    _errorMessage = null;
    _lastError = null;
    notifyListeners();
  }
}

