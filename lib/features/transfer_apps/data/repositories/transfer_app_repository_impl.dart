import 'dart:developer' as developer;

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/transfer_app.dart';
import '../../domain/entities/transfer_app_filter.dart';
import '../../domain/repositories/transfer_app_repository.dart';
import '../datasources/transfer_app_local_data_source.dart';
import '../datasources/transfer_app_remote_data_source.dart';
import '../models/transfer_app_model.dart';

class TransferAppRepositoryImpl implements TransferAppRepository {
  TransferAppRepositoryImpl({
    required TransferAppRemoteDataSource remoteDataSource,
    required TransferAppLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final TransferAppRemoteDataSource _remoteDataSource;
  final TransferAppLocalDataSource _localDataSource;

  @override
  Future<List<TransferApp>> getTransferApps({
    TransferAppFilter filter = TransferAppFilter.empty,
  }) async {
    try {
      final models =
          await _remoteDataSource.getTransferApps(filter: filter);

      await _localDataSource.cacheResponse(
        models.map((model) => model.toJson()).toList(),
      );

      return models.map((model) => model.toEntity()).toList();
    } on AppException catch (error) {
      final cached = _localDataSource.getLastCachedApps();
      if (cached != null && cached.isNotEmpty) {
        developer.log(
          'TransferAppRepository returning cached data after error: ${error.message}',
          name: 'TransferAppRepository',
          error: error,
        );
        return cached.map((model) => model.toEntity()).toList();
      }
      rethrow;
    }
  }
}

