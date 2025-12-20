import '../entities/avichipta_filter.dart';
import '../entities/avichipta_search_result.dart';
import '../repositories/avichiptalar_repository.dart';

class SearchFlights {
  SearchFlights(this._repository);

  final AvichiptalarRepository _repository;

  Future<AvichiptaSearchResult> call({
    AvichiptaFilter filter = AvichiptaFilter.empty,
  }) {
    return _repository.searchFlights(filter: filter);
  }
}

