import '../entities/mortgage_offer.dart';
import '../repositories/mortgage_repository.dart';

class GetMortgageOffers {
  const GetMortgageOffers(this.repository);

  final MortgageRepository repository;

  Future<List<MortgageOffer>> call() => repository.getMortgageOffers();
}

