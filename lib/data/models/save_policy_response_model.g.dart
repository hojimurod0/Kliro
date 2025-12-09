// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_policy_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavePolicyResponseModel _$SavePolicyResponseModelFromJson(
        Map<String, dynamic> json) =>
    SavePolicyResponseModel(
      policyId: json['policyId'] as String?,
      policyNumber: json['policyNumber'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SavePolicyResponseModelToJson(
        SavePolicyResponseModel instance) =>
    <String, dynamic>{
      'policyId': instance.policyId,
      'policyNumber': instance.policyNumber,
      'data': instance.data,
    };
