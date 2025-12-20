// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'airport_hint_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AirportHintModel _$AirportHintModelFromJson(Map<String, dynamic> json) =>
    AirportHintModel(
      code: json['code'] as String?,
      name: json['name'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      nameIntl: json['name_intl'] == null
          ? null
          : InternationalNames.fromJson(
              json['name_intl'] as Map<String, dynamic>),
      cityIntl: json['city_intl'] == null
          ? null
          : InternationalNames.fromJson(
              json['city_intl'] as Map<String, dynamic>),
      countryIntl: json['country_intl'] == null
          ? null
          : InternationalNames.fromJson(
              json['country_intl'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AirportHintModelToJson(AirportHintModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'city': instance.city,
      'country': instance.country,
      'name_intl': instance.nameIntl,
      'city_intl': instance.cityIntl,
      'country_intl': instance.countryIntl,
    };

InternationalNames _$InternationalNamesFromJson(Map<String, dynamic> json) =>
    InternationalNames(
      en: json['en'] as String?,
      ru: json['ru'] as String?,
      uz: json['uz'] as String?,
    );

Map<String, dynamic> _$InternationalNamesToJson(InternationalNames instance) =>
    <String, dynamic>{
      'en': instance.en,
      'ru': instance.ru,
      'uz': instance.uz,
    };
