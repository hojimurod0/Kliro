import '../entities/osago_calc_result.dart';
import '../entities/osago_insurance.dart';
import '../entities/osago_vehicle.dart';
import '../repositories/osago_repository.dart';

class CalcOsago {
  CalcOsago(this._repository);

  final OsagoRepository _repository;

  Future<OsagoCalcResult> call({
    required OsagoVehicle vehicle,
    required OsagoInsurance insurance,
  }) {
    return _repository.calc(vehicle: vehicle, insurance: insurance);
  }
}
