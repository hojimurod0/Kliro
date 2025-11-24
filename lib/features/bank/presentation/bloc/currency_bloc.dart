import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/usecases/get_currencies.dart';
import '../../domain/usecases/search_bank_services.dart';
import 'currency_event.dart';
import 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  CurrencyBloc({
    required GetCurrencies getCurrencies,
    required SearchBankServices searchBankServices,
  })  : _getCurrencies = getCurrencies,
        _searchBankServices = searchBankServices,
        super(const CurrencyInitial()) {
    on<LoadCurrenciesEvent>(_onLoadCurrencies);
    on<SearchCurrenciesEvent>(_onSearchCurrencies);
    on<ClearCurrencyErrorEvent>(_onClearError);
  }

  final GetCurrencies _getCurrencies;
  final SearchBankServices _searchBankServices;

  Future<void> _onLoadCurrencies(
    LoadCurrenciesEvent event,
    Emitter<CurrencyState> emit,
  ) async {
    emit(const CurrencyLoading());
    
    try {
      final currencies = await _getCurrencies();
      print('CurrencyBloc: Loaded ${currencies.length} currencies');
      if (currencies.isEmpty) {
        emit(const CurrencyError('Valyuta kurslari topilmadi'));
      } else {
        emit(CurrencyLoaded(currencies));
      }
    } on AppException catch (e) {
      print('CurrencyBloc: AppException - ${e.message}');
      emit(CurrencyError(e.message));
    } catch (e, stackTrace) {
      print('CurrencyBloc: Exception - $e');
      print('Stack trace: $stackTrace');
      emit(CurrencyError('Noma\'lum xatolik yuz berdi: ${e.toString()}'));
    }
  }

  Future<void> _onSearchCurrencies(
    SearchCurrenciesEvent event,
    Emitter<CurrencyState> emit,
  ) async {
    // Agar query bo'sh bo'lsa, barcha valyutalarni yuklash
    if (event.query.trim().isEmpty) {
      add(const LoadCurrenciesEvent());
      return;
    }

    emit(const CurrencyLoading());
    
    try {
      final currencies = await _searchBankServices(
        query: event.query,
        page: 0,
        size: 10,
      );
      emit(CurrencyLoaded(currencies));
    } on AppException catch (e) {
      emit(CurrencyError(e.message));
    } catch (e) {
      emit(CurrencyError('Qidiruvda xatolik yuz berdi: ${e.toString()}'));
    }
  }

  void _onClearError(
    ClearCurrencyErrorEvent event,
    Emitter<CurrencyState> emit,
  ) {
    if (state is CurrencyError) {
      emit(const CurrencyInitial());
    }
  }
}

