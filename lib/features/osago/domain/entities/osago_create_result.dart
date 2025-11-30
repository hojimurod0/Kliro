import 'package:equatable/equatable.dart';

class OsagoCreateResult extends Equatable {
  const OsagoCreateResult({
    required this.sessionId,
    this.policyNumber,
    this.paymentUrl,
    this.clickUrl,
    this.paymeUrl,
    this.amount,
    this.currency,
  });

  final String sessionId;
  final String? policyNumber;
  final String? paymentUrl;
  final String? clickUrl;
  final String? paymeUrl;
  final double? amount;
  final String? currency;

  /// Получить URL для оплаты в зависимости от метода
  String? getPaymentUrl(String? method) {
    if (method == 'click') return clickUrl;
    if (method == 'payme') return paymeUrl;
    return paymentUrl ?? clickUrl ?? paymeUrl;
  }

  @override
  List<Object?> get props => [
    sessionId,
    policyNumber,
    paymentUrl,
    clickUrl,
    paymeUrl,
    amount,
    currency,
  ];
}
