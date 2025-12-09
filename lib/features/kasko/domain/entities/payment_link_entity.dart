class PaymentLinkEntity {
  final String? clickUrl; // Click ссылка
  final String? paymeUrl; // Payme ссылка
  final String? paymentUrl; // Fallback для обратной совместимости
  final String? orderId;
  final String? contractId;
  final double amount;

  PaymentLinkEntity({
    this.clickUrl,
    this.paymeUrl,
    this.paymentUrl,
    this.orderId,
    this.contractId,
    required this.amount,
  });

  // Метод для получения URL в зависимости от способа оплаты
  String? getUrlForPaymentMethod(String? paymentMethod) {
    if (paymentMethod == 'payme') {
      return paymeUrl ?? paymentUrl;
    } else if (paymentMethod == 'click') {
      return clickUrl ?? paymentUrl;
    }
    // Если способ оплаты не указан, возвращаем первый доступный URL
    return clickUrl ?? paymeUrl ?? paymentUrl;
  }
}

