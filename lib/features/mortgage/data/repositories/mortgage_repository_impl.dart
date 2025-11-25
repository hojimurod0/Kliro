import 'dart:developer' as developer;

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/mortgage_filter.dart';
import '../../domain/entities/mortgage_page.dart';
import '../../domain/repositories/mortgage_repository.dart';
import '../datasources/mortgage_local_data_source.dart';
import '../datasources/mortgage_remote_data_source.dart';
import '../models/mortgage_page_model.dart';

class MortgageRepositoryImpl implements MortgageRepository {
  MortgageRepositoryImpl({
    required MortgageRemoteDataSource remoteDataSource,
    required MortgageLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final MortgageRemoteDataSource _remoteDataSource;
  final MortgageLocalDataSource _localDataSource;

  @override
  Future<MortgagePage> getMortgages({
    required int page,
    required int size,
    MortgageFilter filter = MortgageFilter.empty,
  }) async {
    print('[MortgageRepository] Fetching mortgages:');
    print('  - Page: $page, Size: $size');
    print('  - Filter: ${filter.toQueryParameters()}');
    
    developer.log(
      'Repository fetching page=$page size=$size filter=${filter.toQueryParameters()}',
      name: 'MortgageRepository',
    );
    try {
      final result = await _remoteDataSource.getMortgages(
        page: page,
        size: size,
        filter: filter,
      );
      
      print('[MortgageRepository] API response received:');
      print('  - Items count: ${result.content.length}');
      print('  - Page number: ${result.number}');
      print('  - Total pages: ${result.totalPages}');
      print('  - Is last: ${result.last}');
      
      if (result.content.isNotEmpty) {
        print('[MortgageRepository] First item: ${result.content.first.bankName}');
      }
      
      developer.log(
        'Repository received ${result.content.length} items, caching...',
        name: 'MortgageRepository',
      );
      await _localDataSource.cacheResponse(result.toJson());
      developer.log('Repository returning fresh data', name: 'MortgageRepository');
      
      final entity = result.toEntity();
      print('[MortgageRepository] Converted to entity: ${entity.items.length} items');
      return entity;
    } on AppException catch (error) {
      developer.log(
        'Repository caught AppException, trying cache -> ${error.message}',
        name: 'MortgageRepository',
        error: error,
      );
      final cached = _localDataSource.getLastCachedResponse();
      if (cached != null) {
        developer.log('Repository returning cached data', name: 'MortgageRepository');
        return MortgagePageModel.fromJson(cached).toEntity();
      }
      developer.log('No cache available, rethrowing', name: 'MortgageRepository', error: error);
      rethrow;
    }
  }
}
