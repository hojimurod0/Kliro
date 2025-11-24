import '../../domain/entities/deposit_offer.dart';
import '../../domain/repositories/deposit_repository.dart';
import '../datasources/deposit_local_data_source.dart';

class DepositRepositoryImpl implements DepositRepository {
  DepositRepositoryImpl({required DepositLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final DepositLocalDataSource _localDataSource;

  @override
  List<DepositOffer> getOffers() {
    return _localDataSource.fetchOffers();
  }
}
