import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/policy.dart';
import '../entities/person.dart';
import '../entities/traveler.dart';
import '../repositories/travel_repository.dart';

/// Use case для сохранения полиса
class SavePolicyUseCase {
  final TravelRepository repository;

  SavePolicyUseCase(this.repository);

  Future<Either<Failure, Policy>> call({
    required String sessionId,
    required String provider,
    required double summaAll,
    required String programId,
    required Person sugurtalovchi,
    required List<Traveler> travelers,
  }) async {
    return await repository.savePolicy(
      sessionId: sessionId,
      provider: provider,
      summaAll: summaAll,
      programId: programId,
      sugurtalovchi: sugurtalovchi,
      travelers: travelers,
    );
  }
}

