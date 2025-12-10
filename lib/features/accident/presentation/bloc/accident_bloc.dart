import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/usecases/get_tariffs.dart';
import '../../domain/usecases/get_regions.dart';
import '../../domain/usecases/create_insurance.dart' as usecases;
import '../../domain/usecases/check_payment.dart' as usecases;
import '../../domain/entities/tariff_entity.dart';
import '../../domain/entities/region_entity.dart';
import 'accident_event.dart';
import 'accident_state.dart';

class AccidentBloc extends Bloc<AccidentEvent, AccidentState> {
  AccidentBloc({
    required GetTariffs getTariffs,
    required GetRegions getRegions,
    required usecases.CreateInsurance createInsurance,
    required usecases.CheckPayment checkPayment,
  }) : _getTariffs = getTariffs,
       _getRegions = getRegions,
       _createInsurance = createInsurance,
       _checkPayment = checkPayment,
       super(const AccidentInitial()) {
    on<FetchTariffs>(_onFetchTariffs);
    on<SelectTariff>(_onSelectTariff);
    on<FetchRegions>(_onFetchRegions);
    on<SelectRegion>(_onSelectRegion);
    on<CreateInsurance>(_onCreateInsurance);
    on<CheckPayment>(_onCheckPayment);
  }

  final GetTariffs _getTariffs;
  final GetRegions _getRegions;
  final usecases.CreateInsurance _createInsurance;
  final usecases.CheckPayment _checkPayment;

  // Cache
  List<TariffEntity>? _cachedTariffs;
  List<RegionEntity>? _cachedRegions;
  TariffEntity? _selectedTariff;
  RegionEntity? _selectedRegion;

  // Tariffs handlers
  Future<void> _onFetchTariffs(
    FetchTariffs event,
    Emitter<AccidentState> emit,
  ) async {
    if (!event.forceRefresh && _cachedTariffs != null) {
      emit(
        AccidentTariffsLoaded(_cachedTariffs!, selectedTariff: _selectedTariff),
      );
      return;
    }

    emit(const AccidentTariffsLoading());

    final result = await _getTariffs();

    result.fold((failure) => emit(AccidentError(_mapError(failure.message))), (
      tariffs,
    ) {
      _cachedTariffs = tariffs;
      emit(AccidentTariffsLoaded(tariffs, selectedTariff: _selectedTariff));
    });
  }

  void _onSelectTariff(SelectTariff event, Emitter<AccidentState> emit) {
    _selectedTariff = event.tariff;
    if (_cachedTariffs != null) {
      emit(
        AccidentTariffsLoaded(_cachedTariffs!, selectedTariff: _selectedTariff),
      );
    }
  }

  // Regions handlers
  Future<void> _onFetchRegions(
    FetchRegions event,
    Emitter<AccidentState> emit,
  ) async {
    if (!event.forceRefresh && _cachedRegions != null) {
      emit(
        AccidentRegionsLoaded(_cachedRegions!, selectedRegion: _selectedRegion),
      );
      return;
    }

    emit(const AccidentRegionsLoading());

    final result = await _getRegions();

    result.fold((failure) => emit(AccidentError(_mapError(failure.message))), (
      regions,
    ) {
      _cachedRegions = regions;
      emit(AccidentRegionsLoaded(regions, selectedRegion: _selectedRegion));
    });
  }

  void _onSelectRegion(SelectRegion event, Emitter<AccidentState> emit) {
    _selectedRegion = event.region;
    if (_cachedRegions != null) {
      emit(
        AccidentRegionsLoaded(_cachedRegions!, selectedRegion: _selectedRegion),
      );
    }
  }

  // Create Insurance handler
  Future<void> _onCreateInsurance(
    CreateInsurance event,
    Emitter<AccidentState> emit,
  ) async {
    emit(const AccidentCreatingInsurance());

    if (kDebugMode) {
      debugPrint('🚀 Creating insurance...');
    }

    final result = await _createInsurance(
      startDate: event.startDate,
      tariffId: event.tariffId,
      pinfl: event.pinfl,
      passSery: event.passSery,
      passNum: event.passNum,
      dateBirth: event.dateBirth,
      lastName: event.lastName,
      firstName: event.firstName,
      patronymName: event.patronymName,
      region: event.region,
      phone: event.phone,
      address: event.address,
    );

    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint('❌ Create insurance failed: ${failure.message}');
        }
        emit(AccidentError(_mapError(failure.message)));
      },
      (insurance) {
        if (kDebugMode) {
          debugPrint(
            '✅ Create insurance success: anketaId=${insurance.anketaId}',
          );
        }
        emit(AccidentInsuranceCreated(insurance));
      },
    );
  }

  // Check Payment handler
  Future<void> _onCheckPayment(
    CheckPayment event,
    Emitter<AccidentState> emit,
  ) async {
    emit(const AccidentCheckingPayment());

    final result = await _checkPayment(
      anketaId: event.anketaId,
      lan: event.lan,
    );

    result.fold(
      (failure) => emit(AccidentError(_mapError(failure.message))),
      (paymentStatus) => emit(AccidentPaymentChecked(paymentStatus)),
    );
  }

  String _mapError(String error) {
    if (error.contains('timeout') || error.contains('Timeout')) {
      return 'insurance.accident.error_messages.timeout'.tr();
    }
    if (error.contains('connection') || error.contains('network')) {
      return 'insurance.accident.error_messages.network'.tr();
    }
    if (error.contains('401') || error.contains('Unauthorized')) {
      return 'insurance.accident.error_messages.unauthorized'.tr();
    }
    if (error.contains('400') || error.contains('Bad Request')) {
      return 'insurance.accident.error_messages.bad_request'.tr();
    }
    if (error.contains('404') || error.contains('Not Found')) {
      return 'insurance.accident.error_messages.not_found'.tr();
    }
    if (error.contains('500') || error.contains('Server')) {
      return 'insurance.accident.error_messages.server_error'.tr();
    }
    // Validation xatoliklari
    if (error.contains('pinfl') || error.contains('ПИНФЛ')) {
      return 'insurance.accident.error_messages.pinfl_invalid'.tr();
    }
    if (error.contains('passport') || error.contains('паспорт')) {
      return 'insurance.accident.error_messages.passport_invalid'.tr();
    }
    if (error.contains('phone') || error.contains('телефон')) {
      return 'insurance.accident.error_messages.phone_invalid'.tr();
    }
    return error;
  }
}
