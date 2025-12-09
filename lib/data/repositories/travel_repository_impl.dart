import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/repositories/travel_repository.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/travel_details.dart';
import '../../domain/entities/calculate_request.dart';
import '../../domain/entities/policy.dart';
import '../../domain/entities/country.dart';
import '../../domain/entities/person.dart';
import '../../domain/entities/traveler.dart';
import '../datasources/travel_remote_data_source.dart';
import '../models/session_model.dart';
import '../models/travel_details_model.dart';
import '../models/calculate_request_model.dart';
import '../models/save_policy_request_model.dart';
import '../models/person_model.dart';
import '../models/traveler_model.dart';
import '../models/purpose_request_model.dart';
import '../models/tarif_request_model.dart';
import 'package:dartz/dartz.dart';

/// Реализация TravelRepository
class TravelRepositoryImpl implements TravelRepository {
  final TravelRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TravelRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Session>> createPurpose({
    required int purposeId,
    required List<String> destinations,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Нет подключения к интернету'));
    }

    try {
      final request = PurposeRequestModel(
        purposeId: purposeId,
        destinations: destinations,
      );

      final sessionModel = await remoteDataSource.createPurpose(request);

      return Right(
        Session(sessionId: sessionModel.sessionId, data: sessionModel.data),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ParsingException catch (e) {
      return Left(ParsingFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Неизвестная ошибка: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> sendDetails({
    required String sessionId,
    required String startDate,
    required String endDate,
    required List<String> travelersBirthdates,
    required bool annualPolicy,
    required bool covidProtection,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Нет подключения к интернету'));
    }

    try {
      final request = TravelDetailsModel(
        sessionId: sessionId,
        startDate: startDate,
        endDate: endDate,
        travelersBirthdates: travelersBirthdates,
        annualPolicy: annualPolicy,
        covidProtection: covidProtection,
      );

      await remoteDataSource.sendDetails(request);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ParsingException catch (e) {
      return Left(ParsingFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Неизвестная ошибка: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, double>> calculate({
    required String sessionId,
    required bool accident,
    required bool luggage,
    required bool cancelTravel,
    required bool personRespon,
    required bool delayTravel,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Нет подключения к интернету'));
    }

    try {
      final request = CalculateRequestModel(
        sessionId: sessionId,
        accident: accident,
        luggage: luggage,
        cancelTravel: cancelTravel,
        personRespon: personRespon,
        delayTravel: delayTravel,
      );

      final response = await remoteDataSource.calculate(request);

      final premium = response.premium ?? response.summaAll ?? 0.0;

      return Right(premium);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ParsingException catch (e) {
      return Left(ParsingFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Неизвестная ошибка: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Policy>> savePolicy({
    required String sessionId,
    required String provider,
    required double summaAll,
    required String programId,
    required Person sugurtalovchi,
    required List<Traveler> travelers,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Нет подключения к интернету'));
    }

    try {
      final personModel = PersonModel(
        type: sugurtalovchi.type,
        passportSeries: sugurtalovchi.passportSeries,
        passportNumber: sugurtalovchi.passportNumber,
        birthday: sugurtalovchi.birthday,
        phone: sugurtalovchi.phone,
        pinfl: sugurtalovchi.pinfl,
        lastName: sugurtalovchi.lastName,
        firstName: sugurtalovchi.firstName,
        middleName: sugurtalovchi.middleName,
      );

      final travelersModel = travelers
          .map(
            (t) => TravelerModel(
              passportSeries: t.passportSeries,
              passportNumber: t.passportNumber,
              birthday: t.birthday,
              pinfl: t.pinfl,
              lastName: t.lastName,
              firstName: t.firstName,
            ),
          )
          .toList();

      final request = SavePolicyRequestModel(
        sessionId: sessionId,
        provider: provider,
        summaAll: summaAll,
        programId: programId,
        sugurtalovchi: personModel,
        travelers: travelersModel,
      );

      final response = await remoteDataSource.savePolicy(request);

      return Right(
        Policy(
          policyId: response.policyId,
          policyNumber: response.policyNumber,
          data: response.data,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ParsingException catch (e) {
      return Left(ParsingFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Неизвестная ошибка: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Policy>> checkSession(String sessionId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Нет подключения к интернету'));
    }

    try {
      final response = await remoteDataSource.checkSession(sessionId);

      return Right(
        Policy(
          policyId: response.policyId,
          policyNumber: response.policyNumber,
          status: response.status,
          data: response.data,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ParsingException catch (e) {
      return Left(ParsingFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Неизвестная ошибка: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Country>>> getCountries() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Нет подключения к интернету'));
    }

    try {
      final countries = await remoteDataSource.getCountries();

      return Right(
        countries
            .map((c) => Country(code: c.code, name: c.name, flag: c.flag))
            .toList(),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ParsingException catch (e) {
      return Left(ParsingFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Неизвестная ошибка: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTarifs(
    String countryCode,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Нет подключения к интернету'));
    }

    try {
      final request = TarifRequestModel(country: countryCode);
      final response = await remoteDataSource.getTarifs(request);

      return Right(response.data ?? response.tarifs?.first ?? {});
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ParsingException catch (e) {
      return Left(ParsingFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Неизвестная ошибка: ${e.toString()}'));
    }
  }
}
