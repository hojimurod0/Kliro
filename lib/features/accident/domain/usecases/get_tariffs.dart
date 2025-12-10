import '../../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/tariff_entity.dart';
import '../repositories/accident_repository.dart';

class GetTariffs {
  GetTariffs(this._repository);

  final AccidentRepository _repository;

  Future<Either<Failure, List<TariffEntity>>> call() {
    return _repository.getTariffs();
  }
}

