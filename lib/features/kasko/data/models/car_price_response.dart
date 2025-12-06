import 'package:freezed_annotation/freezed_annotation.dart';

part 'car_price_response.freezed.dart';
part 'car_price_response.g.dart';

@freezed
class CarPriceResponse with _$CarPriceResponse {
  const factory CarPriceResponse({
    required double price,
    @JsonKey(name: 'car_id') int? carId,
    int? year,
    String? currency,
  }) = _CarPriceResponse;

  factory CarPriceResponse.fromJson(Map<String, dynamic> json) =>
      _$CarPriceResponseFromJson(json);
}
