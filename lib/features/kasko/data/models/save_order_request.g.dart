// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_order_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SaveOrderRequestImpl _$$SaveOrderRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$SaveOrderRequestImpl(
      carId: (json['car_id'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      beginDate: json['begin_date'] as String,
      endDate: json['end_date'] as String,
      driverCount: (json['driver_count'] as num).toInt(),
      franchise: (json['franchise'] as num).toDouble(),
      premium: (json['premium'] as num).toDouble(),
      ownerName: json['owner_name'] as String,
      ownerPhone: json['owner_phone'] as String,
      ownerPassport: json['owner_passport'] as String,
      carNumber: json['car_number'] as String,
      vin: json['vin'] as String,
    );

Map<String, dynamic> _$$SaveOrderRequestImplToJson(
        _$SaveOrderRequestImpl instance) =>
    <String, dynamic>{
      'car_id': instance.carId,
      'year': instance.year,
      'price': instance.price,
      'begin_date': instance.beginDate,
      'end_date': instance.endDate,
      'driver_count': instance.driverCount,
      'franchise': instance.franchise,
      'premium': instance.premium,
      'owner_name': instance.ownerName,
      'owner_phone': instance.ownerPhone,
      'owner_passport': instance.ownerPassport,
      'car_number': instance.carNumber,
      'vin': instance.vin,
    };
