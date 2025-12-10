import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'traveler_model.g.dart';

/// Модель путешественника
@JsonSerializable()
class TravelerModel extends Equatable {
  @JsonKey(name: 'passportSeries')
  final String passportSeries;
  @JsonKey(name: 'passportNumber')
  final String passportNumber;
  final String birthday; // DD-MM-YYYY
  final String pinfl;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'first_name')
  final String firstName;

  const TravelerModel({
    required this.passportSeries,
    required this.passportNumber,
    required this.birthday,
    required this.pinfl,
    required this.lastName,
    required this.firstName,
  });

  factory TravelerModel.fromJson(Map<String, dynamic> json) =>
      _$TravelerModelFromJson(json);

  Map<String, dynamic> toJson() => _$TravelerModelToJson(this);

  @override
  List<Object?> get props => [
        passportSeries,
        passportNumber,
        birthday,
        pinfl,
        lastName,
        firstName,
      ];
}

