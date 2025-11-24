import '../entities/deposit_filter.dart';
import '../entities/deposit_page.dart';

abstract class DepositRepository {
  Future<DepositPage> getDeposits({
    required int page,
    required int size,
    DepositFilter filter,
  });
}
