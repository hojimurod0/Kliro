import '../../domain/repositories/register_repository.dart';
import '../datasources/register_remote_data_source.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  final RegisterRemoteDataSource remote;
  RegisterRepositoryImpl(this.remote);

  @override
  Future<void> register({required String email, required String password}) {
    return remote.register(email: email, password: password);
  }
}
