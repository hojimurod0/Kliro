// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'policy_info_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PolicyInfoModel _$PolicyInfoModelFromJson(Map<String, dynamic> json) =>
    PolicyInfoModel(
      policyNumber: json['policyNumber'] as String?,
      issueDate: json['issueDate'] as String?,
      expiryDate: json['expiryDate'] as String?,
    );

Map<String, dynamic> _$PolicyInfoModelToJson(PolicyInfoModel instance) =>
    <String, dynamic>{
      'policyNumber': instance.policyNumber,
      'issueDate': instance.issueDate,
      'expiryDate': instance.expiryDate,
    };
