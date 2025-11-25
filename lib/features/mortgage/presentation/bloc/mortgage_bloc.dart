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
  const factory MortgageEvent.searchChanged(String query) = MortgageSearchChanged;
  const factory MortgageEvent.filterApplied(MortgageFilter filter) =
      MortgageFilterApplied;
  const factory MortgageEvent.pageSizeChanged(int size) = MortgagePageSizeChanged;
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
    filter: MortgageFilter.empty,
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
    final preservedItems = showFullScreenLoader
        ? const <MortgageEntity>[]
        : state.items;
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
      print('[MortgageBloc] Calling _getMortgages:');
      print('  - Page: $page');
      print('  - Size: ${state.pageSize}');
      print('  - Filter: ${effectiveFilter.toQueryParameters()}');

      final result = await _getMortgages(
        page: page,
        size: state.pageSize,
        filter: effectiveFilter,
      );

      print('[MortgageBloc] _getMortgages returned:');
      print('  - Items count: ${result.items.length}');
      print('  - Page number: ${result.pageNumber}');
      print('  - Total pages: ${result.totalPages}');
      print('  - Total elements: ${result.totalElements}');
      print('  - Is last: ${result.isLast}');

      if (result.items.isNotEmpty) {
        print(
          '[MortgageBloc] First item: ${result.items.first.bankName} - ${result.items.first.description}',
        );
      }

      debugPrint('[MortgageBloc] Loaded ${result.items.length} items');
      debugPrint(
        '[MortgageBloc] Result page: ${result.pageNumber}, isLast: ${result.isLast}',
      );

      final combinedItems = append
          ? [...state.items, ...result.items]
          : result.items;
      final sortedItems = _sortItems(
        combinedItems,
        effectiveFilter.sort,
      );

      print('[MortgageBloc] Updated items list:');
      print('  - Previous items: ${state.items.length}');
      print('  - New items: ${result.items.length}');
      print(
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
      print('[MortgageBloc] ERROR loading page:');
      print('  - Error type: ${error.runtimeType}');
      print('  - Error message: $error');
      print('  - Stack trace: $stackTrace');
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
      debugPrint('[MortgageBloc] Completed _loadPage page=$page append=$append');
    }
  }

  String _mapError(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return error.toString();
  }

  List<MortgageEntity> _sortItems(
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
            _extractNumber(a.interestRate),
            _extractNumber(b.interestRate),
          ),
        );
        break;
      case 'amount':
      case 'max_sum':
        sorted.sort(
          (a, b) => compare(
            _extractNumber(a.maxSum),
            _extractNumber(b.maxSum),
          ),
        );
        break;
      case 'term':
        sorted.sort(
          (a, b) => compare(
            _extractNumber(a.term),
            _extractNumber(b.term),
          ),
        );
        break;
    }
    return sorted;
  }

  double _extractNumber(String value) {
    final match = RegExp(r'[\d.,]+').firstMatch(value);
    if (match == null) return double.infinity;
    final normalized = match.group(0)!.replaceAll(' ', '').replaceAll(',', '.');
    return double.tryParse(normalized) ?? double.infinity;
  }
}

