import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_booking_request_model.g.dart';

String _stringOrEmpty(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return value.toString();
}

@JsonSerializable()
class CreateBookingRequestModel extends Equatable {
  @JsonKey(name: 'payer_name')
  final String payerName;
  @JsonKey(name: 'payer_email')
  final String payerEmail;
  @JsonKey(name: 'payer_tel')
  final String payerTel;
  final List<PassengerModel> passengers;

  const CreateBookingRequestModel({
    required this.payerName,
    required this.payerEmail,
    required this.payerTel,
    required this.passengers,
  });

  factory CreateBookingRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CreateBookingRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBookingRequestModelToJson(this);

  CreateBookingRequestModel copyWith({
    String? payerName,
    String? payerEmail,
    String? payerTel,
    List<PassengerModel>? passengers,
  }) {
    return CreateBookingRequestModel(
      payerName: payerName ?? this.payerName,
      payerEmail: payerEmail ?? this.payerEmail,
      payerTel: payerTel ?? this.payerTel,
      passengers: passengers ?? this.passengers,
    );
  }

  @override
  List<Object?> get props => [payerName, payerEmail, payerTel, passengers];
}

@JsonSerializable()
class PassengerModel extends Equatable {
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'first_name')
  final String firstName;
  final String age;
  final String birthdate;
  final String gender;
  final String citizenship;
  final String tel;
  @JsonKey(name: 'doc_type')
  final String docType;
  @JsonKey(name: 'doc_number')
  final String docNumber;
  @JsonKey(name: 'doc_expire')
  final String docExpire;

  const PassengerModel({
    required this.lastName,
    required this.firstName,
    required this.age,
    required this.birthdate,
    required this.gender,
    required this.citizenship,
    required this.tel,
    required this.docType,
    required this.docNumber,
    required this.docExpire,
  });

  /// Backend booking payloads sometimes contain nulls; parse defensively.
  factory PassengerModel.fromJson(Map<String, dynamic> json) {
    return PassengerModel(
      lastName: _stringOrEmpty(json['last_name'] ?? json['lastName']),
      firstName: _stringOrEmpty(json['first_name'] ?? json['firstName']),
      age: _stringOrEmpty(json['age']),
      birthdate: _stringOrEmpty(json['birthdate'] ?? json['birth_date']),
      gender: _stringOrEmpty(json['gender']),
      citizenship: _stringOrEmpty(json['citizenship']),
      tel: _stringOrEmpty(json['tel'] ?? json['phone']),
      docType: _stringOrEmpty(json['doc_type'] ?? json['docType'] ?? 'P'),
      docNumber: _stringOrEmpty(json['doc_number'] ?? json['docNumber']),
      docExpire: _stringOrEmpty(json['doc_expire'] ?? json['docExpire']),
    );
  }

  Map<String, dynamic> toJson() => _$PassengerModelToJson(this);

  PassengerModel copyWith({
    String? lastName,
    String? firstName,
    String? age,
    String? birthdate,
    String? gender,
    String? citizenship,
    String? tel,
    String? docType,
    String? docNumber,
    String? docExpire,
  }) {
    return PassengerModel(
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      age: age ?? this.age,
      birthdate: birthdate ?? this.birthdate,
      gender: gender ?? this.gender,
      citizenship: citizenship ?? this.citizenship,
      tel: tel ?? this.tel,
      docType: docType ?? this.docType,
      docNumber: docNumber ?? this.docNumber,
      docExpire: docExpire ?? this.docExpire,
    );
  }

  @override
  List<Object?> get props => [
        lastName,
        firstName,
        age,
        birthdate,
        gender,
        citizenship,
        tel,
        docType,
        docNumber,
        docExpire,
      ];
}

