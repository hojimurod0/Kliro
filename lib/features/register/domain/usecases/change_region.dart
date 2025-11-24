import '../entities/user_profile.dart';
import '../params/auth_params.dart';
import '../repositories/profile_repository.dart';

class ChangeRegion {
  ChangeRegion(this.repository);

  final ProfileRepository repository;

  Future<UserProfile> call(ChangeRegionParams params) {
    return repository.changeRegion(params);
  }
}

