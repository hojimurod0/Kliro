import '../entities/transfer_app.dart';
import '../entities/transfer_app_filter.dart';

abstract class TransferAppRepository {
  Future<List<TransferApp>> getTransferApps({
    TransferAppFilter filter = TransferAppFilter.empty,
  });
}

