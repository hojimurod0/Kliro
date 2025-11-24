import '../entities/osago_order.dart';
import '../repositories/osago_repository.dart';

class CreateOsagoOrder {
  const CreateOsagoOrder(this.repository);

  final OsagoRepository repository;

  Future<OsagoOrder> call(OsagoOrder order) => repository.createOrder(order);
}

