import 'package:equatable/equatable.dart';

/// Сущность персоны (sugurtalovchi)
class Person extends Equatable {
  final int type;
  final String passportSeries;
  final String passportNumber;
  final String birthday; // DD-MM-YYYY
  final String phone;
  final String pinfl;
  final String lastName;
  final String firstName;
  final String? middleName;

  const Person({
    required this.type,
    required this.passportSeries,
    required this.passportNumber,
    required this.birthday,
    required this.phone,
    required this.pinfl,
    required this.lastName,
    required this.firstName,
    this.middleName,
  });

  @override
  List<Object?> get props => [
        type,
        passportSeries,
        passportNumber,
        birthday,
        phone,
        pinfl,
        lastName,
        firstName,
        middleName,
      ];
}

