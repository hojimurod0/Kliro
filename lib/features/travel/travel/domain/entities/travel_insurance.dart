import 'package:equatable/equatable.dart';

class TravelInsurance extends Equatable {
  const TravelInsurance({
    required this.provider,
    required this.companyName,
    required this.startDate,
    required this.endDate,
    required this.phoneNumber,
    this.email,
    this.sessionId,
    this.amount,
    this.programId,
    this.countryName,
    this.purposeName,
  });

  final String provider;
  final String companyName;
  final DateTime startDate;
  final DateTime endDate;
  final String phoneNumber;
  final String? email;
  final String? sessionId;
  final double? amount;
  final String? programId;
  final String? countryName;
  final String? purposeName;

  TravelInsurance copyWith({
    String? provider,
    String? companyName,
    DateTime? startDate,
    DateTime? endDate,
    String? phoneNumber,
    String? email,
    String? sessionId,
    double? amount,
    String? programId,
    String? countryName,
    String? purposeName,
  }) {
    return TravelInsurance(
      provider: provider ?? this.provider,
      companyName: companyName ?? this.companyName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      sessionId: sessionId ?? this.sessionId,
      amount: amount ?? this.amount,
      programId: programId ?? this.programId,
      countryName: countryName ?? this.countryName,
      purposeName: purposeName ?? this.purposeName,
    );
  }

  @override
  List<Object?> get props => [
        provider,
        companyName,
        startDate,
        endDate,
        phoneNumber,
        email,
        sessionId,
        amount,
        programId,
        countryName,
        purposeName,
      ];
}
