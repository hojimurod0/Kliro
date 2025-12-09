// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckResponseModel _$CheckResponseModelFromJson(Map<String, dynamic> json) =>
    CheckResponseModel(
      status: json['status'] as String?,
      policyId: json['policyId'] as String?,
      policyNumber: json['policyNumber'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CheckResponseModelToJson(CheckResponseModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'policyId': instance.policyId,
      'policyNumber': instance.policyNumber,
      'data': instance.data,
    };
