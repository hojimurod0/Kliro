import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'passenger_type_model.g.dart';

@JsonSerializable()
class PassengerTypeModel extends Equatable {
  final String? code;
  final String? name;
  final String? description;
  @JsonKey(name: 'min_age')
  final int? minAge;
  @JsonKey(name: 'max_age')
  final int? maxAge;
  @JsonKey(name: 'name_intl')
  final Map<String, String>? nameIntl;

  const PassengerTypeModel({
    this.code,
    this.name,
    this.description,
    this.minAge,
    this.maxAge,
    this.nameIntl,
  });

  factory PassengerTypeModel.fromJson(Map<String, dynamic> json) =>
      _$PassengerTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$PassengerTypeModelToJson(this);

  @override
  List<Object?> get props => [code, name, description, minAge, maxAge, nameIntl];
}

