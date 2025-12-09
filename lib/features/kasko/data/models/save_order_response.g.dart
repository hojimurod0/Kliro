// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SaveOrderResponseImpl _$$SaveOrderResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$SaveOrderResponseImpl(
      orderId: json['order_id'] == null
          ? null
          : json['order_id'].toString(),
      premium: (json['premium'] as num?)?.toDouble(),
      carId: (json['car_id'] as num?)?.toInt(),
      ownerName: json['owner_name'] as String?,
      ownerPhone: json['owner_phone'] as String?,
      status: json['status'] as String?,
      message: json['message'] as String?,
      url: json['url'] as String?,
      urlShartnoma: json['url_shartnoma'] as String?,
      paymeUrl: json['payme_url'] as String?,
      contractId: json['contract_id'] == null
          ? null
          : json['contract_id'].toString(),
    );

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
