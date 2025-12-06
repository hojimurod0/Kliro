import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/calculate_entity.dart';
import '../../domain/entities/car_entity.dart';
import '../../domain/entities/car_price_entity.dart';
import '../../domain/entities/rate_entity.dart';
import '../../domain/usecases/calculate_car_price.dart' as usecases;
import '../../domain/usecases/calculate_policy.dart' as usecases;
import '../../domain/usecases/check_payment_status.dart';
import '../../domain/usecases/get_cars.dart';
import '../../domain/usecases/get_cars_minimal.dart';
import '../../domain/usecases/get_payment_link.dart';
import '../../domain/usecases/get_rates.dart';
import '../../domain/usecases/save_order.dart' as usecases;
import '../../domain/usecases/upload_image.dart' as usecases;
import 'kasko_event.dart';
import 'kasko_state.dart';

class KaskoBloc extends Bloc<KaskoEvent, KaskoState> {
  KaskoBloc({
    required GetCars getCars,
    required GetCarsMinimal getCarsMinimal,
    required GetRates getRates,
    required usecases.CalculateCarPrice calculateCarPrice,
    required usecases.CalculatePolicy calculatePolicy,
    required usecases.SaveOrder saveOrder,
    required GetPaymentLink getPaymentLink,
    required CheckPaymentStatus checkPaymentStatus,
    required usecases.UploadImage uploadImage,
  }) : _getCars = getCars,
       _getCarsMinimal = getCarsMinimal,
       _getRates = getRates,
       _calculateCarPrice = calculateCarPrice,
       _calculatePolicy = calculatePolicy,
       _saveOrder = saveOrder,
       _getPaymentLink = getPaymentLink,
       _checkPaymentStatus = checkPaymentStatus,
       _uploadImage = uploadImage,
       super(const KaskoInitial()) {
    // Регистрация обработчиков событий
    on<FetchCars>(_onFetchCars);
    on<FetchCarsMinimal>(_onFetchCarsMinimal);
    on<FetchRates>(_onFetchRates);
    
    // Обработчики для сохранения выбора пользователя
    on<SelectCarBrand>(_onSelectCarBrand);
    on<SelectCarModel>(_onSelectCarModel);
    on<SelectCarPosition>(_onSelectCarPosition);
    on<SelectYear>(_onSelectYear);
    on<SelectRate>(_onSelectRate);
    
    // Обработчики для расчетов и операций
    on<CalculateCarPrice>(_onCalculateCarPrice);
    on<CalculatePolicy>(_onCalculatePolicy);
    on<SaveDocumentData>(_onSaveDocumentData);
    on<SavePersonalData>(_onSavePersonalData);
    on<SaveOrder>(_onSaveOrder);
    on<CreatePaymentLink>(_onCreatePaymentLink);
    on<CheckPayment>(_onCheckPayment);
    on<UploadImage>(_onUploadImage);
    on<ValidatePersonalData>(_onValidatePersonalData);
  }

  final GetCars _getCars;
  final GetCarsMinimal _getCarsMinimal;
  final GetRates _getRates;
  final usecases.CalculateCarPrice _calculateCarPrice;
  final usecases.CalculatePolicy _calculatePolicy;
  final usecases.SaveOrder _saveOrder;
  final GetPaymentLink _getPaymentLink;
  final CheckPaymentStatus _checkPaymentStatus;
  final usecases.UploadImage _uploadImage;

  static const bool _enableDebugLogs = false;

  // ============================================
  // КЭШИРОВАННЫЕ ДАННЫЕ (загруженные из API)
  // ============================================
  List<CarEntity>? _cachedCars;
  List<RateEntity>? _cachedRates;

  // ============================================
  // КЭШИРОВАННЫЕ ВЫБРАННЫЕ ЗНАЧЕНИЯ ПОЛЬЗОВАТЕЛЯ
  // Эти значения сохраняются между страницами
  // ============================================
  
