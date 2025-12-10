// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tariff_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TariffModel _$TariffModelFromJson(Map<String, dynamic> json) => TariffModel(
      id: (json['id'] as num).toInt(),
      insurancePremium: (json['insurance_premium'] as num).toDouble(),
      insuranceOtv: (json['insurance_otv'] as num).toDouble(),
    );

Map<String, dynamic> _$TariffModelToJson(TariffModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'insurance_premium': instance.insurancePremium,
      'insurance_otv': instance.insuranceOtv,
    };
