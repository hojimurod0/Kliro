import '../entities/transfer_app.dart';

abstract class TransferAppRepository {
  Future<List<TransferApp>> getTransferApps();
}

