import '../entities/deposit_offer.dart';

abstract class DepositRepository {
  List<DepositOffer> getOffers();
}
