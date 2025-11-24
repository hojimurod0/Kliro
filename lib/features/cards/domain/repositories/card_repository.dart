import '../entities/card_offer.dart';

abstract class CardRepository {
  Future<List<CardOffer>> getCardOffers();
}

