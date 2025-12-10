import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'calculate_request_model.g.dart';

/// Модель запроса расчета
@JsonSerializable()
class CalculateRequestModel extends Equatable {
  @JsonKey(name: 'session_id')
  final String sessionId;
  final bool accident;
  final bool luggage;
  @JsonKey(name: 'cancel_travel')
  final bool cancelTravel;
  @JsonKey(name: 'person_respon')
  final bool personRespon;
  @JsonKey(name: 'delay_travel')
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
