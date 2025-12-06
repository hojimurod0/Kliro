// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculate_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CalculateResponseImpl _$$CalculateResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CalculateResponseImpl(
      premium: (json['premium'] as num).toDouble(),
      carId: (json['car_id'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      beginDate: json['begin_date'] as String,
      endDate: json['end_date'] as String,
      driverCount: (json['driver_count'] as num).toInt(),
      franchise: (json['franchise'] as num).toDouble(),
      currency: json['currency'] as String?,
      rates: (json['rates'] as List<dynamic>?)
              ?.map((e) => RateModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CalculateResponseImplToJson(
        _$CalculateResponseImpl instance) =>
    <String, dynamic>{
      'premium': instance.premium,
      'car_id': instance.carId,
      'year': instance.year,
      'price': instance.price,
      'begin_date': instance.beginDate,
      'end_date': instance.endDate,
      'driver_count': instance.driverCount,
      'franchise': instance.franchise,
      'currency': instance.currency,
      'rates': instance.rates,
    };
