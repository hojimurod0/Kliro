import '../repositories/register_repository.dart';

class RegisterUser {
  final RegisterRepository repository;
  RegisterUser(this.repository);

  Future<void> call({required String email, required String password}) {
    return repository.register(email: email, password: password);
  }
}
