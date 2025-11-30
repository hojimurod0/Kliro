import '../entities/osago_create_result.dart';
import '../entities/osago_driver.dart';
import '../entities/osago_insurance.dart';
import '../entities/osago_vehicle.dart';
import '../repositories/osago_repository.dart';

class CreateOsagoPolicy {
  CreateOsagoPolicy(this._repository);

  final OsagoRepository _repository;

  Future<OsagoCreateResult> call({
    required String sessionId,
    required List<OsagoDriver> drivers,
    required OsagoInsurance insurance,
    required OsagoVehicle vehicle,
    String? ownerName,
    String? numberDriversId,
  }) {
    return _repository.create(
      sessionId: sessionId,
      drivers: drivers,
      insurance: insurance,
      vehicle: vehicle,
      ownerName: ownerName,
      numberDriversId: numberDriversId,
    );
  }
}
