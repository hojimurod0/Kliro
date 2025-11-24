import '../entities/auth_tokens.dart';
import '../params/auth_params.dart';
import '../repositories/auth_repository.dart';

class CompleteRegistration {
  CompleteRegistration(this.repository);

  final AuthRepository repository;

  Future<AuthTokens> call(RegistrationFinalizeParams params) {
    return repository.finalizeRegistration(params);
  }
}

