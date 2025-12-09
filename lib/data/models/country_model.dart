import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'country_model.g.dart';

/// Модель страны
@JsonSerializable()
class CountryModel extends Equatable {
  final String code;
  final String name;
  final String? flag;

  const CountryModel({
    required this.code,
    required this.name,
    this.flag,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) =>
      _$CountryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CountryModelToJson(this);

  @override
  List<Object?> get props => [code, name, flag];
}

