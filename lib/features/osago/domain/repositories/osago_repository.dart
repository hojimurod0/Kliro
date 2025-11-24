import '../entities/osago_company.dart';
import '../entities/osago_duration.dart';
import '../entities/osago_order.dart';
import '../entities/osago_payment.dart';
import '../entities/osago_type.dart';

abstract class OsagoRepository {
  Future<List<OsagoCompany>> getCompanies();
  Future<List<OsagoDuration>> getDurations();
  Future<List<OsagoType>> getTypes();
  Future<OsagoOrder> createOrder(OsagoOrder order);
  Future<OsagoPayment> processPayment(OsagoPayment payment);
}

