import 'package:equatable/equatable.dart';

/// Сущность путешественника
class Traveler extends Equatable {
  final String passportSeries;
  final String passportNumber;
  final String birthday; // DD-MM-YYYY
  final String pinfl;
  final String lastName;
  final String firstName;

  const Traveler({
    required this.passportSeries,
    required this.passportNumber,
    required this.birthday,
    required this.pinfl,
    required this.lastName,
    required this.firstName,
  });

  @override
  List<Object?> get props => [
        passportSeries,
        passportNumber,
        birthday,
        pinfl,
        lastName,
        firstName,
      ];
}

