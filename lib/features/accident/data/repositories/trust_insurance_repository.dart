import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../datasources/trust_insurance_remote_data_source.dart';
import '../models/tariff_model.dart';
import '../models/region_model.dart';
import '../models/create_insurance_request.dart';
import '../models/create_insurance_response.dart';
import '../models/check_payment_request.dart';
import '../models/check_payment_response.dart';

abstract class TrustInsuranceRepository {
  Future<Either<Failure, List<TariffModel>>> getTariffs();
  Future<Either<Failure, List<RegionModel>>> getRegions();
  Future<Either<Failure, CreateInsuranceResponse>> createInsurance(
      CreateInsuranceRequest request);
  Future<Either<Failure, CheckPaymentResponse>> checkPayment(
      CheckPaymentRequest request);
}

class TrustInsuranceRepositoryImpl implements TrustInsuranceRepository {
  final TrustInsuranceRemoteDataSource remoteDataSource;
  
  // Cache
  List<TariffModel>? _cachedTariffs;
  DateTime? _tariffsCacheTime;
  List<RegionModel>? _cachedRegions;
  DateTime? _regionsCacheTime;
  
  static const Duration _cacheDuration = Duration(minutes: 5);

  TrustInsuranceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TariffModel>>> getTariffs() async {
    try {
      // Cache tekshiruvi
      if (_cachedTariffs != null &&
          _tariffsCacheTime != null &&
          DateTime.now().difference(_tariffsCacheTime!) < _cacheDuration) {
        return Right(_cachedTariffs!);
      }
      
      // API chaqiruv
      final tariffs = await remoteDataSource.getTariffs();
      
      // Cache'ga saqlash
      _cachedTariffs = tariffs;
      _tariffsCacheTime = DateTime.now();
      
      return Right(tariffs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      // Network xatolikda cache'dan qaytarish
      if (_cachedTariffs != null) {
        return Right(_cachedTariffs!);
      }
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RegionModel>>> getRegions() async {
    try {
      // Cache tekshiruvi
      if (_cachedRegions != null &&
          _regionsCacheTime != null &&
          DateTime.now().difference(_regionsCacheTime!) < _cacheDuration) {
        return Right(_cachedRegions!);
      }
      
      // API chaqiruv
      final regions = await remoteDataSource.getRegions();
      
      // Cache'ga saqlash
      _cachedRegions = regions;
      _regionsCacheTime = DateTime.now();
      
      return Right(regions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      // Network xatolikda cache'dan qaytarish
      if (_cachedRegions != null) {
        return Right(_cachedRegions!);
      }
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CreateInsuranceResponse>> createInsurance(
      CreateInsuranceRequest request) async {
    try {
      final response = await remoteDataSource.createInsurance(request);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CheckPaymentResponse>> checkPayment(
      CheckPaymentRequest request) async {
    try {
      final response = await remoteDataSource.checkPayment(request);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

