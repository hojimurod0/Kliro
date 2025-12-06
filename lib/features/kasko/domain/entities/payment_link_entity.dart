class PaymentLinkEntity {
  final String paymentUrl;
  final String orderId;
  final double amount;

  PaymentLinkEntity({
    required this.paymentUrl,
    required this.orderId,
    required this.amount,
  });
}

