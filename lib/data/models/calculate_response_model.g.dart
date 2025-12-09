// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculate_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalculateResponseModel _$CalculateResponseModelFromJson(
        Map<String, dynamic> json) =>
    CalculateResponseModel(
      premium: (json['premium'] as num?)?.toDouble(),
      summaAll: (json['summaAll'] as num?)?.toDouble(),
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CalculateResponseModelToJson(
        CalculateResponseModel instance) =>
    <String, dynamic>{
      'premium': instance.premium,
      'summaAll': instance.summaAll,
      'data': instance.data,
    };
