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
    final request = CalcRequest(
      gosNumber: _sanitizeGos(vehicle.gosNumber),
      techSeria: vehicle.techSeria.toUpperCase(),
      techNumber: vehicle.techNumber,
      ownerPassSeria: vehicle.ownerPassportSeria.toUpperCase(),
      ownerPassNumber: vehicle.ownerPassportNumber,
      periodId: insurance.periodId,
      numberDriversId: insurance.numberDriversId,
    );

    final response = await _api.calc(request);
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
    // Если заявитель является водителем, берем данные водительского удостоверения из первого водителя
    String? applicantLicenseSeria;
    String? applicantLicenseNumber;
    if (vehicle.isOwner && drivers.isNotEmpty) {
      final firstDriver = drivers.first;
      if (firstDriver.licenseSeria != null &&
          firstDriver.licenseSeria!.isNotEmpty) {
        applicantLicenseSeria = firstDriver.licenseSeria!.toUpperCase();
        // Убеждаемся, что licenseNumber всегда строка
        applicantLicenseNumber = firstDriver.licenseNumber?.toString() ?? '';
      } else {
        // Если данные не заполнены, но applicant_is_driver: true, это ошибка
        // Но на всякий случай передаем пустые строки
        applicantLicenseSeria = '';
        applicantLicenseNumber = '';
      }
    }

    // number_drivers_id ni to'g'ri aniqlash: provider, isUnlimited yoki insurance.numberDriversId ga qarab
    // MUHIM: finalNumberDriversId hech qachon null bo'lmasligi kerak, chunki API uni talab qiladi
    String finalNumberDriversId;

    // Avval provider ni tekshiramiz (ustunlik) - NEO doim cheklanmagan (0)
    final providerLower = insurance.provider.toLowerCase();
    if (providerLower == 'neo') {
      finalNumberDriversId = '0';
    } else if (insurance.isUnlimited) {
      // Keyin isUnlimited ni tekshiramiz
      finalNumberDriversId = '0';
    } else {
      // numberDriversId yoki insurance.numberDriversId dan olamiz
      final tempNumberDriversId = numberDriversId ?? insurance.numberDriversId;

      // Agar '0' yoki '5' bo'lsa, ishlatamiz
      if (tempNumberDriversId == '0' || tempNumberDriversId == '5') {
        finalNumberDriversId = tempNumberDriversId;
      } else {
        // Default: '5' (Cheklangan) - hech qachon null emas
        finalNumberDriversId = '5';
      }
    }

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
      numberDriversId: finalNumberDriversId, // Majburiy parametr
      startDate: insurance.startDate,
    );

    final response = await _api.create(request);
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
    final response = await _api.check(CheckRequest(sessionId: sessionId));
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
