import '../../domain/entities/travel_calc_result.dart';
import '../../domain/entities/travel_check_result.dart';
import '../../domain/entities/travel_create_result.dart';
import '../../domain/entities/travel_insurance.dart';
import '../../domain/entities/travel_person.dart';
import '../../domain/repositories/travel_repository.dart';
import '../data_source/travel_api.dart';
import '../models/calc_request.dart';
import '../models/check_request.dart';
import '../models/create_request.dart';
import '../models/purpose_request.dart';
import '../models/details_request.dart';
import '../models/tarif_request.dart';

class TravelRepositoryImpl implements TravelRepository {
  TravelRepositoryImpl(this._api);

  final TravelApi _api;

  @override
  Future<TravelCalcResult> calc({
    required List<TravelPerson> persons,
    required TravelInsurance insurance,
  }) async {
    final request = CalcRequest(
      persons: persons.map((person) => {
        'first_name': person.firstName,
        'last_name': person.lastName,
        'middle_name': person.middleName ?? '',
        'passport_seria': person.passportSeria.toUpperCase(),
        'passport_number': person.passportNumber,
        'birth_date': _formatDate(person.birthDate),
      }).toList(),
      startDate: _formatDate(insurance.startDate),
      endDate: _formatDate(insurance.endDate),
      provider: insurance.provider,
    );

    final response = await _api.calc(request);

    return TravelCalcResult(
      sessionId: response.sessionId,
      amount: response.amount,
      currency: response.currency,
      provider: response.provider,
      availableProviders: [],
    );
  }

  @override
  Future<TravelCreateResult> create({
    required String sessionId,
    required List<TravelPerson> persons,
    required TravelInsurance insurance,
  }) async {
    final request = CreateRequest(
      sessionId: sessionId,
      provider: insurance.provider,
      persons: persons.map((person) => {
        'first_name': person.firstName,
        'last_name': person.lastName,
        'middle_name': person.middleName ?? '',
        'passport_seria': person.passportSeria.toUpperCase(),
        'passport_number': person.passportNumber,
        'birth_date': _formatDate(person.birthDate),
      }).toList(),
      startDate: _formatDate(insurance.startDate),
      endDate: _formatDate(insurance.endDate),
      phoneNumber: insurance.phoneNumber,
      email: insurance.email,
    );

    final response = await _api.create(request);

    return TravelCreateResult(
      sessionId: response.sessionId,
      policyNumber: response.policyNumber,
      paymentUrl: response.paymentUrl,
      amount: response.amount,
      currency: response.currency,
      clickUrl: response.pay?['click'] as String?,
      paymeUrl: response.pay?['payme'] as String?,
    );
  }

  @override
  Future<TravelCheckResult> check({required String sessionId}) async {
    final request = CheckRequest(sessionId: sessionId);
    final response = await _api.check(request);

    return TravelCheckResult(
      sessionId: response.sessionId,
      status: response.status,
      policyNumber: response.policyNumber,
      amount: response.amount,
      currency: response.currency,
      issuedAt: response.issuedAt != null
          ? DateTime.tryParse(response.issuedAt!)
          : null,
      downloadUrl: response.downloadUrl,
    );
  }

  @override
  Future<String> createPurpose({
    required int purposeId,
    required List<String> destinations,
  }) async {
    final request = PurposeRequest(
      purposeId: purposeId,
      destinations: destinations,
    );
    final response = await _api.createPurpose(request);
    return response.sessionId;
  }

  @override
  Future<void> sendDetails({
    required String sessionId,
    required String startDate,
    required String endDate,
    required List<String> travelersBirthdates,
    required bool annualPolicy,
    required bool covidProtection,
  }) async {
    final request = DetailsRequest(
      sessionId: sessionId,
      startDate: startDate,
      endDate: endDate,
      travelersBirthdates: travelersBirthdates,
      annualPolicy: annualPolicy,
      covidProtection: covidProtection,
    );
    await _api.sendDetails(request);
  }

  @override
  Future<List<dynamic>> getCountries() async {
    final countries = await _api.getCountries();
    return countries.map((c) => {
      'code': c.code,
      'name': c.name,
      'flag': c.flag,
      'en': c.en,
      'ru': c.ru,
      'uz': c.uz,
    }).toList();
  }

  @override
  Future<List<dynamic>> getPurposes() async {
    final purposes = await _api.getPurposes();
    return purposes.map((p) => {
      'id': p.id,
      'name': p.name,
      'en': p.nameEn,
      'ru': p.nameRu,
      'uz': p.nameUz,
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> getTarifs(String countryCode) async {
    final request = TarifRequest(country: countryCode);
    final response = await _api.getTarifs(request);
    return response.data ?? response.tarifs?.first ?? {};
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
}

