import 'dart:developer' as developer;

import '../entities/microcredit_filter.dart';
import '../entities/microcredit_page.dart';
import '../repositories/microcredit_repository.dart';

class GetMicrocredits {
  const GetMicrocredits(this.repository);

  final MicrocreditRepository repository;

  Future<MicrocreditPage> call({
    required int page,
    required int size,
    MicrocreditFilter filter = MicrocreditFilter.empty,
  }) {
    developer.log(
      'UseCase: fetching microcredits page=$page size=$size filter=${filter.toQueryParameters()}',
      name: 'GetMicrocredits',
    );
    return repository.getMicrocredits(page: page, size: size, filter: filter);
  }
}

