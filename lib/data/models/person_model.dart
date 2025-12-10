import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'person_model.g.dart';

/// Модель персоны (sugurtalovchi)
@JsonSerializable()
class PersonModel extends Equatable {
  final int type;
  @JsonKey(name: 'passportSeries')
  final String passportSeries;
  @JsonKey(name: 'passportNumber')
  final String passportNumber;
  final String birthday; // DD-MM-YYYY
  final String phone;
  final String pinfl;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'middle_name')
  final String? middleName;

  const PersonModel({
    required this.type,
    required this.passportSeries,
    required this.passportNumber,
    required this.birthday,
    required this.phone,
    required this.pinfl,
    required this.lastName,
    required this.firstName,
    this.middleName,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) =>
      _$PersonModelFromJson(json);

  Map<String, dynamic> toJson() => _$PersonModelToJson(this);

  @override
  List<Object?> get props => [
        type,
        passportSeries,
        passportNumber,
        birthday,
        phone,
        pinfl,
        lastName,
        firstName,
        middleName,
      ];
}

