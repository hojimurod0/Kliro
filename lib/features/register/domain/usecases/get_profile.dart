import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfile {
  GetProfile(this.repository);

  final ProfileRepository repository;

  Future<UserProfile> call() {
    return repository.getProfile();
  }
}

