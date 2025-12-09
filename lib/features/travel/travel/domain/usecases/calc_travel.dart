import '../entities/travel_calc_result.dart';
import '../entities/travel_insurance.dart';
import '../entities/travel_person.dart';
import '../repositories/travel_repository.dart';

class CalcTravel {
  CalcTravel(this._repository);

  final TravelRepository _repository;

  Future<TravelCalcResult> call({
    required List<TravelPerson> persons,
    required TravelInsurance insurance,
  }) {
    return _repository.calc(persons: persons, insurance: insurance);
  }
}

