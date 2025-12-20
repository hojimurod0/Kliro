// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleModel _$ScheduleModelFromJson(Map<String, dynamic> json) =>
    ScheduleModel(
      flightNumber: json['flightNumber'] as String?,
      airline: json['airline'] as String?,
      departureAirport: json['departureAirport'] as String?,
      arrivalAirport: json['arrivalAirport'] as String?,
      departureTime: json['departure_time'] as String?,
      arrivalTime: json['arrival_time'] as String?,
      departureDate: json['departure_date'] as String?,
      arrivalDate: json['arrival_date'] as String?,
      aircraft: json['aircraft'] as String?,
      duration: json['duration'] as String?,
    );

Map<String, dynamic> _$ScheduleModelToJson(ScheduleModel instance) =>
    <String, dynamic>{
      'flightNumber': instance.flightNumber,
      'airline': instance.airline,
      'departureAirport': instance.departureAirport,
      'arrivalAirport': instance.arrivalAirport,
      'departure_time': instance.departureTime,
      'arrival_time': instance.arrivalTime,
      'departure_date': instance.departureDate,
      'arrival_date': instance.arrivalDate,
      'aircraft': instance.aircraft,
      'duration': instance.duration,
    };
