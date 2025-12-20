import '../entities/car_page.dart';
import '../repositories/kasko_repository.dart';

class GetCarsPaginated {
  GetCarsPaginated(this._repository);

  final KaskoRepository _repository;

  Future<CarPage> call({
    required int page,
    required int size,
  }) {
    return _repository.getCarsPaginated(page: page, size: size);
  }
}

