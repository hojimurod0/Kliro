import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remote;
  HomeRepositoryImpl(this.remote);

  @override
  Future<List<String>> getHomeData() {
    return remote.getHomeData();
  }
}
