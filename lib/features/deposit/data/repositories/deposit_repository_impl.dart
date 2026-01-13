import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/deposit_filter.dart';
import '../../domain/entities/deposit_page.dart';
import '../../domain/repositories/deposit_repository.dart';
import '../datasources/deposit_local_data_source.dart';
import '../datasources/deposit_remote_data_source.dart';
import '../models/deposit_page_model.dart';

class DepositRepositoryImpl implements DepositRepository {
  DepositRepositoryImpl({
    required DepositRemoteDataSource remoteDataSource,
    required DepositLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final DepositRemoteDataSource _remoteDataSource;
  final DepositLocalDataSource _localDataSource;

  @override
  Future<DepositPage> getDeposits({
    required int page,
    required int size,
    DepositFilter filter = DepositFilter.empty,
  }) async {
    debugPrint('[DepositRepository] Fetching deposits:');
    debugPrint('  - Page: $page, Size: $size');
    debugPrint('  - Filter: ${filter.toQueryParameters()}');
    
    developer.log(
      'Repository fetching page=$page size=$size filter=${filter.toQueryParameters()}',
      name: 'DepositRepository',
    );
    try {
      final result = await _remoteDataSource.getDeposits(
        page: page,
        size: size,
        filter: filter,
      );
      
      debugPrint('[DepositRepository] API response received:');
      debugPrint('  - Items count: ${result.content.length}');
      debugPrint('  - Page number: ${result.number}');
      debugPrint('  - Total pages: ${result.totalPages}');
      debugPrint('  - Is last: ${result.last}');
      
      if (result.content.isNotEmpty) {
        debugPrint('[DepositRepository] First item: ${result.content.first.bankName}');
      }
      
      developer.log(
        'Repository received ${result.content.length} items, caching...',
        name: 'DepositRepository',
      );
      await _localDataSource.cacheResponse(result.toJson());
      developer.log('Repository returning fresh data', name: 'DepositRepository');
      
      final entity = result.toEntity();
      debugPrint('[DepositRepository] Converted to entity: ${entity.items.length} items');
      return entity;
    } on AppException catch (error) {
      developer.log(
        'Repository caught AppException, trying cache -> ${error.message}',
        name: 'DepositRepository',
        error: error,
      );
      final cached = _localDataSource.getLastCachedResponse();
      if (cached != null) {
        developer.log('Repository returning cached data', name: 'DepositRepository');
        return DepositPageModel.fromJson(cached).toEntity();
      }
      developer.log('No cache available, rethrowing', name: 'DepositRepository', error: error);
      rethrow;
    }
  }
}
