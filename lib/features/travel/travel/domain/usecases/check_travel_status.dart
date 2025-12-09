import '../entities/travel_check_result.dart';
import '../repositories/travel_repository.dart';

class CheckTravelStatus {
  CheckTravelStatus(this._repository);

  final TravelRepository _repository;

  Future<TravelCheckResult> call({required String sessionId}) {
    return _repository.check(sessionId: sessionId);
  }
}

