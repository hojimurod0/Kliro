import '../entities/auth_tokens.dart';
import '../params/auth_params.dart';
import '../repositories/auth_repository.dart';

class CompleteGoogleRegistration {
  CompleteGoogleRegistration(this.repository);

  final AuthRepository repository;

  Future<AuthTokens> call(GoogleCompleteParams params) {
    return repository.completeGoogleRegistration(params);
  }
}

