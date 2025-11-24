import 'package:equatable/equatable.dart';

import '../../domain/entities/currency_entity.dart';

abstract class CurrencyState extends Equatable {
  const CurrencyState();

  @override
  List<Object?> get props => [];
}

class CurrencyInitial extends CurrencyState {
  const CurrencyInitial();
}

class CurrencyLoading extends CurrencyState {
  const CurrencyLoading();
}

class CurrencyLoaded extends CurrencyState {
  const CurrencyLoaded(this.currencies);

  final List<CurrencyEntity> currencies;

  @override
  List<Object?> get props => [currencies];
}

class CurrencyError extends CurrencyState {
  const CurrencyError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

