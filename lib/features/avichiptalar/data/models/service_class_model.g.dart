// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_class_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceClassModel _$ServiceClassModelFromJson(Map<String, dynamic> json) =>
    ServiceClassModel(
      code: json['code'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      nameIntl: (json['name_intl'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$ServiceClassModelToJson(ServiceClassModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'name_intl': instance.nameIntl,
    };
