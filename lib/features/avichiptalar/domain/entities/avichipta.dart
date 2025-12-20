import 'package:equatable/equatable.dart';

class Avichipta extends Equatable {
  const Avichipta({
    required this.id,
    required this.fromCity,
    required this.toCity,
    required this.departureDate,
    required this.returnDate,
    required this.passengers,
    this.price,
    this.airline,
    this.flightNumber,
    this.departureTime,
    this.arrivalTime,
  });

  final String id;
  final String fromCity;
  final String toCity;
  final DateTime departureDate;
  final DateTime returnDate;
  final int passengers;
  final double? price;
  final String? airline;
  final String? flightNumber;
  final DateTime? departureTime;
  final DateTime? arrivalTime;

  Avichipta copyWith({
    String? id,
    String? fromCity,
    String? toCity,
    DateTime? departureDate,
    DateTime? returnDate,
    int? passengers,
    double? price,
    String? airline,
    String? flightNumber,
    DateTime? departureTime,
    DateTime? arrivalTime,
  }) {
    return Avichipta(
      id: id ?? this.id,
      fromCity: fromCity ?? this.fromCity,
      toCity: toCity ?? this.toCity,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      passengers: passengers ?? this.passengers,
      price: price ?? this.price,
      airline: airline ?? this.airline,
      flightNumber: flightNumber ?? this.flightNumber,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fromCity,
        toCity,
        departureDate,
        returnDate,
        passengers,
        price,
        airline,
        flightNumber,
        departureTime,
        arrivalTime,
      ];
}

