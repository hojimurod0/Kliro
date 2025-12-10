import '../../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/tariff_entity.dart';
import '../entities/region_entity.dart';
import '../entities/create_insurance_entity.dart';
import '../entities/check_payment_entity.dart';

abstract class AccidentRepository {
  Future<Either<Failure, List<TariffEntity>>> getTariffs();
  Future<Either<Failure, List<RegionEntity>>> getRegions();
  Future<Either<Failure, CreateInsuranceEntity>> createInsurance({
    required String startDate,
    required int tariffId,
    required String pinfl,
    required String passSery,
    required String passNum,
    required String dateBirth,
    required String lastName,
    required String firstName,
    String? patronymName,
    required int region,
    required String phone,
    required String address,
  });
  Future<Either<Failure, CheckPaymentEntity>> checkPayment({
    required int anketaId,
    required String lan,
  });
}

