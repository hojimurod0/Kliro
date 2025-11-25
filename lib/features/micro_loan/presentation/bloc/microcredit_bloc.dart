import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/microcredit_entity.dart';
import '../../domain/entities/microcredit_filter.dart';
import '../../domain/usecases/get_microcredits.dart';

part 'microcredit_bloc.freezed.dart';

enum MicrocreditViewStatus { initial, loading, success, failure }

@freezed
class MicrocreditEvent with _$MicrocreditEvent {
  const factory MicrocreditEvent.started() = MicrocreditStarted;
  const factory MicrocreditEvent.refreshRequested({
    Completer<void>? completer,
  }) = MicrocreditRefreshRequested;
  const factory MicrocreditEvent.loadMoreRequested() =
      MicrocreditLoadMoreRequested;
  const factory MicrocreditEvent.searchChanged(String query) =
      MicrocreditSearchChanged;
  const factory MicrocreditEvent.filterApplied(MicrocreditFilter filter) =
      MicrocreditFilterApplied;
  const factory MicrocreditEvent.pageSizeChanged(int size) =
      MicrocreditPageSizeChanged;
}

@freezed
class MicrocreditState with _$MicrocreditState {
  const factory MicrocreditState({
    required List<MicrocreditEntity> items,
    required MicrocreditFilter filter,
    required MicrocreditViewStatus status,
    required bool isInitialLoading,
    required bool isPaginating,
    required bool hasMore,
    required int page,
    required int pageSize,
    String? errorMessage,
    String? paginationErrorMessage,
  }) = _MicrocreditState;

  const MicrocreditState._();

  factory MicrocreditState.initial() => MicrocreditState(
    items: const <MicrocreditEntity>[],
    filter: MicrocreditFilter.empty,
    status: MicrocreditViewStatus.initial,
    isInitialLoading: true,
    isPaginating: false,
    hasMore: true,
    page: 0,
    pageSize: 10,
  );
}

class MicrocreditBloc extends Bloc<MicrocreditEvent, MicrocreditState> {
  MicrocreditBloc({required GetMicrocredits getMicrocredits})
    : _getMicrocredits = getMicrocredits,
      super(MicrocreditState.initial()) {
    on<MicrocreditStarted>(_onStarted);
    on<MicrocreditRefreshRequested>(_onRefreshRequested);
    on<MicrocreditLoadMoreRequested>(_onLoadMoreRequested);
    on<MicrocreditSearchChanged>(_onSearchChanged);
    on<MicrocreditFilterApplied>(_onFilterApplied);
    on<MicrocreditPageSizeChanged>(_onPageSizeChanged);
  }

  final GetMicrocredits _getMicrocredits;

  Future<void> _onStarted(
    MicrocreditStarted event,
    Emitter<MicrocreditState> emit,
  ) async {
    debugPrint('[MicrocreditBloc] Event: started');
    await _reload(emit, filter: state.filter, showFullScreenLoader: true);
  }

  Future<void> _onRefreshRequested(
    MicrocreditRefreshRequested event,
    Emitter<MicrocreditState> emit,
  ) async {
    debugPrint('[MicrocreditBloc] Event: refreshRequested');
    await _reload(
      emit,
      filter: state.filter,
      completer: event.completer,
      showFullScreenLoader: false,
    );
  }

  Future<void> _onLoadMoreRequested(
    MicrocreditLoadMoreRequested event,
    Emitter<MicrocreditState> emit,
  ) async {
    debugPrint('[MicrocreditBloc] Event: loadMoreRequested');
    if (!state.hasMore || state.isPaginating || state.isInitialLoading) {
      debugPrint(
        '[MicrocreditBloc] Skipping loadMore (hasMore=${state.hasMore}, '
        'isPaginating=${state.isPaginating}, isInitialLoading=${state.isInitialLoading})',
      );
      return;
    }

    emit(state.copyWith(isPaginating: true, paginationErrorMessage: null));

    final nextPage = state.page + 1;
    await _loadPage(emit: emit, page: nextPage, append: true);
  }

