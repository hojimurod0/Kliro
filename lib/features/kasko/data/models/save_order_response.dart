import 'package:freezed_annotation/freezed_annotation.dart';

part 'save_order_response.freezed.dart';
part 'save_order_response.g.dart';

@freezed
class SaveOrderResponse with _$SaveOrderResponse {
  const factory SaveOrderResponse({
    @JsonKey(name: 'order_id') required String orderId,
    required double premium,
    @JsonKey(name: 'car_id') required int carId,
    @JsonKey(name: 'owner_name') required String ownerName,
    @JsonKey(name: 'owner_phone') required String ownerPhone,
    String? status,
  }) = _SaveOrderResponse;

  factory SaveOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$SaveOrderResponseFromJson(json);
}
