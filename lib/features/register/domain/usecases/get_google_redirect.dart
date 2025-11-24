import '../entities/google_auth_redirect.dart';
import '../repositories/auth_repository.dart';

class GetGoogleRedirect {
  GetGoogleRedirect(this.repository);

  final AuthRepository repository;

  Future<GoogleAuthRedirect> call(String redirectUrl) {
    return repository.getGoogleAuthRedirect(redirectUrl);
  }
}

