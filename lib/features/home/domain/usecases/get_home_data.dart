import '../repositories/home_repository.dart';

class GetHomeData {
  final HomeRepository repository;
  GetHomeData(this.repository);

  Future<List<String>> call() {
    return repository.getHomeData();
  }
}
