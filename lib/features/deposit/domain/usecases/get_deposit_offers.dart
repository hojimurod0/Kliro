import 'dart:developer' as developer;

import '../entities/deposit_filter.dart';
import '../entities/deposit_page.dart';
import '../repositories/deposit_repository.dart';

class GetDeposits {
  const GetDeposits(this.repository);

  final DepositRepository repository;

  Future<DepositPage> call({
    required int page,
    required int size,
    DepositFilter filter = DepositFilter.empty,
  }) {
    developer.log(
      'UseCase: fetching deposits page=$page size=$size filter=${filter.toQueryParameters()}',
      name: 'GetDeposits',
    );
    return repository.getDeposits(page: page, size: size, filter: filter);
  }
}
