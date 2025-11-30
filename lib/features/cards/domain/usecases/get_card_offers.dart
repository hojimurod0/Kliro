import '../entities/card_filter.dart';
import '../entities/card_page.dart';
import '../repositories/card_repository.dart';

class GetCardOffers {
  const GetCardOffers(this.repository);

  final CardRepository repository;

  Future<CardPage> call({
    required int page,
    required int size,
    CardFilter filter = CardFilter.empty,
  }) => repository.getCardOffers(page: page, size: size, filter: filter);
}
