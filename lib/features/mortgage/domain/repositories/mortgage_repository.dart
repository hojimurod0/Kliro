import '../entities/mortgage_filter.dart';
import '../entities/mortgage_page.dart';

abstract class MortgageRepository {
  Future<MortgagePage> getMortgages({
    required int page,
    required int size,
    MortgageFilter filter,
  });
}

