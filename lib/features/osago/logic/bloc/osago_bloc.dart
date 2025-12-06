import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/osago_driver.dart';
import '../../domain/entities/osago_insurance.dart';
import '../../domain/usecases/calc_osago.dart';
import '../../domain/usecases/check_osago_status.dart';
import '../../domain/usecases/create_osago_policy.dart';
import 'osago_event.dart';
import 'osago_state.dart';

class OsagoBloc extends Bloc<OsagoEvent, OsagoState> {
  OsagoBloc({
    required CalcOsago calcOsago,
    required CreateOsagoPolicy createOsagoPolicy,
    required CheckOsagoStatus checkOsagoStatus,
  }) : _calcOsago = calcOsago,
       _createOsagoPolicy = createOsagoPolicy,
       _checkOsagoStatus = checkOsagoStatus,
       super(const OsagoInitial()) {
    log(
      '[OSAGO_BLOC] OsagoBloc yaratildi, event handlerlar ro\'yxatdan o\'tkazilmoqda...',
      name: 'OSAGO',
    );
    on<LoadVehicleData>(_onLoadVehicleData);
    on<FetchVehicleInfo>(_onFetchVehicleInfo);
    on<LoadInsuranceCompany>(_onLoadInsuranceCompany);
    on<CalcRequested>(_onCalcRequested);
    on<CreatePolicyRequested>(_onCreatePolicyRequested);
    on<PaymentSelected>(_onPaymentSelected);
    on<CheckPolicyRequested>(_onCheckPolicyRequested);
    log(
      '[OSAGO_BLOC] ✅ Barcha event handlerlar ro\'yxatdan o\'tkazildi',
      name: 'OSAGO',
    );
  }

  final CalcOsago _calcOsago;
  final CreateOsagoPolicy _createOsagoPolicy;
  final CheckOsagoStatus _checkOsagoStatus;
  static const int _maxCheckAttempts = 3;
  static const Duration _checkRetryDelay = Duration(seconds: 3);

  int _checkAttempts = 0;
  bool _isCreating = false;

  void _onLoadVehicleData(LoadVehicleData event, Emitter<OsagoState> emit) {
    log('[OSAGO_BLOC] LoadVehicleData event qabul qilindi', name: 'OSAGO');
    log(
      '[OSAGO_BLOC] Vehicle: brand=${event.vehicle.brand}, model=${event.vehicle.model}, gosNumber=${event.vehicle.gosNumber}',
      name: 'OSAGO',
    );
    log('[OSAGO_BLOC] Drivers count: ${event.drivers.length}', name: 'OSAGO');
    for (var i = 0; i < event.drivers.length; i++) {
      final d = event.drivers[i];
      log(
        '[OSAGO_BLOC] LoadVehicleData Driver[$i]: passport=${d.passportSeria} ${d.passportNumber}, relative=${d.relative}',
        name: 'OSAGO',
      );
    }
    log(
      '[OSAGO_BLOC] OSAGO type: ${event.osagoType}, periodId: ${event.periodId}',
      name: 'OSAGO',
    );

    // Synchronous emit - tez operatsiya, main thread ni bloklamaydi
    emit(
      OsagoVehicleFilled(
        vehicle: event.vehicle,
        drivers: event.drivers,
        gosNumber: event.gosNumber,
        periodId: event.periodId,
        birthDate: event.birthDate,
        osagoType: event.osagoType,
      ),
    );

    log('[OSAGO_BLOC] ✅ OsagoVehicleFilled state emit qilindi', name: 'OSAGO');
  }

