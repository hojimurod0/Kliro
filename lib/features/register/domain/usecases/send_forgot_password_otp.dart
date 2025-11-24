import '../params/auth_params.dart';
import '../repositories/auth_repository.dart';

class SendForgotPasswordOtp {
  SendForgotPasswordOtp(this.repository);

  final AuthRepository repository;

  Future<void> call(ForgotPasswordParams params) {
    return repository.sendForgotPasswordOtp(params);
  }
}

