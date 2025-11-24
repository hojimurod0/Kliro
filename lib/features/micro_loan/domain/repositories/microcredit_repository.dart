import '../entities/microcredit_filter.dart';
import '../entities/microcredit_page.dart';

abstract class MicrocreditRepository {
  Future<MicrocreditPage> getMicrocredits({
    required int page,
    required int size,
    MicrocreditFilter filter,
  });
}