  Future<void> _onFetchVehicleInfo(
    FetchVehicleInfo event,
    Emitter<OsagoState> emit,
  ) async {
    log('[OSAGO_BLOC] FetchVehicleInfo event qabul qilindi', name: 'OSAGO');
    log(
      '[OSAGO_BLOC] Vehicle: gosNumber=${event.vehicle.gosNumber}, techSeria=${event.vehicle.techSeria}, techNumber=${event.vehicle.techNumber}',
      name: 'OSAGO',
    );

    emit(OsagoLoading(vehicle: event.vehicle, osagoType: event.osagoType));

    try {
      // Calc API ni chaqirish - tanlangan periodId yoki default bilan
      final periodId = event.periodId ?? '12'; // Default: 12 oy
      final tempInsurance = OsagoInsurance(
        provider: 'neo',
        companyName: 'NEO Insurance',
        periodId: periodId,
        numberDriversId: '5', // Default: cheklangan
        startDate: DateTime.now(),
        phoneNumber: '+998',
        ownerInn: '',
        isUnlimited: false,
      );

      final calcResult = await _calcOsago(
        vehicle: event.vehicle,
        insurance: tempInsurance,
      );

      log(
        '[OSAGO_BLOC] ✅ Calc muvaffaqiyatli: brand=${calcResult.vehicle?.brand}, model=${calcResult.vehicle?.model}, ownerName=${calcResult.ownerName}',
        name: 'OSAGO',
      );

      // Vehicle ma'lumotlarini yangilash
      final updatedVehicle = calcResult.vehicle ?? event.vehicle;

      emit(
        OsagoVehicleFilled(
          vehicle: updatedVehicle,
          drivers: const [],
          gosNumber: event.vehicle.gosNumber,
          periodId: event.periodId,
          ownerName: calcResult.ownerName,
          osagoType: event.osagoType,
          birthDate: updatedVehicle.ownerBirthDate,
          calcResponse: calcResult,
        ),
      );
    } catch (e, stackTrace) {
      log(
        '[OSAGO_BLOC] ❌ FetchVehicleInfo xatosi: $e',
        name: 'OSAGO',
        error: e,
        stackTrace: stackTrace,
      );
      emit(
        OsagoFailure(
          message: e.toString(),
          vehicle: event.vehicle,
          osagoType: event.osagoType,
        ),
      );
    }
  }

