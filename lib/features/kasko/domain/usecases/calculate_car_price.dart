import '../entities/car_price_entity.dart';
import '../repositories/kasko_repository.dart';

class CalculateCarPrice {
  CalculateCarPrice(this._repository);

  final KaskoRepository _repository;

  Future<CarPriceEntity> call({
    required int carId,
    required int tarifId,
    required int year,
  }) {
    return _repository.calculateCarPrice(
      carId: carId,
      tarifId: tarifId,
      year: year,
    );
  }
}

