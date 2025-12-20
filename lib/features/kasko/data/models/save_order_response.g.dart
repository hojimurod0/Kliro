// GENERATED CODE - DO NOT MODIFY BY HAND
// NOTE: This file has been manually modified to handle int to String conversion
// for order_id and contract_id fields. If regenerated, these changes will be lost.

part of 'save_order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SaveOrderResponseImpl _$$SaveOrderResponseImplFromJson(
        Map<String, dynamic> json) {
  // Handle int to String conversion for order_id and contract_id
  final orderIdValue = json['order_id'];
  final contractIdValue = json['contract_id'];
  
  return _$SaveOrderResponseImpl(
    orderId: orderIdValue == null
        ? null
        : (orderIdValue is int ? orderIdValue.toString() : orderIdValue as String?),
    premium: (json['premium'] as num?)?.toDouble(),
    carId: (json['car_id'] as num?)?.toInt(),
    ownerName: json['owner_name'] as String?,
    ownerPhone: json['owner_phone'] as String?,
    status: json['status'] as String?,
    message: json['message'] as String?,
    url: json['url'] as String?,
    urlShartnoma: json['url_shartnoma'] as String?,
    paymeUrl: json['payme_url'] as String?,
    contractId: contractIdValue == null
        ? null
        : (contractIdValue is int ? contractIdValue.toString() : contractIdValue as String?),
  );
}

Map<String, dynamic> _$$SaveOrderResponseImplToJson(
        _$SaveOrderResponseImpl instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'premium': instance.premium,
      'car_id': instance.carId,
      'owner_name': instance.ownerName,
      'owner_phone': instance.ownerPhone,
      'status': instance.status,
      'message': instance.message,
      'url': instance.url,
      'url_shartnoma': instance.urlShartnoma,
      'payme_url': instance.paymeUrl,
      'contract_id': instance.contractId,
    };

