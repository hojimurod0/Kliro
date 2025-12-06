// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_price_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CarPriceRequestImpl _$$CarPriceRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CarPriceRequestImpl(
      carPositionId: (json['car_position_id'] as num).toInt(),
      tarifId: (json['tarif_id'] as num).toInt(),
      year: (json['year'] as num).toInt(),
    );

Map<String, dynamic> _$$CarPriceRequestImplToJson(
        _$CarPriceRequestImpl instance) =>
    <String, dynamic>{
      'car_position_id': instance.carPositionId,
      'tarif_id': instance.tarifId,
      'year': instance.year,
    };
