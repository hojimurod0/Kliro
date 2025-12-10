import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/errors/app_exception.dart';
import '../../../domain/entities/travel_insurance.dart';
import '../../../domain/usecases/calc_travel.dart';
import '../../../domain/usecases/check_travel_status.dart';
import '../../../domain/usecases/create_travel_policy.dart';
import '../../../domain/repositories/travel_repository.dart';
import 'travel_event.dart';
import 'travel_state.dart';

class TravelBloc extends Bloc<TravelEvent, TravelState> {
  TravelBloc({
    required CalcTravel calcTravel,
    required CreateTravelPolicy createTravelPolicy,
    required CheckTravelStatus checkTravelStatus,
    required TravelRepository repository,
  }) : _calcTravel = calcTravel,
       _createTravelPolicy = createTravelPolicy,
       _checkTravelStatus = checkTravelStatus,
       _repository = repository,
       super(const TravelInitial()) {
    log(
      '[TRAVEL_BLOC] TravelBloc yaratildi, event handlerlar ro\'yxatdan o\'tkazilmoqda...',
      name: 'TRAVEL',
    );
    on<LoadPersonsData>(_onLoadPersonsData);
    on<LoadInsuranceData>(_onLoadInsuranceData);
    on<CalcRequested>(_onCalcRequested);
    on<CreatePolicyRequested>(_onCreatePolicyRequested);
    on<PaymentSelected>(_onPaymentSelected);
    on<CheckPolicyRequested>(_onCheckPolicyRequested);
    on<PurposeSubmitted>(_onPurposeSubmitted);
    on<DetailsSubmitted>(_onDetailsSubmitted);
    on<LoadCountries>(_onLoadCountries);
    on<LoadPurposes>(_onLoadPurposes);
    on<LoadTarifs>(_onLoadTarifs);
    log(
      '[TRAVEL_BLOC] ✅ Barcha event handlerlar ro\'yxatdan o\'tkazildi',
      name: 'TRAVEL',
    );
  }

  final CalcTravel _calcTravel;
  final CreateTravelPolicy _createTravelPolicy;
  final CheckTravelStatus _checkTravelStatus;
  final TravelRepository _repository;
  static const int _maxCheckAttempts = 3;
  static const Duration _checkRetryDelay = Duration(seconds: 3);

  int _checkAttempts = 0;
  bool _isCreating = false;

  void _onLoadPersonsData(LoadPersonsData event, Emitter<TravelState> emit) {
    log(
      '[TRAVEL_BLOC] 📝 LoadPersonsData event qabul qilindi:\n'
      '  - Sayohatchilar soni: ${event.persons.length}\n'
      '  - Insurance: ${event.insurance != null ? "mavjud" : "yo'q"}\n'
      '  - Session ID: ${state.sessionId ?? "yo'q"}',
      name: 'TRAVEL',
    );
    
    emit(
      TravelPersonsFilled(
        persons: event.persons,
        insurance: event.insurance,
        sessionId: state.sessionId,
      ),
    );
    
    log(
      '[TRAVEL_BLOC] ✅ TravelPersonsFilled state emit qilindi',
      name: 'TRAVEL',
    );
  }

  void _onLoadInsuranceData(
    LoadInsuranceData event,
    Emitter<TravelState> emit,
  ) {
    log(
      '[TRAVEL_BLOC] 📝 LoadInsuranceData event qabul qilindi:\n'
      '  - Provider: ${event.insurance.provider}\n'
      '  - Company: ${event.insurance.companyName}\n'
      '  - Phone: ${event.insurance.phoneNumber}\n'
      '  - Email: ${event.insurance.email ?? "yo'q"}\n'
      '  - Session ID: ${event.insurance.sessionId ?? "yo'q"}\n'
      '  - Amount: ${event.insurance.amount ?? "yo'q"}\n'
      '  - Country: ${event.insurance.countryName ?? "yo'q"}\n'
      '  - Purpose: ${event.insurance.purposeName ?? "yo'q"}',
      name: 'TRAVEL',
    );
    
    emit(
      TravelInsuranceFilled(
        persons: state.persons,
        insurance: event.insurance,
        sessionId: state.sessionId,
      ),
    );
    
    log(
      '[TRAVEL_BLOC] ✅ TravelInsuranceFilled state emit qilindi',
      name: 'TRAVEL',
    );
  }

