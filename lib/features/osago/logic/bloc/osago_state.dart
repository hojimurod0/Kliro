import 'package:equatable/equatable.dart';

import '../../domain/entities/osago_calc_result.dart';
import '../../domain/entities/osago_check_result.dart';
import '../../domain/entities/osago_create_result.dart';
import '../../domain/entities/osago_driver.dart';
import '../../domain/entities/osago_insurance.dart';
import '../../domain/entities/osago_vehicle.dart';

abstract class OsagoState extends Equatable {
  const OsagoState({
    this.vehicle,
    this.insurance,
    this.drivers = const <OsagoDriver>[],
    this.calcResponse,
    this.createResponse,
    this.checkResponse,
    this.paymentMethod,
    this.errorMessage,
    this.gosNumber,
    this.periodId,
    this.numberDriversId,
    this.ownerName,
    this.birthDate,
    this.osagoType,
  });

  final OsagoVehicle? vehicle;
  final OsagoInsurance? insurance;
  final List<OsagoDriver> drivers;
  final OsagoCalcResult? calcResponse;
  final OsagoCreateResult? createResponse;
  final OsagoCheckResult? checkResponse;
  final String? paymentMethod;
  final String? errorMessage;
  final String? gosNumber;
  final String? periodId;
  final String? numberDriversId;
  final String? ownerName;
  final DateTime? birthDate;
  final String? osagoType;

  @override
  List<Object?> get props => [
    vehicle,
    insurance,
    drivers,
    calcResponse,
    createResponse,
    checkResponse,
    paymentMethod,
    errorMessage,
    gosNumber,
    periodId,
    numberDriversId,
    ownerName,
    birthDate,
    osagoType,
  ];
}

class OsagoInitial extends OsagoState {
  const OsagoInitial() : super();
}

class OsagoLoading extends OsagoState {
  const OsagoLoading({
    super.vehicle,
    super.insurance,
    super.drivers,
    super.calcResponse,
    super.createResponse,
    super.checkResponse,
    super.paymentMethod,
    super.gosNumber,
    super.periodId,
    super.numberDriversId,
    super.ownerName,
    super.birthDate,
    super.osagoType,
  });
}

class OsagoVehicleFilled extends OsagoState {
  const OsagoVehicleFilled({
    required super.vehicle,
    required super.drivers,
    super.gosNumber,
    super.periodId,
    super.birthDate,
    super.osagoType,
  });
}

class OsagoCompanyFilled extends OsagoState {
  const OsagoCompanyFilled({
    required super.vehicle,
    required super.drivers,
    required super.insurance,
    super.gosNumber,
    super.periodId,
    super.birthDate,
    super.osagoType,
  });
}

class OsagoCalcSuccess extends OsagoState {
  const OsagoCalcSuccess({
    required super.vehicle,
    required super.drivers,
    required super.insurance,
    required super.calcResponse,
    super.gosNumber,
    super.periodId,
    super.numberDriversId,
    super.ownerName,
    super.birthDate,
    super.osagoType,
  });
}

class OsagoCreateSuccess extends OsagoState {
  const OsagoCreateSuccess({
    required super.vehicle,
    required super.drivers,
    required super.insurance,
    required super.calcResponse,
    required super.createResponse,
    super.paymentMethod,
    super.gosNumber,
    super.periodId,
    super.numberDriversId,
    super.ownerName,
    super.birthDate,
    super.osagoType,
  });
}

class OsagoCheckSuccess extends OsagoState {
  const OsagoCheckSuccess({
    required super.vehicle,
    required super.drivers,
    required super.insurance,
    required super.calcResponse,
    required super.createResponse,
    required super.checkResponse,
    super.paymentMethod,
    super.gosNumber,
    super.periodId,
    super.numberDriversId,
    super.ownerName,
    super.birthDate,
    super.osagoType,
  });
}

class OsagoFailure extends OsagoState {
  const OsagoFailure({
    required String message,
    super.vehicle,
    super.drivers,
    super.insurance,
    super.calcResponse,
    super.createResponse,
    super.checkResponse,
    super.paymentMethod,
    super.gosNumber,
    super.periodId,
    super.numberDriversId,
    super.ownerName,
    super.birthDate,
    super.osagoType,
  }) : super(errorMessage: message);
}
