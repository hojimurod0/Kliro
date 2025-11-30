import 'package:equatable/equatable.dart';

class OsagoDriver extends Equatable {
  const OsagoDriver({
    required this.passportSeria,
    required this.passportNumber,
    required this.driverBirthday,
    this.relative = 0,
    this.name,
    this.licenseSeria,
    this.licenseNumber,
  });

  final String passportSeria;
  final String passportNumber;
  final DateTime driverBirthday;
  final int relative;
  final String? name;
  final String? licenseSeria;
  final String? licenseNumber;

  @override
  List<Object?> get props => [
    passportSeria,
    passportNumber,
    driverBirthday,
    relative,
    name,
    licenseSeria,
    licenseNumber,
  ];
}
