import '../entities/check_payment_entity.dart';
import '../repositories/kasko_repository.dart';

class CheckPaymentStatus {
  CheckPaymentStatus(this._repository);

  final KaskoRepository _repository;

  Future<CheckPaymentEntity> call({
    required String orderId,
    required String transactionId,
  }) {
    return _repository.checkPaymentStatus(
      orderId: orderId,
      transactionId: transactionId,
    );
  }
}

