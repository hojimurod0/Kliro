import '../entities/card_offer.dart';
import '../repositories/card_repository.dart';

class GetCardOffers {
  const GetCardOffers(this.repository);

  final CardRepository repository;

  Future<List<CardOffer>> call() => repository.getCardOffers();
}

