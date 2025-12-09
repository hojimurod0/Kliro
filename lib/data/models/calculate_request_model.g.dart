// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculate_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalculateRequestModel _$CalculateRequestModelFromJson(
        Map<String, dynamic> json) =>
    CalculateRequestModel(
      sessionId: json['sessionId'] as String,
      accident: json['accident'] as bool,
      luggage: json['luggage'] as bool,
      cancelTravel: json['cancelTravel'] as bool,
      personRespon: json['personRespon'] as bool,
      delayTravel: json['delayTravel'] as bool,
    );

Map<String, dynamic> _$CalculateRequestModelToJson(
        CalculateRequestModel instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'accident': instance.accident,
      'luggage': instance.luggage,
      'cancelTravel': instance.cancelTravel,
      'personRespon': instance.personRespon,
      'delayTravel': instance.delayTravel,
    };
