import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/deposit_entity.dart';
import '../../domain/entities/deposit_filter.dart';
import '../../domain/usecases/get_deposit_offers.dart';

part 'deposit_bloc.freezed.dart';

enum DepositViewStatus { initial, loading, success, failure }

@freezed
class DepositEvent with _$DepositEvent {
  const factory DepositEvent.started() = DepositStarted;
  const factory DepositEvent.refreshRequested({Completer<void>? completer}) =
      DepositRefreshRequested;
  const factory DepositEvent.loadMoreRequested() = DepositLoadMoreRequested;
  const factory DepositEvent.searchChanged(String query) = DepositSearchChanged;
  const factory DepositEvent.filterApplied(DepositFilter filter) =
      DepositFilterApplied;
  const factory DepositEvent.pageSizeChanged(int size) = DepositPageSizeChanged;
}

@freezed
class DepositState with _$DepositState {
  const factory DepositState({
    required List<DepositEntity> items,
    required DepositFilter filter,
    required DepositViewStatus status,
    required bool isInitialLoading,
    required bool isPaginating,
    required bool hasMore,
    required int page,
    required int pageSize,
    String? errorMessage,
    String? paginationErrorMessage,
  }) = _DepositState;

  const DepositState._();

  factory DepositState.initial() => DepositState(
    items: const <DepositEntity>[],
    filter: DepositFilter.empty.copyWith(
      sort: 'rate',
      direction: 'desc', // Самый высокий процент сверху
    ),
    status: DepositViewStatus.initial,
    isInitialLoading: true,
    isPaginating: false,
    hasMore: true,
    page: 0,
    pageSize: 10,
  );
}

class DepositBloc extends Bloc<DepositEvent, DepositState> {
  DepositBloc({required GetDeposits getDeposits})
    : _getDeposits = getDeposits,
      super(DepositState.initial()) {
    on<DepositStarted>(_onStarted);
    on<DepositRefreshRequested>(_onRefreshRequested);
    on<DepositLoadMoreRequested>(_onLoadMoreRequested);
    on<DepositSearchChanged>(_onSearchChanged);
    on<DepositFilterApplied>(_onFilterApplied);
    on<DepositPageSizeChanged>(_onPageSizeChanged);
  }

  final GetDeposits _getDeposits;

  Future<void> _onStarted(
    DepositStarted event,
    Emitter<DepositState> emit,
  ) async {
    debugPrint('[DepositBloc] Event: started');
    // Гарантируем сортировку по наивысшему проценту сверху
    final defaultFilter = state.filter.copyWith(
      sort: 'rate',
      direction: 'desc',
    );
    await _reload(emit, filter: defaultFilter, showFullScreenLoader: true);
  }

  Future<void> _onRefreshRequested(
    DepositRefreshRequested event,
    Emitter<DepositState> emit,
  ) async {
    debugPrint('[DepositBloc] Event: refreshRequested');
    // Гарантируем сортировку по наивысшему проценту при обновлении
    final filterWithSort = state.filter.copyWith(
      sort: state.filter.sort ?? 'rate',
      direction: state.filter.direction ?? 'desc',
    );
    await _reload(
      emit,
      filter: filterWithSort,
      completer: event.completer,
      showFullScreenLoader: false,
    );
  }

  Future<void> _onLoadMoreRequested(
    DepositLoadMoreRequested event,
    Emitter<DepositState> emit,
  ) async {
    debugPrint('[DepositBloc] Event: loadMoreRequested');
    if (!state.hasMore || state.isPaginating || state.isInitialLoading) {
      debugPrint(
        '[DepositBloc] Skipping loadMore (hasMore=${state.hasMore}, '
        'isPaginating=${state.isPaginating}, isInitialLoading=${state.isInitialLoading})',
      );
      return;
    }

    emit(state.copyWith(isPaginating: true, paginationErrorMessage: null));

    final nextPage = state.page + 1;
    await _loadPage(emit: emit, page: nextPage, append: true);
  }

  Future<void> _onSearchChanged(
    DepositSearchChanged event,
    Emitter<DepositState> emit,
  ) async {
    debugPrint('[DepositBloc] Event: searchChanged query="${event.query}"');
    final query = event.query.trim();
    final currentSearch = state.filter.search ?? '';
    if (currentSearch == query) {
      debugPrint('[DepositBloc] Search query unchanged, skipping reload');
      return;
    }

    // Сохраняем сортировку по наивысшему проценту при поиске
    final updatedFilter = state.filter.copyWith(
      search: query.isEmpty ? null : query,
      resetSearch: query.isEmpty,
      sort: state.filter.sort ?? 'rate',
      direction: state.filter.direction ?? 'desc',
    );
    await _reload(emit, filter: updatedFilter, showFullScreenLoader: true);
  }

  Future<void> _onFilterApplied(
    DepositFilterApplied event,
    Emitter<DepositState> emit,
  ) async {
    debugPrint('[DepositBloc] Event: filterApplied ${event.filter}');
    await _reload(emit, filter: event.filter, showFullScreenLoader: true);
  }

  Future<void> _onPageSizeChanged(
    DepositPageSizeChanged event,
    Emitter<DepositState> emit,
  ) async {
    debugPrint('[DepositBloc] Event: pageSizeChanged size=${event.size}');
    if (event.size == state.pageSize) return;
    await _reload(
      emit,
      filter: state.filter,
      pageSize: event.size,
      showFullScreenLoader: true,
    );
  }

