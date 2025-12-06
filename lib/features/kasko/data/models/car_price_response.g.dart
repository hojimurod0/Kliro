// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_price_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CarPriceResponseImpl _$$CarPriceResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CarPriceResponseImpl(
      price: (json['price'] as num).toDouble(),
      carId: (json['car_id'] as num?)?.toInt(),
      year: (json['year'] as num?)?.toInt(),
      currency: json['currency'] as String?,
    );

Map<String, dynamic> _$$CarPriceResponseImplToJson(
        _$CarPriceResponseImpl instance) =>
    <String, dynamic>{
      'price': instance.price,
      'car_id': instance.carId,
      'year': instance.year,
      'currency': instance.currency,
    };
