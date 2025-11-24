import '../entities/deposit_offer.dart';
import '../repositories/deposit_repository.dart';

class GetDepositOffers {
  const GetDepositOffers(this.repository);

  final DepositRepository repository;

  List<DepositOffer> call() => repository.getOffers();
}