  Future<void> _onCalcRequested(
    CalcRequested event,
    Emitter<TravelState> emit,
  ) async {
    log(
      '[TRAVEL_BLOC] 🔄 CalcRequested event qabul qilindi',
      name: 'TRAVEL',
    );
    
    if (state.persons.isEmpty || state.insurance == null) {
      log(
        '[TRAVEL_BLOC] ❌ CalcRequested: Ma\'lumotlar to\'liq emas!\n'
        '  - Persons: ${state.persons.length}\n'
        '  - Insurance: ${state.insurance != null ? "mavjud" : "yo'q"}',
        name: 'TRAVEL',
      );
      emit(
        TravelFailure(
          message: 'Ma\'lumotlar to\'liq emas',
          persons: state.persons,
          insurance: state.insurance,
          sessionId: state.sessionId,
        ),
      );
      return;
    }

    // ✅ Session ID tekshirish
    final currentInsurance = state.insurance!;
    // Session ID ni state yoki insurance'dan olish
    final sessionIdFromState = state.sessionId;
    // TravelInsurance entity'da sessionId field mavjud
    final sessionIdFromInsurance = currentInsurance.sessionId;
    final sessionId = sessionIdFromState ?? sessionIdFromInsurance;

    if (sessionId == null || sessionId.isEmpty) {
      emit(
        TravelFailure(
          message: 'Session ID mavjud emas',
          persons: state.persons,
          insurance: state.insurance,
          sessionId: state.sessionId,
        ),
      );
      return;
    }

    // ✅ Persons ma'lumotlarini to'liqligini tekshirish
    final hasEmptyFields = state.persons.any(
      (person) =>
          person.firstName.isEmpty ||
          person.lastName.isEmpty ||
          person.passportSeria.isEmpty ||
          person.passportNumber.isEmpty,
    );

    if (hasEmptyFields) {
      emit(
        TravelFailure(
          message:
              'Shaxsiy ma\'lumotlar to\'liq emas. Iltimos, barcha maydonlarni to\'ldiring.',
          persons: state.persons,
          insurance: state.insurance,
          sessionId: state.sessionId,
        ),
      );
      return;
    }

    log(
      '[TRAVEL_BLOC] ⏳ CalcTravel API chaqirilmoqda...\n'
      '  - Session ID: $sessionId\n'
      '  - Persons: ${state.persons.length}\n'
      '  - Provider: ${currentInsurance.provider}',
      name: 'TRAVEL',
    );
    
    emit(
      TravelLoading(
        persons: state.persons,
        insurance: state.insurance,
        sessionId: state.sessionId,
      ),
    );

    try {
      // ✅ Insurance'ga sessionId qo'shish
      // TravelInsurance entity'da sessionId, amount, programId field'lar mavjud
      final insuranceWithSessionId = TravelInsurance(
        provider: currentInsurance.provider,
        companyName: currentInsurance.companyName,
        startDate: currentInsurance.startDate,
        endDate: currentInsurance.endDate,
        phoneNumber: currentInsurance.phoneNumber,
        email: currentInsurance.email,
        sessionId: sessionId,
        amount: currentInsurance.amount,
        programId: currentInsurance.programId,
      );

      final result = await _calcTravel(
        persons: state.persons,
        insurance: insuranceWithSessionId,
      );

      log(
        '[TRAVEL_BLOC] ✅ CalcTravel muvaffaqiyatli:\n'
        '  - Amount: ${result.amount} ${result.currency}\n'
        '  - Session ID: ${result.sessionId}',
        name: 'TRAVEL',
      );

      emit(
        TravelCalcSuccess(
          persons: state.persons,
          insurance: state.insurance,
          calcResponse: result,
          sessionId: state.sessionId,
        ),
      );
    } on AppException catch (e) {
      emit(
        TravelFailure(
          message: e.message,
          persons: state.persons,
          insurance: state.insurance,
          sessionId: state.sessionId,
        ),
      );
    } catch (e) {
      emit(
        TravelFailure(
          message: 'Noma\'lum xatolik: ${e.toString()}',
          persons: state.persons,
          insurance: state.insurance,
          sessionId: state.sessionId,
        ),
      );
    }
  }