  // Выбранный бренд автомобиля (ID или название)
  String? _selectedCarBrandId;
  String? _selectedCarBrandName;
  
  // Выбранная модель автомобиля (ID или название)
  String? _selectedCarModelId;
  String? _selectedCarModelName;
  
  // Выбранная позиция автомобиля (комплектация)
  // car_position_id используется как carId в API
  int? _selectedCarPositionId;
  String? _selectedCarPositionName;
  CarEntity? _selectedCarEntity;
  
  // Выбранный год выпуска
  int? _selectedYear;
  
  // Выбранный тариф
  RateEntity? _cachedSelectedRate;
  
  // Данные документа (сохраняются на странице document_data_page)
  String? _documentCarNumber;
  String? _documentVin;
  String? _documentPassportSeria;
  String? _documentPassportNumber;
  
  // Личные данные (сохраняются на странице personal_data_page)
  String? _ownerName;
  String? _ownerPhone;
  String? _ownerPassport;
  String? _birthDate;
  
  // Рассчитанная цена автомобиля
  CarPriceEntity? _cachedCarPrice;
  
  // Кэшированные данные расчета полиса
  CalculateEntity? _cachedCalculateResult;

  Future<void> _onFetchCars(FetchCars event, Emitter<KaskoState> emit) async {
    // Agar ma'lumotlar allaqachon yuklangan bo'lsa va forceRefresh false bo'lsa,
    // cache'dan qaytarish
    if (_cachedCars != null && !event.forceRefresh) {
      emit(KaskoCarsLoaded(_cachedCars!));
      return;
    }

    emit(const KaskoLoading());
    try {
      final cars = await _getCars();
      _cachedCars = cars; // Cache'ga saqlash
      emit(KaskoCarsLoaded(cars));
    } catch (e) {
      emit(KaskoError(_mapError(e)));
    }
  }

  Future<void> _onFetchCarsMinimal(
    FetchCarsMinimal event,
    Emitter<KaskoState> emit,
  ) async {
    // Minimal ma'lumotlar uchun cache tekshiruvi
    if (_cachedCars != null && !event.forceRefresh) {
      emit(KaskoCarsLoaded(_cachedCars!));
      return;
    }

    emit(const KaskoLoading());
    try {
      // Faqat brand, model, position uchun minimal ma'lumotlarni yuklash
      final cars = await _getCarsMinimal();
      _cachedCars = cars; // Cache'ga saqlash
      emit(KaskoCarsLoaded(cars));
    } catch (e) {
      emit(KaskoError(_mapError(e)));
    }
  }

  Future<void> _onFetchRates(FetchRates event, Emitter<KaskoState> emit) async {
    if (_enableDebugLogs) {
      debugPrint(
        '🔄🔄🔄 _onFetchRates called, forceRefresh: ${event.forceRefresh}',
      );
      debugPrint('📊 Current cached rates: ${_cachedRates?.length ?? 0} items');
    }

    // Agar ma'lumotlar allaqachon yuklangan bo'lsa va forceRefresh false bo'lsa,
    // cache'dan qaytarish
    if (_cachedRates != null && !event.forceRefresh) {
      if (_enableDebugLogs) {
        debugPrint('📦 Returning cached rates: ${_cachedRates!.length} items');
      }
      emit(KaskoRatesLoaded(_cachedRates!));
      return;
    }

    if (_enableDebugLogs) {
      debugPrint('⏳⏳⏳ Emitting KaskoLoading state...');
    }
    emit(const KaskoLoading());

    try {
      if (_enableDebugLogs) {
        debugPrint('🌐🌐🌐 Calling _getRates() usecase...');
      }
      final rates = await _getRates();
      if (_enableDebugLogs) {
        debugPrint('✅✅✅ Got ${rates.length} rates from API');
      }

      if (rates.isEmpty) {
        if (_enableDebugLogs) {
          debugPrint('⚠️⚠️⚠️ WARNING: Rates list is EMPTY!');
        }
      }

      _cachedRates = rates; // Cache'ga saqlash
      if (_enableDebugLogs) {
        debugPrint('💾 Cached ${rates.length} rates');
      }

      if (_enableDebugLogs) {
        debugPrint(
          '📤📤📤 Emitting KaskoRatesLoaded state with ${rates.length} rates...',
        );
      }
      // Agar oldin tanlangan rate bo'lsa, uni saqlash
      // Avval cache'dan, keyin joriy state'dan
      RateEntity? previousSelectedRate = _cachedSelectedRate;
      final currentState = state;
      if (previousSelectedRate == null && currentState is KaskoRatesLoaded) {
        previousSelectedRate = currentState.selectedRate;
      }
      emit(KaskoRatesLoaded(rates, selectedRate: previousSelectedRate));
      if (_enableDebugLogs) {
        debugPrint('✅✅✅ KaskoRatesLoaded state emitted successfully');
      }
    } catch (e, stackTrace) {
      if (_enableDebugLogs) {
        debugPrint('❌❌❌ Error in _onFetchRates: $e');
        debugPrint('❌ Stack trace: $stackTrace');
      }
      emit(KaskoError(_mapError(e)));
    }
  }

