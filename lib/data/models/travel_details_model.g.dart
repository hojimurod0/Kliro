// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TravelDetailsModel _$TravelDetailsModelFromJson(Map<String, dynamic> json) =>
    TravelDetailsModel(
      sessionId: json['session_id'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      travelersBirthdates: (json['travelers_birthdates'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      annualPolicy: json['annual_policy'] as bool,
      covidProtection: json['covid_protection'] as bool,
    );

Map<String, dynamic> _$TravelDetailsModelToJson(TravelDetailsModel instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'travelers_birthdates': instance.travelersBirthdates,
      'annual_policy': instance.annualPolicy,
      'covid_protection': instance.covidProtection,
    };
