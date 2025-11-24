import '../repositories/profile_repository.dart';

class LogoutUser {
  LogoutUser(this.repository);

  final ProfileRepository repository;

  Future<void> call() {
    return repository.logout();
  }
}



