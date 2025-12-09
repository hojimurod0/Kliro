// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_policy_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavePolicyRequestModel _$SavePolicyRequestModelFromJson(
        Map<String, dynamic> json) =>
    SavePolicyRequestModel(
      sessionId: json['sessionId'] as String,
      provider: json['provider'] as String,
      summaAll: (json['summaAll'] as num).toDouble(),
      programId: json['programId'] as String,
      sugurtalovchi:
          PersonModel.fromJson(json['sugurtalovchi'] as Map<String, dynamic>),
      travelers: (json['travelers'] as List<dynamic>)
          .map((e) => TravelerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SavePolicyRequestModelToJson(
        SavePolicyRequestModel instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'provider': instance.provider,
      'summaAll': instance.summaAll,
      'programId': instance.programId,
      'sugurtalovchi': instance.sugurtalovchi,
      'travelers': instance.travelers,
    };
