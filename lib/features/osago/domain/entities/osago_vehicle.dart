import 'package:equatable/equatable.dart';

class OsagoVehicle extends Equatable {
  const OsagoVehicle({
    required this.brand,
    required this.model,
    required this.gosNumber,
    required this.techSeria,
    required this.techNumber,
    required this.ownerPassportSeria,
    required this.ownerPassportNumber,
    required this.ownerBirthDate,
    this.isOwner = true,
  });

  final String brand;
  final String model;
  final String gosNumber;
  final String techSeria;
  final String techNumber;
  final String ownerPassportSeria;
  final String ownerPassportNumber;
  final DateTime ownerBirthDate;
  final bool isOwner;

  @override
  List<Object?> get props => [
    brand,
    model,
    gosNumber,
    techSeria,
    techNumber,
    ownerPassportSeria,
    ownerPassportNumber,
    ownerBirthDate,
    isOwner,
  ];
}
