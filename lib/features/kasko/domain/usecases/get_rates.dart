import '../entities/rate_entity.dart';
import '../repositories/kasko_repository.dart';

class GetRates {
  GetRates(this._repository);

  final KaskoRepository _repository;

  Future<List<RateEntity>> call() {
    return _repository.getRates();
  }
}

