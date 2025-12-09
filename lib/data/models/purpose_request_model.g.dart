// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purpose_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurposeRequestModel _$PurposeRequestModelFromJson(Map<String, dynamic> json) =>
    PurposeRequestModel(
      purposeId: (json['purposeId'] as num).toInt(),
      destinations: (json['destinations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PurposeRequestModelToJson(
        PurposeRequestModel instance) =>
    <String, dynamic>{
      'purposeId': instance.purposeId,
      'destinations': instance.destinations,
    };
