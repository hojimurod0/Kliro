import 'package:equatable/equatable.dart';

class CardOffer extends Equatable {
  const CardOffer({
    required this.id,
    required this.bankName,
    required this.cardName,
    this.cardNetwork,
    this.cardCategory,
    this.cardType,
    this.currency,
    this.cashback,
    this.serviceFee,
    this.limitAmount,
    this.delivery,
    this.opening,
    this.description,
    this.gracePeriod,
    this.minIncome,
    this.processingTime,
    this.rating,
    this.url,
    this.advantages,
    this.features,
    this.createdAt,
    this.isPrimaryCard = false,
  });

  final int id;
  final String bankName;
  final String cardName;
  final String? cardNetwork;
  final String? cardCategory;
  final String? cardType;
  final String? currency;
  final String? cashback;
  final String? serviceFee;
  final String? limitAmount;
  final String? delivery;
  final String? opening;
  final String? description;
  final String? gracePeriod;
  final String? minIncome;
  final String? processingTime;
  final double? rating;
  final String? url;
  final List<String>? advantages;
  final List<String>? features;
  final DateTime? createdAt;
  final bool isPrimaryCard;

  int get advantagesCount => advantages?.length ?? features?.length ?? 0;

  @override
  List<Object?> get props => [
    id,
    bankName,
    cardName,
    cardNetwork,
    cardCategory,
    cardType,
    currency,
    cashback,
    serviceFee,
    limitAmount,
    delivery,
    opening,
    description,
    gracePeriod,
    minIncome,
    processingTime,
    rating,
    url,
    advantages,
    features,
    createdAt,
    isPrimaryCard,
  ];
}