  Future<void> _reload(
    Emitter<DepositState> emit, {
    required DepositFilter filter,
    Completer<void>? completer,
    int? pageSize,
    required bool showFullScreenLoader,
  }) async {
    final effectivePageSize = pageSize ?? state.pageSize;
    final preservedItems = showFullScreenLoader
        ? const <DepositEntity>[]
        : state.items;
    debugPrint(
      '[DepositBloc] Reload triggered -> pageSize=$effectivePageSize, '
      'showFullScreenLoader=$showFullScreenLoader, preservedItems=${preservedItems.length}',
    );

    emit(
      state.copyWith(
        filter: filter,
        pageSize: effectivePageSize,
        items: preservedItems,
        page: 0,
        hasMore: true,
        status: DepositViewStatus.loading,
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
    required Emitter<DepositState> emit,
    required int page,
    required bool append,
    DepositFilter? filter,
    Completer<void>? completer,
  }) async {
    // Гарантируем сортировку по наивысшему проценту
    final baseFilter = filter ?? state.filter;
    final effectiveFilter = baseFilter.copyWith(
      sort: baseFilter.sort ?? 'rate',
      direction: baseFilter.direction ?? 'desc',
    );
    debugPrint(
      '[DepositBloc] _loadPage page=$page append=$append '
      'filter=${effectiveFilter.toQueryParameters()}',
    );

    try {
      debugPrint('[DepositBloc] Calling _getDeposits:');
      debugPrint('  - Page: $page');
      debugPrint('  - Size: ${state.pageSize}');
      debugPrint('  - Filter: ${effectiveFilter.toQueryParameters()}');

      final result = await _getDeposits(
        page: page,
        size: state.pageSize,
        filter: effectiveFilter,
      );

      debugPrint('[DepositBloc] _getDeposits returned:');
      debugPrint('  - Items count: ${result.items.length}');
      debugPrint('  - Page number: ${result.pageNumber}');
      debugPrint('  - Total pages: ${result.totalPages}');
      debugPrint('  - Total elements: ${result.totalElements}');
      debugPrint('  - Is last: ${result.isLast}');

      if (result.items.isNotEmpty) {
        debugPrint(
          '[DepositBloc] First item: ${result.items.first.bankName} - ${result.items.first.description}',
        );
      }

      debugPrint('[DepositBloc] Loaded ${result.items.length} items');
      debugPrint(
        '[DepositBloc] Result page: ${result.pageNumber}, isLast: ${result.isLast}',
      );

      final updatedItems = append
          ? [...state.items, ...result.items]
          : result.items;

      // Клиентская сортировка по проценту (самый высокий процент сверху)
      final sortedItems = _sortByRate(updatedItems, effectiveFilter.direction ?? 'desc');

      debugPrint('[DepositBloc] Updated items list:');
      debugPrint('  - Previous items: ${state.items.length}');
      debugPrint('  - New items: ${result.items.length}');
      debugPrint(
        '  - Total after ${append ? "append" : "replace"}: ${sortedItems.length}',
      );

      debugPrint(
        '[DepositBloc] Emitting state with ${sortedItems.length} items',
      );
      debugPrint(
        '[DepositBloc] State before emit: items=${state.items.length}, status=${state.status}',
      );

      final newState = state.copyWith(
        items: sortedItems,
        filter: effectiveFilter,
        page: result.pageNumber,
        hasMore: !result.isLast,
        status: DepositViewStatus.success,
        isInitialLoading: false,
        isPaginating: false,
        errorMessage: null,
        paginationErrorMessage: null,
      );

      debugPrint(
        '[DepositBloc] State after copyWith: items=${newState.items.length}, status=${newState.status}',
      );
      debugPrint('[DepositBloc] Emitting new state...');

      emit(newState);

      debugPrint('[DepositBloc] State emitted successfully!');
    } catch (error, stackTrace) {
      debugPrint('[DepositBloc] ERROR loading page:');
      debugPrint('  - Error type: ${error.runtimeType}');
      debugPrint('  - Error message: $error');
      debugPrint('  - Stack trace: $stackTrace');
      debugPrint('[DepositBloc] Error loading page: $error');
      addError(error, stackTrace);
      final message = _mapError(error);
      if (append) {
        emit(
          state.copyWith(isPaginating: false, paginationErrorMessage: message),
        );
      } else {
        emit(
          state.copyWith(
            status: DepositViewStatus.failure,
            isInitialLoading: false,
            errorMessage: message,
          ),
        );
      }
    } finally {
      completer?.complete();
      debugPrint('[DepositBloc] Completed _loadPage page=$page append=$append');
    }
  }

  String _mapError(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return error.toString();
  }

  /// Сортирует депозиты по проценту (rate)
  /// direction: 'desc' - самый высокий процент сверху, 'asc' - самый низкий процент сверху
  List<DepositEntity> _sortByRate(List<DepositEntity> items, String direction) {
    final sorted = List<DepositEntity>.from(items);
    sorted.sort((a, b) {
      // Парсим строку rate в число, удаляя символы % и пробелы
      final aRate = _parseRate(a.rate);
      final bRate = _parseRate(b.rate);
      final comparison = aRate.compareTo(bRate);
      // Если direction == 'asc', возвращаем comparison (низкий -> высокий)
      // Если direction == 'desc', возвращаем -comparison (высокий -> низкий)
      return direction.toLowerCase() == 'desc' ? -comparison : comparison;
    });
    return sorted;
  }

  /// Парсит строку процента в число
  double _parseRate(String rate) {
    try {
      // Удаляем все символы кроме цифр, точки и запятой
      final cleaned = rate.replaceAll(RegExp(r'[^\d.,]'), '').replaceAll(',', '.');
      return double.tryParse(cleaned) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}
