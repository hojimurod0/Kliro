// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VehicleModelImpl _$$VehicleModelImplFromJson(Map<String, dynamic> json) =>
    _$VehicleModelImpl(
      brand: json['brand'] as String,
      model: json['model'] as String,
      gosNumber: json['gos_number'] as String,
      techSeria: json['tech_sery'] as String,
      techNumber: json['tech_number'] as String,
      ownerPassportSeria: json['owner__pass_seria'] as String,
      ownerPassportNumber: json['owner__pass_number'] as String,
      ownerBirthDate: parseOsagoDate(json['owner_birth_date'] as String),
    );

Map<String, dynamic> _$$VehicleModelImplToJson(_$VehicleModelImpl instance) =>
    <String, dynamic>{
      'brand': instance.brand,
      'model': instance.model,
      'gos_number': instance.gosNumber,
      'tech_sery': instance.techSeria,
      'tech_number': instance.techNumber,
      'owner__pass_seria': instance.ownerPassportSeria,
      'owner__pass_number': instance.ownerPassportNumber,
      'owner_birth_date': formatOsagoDate(instance.ownerBirthDate),
    };
