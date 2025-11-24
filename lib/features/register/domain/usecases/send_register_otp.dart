import '../params/auth_params.dart';
import '../repositories/auth_repository.dart';

class SendRegisterOtp {
  SendRegisterOtp(this.repository);

  final AuthRepository repository;

  Future<void> call(SendOtpParams params) {
    return repository.sendRegisterOtp(params);
  }
}

