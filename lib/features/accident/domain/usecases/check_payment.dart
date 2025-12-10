import '../../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/check_payment_entity.dart';
import '../repositories/accident_repository.dart';

class CheckPayment {
  CheckPayment(this._repository);

  final AccidentRepository _repository;

  Future<Either<Failure, CheckPaymentEntity>> call({
    required int anketaId,
    required String lan,
  }) {
    return _repository.checkPayment(
      anketaId: anketaId,
      lan: lan,
    );
  }
}

