import 'package:equatable/equatable.dart';

abstract class CurrencyEvent extends Equatable {
  const CurrencyEvent();

  @override
  List<Object?> get props => [];
}

class LoadCurrenciesEvent extends CurrencyEvent {
  const LoadCurrenciesEvent();
}

class SearchCurrenciesEvent extends CurrencyEvent {
  const SearchCurrenciesEvent(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class ClearCurrencyErrorEvent extends CurrencyEvent {
  const ClearCurrencyErrorEvent();
}

