import 'package:equatable/equatable.dart';

import 'osago_insurance.dart';
import 'osago_vehicle.dart';

class OsagoCalcResult extends Equatable {
  const OsagoCalcResult({
    required this.sessionId,
    required this.amount,
    required this.currency,
    this.provider,
    this.availableProviders = const <OsagoInsurance>[],
    this.ownerName,
    this.numberDriversId,
    this.vehicle,
    this.issueYear,
  });

  final String sessionId;
  final double amount;
  final String currency;
  final String? provider;
  final List<OsagoInsurance> availableProviders;
  final String? ownerName;
  final String? numberDriversId;
  final OsagoVehicle? vehicle;
  final int? issueYear;

  @override
  List<Object?> get props => [
    sessionId,
    amount,
    currency,
    provider,
    availableProviders,
    ownerName,
    numberDriversId,
    vehicle,
    issueYear,
  ];
}
