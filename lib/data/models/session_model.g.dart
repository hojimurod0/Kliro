// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionModel _$SessionModelFromJson(Map<String, dynamic> json) => SessionModel(
      sessionId: json['sessionId'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SessionModelToJson(SessionModel instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'data': instance.data,
    };
