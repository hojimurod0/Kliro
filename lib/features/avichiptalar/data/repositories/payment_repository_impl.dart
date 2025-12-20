import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';
import '../models/invoice_request_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<AppException, Invoice>> createInvoice(
      InvoiceRequestModel request) async {
    try {
      final model = await remoteDataSource.createInvoice(request);
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(e);
    } catch (e, stackTrace) {
      AppLogger.error('Create invoice error', e, stackTrace);
      return Left(ParsingException('Invoice yaratishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, Invoice>> getInvoice(String uuid) async {
    try {
      if (uuid.isEmpty) {
        return Left(const ValidationException('Invoice UUID bo\'sh bo\'lmasligi kerak'));
      }
      final model = await remoteDataSource.getInvoice(uuid);
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(e);
    } catch (e, stackTrace) {
      AppLogger.error('Get invoice error', e, stackTrace);
      return Left(ParsingException('Invoice olishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, Invoice>> scanpay(String uuid, String code) async {
    try {
      if (uuid.isEmpty) {
        return Left(const ValidationException('Invoice UUID bo\'sh bo\'lmasligi kerak'));
      }
      if (code.isEmpty) {
        return Left(const ValidationException('Scanpay kodi bo\'sh bo\'lmasligi kerak'));
      }
      final model = await remoteDataSource.scanpay(uuid, code);
      return Right(model.toEntity());
    } on AppException catch (e) {
      return Left(e);
    } catch (e, stackTrace) {
      AppLogger.error('Scanpay error', e, stackTrace);
      return Left(ParsingException('Scanpay xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, String>> checkStatus(String uuid) async {
    try {
      if (uuid.isEmpty) {
        return Left(const ValidationException('Invoice UUID bo\'sh bo\'lmasligi kerak'));
      }
      final status = await remoteDataSource.checkStatus(uuid);
      return Right(status);
    } on AppException catch (e) {
      return Left(e);
    } catch (e, stackTrace) {
      AppLogger.error('Check status error', e, stackTrace);
      return Left(ParsingException('Status tekshirishda xatolik: $e'));
    }
  }

  @override
  Future<Either<AppException, void>> deleteInvoice(String uuid) async {
    try {
      if (uuid.isEmpty) {
        return Left(const ValidationException('Invoice UUID bo\'sh bo\'lmasligi kerak'));
      }
      await remoteDataSource.deleteInvoice(uuid);
      return const Right(null);
    } on AppException catch (e) {
      return Left(e);
    } catch (e, stackTrace) {
      AppLogger.error('Delete invoice error', e, stackTrace);
      return Left(ParsingException('Invoice o\'chirishda xatolik: $e'));
    }
  }
}
