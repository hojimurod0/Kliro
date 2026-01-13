import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/mortgage_entity.dart';
import '../../domain/entities/mortgage_filter.dart';
import '../../domain/usecases/get_mortgage_offers.dart';

part 'mortgage_bloc.freezed.dart';

enum MortgageViewStatus { initial, loading, success, failure }

@freezed
class MortgageEvent with _$MortgageEvent {
  const factory MortgageEvent.started() = MortgageStarted;
  const factory MortgageEvent.refreshRequested({Completer<void>? completer}) =
      MortgageRefreshRequested;
  const factory MortgageEvent.loadMoreRequested() = MortgageLoadMoreRequested;
  const factory MortgageEvent.searchChanged(String query) =
      MortgageSearchChanged;
  const factory MortgageEvent.filterApplied(MortgageFilter filter) =
      MortgageFilterApplied;
  const factory MortgageEvent.pageSizeChanged(int size) =
      MortgagePageSizeChanged;
}

@freezed
class MortgageState with _$MortgageState {
  const factory MortgageState({
    required List<MortgageEntity> items,
    required MortgageFilter filter,
    required MortgageViewStatus status,
    required bool isInitialLoading,
    required bool isPaginating,
    required bool hasMore,
    required int page,
    required int pageSize,
    String? errorMessage,
    String? paginationErrorMessage,
  }) = _MortgageState;

  const MortgageState._();

  factory MortgageState.initial() => MortgageState(
        items: const <MortgageEntity>[],
        filter: MortgageFilter.empty.copyWith(
          sort: 'rate',
          direction: 'asc', // Самый низкий процент сверху
        ),
        status: MortgageViewStatus.initial,
        isInitialLoading: true,
        isPaginating: false,
        hasMore: true,
        page: 0,
        pageSize: 10,
      );
}

class MortgageBloc extends Bloc<MortgageEvent, MortgageState> {
  MortgageBloc({required GetMortgages getMortgages})
      : _getMortgages = getMortgages,
        super(MortgageState.initial()) {
    on<MortgageStarted>(_onStarted);
    on<MortgageRefreshRequested>(_onRefreshRequested);
    on<MortgageLoadMoreRequested>(_onLoadMoreRequested);
    on<MortgageSearchChanged>(_onSearchChanged);
    on<MortgageFilterApplied>(_onFilterApplied);
    on<MortgagePageSizeChanged>(_onPageSizeChanged);
  }

  final GetMortgages _getMortgages;

  Future<void> _onStarted(
    MortgageStarted event,
    Emitter<MortgageState> emit,
  ) async {
    debugPrint('[MortgageBloc] Event: started');
    await _reload(emit, filter: state.filter, showFullScreenLoader: true);
  }

  Future<void> _onRefreshRequested(
    MortgageRefreshRequested event,
    Emitter<MortgageState> emit,
  ) async {
    debugPrint('[MortgageBloc] Event: refreshRequested');
    await _reload(
      emit,
      filter: state.filter,
      completer: event.completer,
      showFullScreenLoader: false,
    );
  }

  Future<void> _onLoadMoreRequested(
    MortgageLoadMoreRequested event,
    Emitter<MortgageState> emit,
  ) async {
    debugPrint('[MortgageBloc] Event: loadMoreRequested');
    if (!state.hasMore || state.isPaginating || state.isInitialLoading) {
      debugPrint(
        '[MortgageBloc] Skipping loadMore (hasMore=${state.hasMore}, '
        'isPaginating=${state.isPaginating}, isInitialLoading=${state.isInitialLoading})',
      );
      return;
    }

    emit(state.copyWith(isPaginating: true, paginationErrorMessage: null));

    final nextPage = state.page + 1;
    await _loadPage(emit: emit, page: nextPage, append: true);
  }

  Future<void> _onSearchChanged(
    MortgageSearchChanged event,
    Emitter<MortgageState> emit,
  ) async {
    debugPrint('[MortgageBloc] Event: searchChanged query="${event.query}"');
    final query = event.query.trim();
    final currentSearch = state.filter.search ?? '';
    if (currentSearch == query) {
      debugPrint('[MortgageBloc] Search query unchanged, skipping reload');
      return;
    }

    final updatedFilter = state.filter.copyWith(
      search: query.isEmpty ? null : query,
      resetSearch: query.isEmpty,
    );
    await _reload(emit, filter: updatedFilter, showFullScreenLoader: true);
  }

  Future<void> _onFilterApplied(
    MortgageFilterApplied event,
    Emitter<MortgageState> emit,
  ) async {
    debugPrint('[MortgageBloc] Event: filterApplied ${event.filter}');
    await _reload(emit, filter: event.filter, showFullScreenLoader: true);
  }

