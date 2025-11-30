import 'dart:developer';

import '../../domain/entities/osago_calc_result.dart';
import '../../domain/entities/osago_check_result.dart';
import '../../domain/entities/osago_create_result.dart';
import '../../domain/entities/osago_driver.dart';
import '../../domain/entities/osago_insurance.dart';
import '../../domain/entities/osago_vehicle.dart';
import '../../domain/repositories/osago_repository.dart';
import '../data_source/osago_api.dart';
import '../models/calc_request.dart';
import '../models/check_request.dart';
import '../models/create_request.dart';
import '../models/driver_model.dart';
import '../models/insurance_model.dart';

class OsagoRepositoryImpl implements OsagoRepository {
  OsagoRepositoryImpl(this._api);

  final OsagoApi _api;

  @override
  Future<OsagoCalcResult> calc({
    required OsagoVehicle vehicle,
    required OsagoInsurance insurance,
  }) async {
    log('[OSAGO_REPO] calc() chaqirildi', name: 'OSAGO');
    log(
      '[OSAGO_REPO] Vehicle: gosNumber=${vehicle.gosNumber}, brand=${vehicle.brand}, model=${vehicle.model}',
      name: 'OSAGO',
    );
    log(
      '[OSAGO_REPO] Insurance: provider=${insurance.provider}, periodId=${insurance.periodId}, numberDriversId=${insurance.numberDriversId}, isUnlimited=${insurance.isUnlimited}',
      name: 'OSAGO',
    );

    // Calc request uchun numberDriversId - OSAGO type ga qarab '0' yoki '5'
    // API faqat 0 (unlimited) yoki 5 (limited) qabul qiladi
    String numberDriversIdForCalc = '5'; // Default: limited to 5 drivers

    // Agar insurance.numberDriversId to'g'ri bo'lsa (0 yoki 5), ishlatamiz
    if (insurance.numberDriversId == '0' || insurance.numberDriversId == '5') {
      numberDriversIdForCalc = insurance.numberDriversId;
      log(
        '[OSAGO_REPO] ✅ numberDriversId to\'g\'ri: $numberDriversIdForCalc',
        name: 'OSAGO',
      );
    } else if (insurance.isUnlimited) {
      // Agar isUnlimited true bo'lsa, '0' ishlatamiz
      numberDriversIdForCalc = '0';
      log(
        '[OSAGO_REPO] ✅ isUnlimited=true, numberDriversIdForCalc=0',
        name: 'OSAGO',
      );
    } else {
      log('[OSAGO_REPO] ⚠️ Default numberDriversIdForCalc=5', name: 'OSAGO');
    }

    final request = CalcRequest(
      gosNumber: _sanitizeGos(vehicle.gosNumber),
      techSeria: vehicle.techSeria.toUpperCase(),
      techNumber: vehicle.techNumber,
      ownerPassSeria: vehicle.ownerPassportSeria.toUpperCase(),
      ownerPassNumber: vehicle.ownerPassportNumber,
      periodId: insurance.periodId, // "6" yoki "12"
      numberDriversId: numberDriversIdForCalc, // '0' yoki '5'
    );

    log(
      '[OSAGO_REPO] CalcRequest yaratildi: gosNumber=${request.gosNumber}, periodId=${request.periodId}, numberDriversId=${request.numberDriversId}',
      name: 'OSAGO',
    );
    log('[OSAGO_REPO] API calc() chaqiruvi boshlandi...', name: 'OSAGO');

    final response = await _api.calc(request);

    log(
      '[OSAGO_REPO] ✅ API calc() javob qabul qilindi: sessionId=${response.sessionId}, amount=${response.amount}',
      name: 'OSAGO',
    );
    log(
      '[OSAGO_REPO] Calc response: provider=${response.provider}, ownerName=${response.ownerName}, numberDriversId=${response.numberDriversId}',
      name: 'OSAGO',
    );
    log(
      '[OSAGO_REPO] Available providers count: ${response.availableProviders.length}',
      name: 'OSAGO',
    );

    return OsagoCalcResult(
      sessionId: response.sessionId,
      amount: response.amount,
      currency: response.currency,
      provider: response.provider,
      availableProviders: response.availableProviders
          .map(_mapInsuranceModel)
          .toList(),
      ownerName: response.ownerName,
      numberDriversId: response.numberDriversId,
    );
  }

