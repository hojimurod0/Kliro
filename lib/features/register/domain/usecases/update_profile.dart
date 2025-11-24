import '../entities/user_profile.dart';
import '../params/auth_params.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile {
  UpdateProfile(this.repository);

  final ProfileRepository repository;

  Future<UserProfile> call(UpdateProfileParams params) {
    return repository.updateProfile(params);
  }
}

