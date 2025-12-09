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
      lastName: json['lastName'] as String,
      firstName: json['firstName'] as String,
    );

Map<String, dynamic> _$TravelerModelToJson(TravelerModel instance) =>
    <String, dynamic>{
      'passportSeries': instance.passportSeries,
      'passportNumber': instance.passportNumber,
      'birthday': instance.birthday,
      'pinfl': instance.pinfl,
      'lastName': instance.lastName,
      'firstName': instance.firstName,
    };
