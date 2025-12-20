import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../data/models/invoice_request_model.dart';
import '../entities/invoice.dart';

abstract class PaymentRepository {
  Future<Either<AppException, Invoice>> createInvoice(InvoiceRequestModel request);
  Future<Either<AppException, Invoice>> getInvoice(String uuid);
  Future<Either<AppException, Invoice>> scanpay(String uuid, String code);
  Future<Either<AppException, String>> checkStatus(String uuid);
  Future<Either<AppException, void>> deleteInvoice(String uuid);
}
