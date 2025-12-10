import '../../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/create_insurance_entity.dart';
import '../repositories/accident_repository.dart';

class CreateInsurance {
  CreateInsurance(this._repository);

  final AccidentRepository _repository;

  Future<Either<Failure, CreateInsuranceEntity>> call({
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
  }) {
    return _repository.createInsurance(
      startDate: startDate,
      tariffId: tariffId,
      pinfl: pinfl,
      passSery: passSery,
      passNum: passNum,
      dateBirth: dateBirth,
      lastName: lastName,
      firstName: firstName,
      patronymName: patronymName,
      region: region,
      phone: phone,
      address: address,
    );
  }
}

