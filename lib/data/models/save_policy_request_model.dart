import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'person_model.dart';
import 'traveler_model.dart';

part 'save_policy_request_model.g.dart';

/// Модель запроса сохранения полиса
@JsonSerializable()
class SavePolicyRequestModel extends Equatable {
  final String sessionId;
  final String provider;
  final double summaAll;
  final String programId;
  final PersonModel sugurtalovchi;
  final List<TravelerModel> travelers;

  const SavePolicyRequestModel({
    required this.sessionId,
    required this.provider,
    required this.summaAll,
    required this.programId,
    required this.sugurtalovchi,
    required this.travelers,
  });

  factory SavePolicyRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SavePolicyRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$SavePolicyRequestModelToJson(this);

  @override
  List<Object?> get props => [
        sessionId,
        provider,
        summaAll,
        programId,
        sugurtalovchi,
        travelers,
      ];
}

