import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  @override
  Future<AuthUser> login({required String email, required String password}) async {
    await remote.login(email: email, password: password);
    return AuthUser(id: 'tmp', email: email);
  }

  @override
  Future<void> logout() {
    return remote.logout();
  }
}