  // ============================================
  // ОБРАБОТЧИКИ СОБЫТИЙ ДЛЯ СОХРАНЕНИЯ ВЫБОРА
  // ============================================

  /// Обработчик: сохранение выбранного бренда автомобиля
  void _onSelectCarBrand(
    SelectCarBrand event,
    Emitter<KaskoState> emit,
  ) {
    _selectedCarBrandId = event.carBrandId;
    _selectedCarBrandName = event.carBrandName ?? event.carBrandId;
    
    // При смене бренда сбрасываем модель и позицию
    _selectedCarModelId = null;
    _selectedCarModelName = null;
    _selectedCarPositionId = null;
    _selectedCarPositionName = null;
    _selectedCarEntity = null;
    
    // State emit qilish - UI yangilanishi uchun
    // Agar cars yuklangan bo'lsa, KaskoCarsLoaded state'ni emit qilish
    if (_cachedCars != null) {
      emit(KaskoCarsLoaded(_cachedCars!));
    } else {
      // Agar cars yuklanmagan bo'lsa, current state'ni emit qilish
      emit(state);
    }
  }

  /// Обработчик: сохранение выбранной модели автомобиля
  void _onSelectCarModel(
    SelectCarModel event,
    Emitter<KaskoState> emit,
  ) {
    _selectedCarModelId = event.carModelId;
    _selectedCarModelName = event.carModelName ?? event.carModelId;
    
    // При смене модели сбрасываем позицию
    _selectedCarPositionId = null;
    _selectedCarPositionName = null;
    _selectedCarEntity = null;
    
    // State emit qilish - UI yangilanishi uchun
    if (_cachedCars != null) {
      emit(KaskoCarsLoaded(_cachedCars!));
    } else {
      emit(state);
    }
  }

  /// Обработчик: сохранение выбранной позиции автомобиля (комплектация)
  void _onSelectCarPosition(
    SelectCarPosition event,
    Emitter<KaskoState> emit,
  ) {
    _selectedCarPositionId = event.carPositionId;
    _selectedCarPositionName = event.carPositionName;
    _selectedCarEntity = event.carEntity;
    
    // State emit qilish - UI yangilanishi uchun
    if (_cachedCars != null) {
      emit(KaskoCarsLoaded(_cachedCars!));
    } else {
      emit(state);
    }
  }

  /// Обработчик: сохранение выбранного года выпуска
  void _onSelectYear(
    SelectYear event,
    Emitter<KaskoState> emit,
  ) {
    _selectedYear = event.year;
    
    // State emit qilish - UI yangilanishi uchun
    if (_cachedCars != null) {
      emit(KaskoCarsLoaded(_cachedCars!));
    } else if (state is KaskoCarPriceCalculated) {
      // Agar car price hisoblangan bo'lsa, uni qayta emit qilish
      emit(state);
    } else {
      emit(state);
    }
  }

