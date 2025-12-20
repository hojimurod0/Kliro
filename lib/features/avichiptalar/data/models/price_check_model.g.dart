// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_check_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceCheckModel _$PriceCheckModelFromJson(Map<String, dynamic> json) =>
    PriceCheckModel(
      price: json['price'] as String?,
      currency: json['currency'] as String?,
      priceChanged: json['price_changed'] as bool?,
      oldPrice: json['old_price'] as String?,
    );

Map<String, dynamic> _$PriceCheckModelToJson(PriceCheckModel instance) =>
    <String, dynamic>{
      'price': instance.price,
      'currency': instance.currency,
      'price_changed': instance.priceChanged,
      'old_price': instance.oldPrice,
    };
