import '../../domain/entities/currency_rate.dart';
import '../../domain/repositories/currency_repository.dart';
import '../datasources/currency_local_data_source.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  CurrencyRepositoryImpl({required CurrencyLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final CurrencyLocalDataSource _localDataSource;

  @override
  List<CurrencyRate> getRates() {
    return _localDataSource.fetchRates();
  }
}