  @override
  Future<OsagoCreateResult> create({
    required String sessionId,
    required List<OsagoDriver> drivers,
    required OsagoInsurance insurance,
    required OsagoVehicle vehicle,
    String? ownerName,
    String? numberDriversId,
  }) async {
    log('[OSAGO_REPO] create() chaqirildi', name: 'OSAGO');
    log(
      '[OSAGO_REPO] Create uchun: sessionId=$sessionId, drivers count=${drivers.length}',
      name: 'OSAGO',
    );
    log(
      '[OSAGO_REPO] Insurance: provider=${insurance.provider}, phoneNumber=${insurance.phoneNumber}, startDate=${insurance.startDate}',
      name: 'OSAGO',
    );
    log(
      '[OSAGO_REPO] Vehicle: isOwner=${vehicle.isOwner}, gosNumber=${vehicle.gosNumber}',
      name: 'OSAGO',
    );
    log(
      '[OSAGO_REPO] ownerName=$ownerName, numberDriversId=$numberDriversId (e\'tiborsiz qoldiriladi)',
      name: 'OSAGO',
    );

    // Если заявитель является водителем, берем данные водительского удостоверения из первого водителя
    // Важно: applicant_is_driver doim false bo'lishi kerak (Postman collection ga ko'ra)
    // Shuning uchun license ma'lumotlarini faqat agar mavjud bo'lsa yuboramiz, aks holda bo'sh string
    String? applicantLicenseSeria;
    String? applicantLicenseNumber;
    
    // Agar isOwner=true va license ma'lumotlari mavjud bo'lsa, yuboramiz
    if (vehicle.isOwner && drivers.isNotEmpty) {
      final firstDriver = drivers.first;
      log(
        '[OSAGO_REPO] First driver: licenseSeria=${firstDriver.licenseSeria}, licenseNumber=${firstDriver.licenseNumber}',
        name: 'OSAGO',
      );

      if (firstDriver.licenseSeria != null &&
          firstDriver.licenseSeria!.isNotEmpty &&
          firstDriver.licenseNumber != null &&
          firstDriver.licenseNumber!.toString().isNotEmpty) {
        applicantLicenseSeria = firstDriver.licenseSeria!.toUpperCase();
        applicantLicenseNumber = firstDriver.licenseNumber!.toString();
        log(
          '[OSAGO_REPO] ✅ Applicant license ma\'lumotlari: seria=$applicantLicenseSeria, number=$applicantLicenseNumber',
          name: 'OSAGO',
        );
      } else {
        // Agar license ma'lumotlari bo'sh bo'lsa, bo'sh string yuboramiz (null emas)
        // Bu server tomonidan talab qilinadi, hatto applicant_is_driver=false bo'lsa ham
        applicantLicenseSeria = '';
        applicantLicenseNumber = '';
        log(
          '[OSAGO_REPO] ⚠️ Applicant license ma\'lumotlari bo\'sh, bo\'sh string yuborilmoqda',
          name: 'OSAGO',
        );
      }
    } else {
      // Agar isOwner=false yoki drivers bo'sh bo'lsa, bo'sh string yuboramiz
      applicantLicenseSeria = '';
      applicantLicenseNumber = '';
      log(
        '[OSAGO_REPO] ⚠️ applicant_is_driver=false, license ma\'lumotlari bo\'sh string',
        name: 'OSAGO',
      );
    }

    // Postman collection ga ko'ra: create requestda number_drivers_id yo'q
    // Shuningdek, applicant_is_driver doim false bo'lishi kerak
    final request = CreateRequest(
      provider: insurance.provider,
      sessionId: sessionId,
      drivers: drivers
          .map((driver) => _mapDriverModel(driver, ownerName))
          .toList(),
      applicantIsDriver: false, // Postman: doim static false
      phoneNumber: insurance.phoneNumber,
      ownerInn: insurance.ownerInn?.isEmpty ?? true ? '' : insurance.ownerInn,
      applicantLicenseSeria: applicantLicenseSeria,
      applicantLicenseNumber: applicantLicenseNumber,
      startDate: insurance.startDate,
    );

    log(
      '[OSAGO_REPO] CreateRequest yaratildi: provider=${request.provider}, sessionId=${request.sessionId}',
      name: 'OSAGO',
    );
    log(
      '[OSAGO_REPO] CreateRequest: drivers count=${request.drivers.length}, applicantIsDriver=${request.applicantIsDriver}',
      name: 'OSAGO',
    );
    log(
      '[OSAGO_REPO] CreateRequest: applicantLicenseSeria=$applicantLicenseSeria, applicantLicenseNumber=$applicantLicenseNumber',
      name: 'OSAGO',
    );
    log('[OSAGO_REPO] API create() chaqiruvi boshlandi...', name: 'OSAGO');

    final response = await _api.create(request);

    log(
      '[OSAGO_REPO] ✅ API create() javob qabul qilindi: sessionId=${response.sessionId}, policyNumber=${response.policyNumber}',
      name: 'OSAGO',
    );
    log(
      '[OSAGO_REPO] Create response: amount=${response.amount}, paymentUrl=${response.paymentUrl}',
      name: 'OSAGO',
    );

    return OsagoCreateResult(
      sessionId: response.sessionId,
      policyNumber: response.policyNumber,
      paymentUrl: response.paymentUrl,
      amount: response.amount,
      currency: response.currency,
    );
  }

