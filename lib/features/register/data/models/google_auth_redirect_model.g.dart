// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_auth_redirect_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleAuthRedirectModel _$GoogleAuthRedirectModelFromJson(
        Map<String, dynamic> json) =>
    GoogleAuthRedirectModel(
      url: json['url'] as String,
      sessionId: json['session_id'] as String?,
    );

Map<String, dynamic> _$GoogleAuthRedirectModelToJson(
        GoogleAuthRedirectModel instance) =>
    <String, dynamic>{
      'url': instance.url,
      'session_id': instance.sessionId,
    };
