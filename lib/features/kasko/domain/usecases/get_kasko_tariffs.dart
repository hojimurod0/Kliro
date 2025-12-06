import '../entities/kasko_tariff.dart';
import '../entities/rate_entity.dart';
import '../repositories/kasko_repository.dart';

class GetKaskoTariffs {
  final KaskoRepository repository;

  const GetKaskoTariffs(this.repository);

  Future<List<KaskoTariff>> call() async {
    final rates = await repository.getRates();
    return rates.map(_mapRateToTariff).toList();
  }

  KaskoTariff _mapRateToTariff(RateEntity rate) {
    return KaskoTariff(
      id: rate.id.toString(),
      title: rate.name,
      duration:
          '12 oy', // Default duration, можно добавить в RateEntity если нужно
      description: rate.description,
      price: rate.minPremium?.toStringAsFixed(0) ?? '0',
    );
  }
}
