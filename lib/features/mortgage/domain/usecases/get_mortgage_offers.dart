import '../entities/mortgage_filter.dart';
import '../entities/mortgage_page.dart';
import '../repositories/mortgage_repository.dart';

class GetMortgages {
  const GetMortgages(this.repository);

  final MortgageRepository repository;

  Future<MortgagePage> call({
    required int page,
    required int size,
    MortgageFilter filter = MortgageFilter.empty,
  }) =>
      repository.getMortgages(
        page: page,
        size: size,
        filter: filter,
      );
}

