import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/country.dart';
import '../repositories/travel_repository.dart';

/// Use case для получения списка стран
class GetCountriesUseCase {
  final TravelRepository repository;

  GetCountriesUseCase(this.repository);

  Future<Either<Failure, List<Country>>> call() async {
    return await repository.getCountries();
  }
}

