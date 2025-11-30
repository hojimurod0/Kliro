import 'package:equatable/equatable.dart';

class OsagoInsurance extends Equatable {
  const OsagoInsurance({
    required this.provider,
    required this.companyName,
    required this.periodId,
    required this.numberDriversId,
    required this.startDate,
    required this.phoneNumber,
    this.ownerInn,
    this.isUnlimited = false,
  });

  final String provider;
  final String companyName;
  final String periodId;
  final String numberDriversId;
  final DateTime startDate;
  final String phoneNumber;
  final String? ownerInn;
  final bool isUnlimited;

  @override
  List<Object?> get props => [
    provider,
    companyName,
    periodId,
    numberDriversId,
    startDate,
    phoneNumber,
    ownerInn,
    isUnlimited,
  ];
}
