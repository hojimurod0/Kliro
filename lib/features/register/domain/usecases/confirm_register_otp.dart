import '../params/auth_params.dart';
import '../repositories/auth_repository.dart';

class ConfirmRegisterOtp {
  ConfirmRegisterOtp(this.repository);

  final AuthRepository repository;

  Future<void> call(ConfirmOtpParams params) {
    return repository.confirmRegisterOtp(params);
  }
}

