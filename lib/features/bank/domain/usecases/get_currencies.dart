import '../entities/currency_entity.dart';
import '../repositories/bank_repository.dart';

class GetCurrencies {
  const GetCurrencies(this.repository);

  final BankRepository repository;

  Future<List<CurrencyEntity>> call() {
    return repository.getCurrencies();
  }
}

