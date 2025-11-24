import '../../domain/entities/card_offer.dart';

class CardOfferModel extends CardOffer {
  const CardOfferModel({
    required super.bankName,
    required super.cardName,
    required super.currency,
    required super.rating,
    required super.cardTag,
    required super.typeTag,
    required super.typeTagColor,
    required super.metrics,
    required super.advantagesCount,
    super.isPrimaryCard,
  });
}

