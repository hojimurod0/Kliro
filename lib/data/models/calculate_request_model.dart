import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'calculate_request_model.g.dart';

/// Модель запроса расчета
@JsonSerializable()
class CalculateRequestModel extends Equatable {
  final String sessionId;
  final bool accident;
  final bool luggage;
  final bool cancelTravel;
  final bool personRespon;
  final bool delayTravel;

  const CalculateRequestModel({
    required this.sessionId,
    required this.accident,
    required this.luggage,
    required this.cancelTravel,
    required this.personRespon,
    required this.delayTravel,
  });

  factory CalculateRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CalculateRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CalculateRequestModelToJson(this);

  @override
  List<Object?> get props => [
    sessionId,
    accident,
    luggage,
    cancelTravel,
    personRespon,
    delayTravel,
  ];
}
