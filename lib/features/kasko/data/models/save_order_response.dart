import 'package:freezed_annotation/freezed_annotation.dart';

part 'save_order_response.freezed.dart';
part 'save_order_response.g.dart';

@freezed
class SaveOrderResponse with _$SaveOrderResponse {
  const factory SaveOrderResponse({
    @JsonKey(name: 'order_id') String? orderId,
    double? premium,
    @JsonKey(name: 'car_id') int? carId,
    @JsonKey(name: 'owner_name') String? ownerName,
    @JsonKey(name: 'owner_phone') String? ownerPhone,
    String? status,
    String? message,
    String? url,
    @JsonKey(name: 'url_shartnoma') String? urlShartnoma,
    @JsonKey(name: 'payme_url') String? paymeUrl,
    @JsonKey(name: 'contract_id') String? contractId,
  }) = _SaveOrderResponse;

  factory SaveOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$SaveOrderResponseFromJson(json);
}
