import '../repositories/hotel_repository.dart';

class GetCities {
  GetCities(this._repository);

  final HotelRepository _repository;

  Future<List<String>> call({String? query}) {
    return _repository.getCities(query: query);
  }
}