  /// Обработчик: сохранение выбранного тарифа
  Future<void> _onSelectRate(SelectRate event, Emitter<KaskoState> emit) async {
    if (_enableDebugLogs) {
      debugPrint(
        '🎯🎯🎯 _onSelectRate called, rate: ${event.rate.name} (id: ${event.rate.id})',
      );
    }

    // Cache'ga saqlash
    _cachedSelectedRate = event.rate;

    final currentState = state;
    if (currentState is KaskoRatesLoaded) {
      // Tanlangan rate'ni yangi state'da saqlash
      emit(KaskoRatesLoaded(currentState.rates, selectedRate: event.rate));
      if (_enableDebugLogs) {
        debugPrint('✅✅✅ Rate selected: ${event.rate.name}');
      }
    } else {
      // Agar KaskoRatesLoaded holati bo'lmasa, lekin rates cache'da bo'lsa
      if (_cachedRates != null) {
        emit(KaskoRatesLoaded(_cachedRates!, selectedRate: event.rate));
        if (_enableDebugLogs) {
          debugPrint('✅✅✅ Rate selected from cache: ${event.rate.name}');
        }
      } else {
        if (_enableDebugLogs) {
          debugPrint(
            '⚠️⚠️⚠️ Cannot select rate: current state is not KaskoRatesLoaded and rates not cached',
          );
        }
      }
    }
  }

  Future<void> _onCalculateCarPrice(
    CalculateCarPrice event,
    Emitter<KaskoState> emit,
  ) async {
    emit(const KaskoLoading());
    try {
      final result = await _calculateCarPrice(
        carId: event.carId,
        tarifId: event.tarifId,
        year: event.year,
      );
      // Cache'ga saqlash
      _cachedCarPrice = result;
      emit(KaskoCarPriceCalculated(result));
    } catch (e) {
      emit(KaskoError(_mapError(e)));
    }
  }

  Future<void> _onCalculatePolicy(
    CalculatePolicy event,
    Emitter<KaskoState> emit,
  ) async {
    emit(const KaskoLoading());
    try {
      final result = await _calculatePolicy(
        carId: event.carId,
        year: event.year,
        price: event.price,
        beginDate: event.beginDate,
        endDate: event.endDate,
        driverCount: event.driverCount,
        franchise: event.franchise,
      );
      // Кэшируем результат расчета
      _cachedCalculateResult = result;
      // Calculate response'dan tariflarni olish
      emit(KaskoPolicyCalculated(result, rates: result.rates));
    } catch (e) {
      emit(KaskoError(_mapError(e)));
    }
  }

  Future<void> _onSaveDocumentData(
    SaveDocumentData event,
    Emitter<KaskoState> emit,
  ) async {
    // Сохраняем данные документа в BLoC
    _documentCarNumber = event.carNumber;
    _documentVin = event.vin;
    _documentPassportSeria = event.passportSeria;
    _documentPassportNumber = event.passportNumber;
    
    debugPrint('📝 Данные документа сохранены в BLoC:');
    debugPrint('  🚗 Car Number: ${event.carNumber}');
    debugPrint('  🔧 VIN: ${event.vin}');
    debugPrint('  📄 Passport: ${event.passportSeria} ${event.passportNumber}');
    
    // Не меняем состояние, просто сохраняем данные
  }

  void _onSavePersonalData(
    SavePersonalData event,
    Emitter<KaskoState> emit,
  ) {
    // Сохраняем личные данные в BLoC
    _birthDate = event.birthDate;
    _ownerName = event.ownerName;
    _ownerPhone = event.ownerPhone;
    _ownerPassport = event.ownerPassport;
    
    debugPrint('👤 Личные данные сохранены в BLoC:');
    debugPrint('  📅 Birth Date: ${event.birthDate}');
    debugPrint('  👤 Owner Name: ${event.ownerName}');
    debugPrint('  📱 Owner Phone: ${event.ownerPhone}');
    debugPrint('  🆔 Owner Passport: ${event.ownerPassport}');
    
    // Не меняем состояние, просто сохраняем данные
  }