  void _onLoadInsuranceCompany(
    LoadInsuranceCompany event,
    Emitter<OsagoState> emit,
  ) {
    log('[OSAGO_BLOC] LoadInsuranceCompany event qabul qilindi', name: 'OSAGO');
    log(
      '[OSAGO_BLOC] Insurance: provider=${event.insurance.provider}, companyName=${event.insurance.companyName}, periodId=${event.insurance.periodId}',
      name: 'OSAGO',
    );
    log(
      '[OSAGO_BLOC] Insurance: numberDriversId=${event.insurance.numberDriversId}, startDate=${event.insurance.startDate}',
      name: 'OSAGO',
    );

    final currentVehicle = state.vehicle;
    if (currentVehicle == null) {
      log('[OSAGO_BLOC] ❌ Vehicle topilmadi', name: 'OSAGO');
      emit(_failureState('Avtomobil ma\'lumotlari topilmadi'));
      return;
    }
    
    // MUHIM: Agar state OsagoVehicleFilled bo'lsa va drivers mavjud bo'lsa, ularni saqlash
    // Bu LoadVehicleData event dan keyin kelgan drivers ni saqlashni ta'minlaydi
    List<OsagoDriver> currentDrivers = state.drivers;
    if (state is OsagoVehicleFilled && state.drivers.isNotEmpty) {
      currentDrivers = state.drivers;
      log(
        '[OSAGO_BLOC] OsagoVehicleFilled state dan ${currentDrivers.length} ta haydovchi olingan',
        name: 'OSAGO',
      );
    }

    // OSAGO type va provider ga qarab numberDriversId ni map qilish
    // MUHIM: Provider tekshiruvi ustunlik qiladi - har doim tekshiramiz
    final osagoType = state.osagoType;
    final provider = event.insurance.provider;
    String finalNumberDriversId;

    log(
      '[OSAGO_BLOC] Initial numberDriversId: ${event.insurance.numberDriversId}, provider=$provider, osagoType=$osagoType',
      name: 'OSAGO',
    );

    // Provider ga qarab mapping (ustunlik) - har doim tekshiramiz
    final providerLower = provider.toLowerCase();
    if (providerLower == 'neo') {
      // NEO -> cheklanmagan (0) - nechta bo'lsa, hammasini qo'shadi
      finalNumberDriversId = '0';
      log(
        '[OSAGO_BLOC] ✅ Provider=NEO, finalNumberDriversId=0 (Cheklanmagan)',
        name: 'OSAGO',
      );
    } else if (providerLower == 'gusto') {
      // GUSTO -> cheklangan (5) - 5 tagacha
      finalNumberDriversId = '5';
      log(
        '[OSAGO_BLOC] ✅ Provider=GUSTO, finalNumberDriversId=5 (Cheklangan)',
        name: 'OSAGO',
      );
    } else if (providerLower == 'gross') {
      // GROSS -> cheklangan (5) - 5 tagacha
      finalNumberDriversId = '5';
      log(
        '[OSAGO_BLOC] ✅ Provider=GROSS, finalNumberDriversId=5 (Cheklangan)',
        name: 'OSAGO',
      );
    } else {
      // OSAGO type yoki event.insurance.numberDriversId dan map qilish
      final tempNumberDriversId = event.insurance.numberDriversId;
      if (tempNumberDriversId == '0' || tempNumberDriversId == '5') {
        finalNumberDriversId = tempNumberDriversId;
        log(
          '[OSAGO_BLOC] ✅ Event dan numberDriversId=$finalNumberDriversId',
          name: 'OSAGO',
        );
      } else if (osagoType != null &&
          osagoType.toLowerCase().contains('cheklanmagan')) {
        finalNumberDriversId = '0';
        log(
          '[OSAGO_BLOC] Mapping: OSAGO type (cheklanmagan) -> 0',
          name: 'OSAGO',
        );
      } else {
        finalNumberDriversId = '5'; // Default: limited
        log('[OSAGO_BLOC] Mapping: Default -> 5', name: 'OSAGO');
      }
    }

    log(
      '[OSAGO_BLOC] ✅ Final numberDriversId: $finalNumberDriversId',
      name: 'OSAGO',
    );

    // Insurance ni yangilangan numberDriversId bilan yaratish
    final updatedInsurance = OsagoInsurance(
      provider: event.insurance.provider,
      companyName: event.insurance.companyName,
      periodId: event.insurance.periodId,
      numberDriversId: finalNumberDriversId, // To'g'ri qiymat: '0' yoki '5'
      startDate: event.insurance.startDate,
      phoneNumber: event.insurance.phoneNumber,
      ownerInn: event.insurance.ownerInn,
      isUnlimited: finalNumberDriversId == '0',
    );

    log(
      '[OSAGO_BLOC] Updated insurance yaratildi: isUnlimited=${updatedInsurance.isUnlimited}',
      name: 'OSAGO',
    );
    
    // MUHIM: Drivers ni tekshirish va log qilish
    log(
      '[OSAGO_BLOC] LoadInsuranceCompany: currentDrivers count=${currentDrivers.length}',
      name: 'OSAGO',
    );
    for (var i = 0; i < currentDrivers.length; i++) {
      final d = currentDrivers[i];
      log(
        '[OSAGO_BLOC] LoadInsuranceCompany Driver[$i]: passport=${d.passportSeria} ${d.passportNumber}, relative=${d.relative}',
        name: 'OSAGO',
      );
    }

    // State ni yangilash - tez operatsiya
    emit(
      OsagoCompanyFilled(
        vehicle: currentVehicle,
        drivers: currentDrivers, // Drivers ni saqlash
        insurance: updatedInsurance,
        gosNumber: state.gosNumber,
        periodId: state.periodId ?? updatedInsurance.periodId,
        birthDate: state.birthDate,
        osagoType: state.osagoType,
      ),
    );

    log('[OSAGO_BLOC] ✅ OsagoCompanyFilled state emit qilindi', name: 'OSAGO');
    log('[OSAGO_BLOC] CalcRequested event yuborilmoqda...', name: 'OSAGO');

    // Calc requestni keyingi microtask da ishga tushirish - main thread ni bloklamaydi
    Future.microtask(() => add(const CalcRequested()));
  }

