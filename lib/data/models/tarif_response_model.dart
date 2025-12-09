import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'tarif_response_model.g.dart';

/// Модель ответа тарифов
@JsonSerializable()
class TarifResponseModel extends Equatable {
  final List<Map<String, dynamic>>? tarifs;
  final Map<String, dynamic>? data;

  const TarifResponseModel({
    this.tarifs,
    this.data,
  });

  factory TarifResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TarifResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$TarifResponseModelToJson(this);

  @override
  List<Object?> get props => [tarifs, data];
}

