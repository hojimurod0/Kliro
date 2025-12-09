import 'package:equatable/equatable.dart';

import 'travel_insurance.dart';

class TravelCalcResult extends Equatable {
  const TravelCalcResult({
    required this.sessionId,
    required this.amount,
    required this.currency,
    this.provider,
    this.availableProviders = const [],
  });

  final String sessionId;
  final double amount;
  final String currency;
  final String? provider;
  final List<TravelInsurance> availableProviders;

  @override
  List<Object?> get props => [
        sessionId,
        amount,
        currency,
        provider,
        availableProviders,
      ];
}