  Future<void> _onCalcRequested(
    CalcRequested event,
    Emitter<OsagoState> emit,
  ) async {
    log('[OSAGO_BLOC] CalcRequested event qabul qilindi', name: 'OSAGO');

    final vehicle = state.vehicle;
    final insurance = state.insurance;
    if (vehicle == null || insurance == null) {
      log(
        '[OSAGO_BLOC] ❌ Ma\'lumotlar to\'liq emas: vehicle=${vehicle != null}, insurance=${insurance != null}',
        name: 'OSAGO',
      );
      emit(_failureState('Ma\'lumotlar to\'liq emas'));
      return;
    }

    log(
      '[OSAGO_BLOC] Calc uchun: vehicle=${vehicle.gosNumber}, insurance=${insurance.provider}, periodId=${insurance.periodId}',
      name: 'OSAGO',
    );

    // OSAGO type dan numberDriversId ni map qilish (calc request yuborishdan oldin)
    String finalNumberDriversId = insurance.numberDriversId;
    log(
      '[OSAGO_BLOC] Initial numberDriversId: $finalNumberDriversId',
      name: 'OSAGO',
    );

    if (finalNumberDriversId != '0' && finalNumberDriversId != '5') {
      log(
        '[OSAGO_BLOC] ⚠️ numberDriversId noto\'g\'ri, mapping qilinmoqda...',
        name: 'OSAGO',
      );
      // OSAGO type dan map qilish
      final osagoType = state.osagoType;
      if (osagoType != null &&
          osagoType.toLowerCase().contains('cheklanmagan')) {
        finalNumberDriversId = '0';
        log('[OSAGO_BLOC] Mapping: cheklanmagan -> 0', name: 'OSAGO');
      } else {
        finalNumberDriversId = '5'; // Default: limited
        log('[OSAGO_BLOC] Mapping: default -> 5', name: 'OSAGO');
      }
    }

    // Insurance ni yangilangan numberDriversId bilan yaratish
    final updatedInsurance = OsagoInsurance(
      provider: insurance.provider,
      companyName: insurance.companyName,
      periodId: insurance.periodId,
      numberDriversId: finalNumberDriversId, // To'g'ri qiymat: '0' yoki '5'
      startDate: insurance.startDate,
      phoneNumber: insurance.phoneNumber,
      ownerInn: insurance.ownerInn,
      isUnlimited: finalNumberDriversId == '0',
    );

    log(
      '[OSAGO_BLOC] ✅ Updated insurance: numberDriversId=$finalNumberDriversId, isUnlimited=${updatedInsurance.isUnlimited}',
      name: 'OSAGO',
    );

    // Loading state ni emit qilish - tez operatsiya
    log(
      '[OSAGO_BLOC] OsagoLoading state emit qilinmoqda: drivers count=${state.drivers.length}',
      name: 'OSAGO',
    );
    emit(
      OsagoLoading(
        vehicle: vehicle,
        drivers: state.drivers,
        insurance: updatedInsurance,
        calcResponse: state.calcResponse,
        createResponse: state.createResponse,
        checkResponse: state.checkResponse,
        paymentMethod: state.paymentMethod,
        gosNumber: state.gosNumber,
        periodId: state.periodId,
        numberDriversId: finalNumberDriversId,
        ownerName: state.ownerName,
        birthDate: state.birthDate,
        osagoType: state.osagoType,
      ),
    );

    log('[OSAGO_BLOC] OsagoLoading state emit qilindi', name: 'OSAGO');
    log('[OSAGO_BLOC] API calc chaqiruvi boshlandi...', name: 'OSAGO');

    try {
      // API chaqiruvi - asenkron, main thread ni bloklamaydi
      final response = await _calcOsago(
        vehicle: vehicle,
        insurance: updatedInsurance,
      );

      log(
        '[OSAGO_BLOC] ✅ Calc API javob qabul qilindi: sessionId=${response.sessionId}, amount=${response.amount}',
        name: 'OSAGO',
      );
      log(
        '[OSAGO_BLOC] Calc response: numberDriversId=${response.numberDriversId}, ownerName=${response.ownerName}',
        name: 'OSAGO',
      );

      // Calc response dan kelgan numberDriversId ni validate qilish
      // Calc response dan kelgan qiymat ustunlik bilan ishlatiladi
      String? finalNumberDriversId = response.numberDriversId;

      // Agar calc response dan kelgan qiymat to'g'ri bo'lsa ('0' yoki '5'), ishlatamiz
      if (finalNumberDriversId != null &&
          finalNumberDriversId.isNotEmpty &&
          (finalNumberDriversId == '0' || finalNumberDriversId == '5')) {
        log(
          '[OSAGO_BLOC] ✅ Calc response dan kelgan numberDriversId to\'g\'ri: $finalNumberDriversId',
          name: 'OSAGO',
        );
        // Calc response dan kelgan qiymat to'g'ri, ishlatamiz
      } else {
        log(
          '[OSAGO_BLOC] ⚠️ Calc response dan kelgan numberDriversId noto\'g\'ri, yuborilgan qiymat ishlatilmoqda: ${updatedInsurance.numberDriversId}',
          name: 'OSAGO',
        );
        // Agar calc response dan kelgan qiymat noto'g'ri bo'lsa, yuborilgan qiymatni ishlatamiz
        finalNumberDriversId = updatedInsurance.numberDriversId;
      }

      log(
        '[OSAGO_BLOC] ✅ Final numberDriversId: $finalNumberDriversId',
        name: 'OSAGO',
      );

      // Success state ni emit qilish
      log(
        '[OSAGO_BLOC] OsagoCalcSuccess state emit qilinmoqda: drivers count=${state.drivers.length}',
        name: 'OSAGO',
      );
      emit(
        OsagoCalcSuccess(
          vehicle: vehicle,
          drivers: state.drivers,
          insurance: updatedInsurance,
          calcResponse: response,
          gosNumber: state.gosNumber,
          periodId: state.periodId,
          numberDriversId:
              finalNumberDriversId, // Calc response dan yoki yuborilgan qiymat
          ownerName: response.ownerName,
          birthDate: state.birthDate,
          osagoType: state.osagoType,
        ),
      );

      log('[OSAGO_BLOC] ✅ OsagoCalcSuccess state emit qilindi', name: 'OSAGO');
    } catch (error) {
      log('[OSAGO_BLOC] ❌ Calc xatosi: $error', name: 'OSAGO');
      emit(_failureState(_mapError(error)));
    }
  }

