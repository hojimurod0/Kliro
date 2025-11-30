import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/card_filter.dart';
import '../../domain/entities/card_offer.dart';
import '../../domain/usecases/get_card_offers.dart';

part 'card_bloc.freezed.dart';

enum CardViewStatus { initial, loading, success, failure }

@freezed
class CardEvent with _$CardEvent {
  const factory CardEvent.started() = CardStarted;
  const factory CardEvent.searchChanged(String query) = CardSearchChanged;
  const factory CardEvent.filterApplied(CardFilter filter) = CardFilterApplied;
  const factory CardEvent.refreshRequested({Completer<void>? completer}) =
      CardRefreshRequested;
  const factory CardEvent.loadMoreRequested() = CardLoadMoreRequested;
  const factory CardEvent.pageSizeChanged(int size) = CardPageSizeChanged;
  const factory CardEvent.networkChanged(String? network) = CardNetworkChanged;
}

@freezed
class CardState with _$CardState {
  const factory CardState({
    required List<CardOffer> items,
    required List<CardOffer> visibleItems,
    required CardFilter filter,
    required CardViewStatus status,
    required bool isInitialLoading,
    required bool isPaginating,
    required bool hasMore,
    required int page,
    required int pageSize,
    String? selectedNetwork,
    String? errorMessage,
    String? paginationErrorMessage,
  }) = _CardState;

  const CardState._();

  factory CardState.initial() => CardState(
    items: const <CardOffer>[],
    visibleItems: const <CardOffer>[],
    filter: CardFilter.empty.copyWith(
      sort: 'service_fee',
      direction: 'asc', // Самый низкий процент (комиссия) сверху
    ),
    status: CardViewStatus.initial,
    isInitialLoading: true,
    isPaginating: false,
    hasMore: true,
    page: 0,
    pageSize: 10,
    selectedNetwork: null,
  );
}

class CardBloc extends Bloc<CardEvent, CardState> {
  CardBloc({required GetCardOffers getCardOffers})
    : _getCardOffers = getCardOffers,
      super(CardState.initial()) {
    on<CardStarted>(_onStarted);
    on<CardSearchChanged>(_onSearchChanged);
    on<CardFilterApplied>(_onFilterApplied);
    on<CardRefreshRequested>(_onRefreshRequested);
    on<CardLoadMoreRequested>(_onLoadMoreRequested);
    on<CardPageSizeChanged>(_onPageSizeChanged);
    on<CardNetworkChanged>(_onNetworkChanged);
  }

  final GetCardOffers _getCardOffers;

  Future<void> _onStarted(CardStarted event, Emitter<CardState> emit) async {
    // Сортировка по комиссии по умолчанию (самый низкий процент сверху)
    final defaultFilter = CardFilter.empty.copyWith(
      sort: 'service_fee',
      direction: 'asc', // Самый низкий процент (комиссия) сверху
    );
    await _reload(emit, filter: defaultFilter, showFullScreenLoader: true);
  }

  Future<void> _onSearchChanged(
    CardSearchChanged event,
    Emitter<CardState> emit,
  ) async {
    final query = event.query.trim();
    if ((state.filter.search ?? '') == query) return;
    final updated = state.filter.copyWith(
      search: query.isEmpty ? null : query,
      resetSearch: query.isEmpty,
    );
    await _reload(emit, filter: updated, showFullScreenLoader: true);
  }

  Future<void> _onFilterApplied(
    CardFilterApplied event,
    Emitter<CardState> emit,
  ) async {
    // Tab tanlansa, faqat pastdagi ro'yxat yangilanishi kerak, full screen loader yo'q
    await _reload(emit, filter: event.filter, showFullScreenLoader: false);
  }

  Future<void> _onRefreshRequested(
    CardRefreshRequested event,
    Emitter<CardState> emit,
  ) async {
    await _reload(
      emit,
      filter: state.filter,
      showFullScreenLoader: false,
      completer: event.completer,
    );
  }

  Future<void> _onLoadMoreRequested(
    CardLoadMoreRequested event,
    Emitter<CardState> emit,
  ) async {
    if (!state.hasMore || state.isPaginating || state.isInitialLoading) {
      return;
    }
    emit(state.copyWith(isPaginating: true, paginationErrorMessage: null));
    final nextPage = state.page + 1;
    await _loadPage(emit: emit, page: nextPage, append: true);
  }

  Future<void> _onPageSizeChanged(
    CardPageSizeChanged event,
    Emitter<CardState> emit,
  ) async {
    if (event.size == state.pageSize) return;
    await _reload(
      emit,
      filter: state.filter,
      pageSize: event.size,
      showFullScreenLoader: true,
    );
  }

