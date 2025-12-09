import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'calculate_response_model.g.dart';

/// Модель ответа расчета
@JsonSerializable()
class CalculateResponseModel extends Equatable {
  final double? premium;
  final double? summaAll;
  final Map<String, dynamic>? data;

  const CalculateResponseModel({this.premium, this.summaAll, this.data});

  factory CalculateResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CalculateResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CalculateResponseModelToJson(this);

  @override
  List<Object?> get props => [premium, summaAll, data];
}
