import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'schedule_model.g.dart';

@JsonSerializable()
class ScheduleModel extends Equatable {
  final String? flightNumber;
  final String? airline;
  final String? departureAirport;
  final String? arrivalAirport;
  @JsonKey(name: 'departure_time')
  final String? departureTime;
  @JsonKey(name: 'arrival_time')
  final String? arrivalTime;
  @JsonKey(name: 'departure_date')
  final String? departureDate;
  @JsonKey(name: 'arrival_date')
  final String? arrivalDate;
  final String? aircraft;
  final String? duration;

  const ScheduleModel({
    this.flightNumber,
    this.airline,
    this.departureAirport,
    this.arrivalAirport,
    this.departureTime,
    this.arrivalTime,
    this.departureDate,
    this.arrivalDate,
    this.aircraft,
    this.duration,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleModelToJson(this);

  @override
  List<Object?> get props => [
        flightNumber,
        airline,
        departureAirport,
        arrivalAirport,
        departureTime,
        arrivalTime,
        departureDate,
        arrivalDate,
        aircraft,
        duration,
      ];
}

