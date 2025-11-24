import '../params/auth_params.dart';
import '../repositories/profile_repository.dart';

class UpdateContact {
  UpdateContact(this.repository);

  final ProfileRepository repository;

  Future<void> call(UpdateContactParams params) {
    return repository.updateContact(params);
  }
}



