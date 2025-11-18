abstract class AuthRemoteDataSource {
  Future<void> login({required String email, required String password});
  Future<void> logout();
}