  Future<void> _reload(
    Emitter<CardState> emit, {
    required CardFilter filter,
    Completer<void>? completer,
    int? pageSize,
    required bool showFullScreenLoader,
  }) async {
    final effectivePageSize = pageSize ?? state.pageSize;
    // showFullScreenLoader false bo'lsa, eski kartalarni saqlaymiz
    final preservedItems = showFullScreenLoader
        ? const <CardOffer>[]
        : state.items;

    // Loading holatida ham eski kartalarni ko'rsatamiz
    // Lekin status loading bo'lishi kerak, shunda UI yangilanadi
    emit(
      state.copyWith(
        filter: filter,
        pageSize: effectivePageSize,
        items: preservedItems,
        visibleItems: _applyBankFilter(
          _applyNetworkFilter(
            preservedItems,
            state.selectedNetwork,
          ),
          filter.bank,
        ),
        page: 0,
        hasMore: true,
        status: CardViewStatus.loading, // Har doim loading, shunda UI yangilanadi
        isInitialLoading: showFullScreenLoader,
        isPaginating: false,
        errorMessage: null,
        paginationErrorMessage: null,
      ),
    );

    // showFullScreenLoader false bo'lsa, background'da yangilaymiz
    await _loadPage(
      emit: emit,
      page: 0,
      append: false,
      filter: filter,
      completer: completer,
    );
  }

  Future<void> _onNetworkChanged(
    CardNetworkChanged event,
    Emitter<CardState> emit,
  ) async {
    final networkFiltered = _applyNetworkFilter(state.items, event.network);
    final bankFiltered = _applyBankFilter(networkFiltered, state.filter.bank);
    emit(
      state.copyWith(
        selectedNetwork: event.network,
        visibleItems: bankFiltered,
      ),
    );
  }

  Future<void> _loadPage({
    required Emitter<CardState> emit,
    required int page,
    required bool append,
    CardFilter? filter,
    Completer<void>? completer,
  }) async {
    final effectiveFilter = filter ?? state.filter;
    try {
      final result = await _getCardOffers(
        page: page,
        size: state.pageSize,
        filter: effectiveFilter,
      );

      final merged = append ? [...state.items, ...result.items] : result.items;
      // Avval network filter, keyin bank filter
      final networkFiltered = _applyNetworkFilter(merged, state.selectedNetwork);
      final bankFiltered = _applyBankFilter(networkFiltered, effectiveFilter.bank);

      emit(
        state.copyWith(
          items: merged,
          visibleItems: bankFiltered,
          filter: effectiveFilter,
          page: result.pageNumber,
          hasMore: !result.isLast,
          status: CardViewStatus.success,
          isInitialLoading: false,
          isPaginating: false,
          errorMessage: null,
          paginationErrorMessage: null,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      final message = _mapError(error);
      if (append) {
        emit(
          state.copyWith(isPaginating: false, paginationErrorMessage: message),
        );
      } else {
        emit(
          state.copyWith(
            status: CardViewStatus.failure,
            isInitialLoading: false,
            errorMessage: message,
          ),
        );
      }
    } finally {
      completer?.complete();
    }
  }

  String _mapError(Object error) {
    if (error is AppException) return error.message;
    return error.toString();
  }

  List<CardOffer> _applyNetworkFilter(
    List<CardOffer> items,
    String? selectedNetwork,
  ) {
    final normalizedNetwork = selectedNetwork?.toLowerCase().trim();
    final filtered = normalizedNetwork == null || normalizedNetwork.isEmpty
        ? items
        : items.where((offer) {
            final network = _normalizeNetwork(offer);
            return network == normalizedNetwork;
          }).toList();

    return filtered;
  }

  List<CardOffer> _applyBankFilter(
    List<CardOffer> items,
    String? selectedBank,
  ) {
    if (selectedBank == null || selectedBank.trim().isEmpty) {
      return _sortCards(items);
    }
    
    final normalizedBank = selectedBank.trim().toLowerCase();
    final filtered = items.where((offer) {
      final offerBank = offer.bankName.trim().toLowerCase();
      return offerBank == normalizedBank;
    }).toList();

    return _sortCards(filtered);
  }

  List<CardOffer> _sortCards(List<CardOffer> items) {
    const order = ['uzcard', 'humo', 'visa', 'mastercard', 'unionpay'];
    final maxIndex = order.length;
    final sorted = [...items];
    sorted.sort((a, b) {
      final aNetwork = _normalizeNetwork(a);
      final bNetwork = _normalizeNetwork(b);
      final aIndex = order.indexOf(aNetwork);
      final bIndex = order.indexOf(bNetwork);
      final left = aIndex == -1 ? maxIndex : aIndex;
      final right = bIndex == -1 ? maxIndex : bIndex;
      if (left != right) return left.compareTo(right);

      final aBank = (a.bankName).toLowerCase();
      final bBank = (b.bankName).toLowerCase();
      final bankComparison = aBank.compareTo(bBank);
      if (bankComparison != 0) return bankComparison;

      final aRating = a.rating ?? 0;
      final bRating = b.rating ?? 0;
      return bRating.compareTo(aRating);
    });
    return sorted;
  }

  String _normalizeNetwork(CardOffer offer) =>
      (offer.cardNetwork ?? offer.cardType ?? offer.cardCategory ?? '')
          .toLowerCase()
          .trim();
}