  Future<void> _onCreatePolicyRequested(
    CreatePolicyRequested event,
    Emitter<TravelState> emit,
  ) async {
    log(
      '[TRAVEL_BLOC] 🔄 CreatePolicyRequested event qabul qilindi',
      name: 'TRAVEL',
    );
    
    if (_isCreating) {
      log(
        '[TRAVEL_BLOC] ⚠️ CreatePolicyRequested: Polis yaratish jarayoni allaqachon davom etmoqda',
        name: 'TRAVEL',
      );
      return;
    }

    if (state.calcResponse == null || state.insurance == null) {
      log(
        '[TRAVEL_BLOC] ❌ CreatePolicyRequested: Ma\'lumotlar to\'liq emas!\n'
        '  - CalcResponse: ${state.calcResponse != null ? "mavjud" : "yo'q"}\n'
        '  - Insurance: ${state.insurance != null ? "mavjud" : "yo'q"}',
        name: 'TRAVEL',
      );
      emit(
        TravelFailure(
          message: 'Hisob-kitob natijasi mavjud emas',
          persons: state.persons,
          insurance: state.insurance,
          calcResponse: state.calcResponse,
          sessionId: state.sessionId,
        ),
      );
      return;
    }

    _isCreating = true;
    log(
      '[TRAVEL_BLOC] ⏳ CreateTravelPolicy API chaqirilmoqda...\n'
      '  - Session ID: ${state.calcResponse!.sessionId}\n'
      '  - Payment Method: ${state.paymentMethod ?? "yo'q"}\n'
      '  - Persons: ${state.persons.length}',
      name: 'TRAVEL',
    );
    emit(
      TravelLoading(
        persons: state.persons,
        insurance: state.insurance,
        calcResponse: state.calcResponse,
        sessionId: state.sessionId,
      ),
    );

    try {
      // ✅ calcResponse'dan amount ni olish va uzatish
      final amount = state.calcResponse!.amount;
      log(
        '[TRAVEL_BLOC] 💰 Amount olinmoqda:\n'
        '  - calcResponse.amount: $amount\n'
        '  - insurance.amount: ${state.insurance!.amount}',
        name: 'TRAVEL',
      );
      
      final result = await _createTravelPolicy(
        sessionId: state.calcResponse!.sessionId,
        persons: state.persons,
        insurance: state.insurance!,
        amount: amount, // ✅ calcResponse'dan amount ni uzatish
      );

      log(
        '[TRAVEL_BLOC] ✅ CreateTravelPolicy muvaffaqiyatli:\n'
        '  - Policy Number: ${result.policyNumber}\n'
        '  - Amount: ${result.amount} ${result.currency}\n'
        '  - Payment URL: ${result.paymentUrl.isNotEmpty ? "mavjud" : "yo'q"}\n'
        '  - Click URL: ${result.clickUrl != null ? "mavjud" : "yo'q"}\n'
        '  - Payme URL: ${result.paymeUrl != null ? "mavjud" : "yo'q"}',
        name: 'TRAVEL',
      );

      emit(
        TravelCreateSuccess(
          persons: state.persons,
          insurance: state.insurance,
          calcResponse: state.calcResponse,
          createResponse: result,
          paymentMethod: state.paymentMethod, // PaymentMethod ni saqlash
          sessionId: state.sessionId,
        ),
      );
    } on AppException catch (e) {
      log(
        '[TRAVEL_BLOC] ❌ CreateTravelPolicy xatolik: ${e.message}',
        name: 'TRAVEL',
      );
      emit(
        TravelFailure(
          message: e.message,
          persons: state.persons,
          insurance: state.insurance,
          calcResponse: state.calcResponse,
          sessionId: state.sessionId,
        ),
      );
    } catch (e) {
      log(
        '[TRAVEL_BLOC] ❌ CreateTravelPolicy noma\'lum xatolik: ${e.toString()}',
        name: 'TRAVEL',
      );
      emit(
        TravelFailure(
          message: 'Noma\'lum xatolik: ${e.toString()}',
          persons: state.persons,
          insurance: state.insurance,
          calcResponse: state.calcResponse,
          sessionId: state.sessionId,
        ),
      );
    } finally {
      _isCreating = false;
    }
  }

  void _onPaymentSelected(PaymentSelected event, Emitter<TravelState> emit) {
    log(
      '[TRAVEL_BLOC] 💳 PaymentSelected event qabul qilindi: ${event.method}',
      name: 'TRAVEL',
    );
    
    emit(
      TravelCalcSuccess(
        persons: state.persons,
        insurance: state.insurance,
        calcResponse: state.calcResponse,
        paymentMethod: event.method,
        sessionId: state.sessionId,
      ),
    );
    
    log(
      '[TRAVEL_BLOC] ✅ PaymentMethod saqlandi: ${event.method}',
      name: 'TRAVEL',
    );
  }