  Future<void> _onSaveOrder(SaveOrder event, Emitter<KaskoState> emit) async {
    // Используем состояние KaskoSavingOrder для индикации процесса сохранения
    emit(const KaskoSavingOrder());
    try {
      final result = await _saveOrder(
        carId: event.carId,
        year: event.year,
        price: event.price,
        beginDate: event.beginDate,
        endDate: event.endDate,
        driverCount: event.driverCount,
        franchise: event.franchise,
        premium: event.premium,
        ownerName: event.ownerName,
        ownerPhone: event.ownerPhone,
        ownerPassport: event.ownerPassport,
        carNumber: event.carNumber,
        vin: event.vin,
      );
      emit(KaskoOrderSaved(result));
    } catch (e) {
      emit(KaskoError(_mapError(e)));
    }
  }

  Future<void> _onCreatePaymentLink(
    CreatePaymentLink event,
    Emitter<KaskoState> emit,
  ) async {
    emit(const KaskoLoading());
    try {
      final result = await _getPaymentLink(
        orderId: event.orderId,
        amount: event.amount,
        returnUrl: event.returnUrl,
        callbackUrl: event.callbackUrl,
      );
      emit(KaskoPaymentLinkCreated(result));
    } catch (e) {
      emit(KaskoError(_mapError(e)));
    }
  }

  Future<void> _onCheckPayment(
    CheckPayment event,
    Emitter<KaskoState> emit,
  ) async {
    emit(const KaskoLoading());
    try {
      final result = await _checkPaymentStatus(
        orderId: event.orderId,
        transactionId: event.transactionId,
      );
      emit(KaskoPaymentChecked(result));
    } catch (e) {
      emit(KaskoError(_mapError(e)));
    }
  }

  Future<void> _onUploadImage(
    UploadImage event,
    Emitter<KaskoState> emit,
  ) async {
    emit(const KaskoLoading());
    try {
      final result = await _uploadImage(
        filePath: event.filePath,
        orderId: event.orderId,
        imageType: event.imageType,
      );
      emit(KaskoImageUploaded(result));
    } catch (e) {
      emit(KaskoError(_mapError(e)));
    }
  }

