import '../../domain/entities/mortgage_offer.dart';
import '../../domain/repositories/mortgage_repository.dart';
import '../datasources/mortgage_local_data_source.dart';

class MortgageRepositoryImpl implements MortgageRepository {
  MortgageRepositoryImpl({
    required MortgageLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final MortgageLocalDataSource _localDataSource;

  @override
  Future<List<MortgageOffer>> getMortgageOffers() async {
    return await _localDataSource.fetchMortgageOffers();
  }
}