  Future<void> _onCreatePolicyRequested(
    CreatePolicyRequested event,
    Emitter<OsagoState> emit,
  ) async {
    log(
      '[OSAGO_BLOC] CreatePolicyRequested event qabul qilindi',
      name: 'OSAGO',
    );

    // Защита от повторных вызовов: используем синхронный флаг
    if (_isCreating) {
      log(
        '[OSAGO_BLOC] ⚠️ Polis yaratish allaqachon davom etmoqda, e\'tiborsiz qoldirildi',
        name: 'OSAGO',
      );
      return;
    }

    // Проверяем, не создан ли уже полис
    if (state.createResponse != null) {
      log(
        '[OSAGO_BLOC] ⚠️ Polis allaqachon yaratilgan, e\'tiborsiz qoldirildi',
        name: 'OSAGO',
      );
      return;
    }

    final calcResponse = state.calcResponse;
    final insurance = state.insurance;
    final vehicle = state.vehicle;
    if (calcResponse == null || insurance == null || vehicle == null) {
      log(
        '[OSAGO_BLOC] ❌ Ma\'lumotlar to\'liq emas: calcResponse=${calcResponse != null}, insurance=${insurance != null}, vehicle=${vehicle != null}',
        name: 'OSAGO',
      );
      emit(_failureState('Hisoblash natijasi topilmadi'));
      return;
    }

    // Agar haydovchilar bo'sh bo'lsa, egasining ma'lumotlaridan avtomatik yaratamiz
    List<OsagoDriver> drivers = state.drivers;
    if (drivers.isEmpty) {
      log(
        '[OSAGO_BLOC] ⚠️ Haydovchilar bo\'sh, egasining ma\'lumotlaridan yaratilmoqda...',
        name: 'OSAGO',
      );
      final ownerName = state.ownerName ?? calcResponse.ownerName;
      // Tug'ilgan sanani olish: state.birthDate yoki vehicle.ownerBirthDate
      // Agar ikkalasi ham hozirgi vaqt bo'lsa, 30 yil oldin sanani ishlatamiz (default)
      DateTime driverBirthday = state.birthDate ?? vehicle.ownerBirthDate;
      if (driverBirthday.year == DateTime.now().year &&
          driverBirthday.month == DateTime.now().month &&
          driverBirthday.day == DateTime.now().day) {
        // Agar hozirgi sana bo'lsa, 30 yil oldin sanani ishlatamiz
        driverBirthday = DateTime.now().subtract(
          const Duration(days: 365 * 30),
        );
        log(
          '[OSAGO_BLOC] ⚠️ Tug\'ilgan sana to\'g\'ri emas, default sana ishlatilmoqda: $driverBirthday',
          name: 'OSAGO',
        );
      }
      drivers = [
        OsagoDriver(
          passportSeria: vehicle.ownerPassportSeria,
          passportNumber: vehicle.ownerPassportNumber,
          driverBirthday: driverBirthday,
          relative: 0,
          name: ownerName,
          // License ma'lumotlari optional, shuning uchun null qoldiramiz
          licenseSeria: null,
          licenseNumber: null,
        ),
      ];
      log(
        '[OSAGO_BLOC] ✅ Haydovchi yaratildi: passport=${vehicle.ownerPassportSeria} ${vehicle.ownerPassportNumber}, name=$ownerName, birthday=$driverBirthday',
        name: 'OSAGO',
      );
    }

    log(
      '[OSAGO_BLOC] Create uchun: sessionId=${calcResponse.sessionId}, drivers count=${drivers.length}',
      name: 'OSAGO',
    );

    // Устанавливаем флаг перед началом создания
    _isCreating = true;

    emit(
      OsagoLoading(
        vehicle: vehicle,
        drivers: drivers,
        insurance: insurance,
        calcResponse: calcResponse,
        paymentMethod: state.paymentMethod,
        gosNumber: state.gosNumber,
        periodId: state.periodId,
        numberDriversId: state.numberDriversId ?? calcResponse.numberDriversId,
        ownerName: state.ownerName ?? calcResponse.ownerName,
        birthDate: state.birthDate,
        osagoType: state.osagoType,
      ),
    );

    log('[OSAGO_BLOC] OsagoLoading state emit qilindi', name: 'OSAGO');
    log('[OSAGO_BLOC] API create chaqiruvi boshlandi...', name: 'OSAGO');

    try {
      // numberDriversId ni state yoki calcResponse dan olamiz
      final finalNumberDriversId =
          state.numberDriversId ?? calcResponse.numberDriversId;
      log(
        '[OSAGO_BLOC] Create uchun numberDriversId: $finalNumberDriversId',
        name: 'OSAGO',
      );

      final response = await _createOsagoPolicy(
        sessionId: calcResponse.sessionId,
        drivers: drivers,
        insurance: insurance,
        vehicle: vehicle,
        ownerName: state.ownerName ?? calcResponse.ownerName,
        numberDriversId: finalNumberDriversId, // number_drivers_id ni uzatamiz
      );

      log(
        '[OSAGO_BLOC] ✅ Create API javob qabul qilindi: sessionId=${response.sessionId}, policyNumber=${response.policyNumber}',
        name: 'OSAGO',
      );
      log(
        '[OSAGO_BLOC] Create response: amount=${response.amount}, paymentUrl=${response.paymentUrl}',
        name: 'OSAGO',
      );
      log(
        '[OSAGO_BLOC] Payment URLs: clickUrl=${response.clickUrl}, paymeUrl=${response.paymeUrl}',
        name: 'OSAGO',
      );

      _checkAttempts = 0;
      log(
        '[OSAGO_BLOC] OsagoCreateSuccess state emit qilinmoqda: drivers count=${drivers.length}',
        name: 'OSAGO',
      );
      for (var i = 0; i < drivers.length; i++) {
        final d = drivers[i];
        log(
          '[OSAGO_BLOC] Driver[$i] in CreateSuccess: passport=${d.passportSeria} ${d.passportNumber}, relative=${d.relative}',
          name: 'OSAGO',
        );
      }
      emit(
        OsagoCreateSuccess(
          vehicle: vehicle,
          drivers: drivers,
          insurance: insurance,
          calcResponse: calcResponse,
          createResponse: response,
          paymentMethod: state.paymentMethod,
          gosNumber: state.gosNumber,
          periodId: state.periodId,
          numberDriversId:
              state.numberDriversId ?? calcResponse.numberDriversId,
          ownerName: state.ownerName ?? calcResponse.ownerName,
          birthDate: state.birthDate,
          osagoType: state.osagoType,
        ),
      );

      log(
        '[OSAGO_BLOC] ✅ OsagoCreateSuccess state emit qilindi',
        name: 'OSAGO',
      );
    } catch (error) {
      log('[OSAGO_BLOC] ❌ Create xatosi: $error', name: 'OSAGO');
      emit(_failureState(_mapError(error)));
    } finally {
      // Сбрасываем флаг в любом случае (успех или ошибка)
      _isCreating = false;
      log('[OSAGO_BLOC] _isCreating flag false qilindi', name: 'OSAGO');
    }
  }

