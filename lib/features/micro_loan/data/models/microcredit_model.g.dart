// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'microcredit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MicrocreditModel _$MicrocreditModelFromJson(Map<String, dynamic> json) =>
    MicrocreditModel(
      id: _intFromJson(json['id']),
      bankName: _toString(json['bank_name']),
      description: _toString(json['description']),
      rate: _toString(json['rate']),
      term: _toString(json['term']),
      amount: _toString(json['amount']),
      channel: _toString(json['channel']),
      url: _toString(json['url']),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$MicrocreditModelToJson(MicrocreditModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bank_name': instance.bankName,
      'description': instance.description,
      'rate': instance.rate,
      'term': instance.term,
      'amount': instance.amount,
      'channel': instance.channel,
      'url': instance.url,
      'created_at': instance.createdAt?.toIso8601String(),
    };
