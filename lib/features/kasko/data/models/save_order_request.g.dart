// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_order_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SugurtalovchiImpl _$$SugurtalovchiImplFromJson(Map<String, dynamic> json) =>
    _$SugurtalovchiImpl(
      passportSeries: json['passportSeries'] as String,
      passportNumber: json['passportNumber'] as String,
      birthday: json['birthday'] as String,
      phone: json['phone'] as String,
    );

Map<String, dynamic> _$$SugurtalovchiImplToJson(_$SugurtalovchiImpl instance) =>
    <String, dynamic>{
      'passportSeries': instance.passportSeries,
      'passportNumber': instance.passportNumber,
      'birthday': instance.birthday,
      'phone': instance.phone,
    };

_$CarDataImpl _$$CarDataImplFromJson(Map<String, dynamic> json) =>
    _$CarDataImpl(
      carNomer: json['car_nomer'] as String,
      seria: json['seria'] as String,
      number: json['number'] as String,
      priceOfCar: json['price_of_car'] as String,
    );

Map<String, dynamic> _$$CarDataImplToJson(_$CarDataImpl instance) =>
    <String, dynamic>{
      'car_nomer': instance.carNomer,
      'seria': instance.seria,
      'number': instance.number,
      'price_of_car': instance.priceOfCar,
    };

_$SaveOrderRequestImpl _$$SaveOrderRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$SaveOrderRequestImpl(
      sugurtalovchi:
          Sugurtalovchi.fromJson(json['sugurtalovchi'] as Map<String, dynamic>),
      car: CarData.fromJson(json['car'] as Map<String, dynamic>),
      beginDate: json['begin_date'] as String,
      liability: (json['liability'] as num).toInt(),
      premium: (json['premium'] as num).toInt(),
      tarifId: (json['tarif_id'] as num).toInt(),
      tarifType: (json['tarif_type'] as num).toInt(),
    );

Map<String, dynamic> _$$SaveOrderRequestImplToJson(
        _$SaveOrderRequestImpl instance) =>
    <String, dynamic>{
      'sugurtalovchi': instance.sugurtalovchi,
      'car': instance.car,
      'begin_date': instance.beginDate,
      'liability': instance.liability,
      'premium': instance.premium,
      'tarif_id': instance.tarifId,
      'tarif_type': instance.tarifType,
    };
