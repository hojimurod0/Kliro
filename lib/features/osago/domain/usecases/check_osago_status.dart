import '../entities/osago_check_result.dart';
import '../repositories/osago_repository.dart';

class CheckOsagoStatus {
  CheckOsagoStatus(this._repository);

  final OsagoRepository _repository;

  Future<OsagoCheckResult> call(String sessionId) {
    return _repository.check(sessionId: sessionId);
  }
}
