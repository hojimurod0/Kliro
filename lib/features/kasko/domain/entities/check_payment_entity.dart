class CheckPaymentEntity {
  final String orderId;
  final String? transactionId;
  final String status;
  final bool isPaid;
  final double? amount;

  CheckPaymentEntity({
    required this.orderId,
    this.transactionId,
    required this.status,
    required this.isPaid,
    this.amount,
  });
}

