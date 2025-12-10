import '../entities/travel_create_result.dart';
import '../entities/travel_insurance.dart';
import '../entities/travel_person.dart';
import '../repositories/travel_repository.dart';

class CreateTravelPolicy {
  CreateTravelPolicy(this._repository);

  final TravelRepository _repository;

  Future<TravelCreateResult> call({
    required String sessionId,
    required List<TravelPerson> persons,
    required TravelInsurance insurance,
    double? amount,
  }) {
    return _repository.create(
      sessionId: sessionId,
      persons: persons,
      insurance: insurance,
      amount: amount,
    );
  }
}

