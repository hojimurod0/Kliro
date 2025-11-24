import '../entities/currency_rate.dart';
import '../repositories/currency_repository.dart';

class GetCurrencyRates {
  const GetCurrencyRates(this.repository);

  final CurrencyRepository repository;

  List<CurrencyRate> call() => repository.getRates();
}
