class OsagoPayment {
  const OsagoPayment({
    required this.orderId,
    required this.amount,
    required this.paymentType,
    this.paymentId,
    this.status,
  });

  final String orderId;
  final String amount;
  final String paymentType; // 'payme' or 'click'
  final String? paymentId;
  final String? status; // 'pending', 'success', 'failed'
}

