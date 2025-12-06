// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calc_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CalcResponseImpl _$$CalcResponseImplFromJson(Map<String, dynamic> json) =>
    _$CalcResponseImpl(
      sessionId: json['session_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      provider: json['provider'] as String?,
      vehicle: json['vehicle'] == null
          ? null
          : VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>),
      insurance: json['insurance'] == null
          ? null
          : InsuranceModel.fromJson(json['insurance'] as Map<String, dynamic>),
      availableProviders: (json['available_providers'] as List<dynamic>?)
              ?.map((e) => InsuranceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <InsuranceModel>[],
      ownerName: json['owner_name'] as String?,
      numberDriversId: json['number_drivers_id'] as String?,
      issueYear: (json['issue_year'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CalcResponseImplToJson(_$CalcResponseImpl instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'amount': instance.amount,
      'currency': instance.currency,
      'provider': instance.provider,
      'vehicle': instance.vehicle,
      'insurance': instance.insurance,
      'available_providers': instance.availableProviders,
      'owner_name': instance.ownerName,
      'number_drivers_id': instance.numberDriversId,
      'issue_year': instance.issueYear,
    };
