import '../entities/transfer_app.dart';
import '../entities/transfer_app_filter.dart';
import '../repositories/transfer_app_repository.dart';

class GetTransferApps {
  const GetTransferApps(this._repository);

  final TransferAppRepository _repository;

  Future<List<TransferApp>> call({
    TransferAppFilter filter = TransferAppFilter.empty,
  }) async {
    return _repository.getTransferApps(filter: filter);
  }
}

