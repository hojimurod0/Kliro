import '../entities/auto_credit_filter.dart';
import '../entities/auto_credit_offer.dart';

abstract class AutoCreditRepository {
  Future<List<AutoCreditOffer>> getAutoCreditOffers({
    AutoCreditFilter filter = AutoCreditFilter.empty,
  });
}

