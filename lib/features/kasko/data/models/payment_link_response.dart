import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_link_response.freezed.dart';
part 'payment_link_response.g.dart';

@freezed
class PaymentLinkResponse with _$PaymentLinkResponse {
  const factory PaymentLinkResponse({
    @JsonKey(name: 'payment_url') required String paymentUrl,
    @JsonKey(name: 'order_id') required String orderId,
    required double amount,
  }) = _PaymentLinkResponse;

  factory PaymentLinkResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentLinkResponseFromJson(json);
}
