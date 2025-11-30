import '../entities/card_filter.dart';
import '../entities/card_page.dart';

abstract class CardRepository {
  Future<CardPage> getCardOffers({
    required int page,
    required int size,
    CardFilter filter,
  });
}
