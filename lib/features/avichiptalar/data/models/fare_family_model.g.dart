// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fare_family_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FareFamilyModel _$FareFamilyModelFromJson(Map<String, dynamic> json) =>
    FareFamilyModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      price: FareFamilyModel._priceFromJson(json['price']),
      currency: FareFamilyModel._stringFromJson(json['currency']),
      handBaggage: json['hand_baggage'],
      handLuggage: json['hand_luggage'],
      carryOn: json['carry_on'],
      baggage: json['baggage'],
      checkedBaggage: json['checked_baggage'],
      exchange: json['exchange'],
      change: json['change'],
      refund: json['refund'],
      returnPolicy: json['return'],
    );

Map<String, dynamic> _$FareFamilyModelToJson(FareFamilyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'currency': instance.currency,
      'hand_baggage': instance.handBaggage,
      'hand_luggage': instance.handLuggage,
      'carry_on': instance.carryOn,
      'baggage': instance.baggage,
      'checked_baggage': instance.checkedBaggage,
      'exchange': instance.exchange,
      'change': instance.change,
      'refund': instance.refund,
      'return': instance.returnPolicy,
    };

FareFamilyResponseModel _$FareFamilyResponseModelFromJson(
        Map<String, dynamic> json) =>
    FareFamilyResponseModel(
      families: (json['families'] as List<dynamic>?)
          ?.map((e) => FareFamilyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FareFamilyResponseModelToJson(
        FareFamilyResponseModel instance) =>
    <String, dynamic>{
      'families': instance.families,
    };
