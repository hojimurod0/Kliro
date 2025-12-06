import '../entities/calculate_entity.dart';
import '../repositories/kasko_repository.dart';

class CalculatePolicy {
  CalculatePolicy(this._repository);

  final KaskoRepository _repository;

  Future<CalculateEntity> call({
    required int carId,
    required int year,
    required double price,
    required DateTime beginDate,
    required DateTime endDate,
    required int driverCount,
    required double franchise,
  }) {
    return _repository.calculatePolicy(
      carId: carId,
      year: year,
      price: price,
      beginDate: beginDate,
      endDate: endDate,
      driverCount: driverCount,
      franchise: franchise,
    );
  }
}

