// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tarif_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TarifResponseModel _$TarifResponseModelFromJson(Map<String, dynamic> json) =>
    TarifResponseModel(
      tarifs: (json['tarifs'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TarifResponseModelToJson(TarifResponseModel instance) =>
    <String, dynamic>{
      'tarifs': instance.tarifs,
      'data': instance.data,
    };