  void _onPaymentSelected(PaymentSelected event, Emitter<OsagoState> emit) {
    log(
      '[OSAGO_BLOC] PaymentSelected event qabul qilindi: method=${event.method}',
      name: 'OSAGO',
    );

    log('[OSAGO_BLOC] ✅ To\'lov turi tanlandi: ${event.method}', name: 'OSAGO');

    // To'lov turini saqlash - state ni yangilash
    if (state.createResponse != null) {
      // Agar policy allaqachon yaratilgan bo'lsa, OsagoCreateSuccess state ni yangilaymiz
      emit(
        OsagoCreateSuccess(
          vehicle: state.vehicle!,
          drivers: state.drivers,
          insurance: state.insurance!,
          calcResponse: state.calcResponse!,
          createResponse: state.createResponse!,
          paymentMethod: event.method,
          gosNumber: state.gosNumber,
          periodId: state.periodId,
          numberDriversId: state.numberDriversId,
          ownerName: state.ownerName,
          birthDate: state.birthDate,
          osagoType: state.osagoType,
        ),
      );
    } else if (state.calcResponse != null) {
      // Agar policy hali yaratilmagan bo'lsa, lekin calc response bor bo'lsa,
      // to'lov turini saqlash uchun OsagoCalcSuccess state ni yangilaymiz
      emit(
        OsagoCalcSuccess(
          vehicle: state.vehicle!,
          drivers: state.drivers,
          insurance: state.insurance!,
          calcResponse: state.calcResponse!,
          paymentMethod: event.method,
          gosNumber: state.gosNumber,
          periodId: state.periodId,
          numberDriversId:
              state.numberDriversId ?? state.calcResponse!.numberDriversId,
          ownerName: state.ownerName ?? state.calcResponse!.ownerName,
          birthDate: state.birthDate,
          osagoType: state.osagoType,
        ),
      );
    } else {
      // Agar hech qanday ma'lumot bo'lmasa, faqat payment method ni saqlaymiz
      // Bu holat kamdan-kam uchraydi, lekin xavfsizlik uchun qo'shamiz
      log(
        '[OSAGO_BLOC] ⚠️ To\'lov turi saqlanmoqda, lekin ma\'lumotlar to\'liq emas',
        name: 'OSAGO',
      );
    }
  }

