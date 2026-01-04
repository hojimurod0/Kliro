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
import '../models/vehicle_model.dart';

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

    // Vehicle ma'lumotlarini map qilish
    OsagoVehicle? mappedVehicle;
    if (response.vehicle != null) {
      mappedVehicle = _mapVehicleModel(response.vehicle!, vehicle);
    }

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
      vehicle: mappedVehicle,
      issueYear: response.issueYear,
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
    // Har bir haydovchi bo'yicha batafsil log
    for (var i = 0; i < drivers.length; i++) {
      final d = drivers[i];
      log(
        '[OSAGO_REPO] Driver[$i]: passport=${d.passportSeria} ${d.passportNumber}, '
        'birthday=${d.driverBirthday}, relative=${d.relative}, '
        'name=${d.name}, licenseSeria=${d.licenseSeria}, licenseNumber=${d.licenseNumber}',
        name: 'OSAGO',
      );
    }
    log(
      '[OSAGO_REPO] Insurance: provider=${insurance.provider}, phoneNumber=${insurance.phoneNumber}, startDate=${insurance.startDate}',
      name: 'OSAGO',
    );
    log(
      '[OSAGO_REPO] Vehicle: isOwner=${vehicle.isOwner}, gosNumber=${vehicle.gosNumber}',
      name: 'OSAGO',
    );
    log(
      '[OSAGO_REPO] ownerName=$ownerName, numberDriversId=$numberDriversId',
      name: 'OSAGO',
    );

    // number_drivers_id ni to'g'ri aniqlash: provider, isUnlimited yoki insurance.numberDriversId ga qarab
    // MUHIM: finalNumberDriversId hech qachon null bo'lmasligi kerak, chunki API uni talab qiladi
    String finalNumberDriversId;
    
    // Provider va boshqa parametrlarni log qilish
    log(
      '[OSAGO_REPO] Provider tekshiruvi: provider="${insurance.provider}", isUnlimited=${insurance.isUnlimited}, numberDriversId=${insurance.numberDriversId}, paramNumberDriversId=$numberDriversId',
      name: 'OSAGO',
    );
    
    // numberDriversId ni aniqlash: isUnlimited yoki insurance.numberDriversId ga qarab
    // Bloc'da OSAGO type'ga qarab to'g'ri mapping qilingan, shuning uchun insurance.numberDriversId ni ishlatamiz
    if (insurance.isUnlimited) {
      // isUnlimited=true -> cheklanmagan (0)
      finalNumberDriversId = '0';
      log(
        '[OSAGO_REPO] ✅ isUnlimited=true, finalNumberDriversId=0 (Cheklanmagan)',
        name: 'OSAGO',
      );
    } else {
      // numberDriversId yoki insurance.numberDriversId dan olamiz
      final tempNumberDriversId = numberDriversId ?? insurance.numberDriversId;
      
      // Agar '0' yoki '5' bo'lsa, ishlatamiz
      if (tempNumberDriversId == '0' || tempNumberDriversId == '5') {
        finalNumberDriversId = tempNumberDriversId;
        log(
          '[OSAGO_REPO] ✅ finalNumberDriversId=$finalNumberDriversId (${finalNumberDriversId == '0' ? 'Cheklanmagan' : 'Cheklangan'})',
          name: 'OSAGO',
        );
      } else {
        // Default: '5' (Cheklangan) - hech qachon null emas
        finalNumberDriversId = '5';
        log(
          '[OSAGO_REPO] ⚠️ numberDriversId noto\'g\'ri yoki null ($tempNumberDriversId), default=5 ishlatilmoqda',
          name: 'OSAGO',
        );
      }
    }
    
    log(
      '[OSAGO_REPO] ✅ Final numberDriversId: $finalNumberDriversId (provider="${insurance.provider}")',
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

    // number_drivers_id ni CreateRequest ga qo'shamiz
    final request = CreateRequest(
      provider: insurance.provider,
      sessionId: sessionId,
      drivers: drivers
          .map((driver) => _mapDriverModel(driver, ownerName, finalNumberDriversId))
          .toList(),
      applicantIsDriver: false, // Postman: doim static false
      phoneNumber: insurance.phoneNumber,
      ownerInn: insurance.ownerInn?.isEmpty ?? true ? '' : insurance.ownerInn,
      applicantLicenseSeria: applicantLicenseSeria,
      applicantLicenseNumber: applicantLicenseNumber,
      numberDriversId:
          finalNumberDriversId, // To'g'ri number_drivers_id ni qo'shamiz
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
    // To'liq JSON payload ni log qilish (backendga nima ketayotganini ko'rish uchun)
    log('[OSAGO_REPO] CreateRequest JSON: ${request.toJson()}', name: 'OSAGO');
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
    log(
      '[OSAGO_REPO] Payment URLs: click=${response.pay?.click}, payme=${response.pay?.payme}',
      name: 'OSAGO',
    );

    return OsagoCreateResult(
      sessionId: response.sessionId,
      policyNumber: response.policyNumber,
      paymentUrl: response.paymentUrl,
      clickUrl: response.pay?.click,
      paymeUrl: response.pay?.payme,
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

  DriverModel _mapDriverModel(OsagoDriver driver, String? ownerName, String finalNumberDriversId) {
    // Используем имя водителя, если оно есть, иначе используем ownerName из calc response
    final driverName = driver.name ?? ownerName;

    // License ma'lumotlarini to'g'ri formatlash
    // MUHIM: Agar number_drivers_id: 5 bo'lsa (cheklangan), API license ma'lumotlarini talab qiladi
    // Agar number_drivers_id: 0 bo'lsa (cheklanmagan), license ma'lumotlari ixtiyoriy
    String? licenseSeria;
    String? licenseNumber;

    if (finalNumberDriversId == '5') {
      // Cheklangan (5) - license ma'lumotlari majburiy
      // Agar null yoki bo'sh bo'lsa, bo'sh string yuboramiz (null emas)
      licenseSeria = driver.licenseSeria?.toUpperCase().trim() ?? '';
      licenseNumber = driver.licenseNumber?.toString().trim() ?? '';
      log(
        '[OSAGO_REPO] _mapDriverModel: number_drivers_id=5, licenseSeria=$licenseSeria, licenseNumber=$licenseNumber',
        name: 'OSAGO',
      );
    } else {
      // Cheklanmagan (0) - license ma'lumotlari ixtiyoriy
      if (driver.licenseSeria != null && driver.licenseSeria!.trim().isNotEmpty) {
        licenseSeria = driver.licenseSeria!.toUpperCase();
      }
      if (driver.licenseNumber != null &&
          driver.licenseNumber!.toString().trim().isNotEmpty) {
        licenseNumber = driver.licenseNumber!.toString();
      }
      log(
        '[OSAGO_REPO] _mapDriverModel: number_drivers_id=0, licenseSeria=$licenseSeria, licenseNumber=$licenseNumber',
        name: 'OSAGO',
      );
    }

    return DriverModel(
      passportSeria: driver.passportSeria.toUpperCase(),
      passportNumber: driver.passportNumber,
      driverBirthday: driver.driverBirthday,
      relative: driver.relative,
      name: driverName,
      licenseSeria: licenseSeria,
      licenseNumber: licenseNumber,
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

  OsagoVehicle _mapVehicleModel(
    VehicleModel model,
    OsagoVehicle originalVehicle,
  ) {
    return OsagoVehicle(
      brand: model.brand.isNotEmpty ? model.brand : originalVehicle.brand,
      model: model.model.isNotEmpty ? model.model : originalVehicle.model,
      gosNumber: model.gosNumber.isNotEmpty
          ? model.gosNumber
          : originalVehicle.gosNumber,
      techSeria: model.techSeria.isNotEmpty
          ? model.techSeria
          : originalVehicle.techSeria,
      techNumber: model.techNumber.isNotEmpty
          ? model.techNumber
          : originalVehicle.techNumber,
      ownerPassportSeria: model.ownerPassportSeria.isNotEmpty
          ? model.ownerPassportSeria
          : originalVehicle.ownerPassportSeria,
      ownerPassportNumber: model.ownerPassportNumber.isNotEmpty
          ? model.ownerPassportNumber
          : originalVehicle.ownerPassportNumber,
      ownerBirthDate: model.ownerBirthDate,
      isOwner: model.isOwner,
    );
  }
}
