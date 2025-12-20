import '../entities/hotel_filter.dart';
import '../entities/hotel_search_result.dart';
import '../repositories/hotel_repository.dart';

class SearchHotels {
  SearchHotels(this._repository);

  final HotelRepository _repository;

  Future<HotelSearchResult> call({
    HotelFilter filter = HotelFilter.empty,
  }) {
    return _repository.searchHotels(filter: filter);
  }
}