  Future<void> _onSearchChanged(
    MicrocreditSearchChanged event,
    Emitter<MicrocreditState> emit,
  ) async {
    debugPrint('[MicrocreditBloc] Event: searchChanged query="${event.query}"');
    final query = event.query.trim();
    final currentSearch = state.filter.search ?? '';
    if (currentSearch == query) {
      debugPrint('[MicrocreditBloc] Search query unchanged, skipping reload');
      return;
    }

    final updatedFilter = state.filter.copyWith(
      search: query.isEmpty ? null : query,
      resetSearch: query.isEmpty,
    );
    await _reload(emit, filter: updatedFilter, showFullScreenLoader: true);
  }

  Future<void> _onFilterApplied(
    MicrocreditFilterApplied event,
    Emitter<MicrocreditState> emit,
  ) async {
    debugPrint('[MicrocreditBloc] Event: filterApplied ${event.filter}');
    await _reload(emit, filter: event.filter, showFullScreenLoader: true);
  }

  Future<void> _onPageSizeChanged(
    MicrocreditPageSizeChanged event,
    Emitter<MicrocreditState> emit,
  ) async {
    debugPrint('[MicrocreditBloc] Event: pageSizeChanged size=${event.size}');
    if (event.size == state.pageSize) return;
    await _reload(
      emit,
      filter: state.filter,
      pageSize: event.size,
      showFullScreenLoader: true,
    );
  }

