import '../entities/kasko_tariff.dart';
import '../repositories/kasko_repository.dart';

class GetKaskoTariffs {
  final KaskoRepository repository;

  const GetKaskoTariffs(this.repository);

  Future<List<KaskoTariff>> call() async {
    return await repository.getTariffs();
  }
}

