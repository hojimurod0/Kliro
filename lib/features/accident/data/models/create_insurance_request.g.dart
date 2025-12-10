// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_insurance_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateInsuranceRequest _$CreateInsuranceRequestFromJson(
        Map<String, dynamic> json) =>
    CreateInsuranceRequest(
      startDate: json['start_date'] as String,
      tariffId: (json['tariff_id'] as num).toInt(),
      person: PersonModel.fromJson(json['person'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateInsuranceRequestToJson(
        CreateInsuranceRequest instance) =>
    <String, dynamic>{
      'start_date': instance.startDate,
      'tariff_id': instance.tariffId,
      'person': instance.person,
    };
