// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonModel _$PersonModelFromJson(Map<String, dynamic> json) => PersonModel(
      pinfl: json['pinfl'] as String,
      passSery: json['pass_sery'] as String,
      passNum: json['pass_num'] as String,
      dateBirth: json['date_birth'] as String,
      lastName: json['last_name'] as String,
      firstName: json['first_name'] as String,
      patronymName: json['patronym_name'] as String?,
      region: (json['region'] as num).toInt(),
      phone: json['phone'] as String,
      address: json['address'] as String,
    );

Map<String, dynamic> _$PersonModelToJson(PersonModel instance) =>
    <String, dynamic>{
      'pinfl': instance.pinfl,
      'pass_sery': instance.passSery,
      'pass_num': instance.passNum,
      'date_birth': instance.dateBirth,
      'last_name': instance.lastName,
      'first_name': instance.firstName,
      'patronym_name': instance.patronymName,
      'region': instance.region,
      'phone': instance.phone,
      'address': instance.address,
    };
