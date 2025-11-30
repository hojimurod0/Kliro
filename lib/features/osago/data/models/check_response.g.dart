// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CheckResponseImpl _$$CheckResponseImplFromJson(Map<String, dynamic> json) =>
    _$CheckResponseImpl(
      sessionId: json['session_id'] as String,
      policyNumber: json['policy_number'] as String?,
      status: json['status'] as String,
      issuedAt: parseNullableOsagoDate(json['issued_at'] as String?),
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      downloadUrl: json['download_url'] as String?,
    );

Map<String, dynamic> _$$CheckResponseImplToJson(_$CheckResponseImpl instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'policy_number': instance.policyNumber,
      'status': instance.status,
      'issued_at': formatNullableOsagoDate(instance.issuedAt),
      'amount': instance.amount,
      'currency': instance.currency,
      'download_url': instance.downloadUrl,
    };
