import '../entities/transfer_app.dart';
import '../repositories/transfer_app_repository.dart';

class GetTransferApps {
  const GetTransferApps(this._repository);

  final TransferAppRepository _repository;

  Future<List<TransferApp>> call() async {
    return await _repository.getTransferApps();
  }
}

