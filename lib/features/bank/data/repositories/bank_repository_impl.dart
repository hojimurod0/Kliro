import '../../domain/entities/bank_service.dart';
import '../../domain/entities/currency_entity.dart';
import '../../domain/repositories/bank_repository.dart';
import '../datasources/bank_local_data_source.dart';
import '../datasources/bank_remote_data_source.dart';

class BankRepositoryImpl implements BankRepository {
  BankRepositoryImpl({
    required BankLocalDataSource localDataSource,
    required BankRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  final BankLocalDataSource _localDataSource;
  final BankRemoteDataSource _remoteDataSource;

  @override
  List<BankService> getServices() {
    return _localDataSource.fetchServices();
  }

  @override
  Future<List<CurrencyEntity>> getCurrencies() async {
    final models = await _remoteDataSource.getCurrencies();
    return models;
  }

  @override
  Future<List<CurrencyEntity>> searchBankServices({
    required String query,
    int page = 0,
    int size = 10,
  }) async {
    final models = await _remoteDataSource.searchBankServices(
      query: query,
      page: page,
      size: size,
    );
    return models;
  }
}