  Future<void> _onCheckPolicyRequested(
    CheckPolicyRequested event,
    Emitter<OsagoState> emit,
  ) async {
    log(
      '[OSAGO_BLOC] CheckPolicyRequested event qabul qilindi (attempt: ${_checkAttempts + 1}/$_maxCheckAttempts)',
      name: 'OSAGO',
    );

    final sessionId =
        state.createResponse?.sessionId ?? state.calcResponse?.sessionId;
    final vehicle = state.vehicle;
    final insurance = state.insurance;
    final calcResponse = state.calcResponse;
    final createResponse = state.createResponse;

    log('[OSAGO_BLOC] Check uchun: sessionId=$sessionId', name: 'OSAGO');

    if (sessionId == null ||
        vehicle == null ||
        insurance == null ||
        calcResponse == null ||
        createResponse == null) {
      log(
        '[OSAGO_BLOC] ❌ Buyurtma ma\'lumotlari topilmadi: sessionId=${sessionId != null}, vehicle=${vehicle != null}, insurance=${insurance != null}, calcResponse=${calcResponse != null}, createResponse=${createResponse != null}',
        name: 'OSAGO',
      );
      emit(_failureState('Buyurtma ma\'lumotlari topilmadi'));
      return;
    }

    emit(
      OsagoLoading(
        vehicle: vehicle,
        drivers: state.drivers,
        insurance: insurance,
        calcResponse: calcResponse,
        createResponse: createResponse,
        paymentMethod: state.paymentMethod,
        gosNumber: state.gosNumber,
        periodId: state.periodId,
        numberDriversId: state.numberDriversId,
        ownerName: state.ownerName,
        birthDate: state.birthDate,
        osagoType: state.osagoType,
      ),
    );

    log('[OSAGO_BLOC] API check chaqiruvi boshlandi...', name: 'OSAGO');

    try {
      final response = await _checkOsagoStatus(sessionId);
      log(
        '[OSAGO_BLOC] ✅ Check API javob qabul qilindi: isReady=${response.isReady}, status=${response.status}',
        name: 'OSAGO',
      );

      if (response.isReady) {
        log('[OSAGO_BLOC] ✅ Polis tayyor!', name: 'OSAGO');
        _checkAttempts = 0;
        log(
          '[OSAGO_BLOC] OsagoCheckSuccess state emit qilinmoqda: drivers count=${state.drivers.length}',
          name: 'OSAGO',
        );
        for (var i = 0; i < state.drivers.length; i++) {
          final d = state.drivers[i];
          log(
            '[OSAGO_BLOC] Driver[$i] in CheckSuccess: passport=${d.passportSeria} ${d.passportNumber}, relative=${d.relative}',
            name: 'OSAGO',
          );
        }
        emit(
          OsagoCheckSuccess(
            vehicle: vehicle,
            drivers: state.drivers,
            insurance: insurance,
            calcResponse: calcResponse,
            createResponse: createResponse,
            checkResponse: response,
            paymentMethod: state.paymentMethod,
            gosNumber: state.gosNumber,
            periodId: state.periodId,
            numberDriversId: state.numberDriversId,
            ownerName: state.ownerName,
            birthDate: state.birthDate,
            osagoType: state.osagoType,
          ),
        );
        log(
          '[OSAGO_BLOC] ✅ OsagoCheckSuccess state emit qilindi',
          name: 'OSAGO',
        );
        return;
      }

      log(
        '[OSAGO_BLOC] ⚠️ Polis hali tayyor emas, status=${response.status}',
        name: 'OSAGO',
      );
      _checkAttempts += 1;
      if (_checkAttempts >= _maxCheckAttempts) {
        log(
          '[OSAGO_BLOC] ❌ Max attempts yetdi ($_maxCheckAttempts), to\'xtatildi',
          name: 'OSAGO',
        );
        _checkAttempts = 0;
        emit(_failureState('Polis hali tayyor emas, keyinroq urinib ko\'ring'));
        return;
      }

      log(
        '[OSAGO_BLOC] Retry qilinmoqda... ($_checkRetryDelay keyin)',
        name: 'OSAGO',
      );

      emit(
        OsagoCreateSuccess(
          vehicle: vehicle,
          drivers: state.drivers,
          insurance: insurance,
          calcResponse: calcResponse,
          createResponse: createResponse,
          paymentMethod: state.paymentMethod,
          gosNumber: state.gosNumber,
          periodId: state.periodId,
          numberDriversId: state.numberDriversId,
          ownerName: state.ownerName,
          birthDate: state.birthDate,
          osagoType: state.osagoType,
        ),
      );
      // Retry ni keyingi microtask da ishga tushirish
      Future.microtask(() {
        Future.delayed(_checkRetryDelay, () {
          if (!isClosed) {
            log(
              '[OSAGO_BLOC] Retry: CheckPolicyRequested event yuborilmoqda...',
              name: 'OSAGO',
            );
            add(const CheckPolicyRequested());
          }
        });
      });
    } catch (error) {
      log('[OSAGO_BLOC] ❌ Check xatosi: $error', name: 'OSAGO');
      emit(_failureState(_mapError(error)));
    }
  }

