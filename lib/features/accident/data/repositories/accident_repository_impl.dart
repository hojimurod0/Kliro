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
import '../models/person_model.dart';
import '../models/payment_urls_model.dart';
import '../models/policy_info_model.dart';
import '../models/download_urls_model.dart';
import '../../domain/repositories/accident_repository.dart';
import '../../domain/entities/tariff_entity.dart';
import '../../domain/entities/region_entity.dart';
import '../../domain/entities/create_insurance_entity.dart';
import '../../domain/entities/check_payment_entity.dart';
import '../../domain/entities/payment_urls_entity.dart';
import '../../domain/entities/policy_info_entity.dart';
import '../../domain/entities/download_urls_entity.dart';

class AccidentRepositoryImpl implements AccidentRepository {
  final TrustInsuranceRemoteDataSource remoteDataSource;
  
  // Cache
  List<TariffEntity>? _cachedTariffs;
  DateTime? _tariffsCacheTime;
  List<RegionEntity>? _cachedRegions;
  DateTime? _regionsCacheTime;
  
  static const Duration _cacheDuration = Duration(minutes: 5);

  AccidentRepositoryImpl({required this.remoteDataSource});

  // Mapper functions
  TariffEntity _mapTariffModelToEntity(TariffModel model) {
    return TariffEntity(
      id: model.id,
      insurancePremium: model.insurancePremium,
      insuranceOtv: model.insuranceOtv,
    );
  }

  RegionEntity _mapRegionModelToEntity(RegionModel model) {
    return RegionEntity(
      id: model.id,
      name: model.name,
    );
  }

  PaymentUrlsEntity _mapPaymentUrlsModelToEntity(PaymentUrlsModel model) {
    return PaymentUrlsEntity(
      click: model.click,
      payme: model.payme,
    );
  }

  CreateInsuranceEntity _mapCreateInsuranceResponseToEntity(
      CreateInsuranceResponse response) {
    return CreateInsuranceEntity(
      anketaId: response.anketaId,
      paymentUrls: _mapPaymentUrlsModelToEntity(response.paymentUrls),
      insurancePremium: response.insurancePremium,
    );
  }

  PolicyInfoEntity? _mapPolicyInfoModelToEntity(PolicyInfoModel? model) {
    if (model == null) return null;
    return PolicyInfoEntity(
      policyNumber: model.policyNumber,
      issueDate: model.issueDate,
      expiryDate: model.expiryDate,
    );
  }

  DownloadUrlsEntity? _mapDownloadUrlsModelToEntity(
      DownloadUrlsModel? model) {
    if (model == null) return null;
    return DownloadUrlsEntity(
      pdf: model.pdf,
      qr: model.qr,
    );
  }

  CheckPaymentEntity _mapCheckPaymentResponseToEntity(
      CheckPaymentResponse response) {
    return CheckPaymentEntity(
      statusPayment: response.statusPayment,
      statusPolicy: response.statusPolicy,
      paymentType: response.paymentType,
      policyInfo: _mapPolicyInfoModelToEntity(response.policyInfo),
      downloadUrls: _mapDownloadUrlsModelToEntity(response.downloadUrls),
    );
  }

  @override
  Future<Either<Failure, List<TariffEntity>>> getTariffs() async {
    try {
      // Cache tekshiruvi
      if (_cachedTariffs != null &&
          _tariffsCacheTime != null &&
          DateTime.now().difference(_tariffsCacheTime!) < _cacheDuration) {
        return Right(_cachedTariffs!);
      }
      
      // API chaqiruv
      final tariffs = await remoteDataSource.getTariffs();
      
      // Entity ga o'tkazish
      final tariffEntities = tariffs.map(_mapTariffModelToEntity).toList();
      
      // Cache'ga saqlash
      _cachedTariffs = tariffEntities;
      _tariffsCacheTime = DateTime.now();
      
      return Right(tariffEntities);
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
  Future<Either<Failure, List<RegionEntity>>> getRegions() async {
    try {
      // Cache tekshiruvi
      if (_cachedRegions != null &&
          _regionsCacheTime != null &&
          DateTime.now().difference(_regionsCacheTime!) < _cacheDuration) {
        return Right(_cachedRegions!);
      }
      
      // API chaqiruv
      final regions = await remoteDataSource.getRegions();
      
      // Entity ga o'tkazish
      final regionEntities = regions.map(_mapRegionModelToEntity).toList();
      
      // Cache'ga saqlash
      _cachedRegions = regionEntities;
      _regionsCacheTime = DateTime.now();
      
      return Right(regionEntities);
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
  Future<Either<Failure, CreateInsuranceEntity>> createInsurance({
    required String startDate,
    required int tariffId,
    required String pinfl,
    required String passSery,
    required String passNum,
    required String dateBirth,
    required String lastName,
    required String firstName,
    String? patronymName,
    required int region,
    required String phone,
    required String address,
  }) async {
    try {
      final request = CreateInsuranceRequest(
        startDate: startDate,
        tariffId: tariffId,
        person: PersonModel(
          pinfl: pinfl,
          passSery: passSery,
          passNum: passNum,
          dateBirth: dateBirth,
          lastName: lastName,
          firstName: firstName,
          patronymName: patronymName,
          region: region,
          phone: phone,
          address: address,
        ),
      );

      final response = await remoteDataSource.createInsurance(request);
      return Right(_mapCreateInsuranceResponseToEntity(response));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CheckPaymentEntity>> checkPayment({
    required int anketaId,
    required String lan,
  }) async {
    try {
      final request = CheckPaymentRequest(
        anketaId: anketaId,
        lan: lan,
      );

      final response = await remoteDataSource.checkPayment(request);
      return Right(_mapCheckPaymentResponseToEntity(response));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

