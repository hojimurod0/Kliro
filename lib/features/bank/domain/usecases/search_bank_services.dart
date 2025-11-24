import '../entities/currency_entity.dart';
import '../repositories/bank_repository.dart';

class SearchBankServices {
  const SearchBankServices(this.repository);

  final BankRepository repository;

  Future<List<CurrencyEntity>> call({
    required String query,
    int page = 0,
    int size = 10,
  }) {
    return repository.searchBankServices(
      query: query,
      page: page,
      size: size,
    );
  }
}

