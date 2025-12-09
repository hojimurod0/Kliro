// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonModel _$PersonModelFromJson(Map<String, dynamic> json) => PersonModel(
      type: (json['type'] as num).toInt(),
      passportSeries: json['passportSeries'] as String,
      passportNumber: json['passportNumber'] as String,
      birthday: json['birthday'] as String,
      phone: json['phone'] as String,
      pinfl: json['pinfl'] as String,
      lastName: json['lastName'] as String,
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String?,
    );

Map<String, dynamic> _$PersonModelToJson(PersonModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'passportSeries': instance.passportSeries,
      'passportNumber': instance.passportNumber,
      'birthday': instance.birthday,
      'phone': instance.phone,
      'pinfl': instance.pinfl,
      'lastName': instance.lastName,
      'firstName': instance.firstName,
      'middleName': instance.middleName,
    };
