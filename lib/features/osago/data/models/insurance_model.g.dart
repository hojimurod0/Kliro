// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insurance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InsuranceModelImpl _$$InsuranceModelImplFromJson(Map<String, dynamic> json) =>
    _$InsuranceModelImpl(
      provider: json['provider'] as String,
      companyName: json['company_name'] as String,
      periodId: json['period_id'] as String,
      numberDriversId: json['number_drivers_id'] as String,
      startDate: parseOsagoDate(json['start_date'] as String),
      phoneNumber: json['phone_number'] as String,
      ownerInn: json['owner__inn'] as String?,
    );

Map<String, dynamic> _$$InsuranceModelImplToJson(
        _$InsuranceModelImpl instance) =>
    <String, dynamic>{
      'provider': instance.provider,
      'company_name': instance.companyName,
      'period_id': instance.periodId,
      'number_drivers_id': instance.numberDriversId,
      'start_date': formatOsagoDate(instance.startDate),
      'phone_number': instance.phoneNumber,
      'owner__inn': instance.ownerInn,
    };
