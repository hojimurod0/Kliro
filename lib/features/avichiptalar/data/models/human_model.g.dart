// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'human_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HumanModel _$HumanModelFromJson(Map<String, dynamic> json) => HumanModel(
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      middleName: json['middle_name'] as String?,
      birthDate: json['birth_date'] as String,
      gender: json['gender'] as String,
      citizenship: json['citizenship'] as String,
      passportNumber: json['passport_number'] as String,
      passportExpiry: json['passport_expiry'] as String,
      phone: json['phone'] as String,
    );

Map<String, dynamic> _$HumanModelToJson(HumanModel instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'middle_name': instance.middleName,
      'birth_date': instance.birthDate,
      'gender': instance.gender,
      'citizenship': instance.citizenship,
      'passport_number': instance.passportNumber,
      'passport_expiry': instance.passportExpiry,
      'phone': instance.phone,
    };
