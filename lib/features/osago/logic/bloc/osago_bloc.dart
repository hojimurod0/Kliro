import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
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
    on<LoadVehicleData>(_onLoadVehicleData);
    on<LoadInsuranceCompany>(_onLoadInsuranceCompany);
    on<CalcRequested>(_onCalcRequested);
    on<CreatePolicyRequested>(_onCreatePolicyRequested);
    on<PaymentSelected>(_onPaymentSelected);
    on<CheckPolicyRequested>(_onCheckPolicyRequested);
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

    // OSAGO type va provider ga qarab numberDriversId ni map qilish
    // Agar event.insurance.numberDriversId to'g'ri bo'lmasa, provider va OSAGO type dan olamiz
    String finalNumberDriversId = event.insurance.numberDriversId;
    log(
      '[OSAGO_BLOC] Initial numberDriversId: $finalNumberDriversId',
      name: 'OSAGO',
    );

    if (finalNumberDriversId != '0' && finalNumberDriversId != '5') {
      log(
        '[OSAGO_BLOC] ⚠️ numberDriversId noto\'g\'ri, mapping qilinmoqda...',
        name: 'OSAGO',
      );
      // Provider va OSAGO type dan map qilish
      final osagoType = state.osagoType;
      final provider = event.insurance.provider;

      log(
        '[OSAGO_BLOC] Mapping uchun: osagoType=$osagoType, provider=$provider',
        name: 'OSAGO',
      );

      // Provider ga qarab mapping (ustunlik)
      final providerLower = provider.toLowerCase();
      if (providerLower == 'neo') {
        // NEO -> cheklanmagan (0) - nechta bo'lsa, hammasini qo'shadi
        finalNumberDriversId = '0';
        log('[OSAGO_BLOC] Mapping: NEO -> 0 (cheklanmagan)', name: 'OSAGO');
      } else if (providerLower == 'gusto') {
        // GUSTO -> cheklangan (5) - 5 tagacha
        finalNumberDriversId = '5';
        log('[OSAGO_BLOC] Mapping: GUSTO -> 5 (cheklangan)', name: 'OSAGO');
      } else if (providerLower == 'gross') {
        // GROSS -> default (5)
        finalNumberDriversId = '5';
        log('[OSAGO_BLOC] Mapping: GROSS -> 5 (default)', name: 'OSAGO');
      } else {
        // OSAGO type dan map qilish
        if (osagoType != null &&
            osagoType.toLowerCase().contains('cheklanmagan')) {
          finalNumberDriversId = '0';
          log(
            '[OSAGO_BLOC] Mapping: OSAGO type (cheklanmagan) -> 0',
            name: 'OSAGO',
          );
        } else {
          finalNumberDriversId = '5'; // Default: limited
          log('[OSAGO_BLOC] Mapping: OSAGO type (default) -> 5', name: 'OSAGO');
        }
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

    // State ni yangilash - tez operatsiya
    emit(
      OsagoCompanyFilled(
        vehicle: currentVehicle,
        drivers: state.drivers,
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
    if (state.drivers.isEmpty) {
      log('[OSAGO_BLOC] ❌ Haydovchi ma\'lumotlari kiritilmagan', name: 'OSAGO');
      emit(_failureState('Haydovchi ma\'lumotlari kiritilmagan'));
      return;
    }

    log(
      '[OSAGO_BLOC] Create uchun: sessionId=${calcResponse.sessionId}, drivers count=${state.drivers.length}',
      name: 'OSAGO',
    );

    // Устанавливаем флаг перед началом создания
    _isCreating = true;

    emit(
      OsagoLoading(
        vehicle: vehicle,
        drivers: state.drivers,
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
      // Postman collection ga ko'ra: create requestda number_drivers_id yo'q
      // Shuningdek, applicant_is_driver doim false bo'lishi kerak
      final response = await _createOsagoPolicy(
        sessionId: calcResponse.sessionId,
        drivers: state.drivers,
        insurance: insurance,
        vehicle: vehicle,
        ownerName: state.ownerName ?? calcResponse.ownerName,
        numberDriversId:
            null, // Create requestda ishlatilmaydi (Postman collection ga ko'ra)
      );

      log(
        '[OSAGO_BLOC] ✅ Create API javob qabul qilindi: sessionId=${response.sessionId}, policyNumber=${response.policyNumber}',
        name: 'OSAGO',
      );
      log(
        '[OSAGO_BLOC] Create response: amount=${response.amount}, paymentUrl=${response.paymentUrl}',
        name: 'OSAGO',
      );

      _checkAttempts = 0;
      emit(
        OsagoCreateSuccess(
          vehicle: vehicle,
          drivers: state.drivers,
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

    if (state is! OsagoCreateSuccess || state.createResponse == null) {
      log(
        '[OSAGO_BLOC] ❌ To\'lov tanlash uchun buyurtma yaratilmagan',
        name: 'OSAGO',
      );
      emit(
        _failureState('To\'lovni amalga oshirishdan avval buyurtma yarating'),
      );
      return;
    }

    log('[OSAGO_BLOC] ✅ To\'lov turi tanlandi: ${event.method}', name: 'OSAGO');

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
