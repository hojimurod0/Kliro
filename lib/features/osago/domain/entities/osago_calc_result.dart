import 'package:equatable/equatable.dart';

import 'osago_insurance.dart';

class OsagoCalcResult extends Equatable {
  const OsagoCalcResult({
    required this.sessionId,
    required this.amount,
    required this.currency,
    this.provider,
    this.availableProviders = const <OsagoInsurance>[],
    this.ownerName,
    this.numberDriversId,
  });

  final String sessionId;
  final double amount;
  final String currency;
  final String? provider;
  final List<OsagoInsurance> availableProviders;
  final String? ownerName;
  final String? numberDriversId;

  @override
  List<Object?> get props => [
    sessionId,
    amount,
    currency,
    provider,
    availableProviders,
    ownerName,
    numberDriversId,
  ];
}