  Future<void> _onCheckPolicyRequested(
    CheckPolicyRequested event,
    Emitter<TravelState> emit,
  ) async {
    if (state.createResponse == null) {
      emit(
        TravelFailure(
          message: 'Polisa yaratilmagan',
          persons: state.persons,
          insurance: state.insurance,
          calcResponse: state.calcResponse,
          createResponse: state.createResponse,
          sessionId: state.sessionId,
        ),
      );
      return;
    }

    _checkAttempts = 0;
    await _checkWithRetry(emit);
  }

  Future<void> _checkWithRetry(Emitter<TravelState> emit) async {
    if (_checkAttempts >= _maxCheckAttempts) {
      emit(
        TravelFailure(
          message: 'Polisa holatini tekshirishda xatolik',
          persons: state.persons,
          insurance: state.insurance,
          calcResponse: state.calcResponse,
          createResponse: state.createResponse,
          sessionId: state.sessionId,
        ),
      );
      return;
    }

    _checkAttempts++;

    try {
      final result = await _checkTravelStatus(
        sessionId: state.createResponse!.sessionId,
      );

      if (result.status == 'ready' || result.status == 'paid') {
        emit(
          TravelCheckSuccess(
            persons: state.persons,
            insurance: state.insurance,
            calcResponse: state.calcResponse,
            createResponse: state.createResponse,
            checkResponse: result,
            sessionId: state.sessionId,
          ),
        );
      } else {
        await Future.delayed(_checkRetryDelay);
        await _checkWithRetry(emit);
      }
    } on AppException catch (e) {
      emit(
        TravelFailure(
          message: e.message,
          persons: state.persons,
          insurance: state.insurance,
          calcResponse: state.calcResponse,
          createResponse: state.createResponse,
          sessionId: state.sessionId,
        ),
      );
    } catch (e) {
      await Future.delayed(_checkRetryDelay);
      await _checkWithRetry(emit);
    }
  }

  Future<void> _onPurposeSubmitted(
    PurposeSubmitted event,
    Emitter<TravelState> emit,
  ) async {
    emit(
      TravelLoading(
        persons: state.persons,
        insurance: state.insurance,
        sessionId: state.sessionId,
      ),
    );

    try {
      final sessionId = await _repository.createPurpose(
        purposeId: event.purposeId,
        destinations: event.destinations,
      );

      emit(
        PurposeCreated(
          sessionId: sessionId,
          persons: state.persons,
          insurance: state.insurance,
        ),
      );
    } on AppException catch (e) {
      emit(
        TravelFailure(
          message: e.message,
          persons: state.persons,
          insurance: state.insurance,
          sessionId: state.sessionId,
        ),
      );
    } catch (e) {
      emit(
        TravelFailure(
          message: 'Noma\'lum xatolik: ${e.toString()}',
          persons: state.persons,
          insurance: state.insurance,
          sessionId: state.sessionId,
        ),
      );
    }
  }

  Future<void> _onDetailsSubmitted(
    DetailsSubmitted event,
    Emitter<TravelState> emit,
  ) async {
    emit(
      TravelLoading(
        persons: state.persons,
        insurance: state.insurance,
        sessionId: state.sessionId,
      ),
    );

    try {
      await _repository.sendDetails(
        sessionId: event.sessionId,
        startDate: event.startDate,
        endDate: event.endDate,
        travelersBirthdates: event.travelersBirthdates,
        annualPolicy: event.annualPolicy,
        covidProtection: event.covidProtection,
      );

      emit(
        DetailsSaved(
          persons: state.persons,
          insurance: state.insurance,
          sessionId: state.sessionId,
        ),
      );
    } on AppException catch (e) {
      emit(
        TravelFailure(
          message: e.message,
          persons: state.persons,
          insurance: state.insurance,
          sessionId: state.sessionId,
        ),
      );
    } catch (e) {
      emit(
        TravelFailure(
          message: 'Noma\'lum xatolik: ${e.toString()}',
          persons: state.persons,
          insurance: state.insurance,
          sessionId: state.sessionId,
        ),
      );
    }
  }

  Future<void> _onLoadCountries(
    LoadCountries event,
    Emitter<TravelState> emit,
  ) async {
    emit(
      TravelLoading(
        persons: state.persons,
        insurance: state.insurance,
        sessionId: state.sessionId,
      ),
    );

    try {
      final countries = await _repository.getCountries();

      emit(
        CountriesLoaded(
          countries: countries,
          persons: state.persons,
          insurance: state.insurance,
          sessionId: state.sessionId,
        ),
      );
    } on AppException catch (e) {
      emit(
        TravelFailure(
          message: e.message,
          persons: state.persons,
          insurance: state.insurance,
          sessionId: state.sessionId,
        ),
      );
    } catch (e) {
      emit(
        TravelFailure(
          message: 'Noma\'lum xatolik: ${e.toString()}',
          persons: state.persons,
          insurance: state.insurance,
          sessionId: state.sessionId,
        ),
      );
    }
  }

