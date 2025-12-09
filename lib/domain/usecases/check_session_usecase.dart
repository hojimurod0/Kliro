import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/policy.dart';
import '../repositories/travel_repository.dart';

/// Use case для проверки статуса сессии
class CheckSessionUseCase {
  final TravelRepository repository;

  CheckSessionUseCase(this.repository);

  Future<Either<Failure, Policy>> call(String sessionId) async {
    return await repository.checkSession(sessionId);
  }
}

