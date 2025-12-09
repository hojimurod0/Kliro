import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/travel_repository.dart';

/// Use case для расчета стоимости
class CalculateUseCase {
  final TravelRepository repository;

  CalculateUseCase(this.repository);

  Future<Either<Failure, double>> call({
    required String sessionId,
    required bool accident,
    required bool luggage,
    required bool cancelTravel,
    required bool personRespon,
    required bool delayTravel,
  }) async {
    return await repository.calculate(
      sessionId: sessionId,
      accident: accident,
      luggage: luggage,
      cancelTravel: cancelTravel,
      personRespon: personRespon,
      delayTravel: delayTravel,
    );
  }
}

