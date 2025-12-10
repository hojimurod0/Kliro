import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'person_model.g.dart';

@JsonSerializable()
class PersonModel extends Equatable {
  final String pinfl;
  @JsonKey(name: 'pass_sery')
  final String passSery;
  @JsonKey(name: 'pass_num')
  final String passNum;
  @JsonKey(name: 'date_birth')
  final String dateBirth;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'patronym_name')
  final String? patronymName;
  final int region;
  final String phone;
  final String address;

  const PersonModel({
    required this.pinfl,
    required this.passSery,
    required this.passNum,
    required this.dateBirth,
    required this.lastName,
    required this.firstName,
    this.patronymName,
    required this.region,
    required this.phone,
    required this.address,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) =>
      _$PersonModelFromJson(json);

  Map<String, dynamic> toJson() => _$PersonModelToJson(this);

  @override
  List<Object?> get props => [
        pinfl,
        passSery,
        passNum,
        dateBirth,
        lastName,
        firstName,
        patronymName,
        region,
        phone,
        address,
      ];
}

