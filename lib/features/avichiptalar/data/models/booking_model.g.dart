// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) => BookingModel(
      id: json['id'] as String?,
      status: json['status'] as String?,
      price: json['price'] as String?,
      currency: json['currency'] as String?,
      payer: json['payer'] == null
          ? null
          : PayerModel.fromJson(json['payer'] as Map<String, dynamic>),
      passengers: (json['passengers'] as List<dynamic>?)
          ?.map((e) => PassengerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      offers: (json['offers'] as List<dynamic>?)
          ?.map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$BookingModelToJson(BookingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'price': instance.price,
      'currency': instance.currency,
      'payer': instance.payer,
      'passengers': instance.passengers,
      'offers': instance.offers,
      'created_at': instance.createdAt,
    };

PayerModel _$PayerModelFromJson(Map<String, dynamic> json) => PayerModel(
      name: json['name'] as String?,
      email: json['email'] as String?,
      tel: json['tel'] as String?,
    );

Map<String, dynamic> _$PayerModelToJson(PayerModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'tel': instance.tel,
    };
