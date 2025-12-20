import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'offer_model.g.dart';

@JsonSerializable()
class OfferModel extends Equatable {
  final String? id;
  final String? price;
  final String? currency;
  final List<SegmentModel>? segments;
  final String? airline;
  final String? duration;

  const OfferModel({
    this.id,
    this.price,
    this.currency,
    this.segments,
    this.airline,
    this.duration,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) =>
      _$OfferModelFromJson(json);

  Map<String, dynamic> toJson() => _$OfferModelToJson(this);

  OfferModel copyWith({
    String? id,
    String? price,
    String? currency,
    List<SegmentModel>? segments,
    String? airline,
    String? duration,
  }) {
    return OfferModel(
      id: id ?? this.id,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      segments: segments ?? this.segments,
      airline: airline ?? this.airline,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props =>
      [id, price, currency, segments, airline, duration];
}

@JsonSerializable()
class SegmentModel extends Equatable {
  final String? departureAirport;
  final String? arrivalAirport;
  final String? departureAirportName;
  final String? arrivalAirportName;
  final String? departureTerminal;
  final String? arrivalTerminal;
  final String? aircraft;
  final String? cabinClass;
  final String? baggage;
  final String? handBaggage;
  final String? departureTime;
  final String? arrivalTime;
  final String? flightNumber;
  final String? airline;

  const SegmentModel({
    this.departureAirport,
    this.arrivalAirport,
    this.departureAirportName,
    this.arrivalAirportName,
    this.departureTerminal,
    this.arrivalTerminal,
    this.aircraft,
    this.cabinClass,
    this.baggage,
    this.handBaggage,
    this.departureTime,
    this.arrivalTime,
    this.flightNumber,
    this.airline,
  });

  factory SegmentModel.fromJson(Map<String, dynamic> json) =>
      _$SegmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$SegmentModelToJson(this);

  SegmentModel copyWith({
    String? departureAirport,
    String? arrivalAirport,
    String? departureAirportName,
    String? arrivalAirportName,
    String? departureTerminal,
    String? arrivalTerminal,
    String? aircraft,
    String? cabinClass,
    String? baggage,
    String? handBaggage,
    String? departureTime,
    String? arrivalTime,
    String? flightNumber,
    String? airline,
  }) {
    return SegmentModel(
      departureAirport: departureAirport ?? this.departureAirport,
      arrivalAirport: arrivalAirport ?? this.arrivalAirport,
      departureAirportName: departureAirportName ?? this.departureAirportName,
      arrivalAirportName: arrivalAirportName ?? this.arrivalAirportName,
      departureTerminal: departureTerminal ?? this.departureTerminal,
      arrivalTerminal: arrivalTerminal ?? this.arrivalTerminal,
      aircraft: aircraft ?? this.aircraft,
      cabinClass: cabinClass ?? this.cabinClass,
      baggage: baggage ?? this.baggage,
      handBaggage: handBaggage ?? this.handBaggage,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      flightNumber: flightNumber ?? this.flightNumber,
      airline: airline ?? this.airline,
    );
  }

  @override
  List<Object?> get props => [
        departureAirport,
        arrivalAirport,
        departureAirportName,
        arrivalAirportName,
        departureTerminal,
        arrivalTerminal,
        aircraft,
        cabinClass,
        baggage,
        handBaggage,
        departureTime,
        arrivalTime,
        flightNumber,
        airline,
      ];
}

@JsonSerializable()
class OffersResponseModel extends Equatable {
  final List<OfferModel>? offers;
  final int? total;

  const OffersResponseModel({
    this.offers,
    this.total,
  });

  factory OffersResponseModel.fromJson(Map<String, dynamic> json) =>
      _$OffersResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$OffersResponseModelToJson(this);

  OffersResponseModel copyWith({
    List<OfferModel>? offers,
    int? total,
  }) {
    return OffersResponseModel(
      offers: offers ?? this.offers,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [offers, total];
}




