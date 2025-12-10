// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculate_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalculateRequestModel _$CalculateRequestModelFromJson(
        Map<String, dynamic> json) =>
    CalculateRequestModel(
      sessionId: json['session_id'] as String,
      accident: json['accident'] as bool,
      luggage: json['luggage'] as bool,
      cancelTravel: json['cancel_travel'] as bool,
      personRespon: json['person_respon'] as bool,
      delayTravel: json['delay_travel'] as bool,
    );

Map<String, dynamic> _$CalculateRequestModelToJson(
        CalculateRequestModel instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'accident': instance.accident,
      'luggage': instance.luggage,
      'cancel_travel': instance.cancelTravel,
      'person_respon': instance.personRespon,
      'delay_travel': instance.delayTravel,
    };
