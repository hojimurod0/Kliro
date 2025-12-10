import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'travel_details_model.g.dart';

/// Модель деталей путешествия
@JsonSerializable()
class TravelDetailsModel extends Equatable {
  @JsonKey(name: 'session_id')
  final String sessionId;
  @JsonKey(name: 'start_date')
  final String startDate; // DD-MM-YYYY
  @JsonKey(name: 'end_date')
  final String endDate; // DD-MM-YYYY
  @JsonKey(name: 'travelers_birthdates')
  final List<String> travelersBirthdates; // DD-MM-YYYY
  @JsonKey(name: 'annual_policy')
  final bool annualPolicy;
  @JsonKey(name: 'covid_protection')
  final bool covidProtection;

  const TravelDetailsModel({
    required this.sessionId,
    required this.startDate,
    required this.endDate,
    required this.travelersBirthdates,
    required this.annualPolicy,
    required this.covidProtection,
  });

  factory TravelDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$TravelDetailsModelFromJson(json);

  Map<String, dynamic> toJson() => _$TravelDetailsModelToJson(this);

  @override
  List<Object?> get props => [
        sessionId,
        startDate,
        endDate,
        travelersBirthdates,
        annualPolicy,
        covidProtection,
      ];
}

