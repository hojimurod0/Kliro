// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_booking_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateBookingRequestModel _$CreateBookingRequestModelFromJson(
        Map<String, dynamic> json) =>
    CreateBookingRequestModel(
      payerName: json['payer_name'] as String,
      payerEmail: json['payer_email'] as String,
      payerTel: json['payer_tel'] as String,
      passengers: (json['passengers'] as List<dynamic>)
          .map((e) => PassengerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CreateBookingRequestModelToJson(
        CreateBookingRequestModel instance) =>
    <String, dynamic>{
      'payer_name': instance.payerName,
      'payer_email': instance.payerEmail,
      'payer_tel': instance.payerTel,
      'passengers': instance.passengers,
    };

PassengerModel _$PassengerModelFromJson(Map<String, dynamic> json) =>
    PassengerModel(
      lastName: json['last_name'] as String,
      firstName: json['first_name'] as String,
      age: json['age'] as String,
      birthdate: json['birthdate'] as String,
      gender: json['gender'] as String,
      citizenship: json['citizenship'] as String,
      tel: json['tel'] as String,
      docType: json['doc_type'] as String,
      docNumber: json['doc_number'] as String,
      docExpire: json['doc_expire'] as String,
    );

Map<String, dynamic> _$PassengerModelToJson(PassengerModel instance) =>
    <String, dynamic>{
      'last_name': instance.lastName,
      'first_name': instance.firstName,
      'age': instance.age,
      'birthdate': instance.birthdate,
      'gender': instance.gender,
      'citizenship': instance.citizenship,
      'tel': instance.tel,
      'doc_type': instance.docType,
      'doc_number': instance.docNumber,
      'doc_expire': instance.docExpire,
    };
