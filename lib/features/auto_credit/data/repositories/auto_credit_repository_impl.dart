import '../../domain/entities/auto_credit_offer.dart';
import '../../domain/repositories/auto_credit_repository.dart';
import '../datasources/auto_credit_local_data_source.dart';

class AutoCreditRepositoryImpl implements AutoCreditRepository {
  AutoCreditRepositoryImpl({
    required AutoCreditLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final AutoCreditLocalDataSource _localDataSource;

  @override
  Future<List<AutoCreditOffer>> getAutoCreditOffers() async {
    return await _localDataSource.fetchAutoCreditOffers();
  }
}