  Future<void> _onLoadPurposes(
    LoadPurposes event,
    Emitter<TravelState> emit,
  ) async {
    emit(
      TravelLoading(
        persons: state.persons,
        insurance: state.insurance,
        sessionId: state.sessionId,
      ),
    );

    try {
      final purposes = await _repository.getPurposes();

      // Если список пустой, используем fallback данные
      if (purposes.isEmpty) {
        emit(
          PurposesLoaded(
            purposes: [
              {
                'id': 1,
                'name': 'Turizm',
                'uz': 'Turizm',
                'ru': 'Туризм',
                'en': 'Tourism',
              },
              {
                'id': 2,
                'name': 'Biznes',
                'uz': 'Biznes',
                'ru': 'Бизнес',
                'en': 'Business',
              },
              {
                'id': 3,
                'name': 'Davolanish',
                'uz': 'Davolanish',
                'ru': 'Лечение',
                'en': 'Treatment',
              },
              {
                'id': 4,
                'name': "Ta'lim",
                'uz': "Ta'lim",
                'ru': 'Обучение',
                'en': 'Education',
              },
            ],
            persons: state.persons,
            insurance: state.insurance,
            sessionId: state.sessionId,
          ),
        );
      } else {
        emit(
          PurposesLoaded(
            purposes: purposes,
            persons: state.persons,
            insurance: state.insurance,
            sessionId: state.sessionId,
          ),
        );
      }
    } on AppException {
      // При ошибке используем fallback данные
      emit(
        PurposesLoaded(
          purposes: [
            {
              'id': 1,
              'name': 'Turizm',
              'uz': 'Turizm',
              'ru': 'Туризм',
              'en': 'Tourism',
            },
            {
              'id': 2,
              'name': 'Biznes',
              'uz': 'Biznes',
              'ru': 'Бизнес',
              'en': 'Business',
            },
            {
              'id': 3,
              'name': 'Davolanish',
              'uz': 'Davolanish',
              'ru': 'Лечение',
              'en': 'Treatment',
            },
            {
              'id': 4,
              'name': "Ta'lim",
              'uz': "Ta'lim",
              'ru': 'Обучение',
              'en': 'Education',
            },
          ],
          persons: state.persons,
          insurance: state.insurance,
          sessionId: state.sessionId,
        ),
      );
    } catch (e) {
      // При любой ошибке используем fallback данные
      emit(
        PurposesLoaded(
          purposes: [
            {
              'id': 1,
              'name': 'Turizm',
              'uz': 'Turizm',
              'ru': 'Туризм',
              'en': 'Tourism',
            },
            {
              'id': 2,
              'name': 'Biznes',
              'uz': 'Biznes',
              'ru': 'Бизнес',
              'en': 'Business',
            },
            {
              'id': 3,
              'name': 'Davolanish',
              'uz': 'Davolanish',
              'ru': 'Лечение',
              'en': 'Treatment',
            },
            {
              'id': 4,
              'name': "Ta'lim",
              'uz': "Ta'lim",
              'ru': 'Обучение',
              'en': 'Education',
            },
          ],
          persons: state.persons,
          insurance: state.insurance,
          sessionId: state.sessionId,
        ),
      );
    }
  }

  Future<void> _onLoadTarifs(
    LoadTarifs event,
    Emitter<TravelState> emit,
  ) async {
    emit(
      TravelLoading(
        persons: state.persons,
        insurance: state.insurance,
        sessionId: state.sessionId,
      ),
    );

    try {
      final tarifs = await _repository.getTarifs(event.countryCode);

      emit(
        TarifsLoaded(
          tarifs: tarifs,
          persons: state.persons,
          insurance: state.insurance,
          sessionId: state.sessionId,
        ),
      );
    } on AppException catch (e) {
      emit(
        TravelFailure(
          message: e.message,
          persons: state.persons,
          insurance: state.insurance,
          sessionId: state.sessionId,
        ),
      );
    } catch (e) {
      emit(
        TravelFailure(
          message: 'Noma\'lum xatolik: ${e.toString()}',
          persons: state.persons,
          insurance: state.insurance,
          sessionId: state.sessionId,
        ),
      );
    }
  }
}