  Future<void> _onPageSizeChanged(
    MortgagePageSizeChanged event,
    Emitter<MortgageState> emit,
  ) async {
    debugPrint('[MortgageBloc] Event: pageSizeChanged size=${event.size}');
    if (event.size == state.pageSize) return;
    await _reload(
      emit,
      filter: state.filter,
      pageSize: event.size,
      showFullScreenLoader: true,
    );
  }

  Future<void> _reload(
    Emitter<MortgageState> emit, {
    required MortgageFilter filter,
    Completer<void>? completer,
    int? pageSize,
    required bool showFullScreenLoader,
  }) async {
    final effectivePageSize = pageSize ?? state.pageSize;
    final preservedItems =
        showFullScreenLoader ? const <MortgageEntity>[] : state.items;
    debugPrint(
      '[MortgageBloc] Reload triggered -> pageSize=$effectivePageSize, '
      'showFullScreenLoader=$showFullScreenLoader, preservedItems=${preservedItems.length}',
    );

    emit(
      state.copyWith(
        filter: filter,
        pageSize: effectivePageSize,
        items: preservedItems,
        page: 0,
        hasMore: true,
        status: MortgageViewStatus.loading,
        isInitialLoading: showFullScreenLoader,
        isPaginating: false,
        errorMessage: null,
        paginationErrorMessage: null,
      ),
    );

    await _loadPage(
      emit: emit,
      page: 0,
      append: false,
      filter: filter,
      completer: completer,
    );
  }

  Future<void> _loadPage({
    required Emitter<MortgageState> emit,
    required int page,
    required bool append,
    MortgageFilter? filter,
    Completer<void>? completer,
  }) async {
    final effectiveFilter = filter ?? state.filter;
    debugPrint(
      '[MortgageBloc] _loadPage page=$page append=$append '
      'filter=${effectiveFilter.toQueryParameters()}',
    );

    try {
      debugPrint('[MortgageBloc] Calling _getMortgages:');
      debugPrint('  - Page: $page');
      debugPrint('  - Size: ${state.pageSize}');
      debugPrint('  - Filter: ${effectiveFilter.toQueryParameters()}');

      final result = await _getMortgages(
        page: page,
        size: state.pageSize,
        filter: effectiveFilter,
      );

      debugPrint('[MortgageBloc] _getMortgages returned:');
      debugPrint('  - Items count: ${result.items.length}');
      debugPrint('  - Page number: ${result.pageNumber}');
      debugPrint('  - Total pages: ${result.totalPages}');
      debugPrint('  - Total elements: ${result.totalElements}');
      debugPrint('  - Is last: ${result.isLast}');

      if (result.items.isNotEmpty) {
        debugPrint(
          '[MortgageBloc] First item: ${result.items.first.bankName} - ${result.items.first.description}',
        );
      }

      debugPrint('[MortgageBloc] Loaded ${result.items.length} items');
      debugPrint(
        '[MortgageBloc] Result page: ${result.pageNumber}, isLast: ${result.isLast}',
      );

      final sortedItems = await _processMortgagesForUi(
        newItems: result.items,
        currentItems: state.items,
        filter: effectiveFilter,
        append: append,
      );

      debugPrint('[MortgageBloc] Updated items list:');
      debugPrint('  - Previous items: ${state.items.length}');
      debugPrint('  - New items: ${result.items.length}');
      debugPrint(
        '  - Total after ${append ? "append" : "replace"}: ${sortedItems.length}',
      );

      debugPrint(
        '[MortgageBloc] Emitting state with ${sortedItems.length} items',
      );
      debugPrint(
        '[MortgageBloc] State before emit: items=${state.items.length}, status=${state.status}',
      );

      final newState = state.copyWith(
        items: sortedItems,
        filter: effectiveFilter,
        page: result.pageNumber,
        hasMore: !result.isLast,
        status: MortgageViewStatus.success,
        isInitialLoading: false,
        isPaginating: false,
        errorMessage: null,
        paginationErrorMessage: null,
      );

      debugPrint(
        '[MortgageBloc] State after copyWith: items=${newState.items.length}, status=${newState.status}',
      );
      debugPrint('[MortgageBloc] Emitting new state...');

      emit(newState);

      debugPrint('[MortgageBloc] State emitted successfully!');
    } catch (error, stackTrace) {
      debugPrint('[MortgageBloc] ERROR loading page:');
      debugPrint('  - Error type: ${error.runtimeType}');
      debugPrint('  - Error message: $error');
      debugPrint('  - Stack trace: $stackTrace');
      debugPrint('[MortgageBloc] Error loading page: $error');
      addError(error, stackTrace);
      final message = _mapError(error);
      if (append) {
        emit(
          state.copyWith(isPaginating: false, paginationErrorMessage: message),
        );
      } else {
        emit(
          state.copyWith(
            status: MortgageViewStatus.failure,
            isInitialLoading: false,
            errorMessage: message,
          ),
        );
      }
    } finally {
      completer?.complete();
      debugPrint(
          '[MortgageBloc] Completed _loadPage page=$page append=$append');
    }
  }

