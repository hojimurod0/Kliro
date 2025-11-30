import 'package:equatable/equatable.dart';

import '../../domain/entities/osago_driver.dart';
import '../../domain/entities/osago_insurance.dart';
import '../../domain/entities/osago_vehicle.dart';

abstract class OsagoEvent extends Equatable {
  const OsagoEvent();

  @override
  List<Object?> get props => [];
}

class LoadVehicleData extends OsagoEvent {
  const LoadVehicleData({
    required this.vehicle,
    required this.drivers,
    this.osagoType,
    this.periodId,
    this.gosNumber,
    this.birthDate,
  });

  final OsagoVehicle vehicle;
  final List<OsagoDriver> drivers;
  final String? osagoType;
  final String? periodId;
  final String? gosNumber;
  final DateTime? birthDate;

  @override
  List<Object?> get props => [vehicle, drivers, osagoType, periodId, gosNumber, birthDate];
}

class LoadInsuranceCompany extends OsagoEvent {
  const LoadInsuranceCompany(this.insurance);

  final OsagoInsurance insurance;

  @override
  List<Object?> get props => [insurance];
}

class CalcRequested extends OsagoEvent {
  const CalcRequested();
}

class CreatePolicyRequested extends OsagoEvent {
  const CreatePolicyRequested();
}

class PaymentSelected extends OsagoEvent {
  const PaymentSelected(this.method);

  final String method;

  @override
  List<Object?> get props => [method];
}

class CheckPolicyRequested extends OsagoEvent {
  const CheckPolicyRequested();
}
