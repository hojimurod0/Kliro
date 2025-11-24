import '../params/auth_params.dart';
import '../repositories/profile_repository.dart';

class ChangePassword {
  ChangePassword(this.repository);

  final ProfileRepository repository;

  Future<void> call(ChangePasswordParams params) {
    return repository.changePassword(params);
  }
}



