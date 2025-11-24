import '../params/auth_params.dart';
import '../repositories/auth_repository.dart';

class ResetPassword {
  ResetPassword(this.repository);

  final AuthRepository repository;

  Future<void> call(ResetPasswordParams params) {
    return repository.resetPassword(params);
  }
}

