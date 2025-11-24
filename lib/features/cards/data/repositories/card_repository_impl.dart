import '../../domain/entities/card_offer.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/card_local_data_source.dart';

class CardRepositoryImpl implements CardRepository {
  CardRepositoryImpl({
    required CardLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final CardLocalDataSource _localDataSource;

  @override
  Future<List<CardOffer>> getCardOffers() async {
    return await _localDataSource.fetchCardOffers();
  }
}

