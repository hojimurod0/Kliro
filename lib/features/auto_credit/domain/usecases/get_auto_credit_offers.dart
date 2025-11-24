import '../entities/auto_credit_offer.dart';
import '../repositories/auto_credit_repository.dart';

class GetAutoCreditOffers {
  const GetAutoCreditOffers(this.repository);

  final AutoCreditRepository repository;

  Future<List<AutoCreditOffer>> call() => repository.getAutoCreditOffers();
}