  Future<void> _reload(
    Emitter<MicrocreditState> emit, {
    required MicrocreditFilter filter,
    Completer<void>? completer,
    int? pageSize,
    required bool showFullScreenLoader,
  }) async {
    final effectivePageSize = pageSize ?? state.pageSize;
    final preservedItems = showFullScreenLoader
        ? const <MicrocreditEntity>[]
        : state.items;
    debugPrint(
      '[MicrocreditBloc] Reload triggered -> pageSize=$effectivePageSize, '
      'showFullScreenLoader=$showFullScreenLoader, preservedItems=${preservedItems.length}',
    );

    emit(
      state.copyWith(
        filter: filter,
        pageSize: effectivePageSize,
        items: preservedItems,
        page: 0,
        hasMore: true,
        status: MicrocreditViewStatus.loading,
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
    required Emitter<MicrocreditState> emit,
    required int page,
    required bool append,
    MicrocreditFilter? filter,
    Completer<void>? completer,
  }) async {
    final effectiveFilter = filter ?? state.filter;
    debugPrint(
      '[MicrocreditBloc] _loadPage page=$page append=$append '
      'filter=${effectiveFilter.toQueryParameters()}',
    );

    try {
      print('[MicrocreditBloc] Calling _getMicrocredits:');
      print('  - Page: $page');
      print('  - Size: ${state.pageSize}');
      print('  - Filter: ${effectiveFilter.toQueryParameters()}');

      final result = await _getMicrocredits(
        page: page,
        size: state.pageSize,
        filter: effectiveFilter,
      );

      print('[MicrocreditBloc] _getMicrocredits returned:');
      print('  - Items count: ${result.items.length}');
      print('  - Page number: ${result.pageNumber}');
      print('  - Total pages: ${result.totalPages}');
      print('  - Total elements: ${result.totalElements}');
      print('  - Is last: ${result.isLast}');

      if (result.items.isNotEmpty) {
        print(
          '[MicrocreditBloc] First item: ${result.items.first.bankName} - ${result.items.first.description}',
        );
      }

      debugPrint('[MicrocreditBloc] Loaded ${result.items.length} items');
      debugPrint(
        '[MicrocreditBloc] Result page: ${result.pageNumber}, isLast: ${result.isLast}',
      );

      final mergedItems = append
          ? [...state.items, ...result.items]
          : result.items;
      final orderedItems = _applySort(mergedItems, effectiveFilter);

      print('[MicrocreditBloc] Updated items list:');
      print('  - Previous items: ${state.items.length}');
      print('  - New items: ${result.items.length}');
      print(
        '  - Total after ${append ? "append" : "replace"}: ${orderedItems.length}',
      );

      debugPrint(
        '[MicrocreditBloc] Emitting state with ${orderedItems.length} items',
      );
      debugPrint(
        '[MicrocreditBloc] State before emit: items=${state.items.length}, status=${state.status}',
      );

      final newState = state.copyWith(
        items: orderedItems,
        filter: effectiveFilter,
        page: result.pageNumber,
        hasMore: !result.isLast,
        status: MicrocreditViewStatus.success,
        isInitialLoading: false,
        isPaginating: false,
        errorMessage: null,
        paginationErrorMessage: null,
      );

      debugPrint(
        '[MicrocreditBloc] State after copyWith: items=${newState.items.length}, status=${newState.status}',
      );
      debugPrint('[MicrocreditBloc] Emitting new state...');

      emit(newState);

      debugPrint('[MicrocreditBloc] State emitted successfully!');
    } catch (error, stackTrace) {
      print('[MicrocreditBloc] ERROR loading page:');
      print('  - Error type: ${error.runtimeType}');
      print('  - Error message: $error');
      print('  - Stack trace: $stackTrace');
      debugPrint('[MicrocreditBloc] Error loading page: $error');
      addError(error, stackTrace);
      final message = _mapError(error);
      if (append) {
        emit(
          state.copyWith(isPaginating: false, paginationErrorMessage: message),
        );
      } else {
        emit(
          state.copyWith(
            status: MicrocreditViewStatus.failure,
            isInitialLoading: false,
            errorMessage: message,
          ),
        );
      }
    } finally {
      completer?.complete();
      debugPrint(
        '[MicrocreditBloc] Completed _loadPage page=$page append=$append',
      );
    }
  }

  String _mapError(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return error.toString();
  }

  List<MicrocreditEntity> _applySort(
    List<MicrocreditEntity> items,
    MicrocreditFilter filter,
  ) {
    final sortField = filter.sort;
    if (sortField == null) return items;
    final direction = filter.direction ?? 'asc';
    final sorted = [...items];
    sorted.sort((a, b) {
      final aVal = _sortValue(a, sortField);
      final bVal = _sortValue(b, sortField);
      final comparison = aVal.compareTo(bVal);
      return direction == 'asc' ? comparison : -comparison;
    });
    return sorted;
  }

  double _sortValue(MicrocreditEntity item, String field) {
    switch (field) {
      case 'rate':
        return _extractNumber(item.rate);
      case 'amount':
        return _extractNumber(item.amount);
      case 'term':
        return _extractNumber(item.term);
      default:
        return 0;
    }
  }

  double _extractNumber(String value) {
    final buffer = StringBuffer();
    bool started = false;
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      if (_isDigit(char)) {
        buffer.write(char);
        started = true;
        continue;
      }
      if (started && (char == ' ' || char == '\u00A0')) {
        // Skip spacing inside number (e.g., "50 000")
        continue;
      }
      if (!started && (char == ' ' || char == '\u00A0')) {
        // Ignore leading spaces before number
        continue;
      }
      if (started && (char == ',' || char == '.')) {
        buffer.write('.');
        continue;
      }
      if (!started && (char == ',' || char == '.')) {
        // ignore punctuation before number starts
        continue;
      }
      // We reached a non-numeric character after starting -> stop parsing
      if (started) break;
    }

    final normalized = buffer.toString().replaceAll(' ', '');
    if (normalized.isEmpty) {
      // fallback: try to find first numeric chunk with regex
      final match = RegExp(r'(\d+)').firstMatch(value);
      if (match != null) {
        return double.tryParse(match.group(0)!) ?? 0;
      }
      return 0;
    }
    return double.tryParse(normalized) ?? 0;
  }

  bool _isDigit(String char) => char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
}
