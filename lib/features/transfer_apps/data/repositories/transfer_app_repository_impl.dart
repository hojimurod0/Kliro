import '../../domain/entities/transfer_app.dart';
import '../../domain/repositories/transfer_app_repository.dart';
import '../datasources/transfer_app_local_data_source.dart';

class TransferAppRepositoryImpl implements TransferAppRepository {
  const TransferAppRepositoryImpl({
    required this.localDataSource,
  });

  final TransferAppLocalDataSource localDataSource;

  @override
  Future<List<TransferApp>> getTransferApps() async {
    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 100));
    return localDataSource.fetchTransferApps();
  }
}

