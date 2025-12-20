import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'price_check_model.g.dart';

@JsonSerializable()
class PriceCheckModel extends Equatable {
  final String? price;
  final String? currency;
  @JsonKey(name: 'price_changed')
  final bool? priceChanged;
  @JsonKey(name: 'old_price')
  final String? oldPrice;

  const PriceCheckModel({
    this.price,
    this.currency,
    this.priceChanged,
    this.oldPrice,
  });

  factory PriceCheckModel.fromJson(Map<String, dynamic> json) =>
      _$PriceCheckModelFromJson(json);

  Map<String, dynamic> toJson() => _$PriceCheckModelToJson(this);

  PriceCheckModel copyWith({
    String? price,
    String? currency,
    bool? priceChanged,
    String? oldPrice,
  }) {
    return PriceCheckModel(
      price: price ?? this.price,
      currency: currency ?? this.currency,
      priceChanged: priceChanged ?? this.priceChanged,
      oldPrice: oldPrice ?? this.oldPrice,
    );
  }

  @override
  List<Object?> get props => [price, currency, priceChanged, oldPrice];
}




