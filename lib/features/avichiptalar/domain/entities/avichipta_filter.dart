import 'package:equatable/equatable.dart';

class AvichiptaFilter extends Equatable {
  const AvichiptaFilter({
    this.fromCity,
    this.toCity,
    this.departureDate,
    this.returnDate,
    this.passengers = 1,
    this.minPrice,
    this.maxPrice,
    this.airlines,
    this.serviceClasses,
    this.sortBy,
    this.sortDirection,
    this.maxTransfers,
    this.withLuggage,
    this.departureTimeStart,
    this.departureTimeEnd,
    this.arrivalTimeStart,
    this.arrivalTimeEnd,
  });

  final String? fromCity;
  final String? toCity;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final int passengers;
  final double? minPrice;
  final double? maxPrice;
  final List<String>? airlines;
  final List<String>? serviceClasses;
  final String? sortBy;
  final String? sortDirection;
  final int? maxTransfers;
  final bool? withLuggage;
  final int? departureTimeStart; // minutes from midnight (0-1440)
  final int? departureTimeEnd;
  final int? arrivalTimeStart;
  final int? arrivalTimeEnd;

  static const AvichiptaFilter empty = AvichiptaFilter();

  AvichiptaFilter copyWith({
    String? fromCity,
    String? toCity,
    DateTime? departureDate,
    DateTime? returnDate,
    int? passengers,
    double? minPrice,
    double? maxPrice,
    List<String>? airlines,
    List<String>? serviceClasses,
    String? sortBy,
    String? sortDirection,
    int? maxTransfers,
    bool? withLuggage,
    int? departureTimeStart,
    int? departureTimeEnd,
    int? arrivalTimeStart,
    int? arrivalTimeEnd,
  }) {
    return AvichiptaFilter(
      fromCity: fromCity ?? this.fromCity,
      toCity: toCity ?? this.toCity,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      passengers: passengers ?? this.passengers,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      airlines: airlines ?? this.airlines,
      serviceClasses: serviceClasses ?? this.serviceClasses,
      sortBy: sortBy ?? this.sortBy,
      sortDirection: sortDirection ?? this.sortDirection,
      maxTransfers: maxTransfers ?? this.maxTransfers,
      withLuggage: withLuggage ?? this.withLuggage,
      departureTimeStart: departureTimeStart ?? this.departureTimeStart,
      departureTimeEnd: departureTimeEnd ?? this.departureTimeEnd,
      arrivalTimeStart: arrivalTimeStart ?? this.arrivalTimeStart,
      arrivalTimeEnd: arrivalTimeEnd ?? this.arrivalTimeEnd,
    );
  }

  @override
  List<Object?> get props => [
        fromCity,
        toCity,
        departureDate,
        returnDate,
        passengers,
        minPrice,
        maxPrice,
        airlines,
        serviceClasses,
        sortBy,
        sortDirection,
        maxTransfers,
        withLuggage,
        departureTimeStart,
        departureTimeEnd,
        arrivalTimeStart,
        arrivalTimeEnd,
      ];
}

