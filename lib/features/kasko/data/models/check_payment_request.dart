import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_payment_request.freezed.dart';
part 'check_payment_request.g.dart';

@freezed
class CheckPaymentRequest with _$CheckPaymentRequest {
  const factory CheckPaymentRequest({
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'transaction_id') required String transactionId,
  }) = _CheckPaymentRequest;

  factory CheckPaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckPaymentRequestFromJson(json);
}
