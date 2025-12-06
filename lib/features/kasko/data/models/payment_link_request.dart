import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_link_request.freezed.dart';
part 'payment_link_request.g.dart';

@freezed
class PaymentLinkRequest with _$PaymentLinkRequest {
  const factory PaymentLinkRequest({
    @JsonKey(name: 'order_id') required String orderId,
    required double amount,
    @JsonKey(name: 'return_url') required String returnUrl,
    @JsonKey(name: 'callback_url') required String callbackUrl,
  }) = _PaymentLinkRequest;

  factory PaymentLinkRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentLinkRequestFromJson(json);
}
