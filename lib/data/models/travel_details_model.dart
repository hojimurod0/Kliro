import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'travel_details_model.g.dart';

/// Модель деталей путешествия
@JsonSerializable()
class TravelDetailsModel extends Equatable {
  final String sessionId;
  final String startDate; // DD-MM-YYYY
  final String endDate; // DD-MM-YYYY
  final List<String> travelersBirthdates; // DD-MM-YYYY
  final bool annualPolicy;
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

