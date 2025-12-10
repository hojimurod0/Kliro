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
    // ✅ YANGI FORMAT: session_id va boolean flag'lar
    // Session ID insurance'dan yoki state'dan olish kerak
    final sessionId = insurance.sessionId ?? '';
    
    if (sessionId.isEmpty) {
      throw Exception('Session ID mavjud emas');
    }
    
    final request = CalcRequest(
      sessionId: sessionId,
      accident: false, // Bu qiymatlar UI'dan kelishi kerak
      luggage: false,
      cancelTravel: false,
      personRespon: false,
      delayTravel: false,
      programId: insurance.programId, // ✅ Tanlangan programId ni uzatish
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
    double? amount,
  }) async {
    if (persons.isEmpty) {
      throw Exception('Persons ro\'yxati bo\'sh');
    }
    
    // ✅ YANGI FORMAT: sugurtalovchi va travelers
    final firstPerson = persons.first;
    
    // PINFL validatsiyasi (majburiy)
    final pinfl = firstPerson.pinfl?.trim() ?? '';
    if (pinfl.isEmpty) {
      throw Exception('PINFL majburiy maydon. Iltimos, PINFL ni kiriting.');
    }
    
    // Otasining ismi - server bo'sh qatorni qabul qilmaydi, shuning uchun default qiymat yuboramiz
    final middleName = firstPerson.middleName?.trim();
    // Server majburiy maydon deb talab qiladi va bo'sh qatorni qabul qilmaydi
    final middleNameForAPI = (middleName != null && middleName.isNotEmpty) 
        ? middleName 
        : '-'; // Default qiymat (server bo'sh qatorni qabul qilmaydi)
    
    final sugurtalovchi = {
      'type': 0,
      'passportSeries': firstPerson.passportSeria.toUpperCase(),
      'passportNumber': firstPerson.passportNumber,
      'birthday': _formatDateForAPI(firstPerson.birthDate),
      'phone': insurance.phoneNumber,
      'pinfl': pinfl,
      'last_name': firstPerson.lastName,
      'first_name': firstPerson.firstName,
      'middle_name': middleNameForAPI, // Default qiymat yoki asl qiymat
    };

    final travelers = persons.skip(1).map((person) => {
      'passportSeries': person.passportSeria.toUpperCase(),
      'passportNumber': person.passportNumber,
      'birthday': _formatDateForAPI(person.birthDate),
      'pinfl': person.pinfl?.trim() ?? '', // PINFL ni qo'shish
      'last_name': person.lastName,
      'first_name': person.firstName,
    }).toList();

    // Agar sayohatchi yo'q bo'lsa (sug'urtalovchi o'zi sayohatchi), uni travelers ga qo'shamiz
    if (travelers.isEmpty) {
      travelers.add({
        'passportSeries': firstPerson.passportSeria.toUpperCase(),
        'passportNumber': firstPerson.passportNumber,
        'birthday': _formatDateForAPI(firstPerson.birthDate),
        'pinfl': pinfl,
        'last_name': firstPerson.lastName,
        'first_name': firstPerson.firstName,
      });
    }

    // ✅ Amount ni to'g'ri olish: avval parametrdan, keyin insurance'dan, oxirida 0
    final summaAll = amount?.toInt() ?? insurance.amount?.toInt() ?? 0;
    if (summaAll == 0) {
      throw Exception('Summa 0 bo\'lishi mumkin emas. Amount to\'g\'ri olinmagan.');
    }
    final programId = insurance.programId ?? '3';

    final request = CreateRequest(
      sessionId: sessionId,
      provider: insurance.provider,
      summaAll: summaAll,
      programId: programId,
      sugurtalovchi: sugurtalovchi,
      travelers: travelers,
    );

    final response = await _api.create(request);

    return TravelCreateResult(
      sessionId: response.sessionId,
      policyNumber: response.policyNumber ?? '',
      paymentUrl: response.paymentUrl ?? '',
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

  // Yordamchi funksiya: API format'iga mos sana (DD-MM-YYYY)
  String _formatDateForAPI(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }
}

