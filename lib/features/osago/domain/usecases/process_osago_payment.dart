import '../entities/osago_payment.dart';
import '../repositories/osago_repository.dart';

class ProcessOsagoPayment {
  const ProcessOsagoPayment(this.repository);

  final OsagoRepository repository;

  Future<OsagoPayment> call(OsagoPayment payment) =>
      repository.processPayment(payment);
}

