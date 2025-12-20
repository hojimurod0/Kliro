// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fare_rules_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FareRulesModel _$FareRulesModelFromJson(Map<String, dynamic> json) =>
    FareRulesModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      rules: (json['rules'] as List<dynamic>?)
          ?.map((e) => RuleItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FareRulesModelToJson(FareRulesModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'rules': instance.rules,
    };

RuleItemModel _$RuleItemModelFromJson(Map<String, dynamic> json) =>
    RuleItemModel(
      type: json['type'] as String?,
      description: json['description'] as String?,
      allowed: json['allowed'] as bool?,
    );

Map<String, dynamic> _$RuleItemModelToJson(RuleItemModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'description': instance.description,
      'allowed': instance.allowed,
    };
