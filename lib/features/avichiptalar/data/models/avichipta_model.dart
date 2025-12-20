import '../../domain/entities/avichipta.dart';

class AvichiptaModel extends Avichipta {
  const AvichiptaModel({
    required super.id,
    required super.fromCity,
    required super.toCity,
    required super.departureDate,
    required super.returnDate,
    required super.passengers,
    super.price,
    super.airline,
    super.flightNumber,
    super.departureTime,
    super.arrivalTime,
  });

  factory AvichiptaModel.fromJson(Map<String, dynamic> json) {
    return AvichiptaModel(
      id: json['id'] as String? ?? '',
      fromCity: json['from_city'] as String? ?? json['fromCity'] as String? ?? '',
      toCity: json['to_city'] as String? ?? json['toCity'] as String? ?? '',
      departureDate: json['departure_date'] != null
          ? DateTime.parse(json['departure_date'] as String)
          : json['departureDate'] != null
              ? DateTime.parse(json['departureDate'] as String)
              : DateTime.now(),
      returnDate: json['return_date'] != null
          ? DateTime.parse(json['return_date'] as String)
          : json['returnDate'] != null
              ? DateTime.parse(json['returnDate'] as String)
              : DateTime.now(),
      passengers: json['passengers'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble(),
      airline: json['airline'] as String?,
      flightNumber: json['flight_number'] as String? ?? json['flightNumber'] as String?,
      departureTime: json['departure_time'] != null
          ? DateTime.tryParse(json['departure_time'] as String)
          : json['departureTime'] != null
              ? DateTime.tryParse(json['departureTime'] as String)
              : null,
      arrivalTime: json['arrival_time'] != null
          ? DateTime.tryParse(json['arrival_time'] as String)
          : json['arrivalTime'] != null
              ? DateTime.tryParse(json['arrivalTime'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_city': fromCity,
      'to_city': toCity,
      'departure_date': departureDate.toIso8601String(),
      'return_date': returnDate.toIso8601String(),
      'passengers': passengers,
      if (price != null) 'price': price,
      if (airline != null) 'airline': airline,
      if (flightNumber != null) 'flight_number': flightNumber,
      if (departureTime != null) 'departure_time': departureTime!.toIso8601String(),
      if (arrivalTime != null) 'arrival_time': arrivalTime!.toIso8601String(),
    };
  }
}

