import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/travel_repository.dart';

/// Use case для отправки деталей путешествия
class SendDetailsUseCase {
  final TravelRepository repository;

  SendDetailsUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String sessionId,
    required String startDate,
    required String endDate,
    required List<String> travelersBirthdates,
    required bool annualPolicy,
    required bool covidProtection,
  }) async {
    return await repository.sendDetails(
      sessionId: sessionId,
      startDate: startDate,
      endDate: endDate,
      travelersBirthdates: travelersBirthdates,
      annualPolicy: annualPolicy,
      covidProtection: covidProtection,
    );
  }
}

