import 'dart:developer' as developer;
import 'dart:math' as math;

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/card_filter.dart';
import '../../domain/entities/card_page.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/card_local_data_source.dart';
import '../datasources/card_remote_data_source.dart';
import '../models/card_offer_page_model.dart';

class CardRepositoryImpl implements CardRepository {
  CardRepositoryImpl({
    required CardRemoteDataSource remoteDataSource,
    required CardLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final CardRemoteDataSource _remoteDataSource;
  final CardLocalDataSource _localDataSource;

  @override
  Future<CardPage> getCardOffers({
    required int page,
    required int size,
    CardFilter filter = CardFilter.empty,
  }) async {
    developer.log(
      'Repository: fetching cards page=$page size=$size filter=${filter.toQueryParameters()}',
      name: 'CardRepository',
    );
    try {
      final results = await Future.wait([
        _remoteDataSource.getCardOffers(page: page, size: size, filter: filter),
        _remoteDataSource.getCreditCardOffers(
          page: page,
          size: size,
          filter: filter,
        ),
      ]);

      final mergedModel = _mergeResponses(results[0], results[1]);

      await _localDataSource.cacheResponse(mergedModel.toJson());
      developer.log(
        'Repository: returning ${mergedModel.content.length} fresh items',
        name: 'CardRepository',
      );
      return mergedModel.toEntity();
    } on AppException catch (error) {
      developer.log(
        'Repository: remote error -> ${error.message}, trying cache',
        name: 'CardRepository',
        error: error,
      );
      final cached = _localDataSource.getLastCachedResponse();
      if (cached != null) {
        return CardOfferPageModel.fromJson(cached).toEntity();
      }
      rethrow;
    }
  }

  CardOfferPageModel _mergeResponses(
    CardOfferPageModel cards,
    CardOfferPageModel creditCards,
  ) {
    return CardOfferPageModel(
      content: [...cards.content, ...creditCards.content],
      totalPages: math.max(cards.totalPages, creditCards.totalPages),
      totalElements: cards.totalElements + creditCards.totalElements,
      number: cards.number,
      size: cards.size,
      first: cards.first && creditCards.first,
      last: cards.last && creditCards.last,
      numberOfElements: cards.numberOfElements + creditCards.numberOfElements,
    );
  }
}
