import 'package:freezed_annotation/freezed_annotation.dart';

// ignore_for_file: invalid_annotation_target

part 'create_response.freezed.dart';
part 'create_response.g.dart';

@freezed
class PaymentUrls with _$PaymentUrls {
  const factory PaymentUrls({
    String? click,
    String? payme,
  }) = _PaymentUrls;

  factory PaymentUrls.fromJson(Map<String, dynamic> json) =>
      _$PaymentUrlsFromJson(json);
}

@freezed
class CreateResponse with _$CreateResponse {
  const factory CreateResponse({
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'policy_number') String? policyNumber,
    @JsonKey(name: 'payment_url') String? paymentUrl,
    @JsonKey(name: 'pay') PaymentUrls? pay,
    @JsonKey(name: 'amount') double? amount,
    @JsonKey(name: 'currency') String? currency,
  }) = _CreateResponse;

  factory CreateResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateResponseFromJson(json);
}
