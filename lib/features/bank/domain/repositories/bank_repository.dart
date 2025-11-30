import '../entities/bank_service.dart';
import '../entities/currency_entity.dart';

abstract class BankRepository {
  List<BankService> getServices();
  Future<List<BankService>> getBankServicesFromApi();
  Future<List<CurrencyEntity>> getCurrencies();
  Future<List<CurrencyEntity>> searchBankServices({
    required String query,
    int page = 0,
    int size = 10,
  });
}