  OsagoFailure _failureState(String message) {
    return OsagoFailure(
      message: message,
      vehicle: state.vehicle,
      drivers: state.drivers,
      insurance: state.insurance,
      calcResponse: state.calcResponse,
      createResponse: state.createResponse,
      checkResponse: state.checkResponse,
      paymentMethod: state.paymentMethod,
      gosNumber: state.gosNumber,
      periodId: state.periodId,
      numberDriversId: state.numberDriversId,
      ownerName: state.ownerName,
      birthDate: state.birthDate,
      osagoType: state.osagoType,
    );
  }

  String _mapError(Object error) {
    log(
      '[OSAGO_BLOC] _mapError: error type=${error.runtimeType}, error=$error',
      name: 'OSAGO',
    );

    if (error is AppException) {
      log('[OSAGO_BLOC] AppException: ${error.message}', name: 'OSAGO');
      if (error.details != null) {
        log(
          '[OSAGO_BLOC] AppException details: ${error.details}',
          name: 'OSAGO',
        );
      }
      // Улучшенная обработка ошибки "provider not implemented"
      if (error.message.toLowerCase().contains('provider not implemented')) {
        return 'Tanlangan sug\'urta kompaniyasi hozircha mavjud emas. Iltimos, boshqa kompaniyani tanlang.';
      }
      return error.message;
    }
    if (error is Exception) {
      final message = error.toString().replaceFirst('Exception: ', '');
      log('[OSAGO_BLOC] Exception: $message', name: 'OSAGO');
      return message;
    }
    log('[OSAGO_BLOC] Noma\'lum xatolik', name: 'OSAGO');
    return 'Noma\'lum xatolik yuz berdi';
  }
}
