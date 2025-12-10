import 'package:equatable/equatable.dart';

class TravelPerson extends Equatable {
  const TravelPerson({
    required this.firstName,
    required this.lastName,
    required this.passportSeria,
    required this.passportNumber,
    required this.birthDate,
    this.middleName,
    this.pinfl,
  });

  final String firstName;
  final String lastName;
  final String? middleName;
  final String? pinfl;
  final String passportSeria;
  final String passportNumber;
  final DateTime birthDate;

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        middleName,
        pinfl,
        passportSeria,
        passportNumber,
        birthDate,
      ];
}

