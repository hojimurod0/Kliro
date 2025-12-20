// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passenger_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PassengerTypeModel _$PassengerTypeModelFromJson(Map<String, dynamic> json) =>
    PassengerTypeModel(
      code: json['code'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      minAge: (json['min_age'] as num?)?.toInt(),
      maxAge: (json['max_age'] as num?)?.toInt(),
      nameIntl: (json['name_intl'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$PassengerTypeModelToJson(PassengerTypeModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'min_age': instance.minAge,
      'max_age': instance.maxAge,
      'name_intl': instance.nameIntl,
    };
