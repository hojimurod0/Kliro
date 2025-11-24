import '../../domain/entities/user_profile.dart';
import '../../domain/params/auth_params.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<UserProfile> getProfile() {
    return _remote.getProfile();
  }

  @override
  Future<UserProfile> updateProfile(UpdateProfileParams params) {
    return _remote.updateProfile(params);
  }

  @override
  Future<UserProfile> changeRegion(ChangeRegionParams params) {
    return _remote.changeRegion(params);
  }

  @override
  Future<void> changePassword(ChangePasswordParams params) {
    return _remote.changePassword(params);
  }

  @override
  Future<void> updateContact(UpdateContactParams params) {
    return _remote.updateContact(params);
  }

  @override
  Future<void> confirmUpdateContact(ConfirmUpdateContactParams params) {
    return _remote.confirmUpdateContact(params);
  }

  @override
  Future<void> logout() {
    return _remote.logout();
  }
}
