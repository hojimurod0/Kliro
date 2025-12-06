// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculate_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CalculateRequestImpl _$$CalculateRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CalculateRequestImpl(
      carId: (json['car_id'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      beginDate: json['begin_date'] as String,
      endDate: json['end_date'] as String,
      driverCount: (json['driver_count'] as num).toInt(),
      franchise: (json['franchise'] as num).toDouble(),
    );

Map<String, dynamic> _$$CalculateRequestImplToJson(
        _$CalculateRequestImpl instance) =>
    <String, dynamic>{
      'car_id': instance.carId,
      'year': instance.year,
      'price': instance.price,
      'begin_date': instance.beginDate,
      'end_date': instance.endDate,
      'driver_count': instance.driverCount,
      'franchise': instance.franchise,
    };
