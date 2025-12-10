// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'traveler_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TravelerModel _$TravelerModelFromJson(Map<String, dynamic> json) =>
    TravelerModel(
      passportSeries: json['passportSeries'] as String,
      passportNumber: json['passportNumber'] as String,
      birthday: json['birthday'] as String,
      pinfl: json['pinfl'] as String,
      lastName: json['last_name'] as String,
      firstName: json['first_name'] as String,
    );

Map<String, dynamic> _$TravelerModelToJson(TravelerModel instance) =>
    <String, dynamic>{
      'passportSeries': instance.passportSeries,
      'passportNumber': instance.passportNumber,
      'birthday': instance.birthday,
      'pinfl': instance.pinfl,
      'last_name': instance.lastName,
      'first_name': instance.firstName,
    };
