import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/errors/app_exception.dart';
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
  })  : _calcTravel = calcTravel,
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

  void _onLoadPersonsData(
    LoadPersonsData event,
    Emitter<TravelState> emit,
  ) {
    emit(TravelPersonsFilled(
      persons: event.persons,
      insurance: event.insurance,
    ));
  }

  void _onLoadInsuranceData(
    LoadInsuranceData event,
    Emitter<TravelState> emit,
  ) {
    emit(TravelInsuranceFilled(
      persons: state.persons,
      insurance: event.insurance,
    ));
  }

  Future<void> _onCalcRequested(
    CalcRequested event,
    Emitter<TravelState> emit,
  ) async {
    if (state.persons.isEmpty || state.insurance == null) {
      emit(TravelFailure(
        message: 'Ma\'lumotlar to\'liq emas',
        persons: state.persons,
        insurance: state.insurance,
      ));
      return;
    }

    emit(TravelLoading(
      persons: state.persons,
      insurance: state.insurance,
    ));

    try {
      final result = await _calcTravel(
        persons: state.persons,
        insurance: state.insurance!,
      );

      emit(TravelCalcSuccess(
        persons: state.persons,
        insurance: state.insurance,
        calcResponse: result,
      ));
    } on AppException catch (e) {
      emit(TravelFailure(
        message: e.message,
        persons: state.persons,
        insurance: state.insurance,
      ));
    } catch (e) {
      emit(TravelFailure(
        message: 'Noma\'lum xatolik: ${e.toString()}',
        persons: state.persons,
        insurance: state.insurance,
      ));
    }
  }

  Future<void> _onCreatePolicyRequested(
    CreatePolicyRequested event,
    Emitter<TravelState> emit,
  ) async {
    if (_isCreating) return;

    if (state.calcResponse == null || state.insurance == null) {
      emit(TravelFailure(
        message: 'Hisob-kitob natijasi mavjud emas',
        persons: state.persons,
        insurance: state.insurance,
        calcResponse: state.calcResponse,
      ));
      return;
    }

    _isCreating = true;
    emit(TravelLoading(
      persons: state.persons,
      insurance: state.insurance,
      calcResponse: state.calcResponse,
    ));

    try {
      final result = await _createTravelPolicy(
        sessionId: state.calcResponse!.sessionId,
        persons: state.persons,
        insurance: state.insurance!,
      );

      emit(TravelCreateSuccess(
        persons: state.persons,
        insurance: state.insurance,
        calcResponse: state.calcResponse,
        createResponse: result,
      ));
    } on AppException catch (e) {
      emit(TravelFailure(
        message: e.message,
        persons: state.persons,
        insurance: state.insurance,
        calcResponse: state.calcResponse,
      ));
    } catch (e) {
      emit(TravelFailure(
        message: 'Noma\'lum xatolik: ${e.toString()}',
        persons: state.persons,
        insurance: state.insurance,
        calcResponse: state.calcResponse,
      ));
    } finally {
      _isCreating = false;
    }
  }

  void _onPaymentSelected(
    PaymentSelected event,
    Emitter<TravelState> emit,
  ) {
    emit(TravelCalcSuccess(
      persons: state.persons,
      insurance: state.insurance,
      calcResponse: state.calcResponse,
      paymentMethod: event.method,
    ));
  }

  Future<void> _onCheckPolicyRequested(
    CheckPolicyRequested event,
    Emitter<TravelState> emit,
  ) async {
    if (state.createResponse == null) {
      emit(TravelFailure(
        message: 'Polisa yaratilmagan',
        persons: state.persons,
        insurance: state.insurance,
        calcResponse: state.calcResponse,
        createResponse: state.createResponse,
      ));
      return;
    }

    _checkAttempts = 0;
    await _checkWithRetry(emit);
  }

  Future<void> _checkWithRetry(Emitter<TravelState> emit) async {
    if (_checkAttempts >= _maxCheckAttempts) {
      emit(TravelFailure(
        message: 'Polisa holatini tekshirishda xatolik',
        persons: state.persons,
        insurance: state.insurance,
        calcResponse: state.calcResponse,
        createResponse: state.createResponse,
      ));
      return;
    }

    _checkAttempts++;

    try {
      final result = await _checkTravelStatus(
        sessionId: state.createResponse!.sessionId,
      );

      if (result.status == 'ready' || result.status == 'paid') {
        emit(TravelCheckSuccess(
          persons: state.persons,
          insurance: state.insurance,
          calcResponse: state.calcResponse,
          createResponse: state.createResponse,
          checkResponse: result,
        ));
      } else {
        await Future.delayed(_checkRetryDelay);
        await _checkWithRetry(emit);
      }
    } on AppException catch (e) {
      emit(TravelFailure(
        message: e.message,
        persons: state.persons,
        insurance: state.insurance,
        calcResponse: state.calcResponse,
        createResponse: state.createResponse,
      ));
    } catch (e) {
      await Future.delayed(_checkRetryDelay);
      await _checkWithRetry(emit);
    }
  }

  Future<void> _onPurposeSubmitted(
    PurposeSubmitted event,
    Emitter<TravelState> emit,
  ) async {
    emit(TravelLoading(
      persons: state.persons,
      insurance: state.insurance,
    ));

    try {
      final sessionId = await _repository.createPurpose(
        purposeId: event.purposeId,
        destinations: event.destinations,
      );

      emit(PurposeCreated(
        sessionId: sessionId,
        persons: state.persons,
        insurance: state.insurance,
      ));
    } on AppException catch (e) {
      emit(TravelFailure(
        message: e.message,
        persons: state.persons,
        insurance: state.insurance,
      ));
    } catch (e) {
      emit(TravelFailure(
        message: 'Noma\'lum xatolik: ${e.toString()}',
        persons: state.persons,
        insurance: state.insurance,
      ));
    }
  }

  Future<void> _onDetailsSubmitted(
    DetailsSubmitted event,
    Emitter<TravelState> emit,
  ) async {
    emit(TravelLoading(
      persons: state.persons,
      insurance: state.insurance,
    ));

    try {
      await _repository.sendDetails(
        sessionId: event.sessionId,
        startDate: event.startDate,
        endDate: event.endDate,
        travelersBirthdates: event.travelersBirthdates,
        annualPolicy: event.annualPolicy,
        covidProtection: event.covidProtection,
      );

      emit(DetailsSaved(
        persons: state.persons,
        insurance: state.insurance,
      ));
    } on AppException catch (e) {
      emit(TravelFailure(
        message: e.message,
        persons: state.persons,
        insurance: state.insurance,
      ));
    } catch (e) {
      emit(TravelFailure(
        message: 'Noma\'lum xatolik: ${e.toString()}',
        persons: state.persons,
        insurance: state.insurance,
      ));
    }
  }

  Future<void> _onLoadCountries(
    LoadCountries event,
    Emitter<TravelState> emit,
  ) async {
    emit(TravelLoading(
      persons: state.persons,
      insurance: state.insurance,
    ));

    try {
      final countries = await _repository.getCountries();

      emit(CountriesLoaded(
        countries: countries,
        persons: state.persons,
        insurance: state.insurance,
      ));
    } on AppException catch (e) {
      emit(TravelFailure(
        message: e.message,
        persons: state.persons,
        insurance: state.insurance,
      ));
    } catch (e) {
      emit(TravelFailure(
        message: 'Noma\'lum xatolik: ${e.toString()}',
        persons: state.persons,
        insurance: state.insurance,
      ));
    }
  }

  Future<void> _onLoadPurposes(
    LoadPurposes event,
    Emitter<TravelState> emit,
  ) async {
    emit(TravelLoading(
      persons: state.persons,
      insurance: state.insurance,
    ));

    try {
      final purposes = await _repository.getPurposes();

      // Если список пустой, используем fallback данные
      if (purposes.isEmpty) {
        emit(PurposesLoaded(
          purposes: [
            {'id': 1, 'name': 'Turizm', 'uz': 'Turizm', 'ru': 'Туризм', 'en': 'Tourism'},
            {'id': 2, 'name': 'Biznes', 'uz': 'Biznes', 'ru': 'Бизнес', 'en': 'Business'},
            {'id': 3, 'name': 'Davolanish', 'uz': 'Davolanish', 'ru': 'Лечение', 'en': 'Treatment'},
            {'id': 4, 'name': "Ta'lim", 'uz': "Ta'lim", 'ru': 'Обучение', 'en': 'Education'},
          ],
          persons: state.persons,
          insurance: state.insurance,
        ));
      } else {
        emit(PurposesLoaded(
          purposes: purposes,
          persons: state.persons,
          insurance: state.insurance,
        ));
      }
    } on AppException {
      // При ошибке используем fallback данные
      emit(PurposesLoaded(
        purposes: [
          {'id': 1, 'name': 'Turizm', 'uz': 'Turizm', 'ru': 'Туризм', 'en': 'Tourism'},
          {'id': 2, 'name': 'Biznes', 'uz': 'Biznes', 'ru': 'Бизнес', 'en': 'Business'},
          {'id': 3, 'name': 'Davolanish', 'uz': 'Davolanish', 'ru': 'Лечение', 'en': 'Treatment'},
          {'id': 4, 'name': "Ta'lim", 'uz': "Ta'lim", 'ru': 'Обучение', 'en': 'Education'},
        ],
        persons: state.persons,
        insurance: state.insurance,
      ));
    } catch (e) {
      // При любой ошибке используем fallback данные
      emit(PurposesLoaded(
        purposes: [
          {'id': 1, 'name': 'Turizm', 'uz': 'Turizm', 'ru': 'Туризм', 'en': 'Tourism'},
          {'id': 2, 'name': 'Biznes', 'uz': 'Biznes', 'ru': 'Бизнес', 'en': 'Business'},
          {'id': 3, 'name': 'Davolanish', 'uz': 'Davolanish', 'ru': 'Лечение', 'en': 'Treatment'},
          {'id': 4, 'name': "Ta'lim", 'uz': "Ta'lim", 'ru': 'Обучение', 'en': 'Education'},
        ],
        persons: state.persons,
        insurance: state.insurance,
      ));
    }
  }

  Future<void> _onLoadTarifs(
    LoadTarifs event,
    Emitter<TravelState> emit,
  ) async {
    emit(TravelLoading(
      persons: state.persons,
      insurance: state.insurance,
    ));

    try {
      final tarifs = await _repository.getTarifs(event.countryCode);

      emit(TarifsLoaded(
        tarifs: tarifs,
        persons: state.persons,
        insurance: state.insurance,
      ));
    } on AppException catch (e) {
      emit(TravelFailure(
        message: e.message,
        persons: state.persons,
        insurance: state.insurance,
      ));
    } catch (e) {
      emit(TravelFailure(
        message: 'Noma\'lum xatolik: ${e.toString()}',
        persons: state.persons,
        insurance: state.insurance,
      ));
    }
  }
}

