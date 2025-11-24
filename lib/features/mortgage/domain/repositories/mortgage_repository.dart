import '../entities/mortgage_offer.dart';

abstract class MortgageRepository {
  Future<List<MortgageOffer>> getMortgageOffers();
}

