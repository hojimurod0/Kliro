import '../entities/car_entity.dart';
import '../repositories/kasko_repository.dart';

class GetCars {
  GetCars(this._repository);

  final KaskoRepository _repository;

  Future<List<CarEntity>> call() {
    return _repository.getCars();
  }
}

