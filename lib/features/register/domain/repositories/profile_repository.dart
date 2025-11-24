import '../entities/user_profile.dart';
import '../params/auth_params.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();
  Future<UserProfile> updateProfile(UpdateProfileParams params);
  Future<UserProfile> changeRegion(ChangeRegionParams params);
  Future<void> changePassword(ChangePasswordParams params);
  Future<void> updateContact(UpdateContactParams params);
  Future<void> confirmUpdateContact(ConfirmUpdateContactParams params);
  Future<void> logout();
}

