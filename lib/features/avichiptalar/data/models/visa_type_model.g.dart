// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visa_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisaTypeModel _$VisaTypeModelFromJson(Map<String, dynamic> json) =>
    VisaTypeModel(
      country: json['country'] as String?,
      type: json['type'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      isRequired: json['required'] as bool?,
    );

Map<String, dynamic> _$VisaTypeModelToJson(VisaTypeModel instance) =>
    <String, dynamic>{
      'country': instance.country,
      'type': instance.type,
      'name': instance.name,
      'description': instance.description,
      'required': instance.isRequired,
    };
