import 'package:freezed_annotation/freezed_annotation.dart';

part 'car_price_request.freezed.dart';
part 'car_price_request.g.dart';

@freezed
class CarPriceRequest with _$CarPriceRequest {
  const factory CarPriceRequest({
    @JsonKey(name: 'car_position_id') required int carPositionId,
    @JsonKey(name: 'tarif_id') required int tarifId,
    required int year,
  }) = _CarPriceRequest;

  factory CarPriceRequest.fromJson(Map<String, dynamic> json) =>
      _$CarPriceRequestFromJson(json);
}
