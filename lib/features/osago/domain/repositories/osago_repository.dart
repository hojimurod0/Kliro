import '../entities/osago_calc_result.dart';
import '../entities/osago_check_result.dart';
import '../entities/osago_create_result.dart';
import '../entities/osago_driver.dart';
import '../entities/osago_insurance.dart';
import '../entities/osago_vehicle.dart';

abstract class OsagoRepository {
  Future<OsagoCalcResult> calc({
    required OsagoVehicle vehicle,
    required OsagoInsurance insurance,
  });

  Future<OsagoCreateResult> create({
    required String sessionId,
    required List<OsagoDriver> drivers,
    required OsagoInsurance insurance,
    required OsagoVehicle vehicle,
    String? ownerName,
    String? numberDriversId,
  });

  Future<OsagoCheckResult> check({required String sessionId});
}
