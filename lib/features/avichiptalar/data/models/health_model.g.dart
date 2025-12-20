// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthModel _$HealthModelFromJson(Map<String, dynamic> json) => HealthModel(
      status: json['status'] as String?,
      version: json['version'] as String?,
      services: json['services'] as Map<String, dynamic>?,
      uptimeSeconds: (json['uptime'] as num?)?.toInt(),
    );

Map<String, dynamic> _$HealthModelToJson(HealthModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'version': instance.version,
      'services': instance.services,
      'uptime': instance.uptimeSeconds,
    };