  /// Validatsiya qilish: Shaxsiy ma'lumotlar
  /// Barcha maydonlarni tekshirish:
  /// - Tug'ilgan sana: formati (dd/mm/yyyy), kelajak sana bo'lmasligi, kamida 18 yosh
  /// - Ism familiya: kamida 3 ta belgi
  /// - Passport seriya: 2 ta harf
  /// - Passport raqami: 7 ta raqam
  /// - Telefon raqami: 9 ta raqam, 9 bilan boshlanishi kerak
  void _onValidatePersonalData(
    ValidatePersonalData event,
    Emitter<KaskoState> emit,
  ) {
    final errors = <String, String>{};
    final birthDate = event.birthDate.trim();
    final ownerName = event.ownerName.trim();
    final passportSeries = event.passportSeries.trim();
    final passportNumber = event.passportNumber.trim();
    final phoneNumber = event.phoneNumber.trim();

    // 1. Tug'ilgan sana validatsiyasi
    if (birthDate.isEmpty) {
      errors['birthDate'] =
          'insurance.kasko.personal_data.errors.select_birth_date';
    } else {
      // Format tekshiruvi (dd/mm/yyyy)
      final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
      if (!dateRegex.hasMatch(birthDate)) {
        errors['birthDate'] =
            'insurance.kasko.personal_data.errors.select_birth_date';
      } else {
        // Sana pars qilish va tekshirish
        try {
          final parts = birthDate.split('/');
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final date = DateTime(year, month, day);
          final now = DateTime.now();

          // Kelajak sana bo'lmasligi kerak
          if (date.isAfter(now)) {
            errors['birthDate'] =
                'insurance.kasko.personal_data.errors.select_birth_date';
          } else {
            // 18 yoshdan kichik bo'lmasligi kerak
            final age = now.year - year;
            final hasBirthdayPassed = now.month > month ||
                (now.month == month && now.day >= day);
            final actualAge = hasBirthdayPassed ? age : age - 1;

            if (actualAge < 18) {
              errors['birthDate'] =
                  'insurance.kasko.personal_data.errors.age_min_18';
            }
          }
        } catch (e) {
          errors['birthDate'] =
              'insurance.kasko.personal_data.errors.select_birth_date';
        }
      }
    }

    // 2. Ism familiya validatsiyasi
    if (ownerName.isEmpty) {
      errors['ownerName'] =
          'insurance.kasko.personal_data.errors.enter_name';
    } else if (ownerName.length < 3) {
      errors['ownerName'] =
          'insurance.kasko.personal_data.errors.name_min_3';
    }

    // 3. Passport seriya validatsiyasi
    final passportSeriesUpper = passportSeries.toUpperCase();
    if (passportSeries.isEmpty) {
      errors['passportSeries'] =
          'insurance.kasko.personal_data.errors.enter_passport_series';
    } else if (passportSeriesUpper.length != 2) {
      errors['passportSeries'] =
          'insurance.kasko.personal_data.errors.series_2_letters';
    } else if (!RegExp(r'^[A-Za-z]{2}$').hasMatch(passportSeriesUpper)) {
      errors['passportSeries'] =
          'insurance.kasko.personal_data.errors.series_2_letters';
    }

    // 4. Passport raqami validatsiyasi
    if (passportNumber.isEmpty) {
      errors['passportNumber'] =
          'insurance.kasko.personal_data.errors.enter_passport_number';
    } else if (passportNumber.length != 7) {
      errors['passportNumber'] =
          'insurance.kasko.personal_data.errors.number_7_digits';
    } else if (!RegExp(r'^[0-9]{7}$').hasMatch(passportNumber)) {
      errors['passportNumber'] =
          'insurance.kasko.personal_data.errors.number_7_digits';
    }

    // 5. Telefon raqami validatsiyasi
    if (phoneNumber.isEmpty) {
      errors['phoneNumber'] =
          'insurance.kasko.personal_data.errors.enter_phone';
    } else if (!RegExp(r'^[0-9]+$').hasMatch(phoneNumber)) {
      errors['phoneNumber'] =
          'insurance.kasko.personal_data.errors.phone_9_digits';
    } else if (phoneNumber.length != 9) {
      errors['phoneNumber'] =
          'insurance.kasko.personal_data.errors.phone_9_digits';
    } else if (phoneNumber[0] != '9') {
      errors['phoneNumber'] =
          'insurance.kasko.personal_data.errors.phone_9_digits';
    }

    // Xatolar bo'lsa, ularni qaytarish
    if (errors.isNotEmpty) {
      emit(KaskoValidationError(errors));
    } else {
      // Validatsiya muvaffaqiyatli
      emit(const KaskoValidationSuccess());
    }
  }

  String _mapError(Object error) {
    if (error is AppException) {
      // Xatolik xabarlarini foydalanuvchi uchun tushunarli qilish
      final message = error.message;
      if (message.contains('Invalid response format')) {
        return 'Server javob formati noto\'g\'ri. Iltimos, qayta urinib ko\'ring.';
      }
      if (message.contains('Failed to get cars')) {
        return 'Avtomobillar ma\'lumotlarini olishda xatolik yuz berdi.';
      }
      if (message.contains('NetworkException') ||
          message.contains('connection')) {
        return 'Internet aloqasi yo\'q. Iltimos, internet aloqasini tekshiring.';
      }
      if (message.contains('timeout')) {
        return 'Server javob bermadi. Iltimos, qayta urinib ko\'ring.';
      }
      return message.isNotEmpty ? message : 'Noma\'lum xatolik yuz berdi';
    }
    return 'Xatolik: ${error.toString()}';
  }

