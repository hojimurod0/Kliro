// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_offer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardOfferModel _$CardOfferModelFromJson(Map<String, dynamic> json) =>
    CardOfferModel(
      id: _intFromJson(json['id']),
      bankName: _toString(json['bank_name']),
      cardName: _toString(json['card_name']),
      cardNetwork: _toStringOrNull(json['card_network']),
      cardCategory: _toStringOrNull(json['card_category']),
      cardType: _toStringOrNull(json['card_type']),
      currency: _toStringOrNull(json['currency']),
      cashback: _toStringOrNull(json['cashback']),
      serviceFee: _toStringOrNull(json['service_fee']),
      limitAmount: _toStringOrNull(json['limit_amount']),
      delivery: _toStringOrNull(json['delivery']),
      opening: _toStringOrNull(json['opening']),
      description: _toStringOrNull(json['description']),
      gracePeriod: _toStringOrNull(json['grace_period']),
      minIncome: _toStringOrNull(json['min_income']),
      processingTime: _toStringOrNull(json['processing_time']),
      rating: _doubleFromJsonOrNull(json['rating']),
      url: _toStringOrNull(json['url']),
      advantages: _stringListFromJson(json['advantages']),
      features: _stringListFromJson(json['features']),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CardOfferModelToJson(CardOfferModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bank_name': instance.bankName,
      'card_name': instance.cardName,
      'card_network': instance.cardNetwork,
      'card_category': instance.cardCategory,
      'card_type': instance.cardType,
      'currency': instance.currency,
      'cashback': instance.cashback,
      'service_fee': instance.serviceFee,
      'limit_amount': instance.limitAmount,
      'delivery': instance.delivery,
      'opening': instance.opening,
      'description': instance.description,
      'grace_period': instance.gracePeriod,
      'min_income': instance.minIncome,
      'processing_time': instance.processingTime,
      'rating': instance.rating,
      'url': instance.url,
      'advantages': instance.advantages,
      'features': instance.features,
      'created_at': instance.createdAt?.toIso8601String(),
    };
