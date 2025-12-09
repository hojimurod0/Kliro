// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TravelDetailsModel _$TravelDetailsModelFromJson(Map<String, dynamic> json) =>
    TravelDetailsModel(
      sessionId: json['sessionId'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      travelersBirthdates: (json['travelersBirthdates'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      annualPolicy: json['annualPolicy'] as bool,
      covidProtection: json['covidProtection'] as bool,
    );

Map<String, dynamic> _$TravelDetailsModelToJson(TravelDetailsModel instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'travelersBirthdates': instance.travelersBirthdates,
      'annualPolicy': instance.annualPolicy,
      'covidProtection': instance.covidProtection,
    };
