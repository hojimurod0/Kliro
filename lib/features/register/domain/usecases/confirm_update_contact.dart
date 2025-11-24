import '../params/auth_params.dart';
import '../repositories/profile_repository.dart';

class ConfirmUpdateContact {
  ConfirmUpdateContact(this.repository);

  final ProfileRepository repository;

  Future<void> call(ConfirmUpdateContactParams params) {
    return repository.confirmUpdateContact(params);
  }
}



