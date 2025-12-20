import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'search_offers_request_model.g.dart';

@JsonSerializable()
class SearchOffersRequestModel extends Equatable {
  final int adults;
  final int children;
  final int infants;
  @JsonKey(name: 'infants_with_seat')
  final int infantsWithSeat;
  @JsonKey(name: 'service_class')
  final String serviceClass;
  final List<DirectionModel> directions;

  const SearchOffersRequestModel({
    required this.adults,
    this.children = 0,
    this.infants = 0,
    this.infantsWithSeat = 0,
    required this.serviceClass,
    required this.directions,
  });

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'adults': adults.toString(),
      'children': children.toString(),
      'infants': infants.toString(),
      'infants_with_seat': infantsWithSeat.toString(),
      'service_class': serviceClass,
    };

    for (var i = 0; i < directions.length; i++) {
      final direction = directions[i];
      params['directions[$i][departure_airport]'] = direction.departureAirport;
      params['directions[$i][arrival_airport]'] = direction.arrivalAirport;
      params['directions[$i][date]'] = direction.date;
    }

    return params;
  }

  factory SearchOffersRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SearchOffersRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$SearchOffersRequestModelToJson(this);

  SearchOffersRequestModel copyWith({
    int? adults,
    int? children,
    int? infants,
    int? infantsWithSeat,
    String? serviceClass,
    List<DirectionModel>? directions,
  }) {
    return SearchOffersRequestModel(
      adults: adults ?? this.adults,
      children: children ?? this.children,
      infants: infants ?? this.infants,
      infantsWithSeat: infantsWithSeat ?? this.infantsWithSeat,
      serviceClass: serviceClass ?? this.serviceClass,
      directions: directions ?? this.directions,
    );
  }

  @override
  List<Object?> get props =>
      [adults, children, infants, infantsWithSeat, serviceClass, directions];
}

@JsonSerializable()
class DirectionModel extends Equatable {
  @JsonKey(name: 'departure_airport')
  final String departureAirport;
  @JsonKey(name: 'arrival_airport')
  final String arrivalAirport;
  final String date;

  const DirectionModel({
    required this.departureAirport,
    required this.arrivalAirport,
    required this.date,
  });

  factory DirectionModel.fromJson(Map<String, dynamic> json) =>
      _$DirectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$DirectionModelToJson(this);

  DirectionModel copyWith({
    String? departureAirport,
    String? arrivalAirport,
    String? date,
  }) {
    return DirectionModel(
      departureAirport: departureAirport ?? this.departureAirport,
      arrivalAirport: arrivalAirport ?? this.arrivalAirport,
      date: date ?? this.date,
    );
  }

  @override
  List<Object?> get props => [departureAirport, arrivalAirport, date];
}