  @override
  Future<OsagoCheckResult> check({required String sessionId}) async {
    log('[OSAGO_REPO] check() chaqirildi: sessionId=$sessionId', name: 'OSAGO');

    final request = CheckRequest(sessionId: sessionId);
    log('[OSAGO_REPO] CheckRequest yaratildi', name: 'OSAGO');
    log('[OSAGO_REPO] API check() chaqiruvi boshlandi...', name: 'OSAGO');

    final response = await _api.check(request);

    log(
      '[OSAGO_REPO] ✅ API check() javob qabul qilindi: sessionId=${response.sessionId}, status=${response.status}',
      name: 'OSAGO',
    );
    log(
      '[OSAGO_REPO] Check response: policyNumber=${response.policyNumber}, isReady=${response.isReady}',
      name: 'OSAGO',
    );
    log(
      '[OSAGO_REPO] Check response: amount=${response.amount}, issuedAt=${response.issuedAt}',
      name: 'OSAGO',
    );

    return OsagoCheckResult(
      sessionId: response.sessionId,
      status: response.status,
      policyNumber: response.policyNumber,
      issuedAt: response.issuedAt,
      amount: response.amount,
      currency: response.currency,
      downloadUrl: response.downloadUrl,
    );
  }

  String _sanitizeGos(String value) => value.replaceAll(' ', '').toUpperCase();

  DriverModel _mapDriverModel(OsagoDriver driver, String? ownerName) {
    // Используем имя водителя, если оно есть, иначе используем ownerName из calc response
    final driverName = driver.name ?? ownerName;
    return DriverModel(
      passportSeria: driver.passportSeria.toUpperCase(),
      passportNumber: driver.passportNumber,
      driverBirthday: driver.driverBirthday,
      relative: driver.relative,
      name: driverName,
      licenseSeria: driver.licenseSeria?.toUpperCase(),
      // Убеждаемся, что licenseNumber всегда строка
      licenseNumber: driver.licenseNumber?.toString(),
    );
  }

  OsagoInsurance _mapInsuranceModel(InsuranceModel model) {
    return OsagoInsurance(
      provider: model.provider,
      companyName: model.companyName,
      periodId: model.periodId,
      numberDriversId: model.numberDriversId,
      startDate: model.startDate,
      phoneNumber: model.phoneNumber,
      ownerInn: model.ownerInn,
      isUnlimited: model.isUnlimited,
    );
  }
}
