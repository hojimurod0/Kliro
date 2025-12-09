import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'tarif_request_model.g.dart';

/// Модель запроса тарифов
@JsonSerializable()
class TarifRequestModel extends Equatable {
  final String country;

  const TarifRequestModel({
    required this.country,
  });

  factory TarifRequestModel.fromJson(Map<String, dynamic> json) =>
      _$TarifRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$TarifRequestModelToJson(this);

  @override
  List<Object?> get props => [country];
}

