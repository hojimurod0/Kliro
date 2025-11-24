import 'dart:developer' as developer;

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/microcredit_filter.dart';
import '../../domain/entities/microcredit_page.dart';
import '../../domain/repositories/microcredit_repository.dart';
import '../datasources/microcredit_local_data_source.dart';
import '../datasources/microcredit_remote_data_source.dart';
import '../models/microcredit_page_model.dart';

class MicrocreditRepositoryImpl implements MicrocreditRepository {
  MicrocreditRepositoryImpl({
    required MicrocreditRemoteDataSource remoteDataSource,
    required MicrocreditLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final MicrocreditRemoteDataSource _remoteDataSource;
  final MicrocreditLocalDataSource _localDataSource;

  @override
  Future<MicrocreditPage> getMicrocredits({
    required int page,
    required int size,
    MicrocreditFilter filter = MicrocreditFilter.empty,
  }) async {
    print('[MicrocreditRepository] Fetching microcredits:');
    print('  - Page: $page, Size: $size');
    print('  - Filter: ${filter.toQueryParameters()}');
    
    developer.log(
      'Repository fetching page=$page size=$size filter=${filter.toQueryParameters()}',
      name: 'MicrocreditRepository',
    );
    try {
      final result = await _remoteDataSource.getMicrocredits(
        page: page,
        size: size,
        filter: filter,
      );
      
      print('[MicrocreditRepository] API response received:');
      print('  - Items count: ${result.content.length}');
      print('  - Page number: ${result.number}');
      print('  - Total pages: ${result.totalPages}');
      print('  - Is last: ${result.last}');
      
      if (result.content.isNotEmpty) {
        print('[MicrocreditRepository] First item: ${result.content.first.bankName}');
      }
      
      developer.log(
        'Repository received ${result.content.length} items, caching...',
        name: 'MicrocreditRepository',
      );
      await _localDataSource.cacheResponse(result.toJson());
      developer.log('Repository returning fresh data', name: 'MicrocreditRepository');
      
      final entity = result.toEntity();
      print('[MicrocreditRepository] Converted to entity: ${entity.items.length} items');
      return entity;
    } on AppException catch (error) {
      developer.log(
        'Repository caught AppException, trying cache -> ${error.message}',
        name: 'MicrocreditRepository',
        error: error,
      );
      final cached = _localDataSource.getLastCachedResponse();
      if (cached != null) {
        developer.log('Repository returning cached data', name: 'MicrocreditRepository');
        return MicrocreditPageModel.fromJson(cached).toEntity();
      }
      developer.log('No cache available, rethrowing', name: 'MicrocreditRepository', error: error);
      rethrow;
    }
  }
}
