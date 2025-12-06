// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rate_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RateModelImpl _$$RateModelImplFromJson(Map<String, dynamic> json) =>
    _$RateModelImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      minPremium: (json['min_premium'] as num?)?.toDouble(),
      maxPremium: (json['max_premium'] as num?)?.toDouble(),
      franchise: (json['franchise'] as num?)?.toDouble() ?? 0,
      percent: (json['percent'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$RateModelImplToJson(_$RateModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'min_premium': instance.minPremium,
      'max_premium': instance.maxPremium,
      'franchise': instance.franchise,
      'percent': instance.percent,
    };
