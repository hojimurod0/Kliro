import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'purpose_request_model.g.dart';

/// Модель запроса цели путешествия
@JsonSerializable()
class PurposeRequestModel extends Equatable {
  @JsonKey(name: 'purpose_id')
  final int purposeId;
  final List<String> destinations;

  const PurposeRequestModel({
    required this.purposeId,
    required this.destinations,
  });

  factory PurposeRequestModel.fromJson(Map<String, dynamic> json) =>
      _$PurposeRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$PurposeRequestModelToJson(this);

  @override
  List<Object?> get props => [purposeId, destinations];
}

