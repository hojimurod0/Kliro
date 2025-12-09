import '../entities/travel_calc_result.dart';
import '../entities/travel_check_result.dart';
import '../entities/travel_create_result.dart';
import '../entities/travel_insurance.dart';
import '../entities/travel_person.dart';

abstract class TravelRepository {
  Future<TravelCalcResult> calc({
    required List<TravelPerson> persons,
    required TravelInsurance insurance,
  });

  Future<TravelCreateResult> create({
    required String sessionId,
    required List<TravelPerson> persons,
    required TravelInsurance insurance,
  });

  Future<TravelCheckResult> check({required String sessionId});

  // Новые методы для полного flow
  Future<String> createPurpose({
    required int purposeId,
    required List<String> destinations,
  });

  Future<void> sendDetails({
    required String sessionId,
    required String startDate,
    required String endDate,
    required List<String> travelersBirthdates,
    required bool annualPolicy,
    required bool covidProtection,
  });

  Future<List<dynamic>> getCountries();
  Future<List<dynamic>> getPurposes();
  Future<Map<String, dynamic>> getTarifs(String countryCode);
}

