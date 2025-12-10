// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_policy_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavePolicyRequestModel _$SavePolicyRequestModelFromJson(
        Map<String, dynamic> json) =>
    SavePolicyRequestModel(
      sessionId: json['session_id'] as String,
      provider: json['provider'] as String,
      summaAll: (json['summa_all'] as num).toDouble(),
      programId: json['program_id'] as String,
      sugurtalovchi:
          PersonModel.fromJson(json['sugurtalovchi'] as Map<String, dynamic>),
      travelers: (json['travelers'] as List<dynamic>)
          .map((e) => TravelerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SavePolicyRequestModelToJson(
        SavePolicyRequestModel instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'provider': instance.provider,
      'summa_all': instance.summaAll,
      'program_id': instance.programId,
      'sugurtalovchi': instance.sugurtalovchi,
      'travelers': instance.travelers,
    };