  String _mapError(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return error.toString();
  }
}

Future<List<MortgageEntity>> _processMortgagesForUi({
  required List<MortgageEntity> newItems,
  required List<MortgageEntity> currentItems,
  required MortgageFilter filter,
  required bool append,
}) async {
  final payload = <String, dynamic>{
    'newItems': newItems.map(mortgageEntityToMap).toList(),
    'currentItems': currentItems.map(mortgageEntityToMap).toList(),
    'filter': mortgageFilterToMap(filter),
    'append': append,
  };

  final processed = await compute(_processMortgagesIsolate, payload);
  return processed
      .map<MortgageEntity>(mortgageEntityFromMap)
      .toList(growable: false);
}

List<Map<String, dynamic>> _processMortgagesIsolate(
  Map<String, dynamic> payload,
) {
  final append = payload['append'] as bool;
  final filterMap = (payload['filter'] as Map).cast<String, dynamic>();
  final filter = mortgageFilterFromMap(filterMap);

  final incoming = (payload['newItems'] as List)
      .cast<Map<String, dynamic>>()
      .map(mortgageEntityFromMap)
      .toList();
  final existing = (payload['currentItems'] as List)
      .cast<Map<String, dynamic>>()
      .map(mortgageEntityFromMap)
      .toList();

  final combined = append ? [...existing, ...incoming] : incoming;
  final filtered = _applyMortgageFilters(combined, filter);
  final sorted = _sortMortgageItems(filtered, filter.sort);

  return sorted.map(mortgageEntityToMap).toList();
}

List<MortgageEntity> _sortMortgageItems(
  List<MortgageEntity> items,
  String? sortField,
) {
  if (sortField == null) return items;
  final sorted = [...items];
  int compare(double a, double b) => a.compareTo(b);

  switch (sortField) {
    case 'rate':
    case 'interest_rate':
      sorted.sort(
        (a, b) => compare(
          _extractMortgageNumber(a.interestRate),
          _extractMortgageNumber(b.interestRate),
        ),
      );
      break;
    case 'amount':
    case 'max_sum':
      sorted.sort(
        (a, b) => compare(
          _extractMortgageNumber(a.maxSum),
          _extractMortgageNumber(b.maxSum),
        ),
      );
      break;
    case 'term':
      sorted.sort(
        (a, b) => compare(
          _extractMortgageNumber(a.term),
          _extractMortgageNumber(b.term),
        ),
      );
      break;
  }
  return sorted;
}

List<MortgageEntity> _applyMortgageFilters(
  List<MortgageEntity> items,
  MortgageFilter filter,
) {
  var filtered = items;

  if (filter.interestRateFrom != null || filter.interestRateTo != null) {
    filtered = filtered.where((item) {
      final rateValue = _extractMortgageNumber(item.interestRate);
      final meetsMin = filter.interestRateFrom == null ||
          rateValue >= filter.interestRateFrom!;
      final meetsMax =
          filter.interestRateTo == null || rateValue <= filter.interestRateTo!;
      return meetsMin && meetsMax;
    }).toList();
  }

  if (filter.termMonthsFrom != null || filter.termMonthsTo != null) {
    filtered = filtered.where((item) {
      final termValue = _extractMortgageNumber(item.term);
      final meetsMin =
          filter.termMonthsFrom == null || termValue >= filter.termMonthsFrom!;
      final meetsMax =
          filter.termMonthsTo == null || termValue <= filter.termMonthsTo!;
      return meetsMin && meetsMax;
    }).toList();
  }

  if (filter.maxSumFrom != null || filter.maxSumTo != null) {
    filtered = filtered.where((item) {
      final amountValue = _extractMortgageNumber(item.maxSum);
      final meetsMin =
          filter.maxSumFrom == null || amountValue >= filter.maxSumFrom!;
      final meetsMax =
          filter.maxSumTo == null || amountValue <= filter.maxSumTo!;
      return meetsMin && meetsMax;
    }).toList();
  }

  return filtered;
}

double _extractMortgageNumber(String value) {
  final match = RegExp(r'[\d.,]+').firstMatch(value);
  if (match == null) return double.infinity;
  final normalized = match.group(0)!.replaceAll(' ', '').replaceAll(',', '.');
  return double.tryParse(normalized) ?? double.infinity;
}
