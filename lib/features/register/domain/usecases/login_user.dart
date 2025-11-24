import '../entities/auth_tokens.dart';
import '../params/auth_params.dart';
import '../repositories/auth_repository.dart';

class LoginUser {
  LoginUser(this.repository);

  final AuthRepository repository;

  Future<AuthTokens> call(LoginParams params) {
    return repository.login(params);
  }
}

