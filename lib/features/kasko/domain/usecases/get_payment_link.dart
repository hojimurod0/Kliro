import '../entities/payment_link_entity.dart';
import '../repositories/kasko_repository.dart';

class GetPaymentLink {
  GetPaymentLink(this._repository);

  final KaskoRepository _repository;

  Future<PaymentLinkEntity> call({
    required String orderId,
    required double amount,
    required String returnUrl,
    required String callbackUrl,
  }) {
    return _repository.getPaymentLink(
      orderId: orderId,
      amount: amount,
      returnUrl: returnUrl,
      callbackUrl: callbackUrl,
    );
  }
}

