import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/session.dart';
import '../repositories/travel_repository.dart';

/// Use case для создания цели путешествия
class CreatePurposeUseCase {
  final TravelRepository repository;

  CreatePurposeUseCase(this.repository);

  Future<Either<Failure, Session>> call({
    required int purposeId,
    required List<String> destinations,
  }) async {
    return await repository.createPurpose(
      purposeId: purposeId,
      destinations: destinations,
    );
  }
}

