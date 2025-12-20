import '../repositories/avichiptalar_repository.dart';

class GetCities {
  GetCities(this._repository);

  final AvichiptalarRepository _repository;

  Future<List<String>> call({String? query}) {
    return _repository.getCities(query: query);
  }
}

