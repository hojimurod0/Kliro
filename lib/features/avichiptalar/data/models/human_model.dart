import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'human_model.g.dart';

@JsonSerializable()
class HumanModel extends Equatable {
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'middle_name')
  final String? middleName;
  @JsonKey(name: 'birth_date')
  final String birthDate;
  final String gender;
  final String citizenship;
  @JsonKey(name: 'passport_number')
  final String passportNumber;
  @JsonKey(name: 'passport_expiry')
  final String passportExpiry;
  final String phone;

  const HumanModel({
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.birthDate,
    required this.gender,
    required this.citizenship,
    required this.passportNumber,
    required this.passportExpiry,
    required this.phone,
  });

  factory HumanModel.fromJson(Map<String, dynamic> json) =>
      _$HumanModelFromJson(json);

  Map<String, dynamic> toJson() => _$HumanModelToJson(this);

  HumanModel copyWith({
    String? firstName,
    String? lastName,
    String? middleName,
    String? birthDate,
    String? gender,
    String? citizenship,
    String? passportNumber,
    String? passportExpiry,
    String? phone,
  }) {
    return HumanModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      citizenship: citizenship ?? this.citizenship,
      passportNumber: passportNumber ?? this.passportNumber,
      passportExpiry: passportExpiry ?? this.passportExpiry,
      phone: phone ?? this.phone,
    );
  }

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        middleName,
        birthDate,
        gender,
        citizenship,
        passportNumber,
        passportExpiry,
        phone,
      ];
}
