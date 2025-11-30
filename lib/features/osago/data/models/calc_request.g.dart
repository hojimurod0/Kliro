// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calc_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CalcRequestImpl _$$CalcRequestImplFromJson(Map<String, dynamic> json) =>
    _$CalcRequestImpl(
      gosNumber: json['gos_number'] as String,
      techSeria: json['tech_sery'] as String,
      techNumber: json['tech_number'] as String,
      ownerPassSeria: json['owner__pass_seria'] as String,
      ownerPassNumber: json['owner__pass_number'] as String,
      periodId: json['period_id'] as String,
      numberDriversId: json['number_drivers_id'] as String,
    );

Map<String, dynamic> _$$CalcRequestImplToJson(_$CalcRequestImpl instance) =>
    <String, dynamic>{
      'gos_number': instance.gosNumber,
      'tech_sery': instance.techSeria,
      'tech_number': instance.techNumber,
      'owner__pass_seria': instance.ownerPassSeria,
      'owner__pass_number': instance.ownerPassNumber,
      'period_id': instance.periodId,
      'number_drivers_id': instance.numberDriversId,
    };
