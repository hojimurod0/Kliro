import 'package:equatable/equatable.dart';

class TravelInsurance extends Equatable {
  const TravelInsurance({
    required this.provider,
    required this.companyName,
    required this.startDate,
    required this.endDate,
    required this.phoneNumber,
    this.email,
  });

  final String provider;
  final String companyName;
  final DateTime startDate;
  final DateTime endDate;
  final String phoneNumber;
  final String? email;

  @override
  List<Object?> get props => [
        provider,
        companyName,
        startDate,
        endDate,
        phoneNumber,
        email,
      ];
}

