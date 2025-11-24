import '../entities/auto_credit_offer.dart';

abstract class AutoCreditRepository {
  Future<List<AutoCreditOffer>> getAutoCreditOffers();
}

