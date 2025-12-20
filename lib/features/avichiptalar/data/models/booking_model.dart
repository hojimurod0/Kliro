import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'offer_model.dart';
import 'create_booking_request_model.dart';

part 'booking_model.g.dart';

String? _stringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();

  // Backend sometimes returns nested objects for scalar fields (e.g. price/id).
  if (value is Map) {
    final m = Map<String, dynamic>.from(value);
    for (final key in const [
      'id',
      'booking_number',
      'number',
      'value',
      'amount',
      'sum',
      'total',
      'price',
      'currency',
    ]) {
      final v = m[key];
      if (v == null) continue;
      if (v is String) return v;
      if (v is num || v is bool) return v.toString();
    }
  }

  return value.toString();
}

@JsonSerializable()
class BookingModel extends Equatable {
  final String? id;
  final String? status;
  final String? price;
  final String? currency;
  final PayerModel? payer;
  final List<PassengerModel>? passengers;
  final List<OfferModel>? offers;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const BookingModel({
    this.id,
    this.status,
    this.price,
    this.currency,
    this.payer,
    this.passengers,
    this.offers,
    this.createdAt,
  });

  /// NOTE: Backend payloads are not stable (some scalar fields can come as Map).
  /// We parse defensively to avoid runtime type-cast crashes.
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final passengersRaw = json['passengers'];
    final offersRaw = json['offers'];

    return BookingModel(
      id: _stringOrNull(json['id']),
      status: _stringOrNull(json['status']),
      price: _stringOrNull(json['price']),
      currency: _stringOrNull(json['currency']),
      payer: json['payer'] is Map<String, dynamic>
          ? PayerModel.fromJson(json['payer'] as Map<String, dynamic>)
          : null,
      passengers: passengersRaw is List
          ? passengersRaw
              .whereType<Map>()
              .map((e) => PassengerModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
      offers: offersRaw is List
          ? offersRaw
              .whereType<Map>()
              .map((e) => OfferModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
      createdAt: _stringOrNull(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => _$BookingModelToJson(this);

  BookingModel copyWith({
    String? id,
    String? status,
    String? price,
    String? currency,
    PayerModel? payer,
    List<PassengerModel>? passengers,
    List<OfferModel>? offers,
    String? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      status: status ?? this.status,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      payer: payer ?? this.payer,
      passengers: passengers ?? this.passengers,
      offers: offers ?? this.offers,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, status, price, currency, payer, passengers, offers, createdAt];
}

@JsonSerializable()
class PayerModel extends Equatable {
  final String? name;
  final String? email;
  final String? tel;

  const PayerModel({
    this.name,
    this.email,
    this.tel,
  });

  factory PayerModel.fromJson(Map<String, dynamic> json) =>
      _$PayerModelFromJson(json);

  Map<String, dynamic> toJson() => _$PayerModelToJson(this);

  PayerModel copyWith({
    String? name,
    String? email,
    String? tel,
  }) {
    return PayerModel(
      name: name ?? this.name,
      email: email ?? this.email,
      tel: tel ?? this.tel,
    );
  }

  @override
  List<Object?> get props => [name, email, tel];
}