  // ============================================
  // HELPER GETTERS - для удобного доступа к кэшированным данным
  // ============================================

  /// Получить полное название автомобиля (бренд + модель)
  /// Например: "Toyota Camry"
  String get selectedCarFullName {
    final brand = _selectedCarBrandName ?? _selectedCarBrandId;
    final model = _selectedCarModelName ?? _selectedCarModelId;
    
    if (brand != null && model != null) {
      return '$brand $model';
    } else if (brand != null) {
      return brand;
    } else if (model != null) {
      return model;
    } else if (_selectedCarEntity != null) {
      // Если есть полная информация об автомобиле
      final car = _selectedCarEntity!;
      if (car.brand != null && car.model != null) {
        return '${car.brand} ${car.model}';
      } else if (car.brand != null) {
        return car.brand!;
      } else if (car.model != null) {
        return car.model!;
      }
      return car.name;
    }
    return '';
  }

  /// Получить выбранный год выпуска
  int? get selectedYear => _selectedYear;

  /// Получить выбранный тариф
  RateEntity? get selectedRate => _cachedSelectedRate;

  /// Получить рассчитанную цену автомобиля
  double? get calculatedPrice => _cachedCarPrice?.price;

  /// Получить ID выбранной позиции автомобиля (car_position_id)
  int? get selectedCarPositionId => _selectedCarPositionId;

  /// Получить ID выбранного бренда
  String? get selectedCarBrandId => _selectedCarBrandId;

  /// Получить ID выбранной модели
  String? get selectedCarModelId => _selectedCarModelId;

  /// Получить полную информацию о выбранном автомобиле
  CarEntity? get selectedCarEntity => _selectedCarEntity;

  // ============================================
  // МЕТОД ДЛЯ ПОЛУЧЕНИЯ КОМБИНИРОВАННОЙ ИНФОРМАЦИИ
  // Используется на странице 3 для отображения всех выбранных данных
  // ============================================

  /// Получить комбинированную информацию о выбранном автомобиле, тарифе и цене
  /// Возвращает Map с ключами: carFullName, year, tariffName, price
  Map<String, dynamic> getCombinedInfo() {
    return {
      'carFullName': selectedCarFullName,
      'year': selectedYear,
      'tariffName': _cachedSelectedRate?.name ?? '',
      'price': calculatedPrice,
      'carBrandId': _selectedCarBrandId,
      'carModelId': _selectedCarModelId,
      'carPositionId': _selectedCarPositionId,
      'rateId': _cachedSelectedRate?.id,
    };
  }

  // ============================================
  // GETTERS ДЛЯ ДОСТУПА К КЭШИРОВАННЫМ ДАННЫМ
  // ============================================

  /// Получить кэшированную цену автомобиля
  CarPriceEntity? get cachedCarPrice => _cachedCarPrice;
  
  /// Получить кэшированный выбранный тариф
  RateEntity? get cachedSelectedRate => _cachedSelectedRate;
  
  // Геттеры для данных документа
  String? get documentCarNumber => _documentCarNumber;
  String? get documentVin => _documentVin;
  String? get documentPassportSeria => _documentPassportSeria;
  String? get documentPassportNumber => _documentPassportNumber;
  
  // Геттеры для личных данных
  String? get ownerName => _ownerName;
  String? get ownerPhone => _ownerPhone;
  String? get ownerPassport => _ownerPassport;
  String? get birthDate => _birthDate;
  
  /// Получить кэшированный список автомобилей
  List<CarEntity>? get cachedCars => _cachedCars;
  
  /// Получить кэшированный список тарифов
  List<RateEntity>? get cachedRates => _cachedRates;
  
  /// Получить кэшированный результат расчета полиса
  CalculateEntity? get cachedCalculateResult => _cachedCalculateResult;
}
