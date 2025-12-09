import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/travel_repository.dart';

/// Use case для получения тарифов
class GetTarifsUseCase {
  final TravelRepository repository;

  GetTarifsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String countryCode) async {
    return await repository.getTarifs(countryCode);
  }
}

