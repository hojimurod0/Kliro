import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_link_response.freezed.dart';
part 'payment_link_response.g.dart';

String? _intToString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is int) return value.toString();
  return value.toString();
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value);
  }
  if (value is num) return value.toDouble();
  return null;
}

@freezed
class PaymentLinkResponse with _$PaymentLinkResponse {
  const factory PaymentLinkResponse({
    @JsonKey(name: 'click') String? clickUrl, // Click ссылка (приоритет 1)
    @JsonKey(name: 'payme') String? paymeUrl, // Payme ссылка (приоритет 1)
    @JsonKey(name: 'url') String? url, // Click ссылка (приоритет 2) или fallback
    @JsonKey(name: 'payme_url') String? paymeUrlOld, // Payme ссылка (приоритет 2) или fallback
    @JsonKey(name: 'payment_url') String? paymentUrl, // Fallback для обратной совместимости
    @JsonKey(name: 'order_id', fromJson: _intToString) String? orderId,
    @JsonKey(name: 'contract_id', fromJson: _intToString) String? contractId,
    @JsonKey(name: 'amount', fromJson: _toDouble) double? amount,
    @JsonKey(name: 'amount_uzs', fromJson: _toDouble) double? amountUzs,
  }) = _PaymentLinkResponse;

  factory PaymentLinkResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentLinkResponseFromJson(json);
}
