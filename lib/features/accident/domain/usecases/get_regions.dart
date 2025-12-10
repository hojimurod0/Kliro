import '../../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/region_entity.dart';
import '../repositories/accident_repository.dart';

class GetRegions {
  GetRegions(this._repository);

  final AccidentRepository _repository;

  Future<Either<Failure, List<RegionEntity>>> call() {
    return _repository.getRegions();
  }
}

