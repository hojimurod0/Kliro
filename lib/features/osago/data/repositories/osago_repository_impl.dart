import '../../domain/entities/osago_company.dart';
import '../../domain/entities/osago_duration.dart';
import '../../domain/entities/osago_order.dart';
import '../../domain/entities/osago_payment.dart';
import '../../domain/entities/osago_type.dart';
import '../../domain/repositories/osago_repository.dart';
import '../datasources/osago_local_data_source.dart';
import '../models/osago_order_model.dart';
import '../models/osago_payment_model.dart';

class OsagoRepositoryImpl implements OsagoRepository {
  OsagoRepositoryImpl({
    required OsagoLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final OsagoLocalDataSource _localDataSource;

  @override
  Future<List<OsagoCompany>> getCompanies() async {
    return await _localDataSource.fetchCompanies();
  }

  @override
  Future<List<OsagoDuration>> getDurations() async {
    return await _localDataSource.fetchDurations();
  }

  @override
  Future<List<OsagoType>> getTypes() async {
    return await _localDataSource.fetchTypes();
  }

  @override
  Future<OsagoOrder> createOrder(OsagoOrder order) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate order creation
    return OsagoOrderModel(
      vehicleNumber: order.vehicleNumber,
      carMake: order.carMake,
      carModel: order.carModel,
      passportSeries: order.passportSeries,
      passportNumber: order.passportNumber,
      texPassportSeries: order.texPassportSeries,
      texPassportNumber: order.texPassportNumber,
      dateOfBirth: order.dateOfBirth,
      isOwner: order.isOwner,
      companyId: order.companyId,
      durationId: order.durationId,
      typeId: order.typeId,
      startDate: order.startDate,
      phone: order.phone,
      totalAmount: '1200000',
      orderId: 'OSAGO-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<OsagoPayment> processPayment(OsagoPayment payment) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    // Simulate payment processing
    return OsagoPaymentModel(
      orderId: payment.orderId,
      amount: payment.amount,
      paymentType: payment.paymentType,
      paymentId: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
      status: 'success',
    );
  }
}

