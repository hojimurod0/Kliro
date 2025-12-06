import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_payment_response.freezed.dart';
part 'check_payment_response.g.dart';

@freezed
class CheckPaymentResponse with _$CheckPaymentResponse {
  const factory CheckPaymentResponse({
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'transaction_id') String? transactionId,
    required String status,
    @JsonKey(name: 'is_paid') @Default(false) bool isPaid,
    double? amount,
  }) = _CheckPaymentResponse;

  factory CheckPaymentResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckPaymentResponseFromJson(json);
}
