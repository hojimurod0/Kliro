import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/session.dart';
import '../entities/policy.dart';
import '../entities/person.dart';
import '../entities/traveler.dart';
import '../entities/country.dart';

/// Репозиторий для Travel Insurance
abstract class TravelRepository {
  /// Создать цель путешествия
  Future<Either<Failure, Session>> createPurpose({
    required int purposeId,
    required List<String> destinations,
  });

  /// Отправить детали путешествия
  Future<Either<Failure, void>> sendDetails({
    required String sessionId,
    required String startDate,
    required String endDate,
    required List<String> travelersBirthdates,
    required bool annualPolicy,
    required bool covidProtection,
  });

  /// Рассчитать стоимость
  Future<Either<Failure, double>> calculate({
    required String sessionId,
    required bool accident,
    required bool luggage,
    required bool cancelTravel,
    required bool personRespon,
    required bool delayTravel,
  });

  /// Сохранить полис
  Future<Either<Failure, Policy>> savePolicy({
    required String sessionId,
    required String provider,
    required double summaAll,
    required String programId,
    required Person sugurtalovchi,
    required List<Traveler> travelers,
  });

  /// Проверить статус сессии
  Future<Either<Failure, Policy>> checkSession(String sessionId);

  /// Получить список стран
  Future<Either<Failure, List<Country>>> getCountries();

  /// Получить тарифы по стране
  Future<Either<Failure, Map<String, dynamic>>> getTarifs(String countryCode);
}

