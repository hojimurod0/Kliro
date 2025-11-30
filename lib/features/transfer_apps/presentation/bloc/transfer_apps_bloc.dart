import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/transfer_app.dart';
import '../../domain/entities/transfer_app_filter.dart';
import '../../domain/usecases/get_transfer_apps.dart';

enum TransferAppsStatus { initial, loading, refreshing, success, failure }

const _kNoError = Object();

class TransferAppsState extends Equatable {
  const TransferAppsState({
    this.status = TransferAppsStatus.initial,
    this.items = const <TransferApp>[],
    this.filter = const TransferAppFilter(
      sort: 'commission',
      direction: 'asc', // Самый низкий процент (комиссия) сверху
    ),
    this.errorMessage,
  });

  final TransferAppsStatus status;
  final List<TransferApp> items;
  final TransferAppFilter filter;
  final String? errorMessage;

  TransferAppsState copyWith({
    TransferAppsStatus? status,
    List<TransferApp>? items,
    TransferAppFilter? filter,
    Object? errorMessage = _kNoError,
  }) {
    return TransferAppsState(
      status: status ?? this.status,
      items: items ?? this.items,
      filter: filter ?? this.filter,
      errorMessage: identical(errorMessage, _kNoError)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, items, filter, errorMessage];
}

abstract class TransferAppsEvent extends Equatable {
  const TransferAppsEvent();

  @override
  List<Object?> get props => [];
}

class TransferAppsStarted extends TransferAppsEvent {
  const TransferAppsStarted();
}

class TransferAppsRefreshed extends TransferAppsEvent {
  const TransferAppsRefreshed();
}

class TransferAppsSearchChanged extends TransferAppsEvent {
  const TransferAppsSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class TransferAppsFilterApplied extends TransferAppsEvent {
  const TransferAppsFilterApplied(this.filter);

  final TransferAppFilter filter;

  @override
  List<Object?> get props => [filter];
}

class TransferAppsBloc extends Bloc<TransferAppsEvent, TransferAppsState> {
  TransferAppsBloc({required GetTransferApps getTransferApps})
      : _getTransferApps = getTransferApps,
        super(const TransferAppsState()) {
    on<TransferAppsStarted>(_onStarted);
    on<TransferAppsRefreshed>(_onRefreshed);
    on<TransferAppsSearchChanged>(_onSearchChanged);
    on<TransferAppsFilterApplied>(_onFilterApplied);
  }

  final GetTransferApps _getTransferApps;

  Future<void> _onStarted(
    TransferAppsStarted event,
    Emitter<TransferAppsState> emit,
  ) async {
    await _loadApps(
      emit,
      filter: state.filter.copyWith(page: 0),
      showFullLoader: true,
    );
  }

  Future<void> _onRefreshed(
    TransferAppsRefreshed event,
    Emitter<TransferAppsState> emit,
  ) async {
    await _loadApps(
      emit,
      filter: state.filter.copyWith(page: 0),
      showFullLoader: false,
    );
  }

  Future<void> _onSearchChanged(
    TransferAppsSearchChanged event,
    Emitter<TransferAppsState> emit,
  ) async {
    final trimmed = event.query.trim();
    final updatedFilter = state.filter.copyWith(
      search: trimmed.isEmpty ? null : trimmed,
      resetSearch: trimmed.isEmpty,
      page: 0,
    );
    await _loadApps(
      emit,
      filter: updatedFilter,
      showFullLoader: true,
    );
  }

  Future<void> _onFilterApplied(
    TransferAppsFilterApplied event,
    Emitter<TransferAppsState> emit,
  ) async {
    await _loadApps(
      emit,
      filter: event.filter.copyWith(page: 0),
      showFullLoader: true,
    );
  }

  Future<void> _loadApps(
    Emitter<TransferAppsState> emit, {
    required TransferAppFilter filter,
    required bool showFullLoader,
  }) async {
    emit(
      state.copyWith(
        status: showFullLoader
            ? TransferAppsStatus.loading
            : TransferAppsStatus.refreshing,
        filter: filter,
        errorMessage: null,
      ),
    );

    try {
      final apps = await _getTransferApps(filter: filter);
      final filtered = _applyLocalFilters(apps, filter);
      final processed = _applyLocalSorting(filtered, filter);
      emit(
        state.copyWith(
          status: TransferAppsStatus.success,
          items: processed,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: TransferAppsStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TransferAppsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}

const _kDefaultSortField = 'commission';
const _kCommissionEpsilon = 0.0001;

List<TransferApp> _applyLocalFilters(
  List<TransferApp> apps,
  TransferAppFilter filter,
) {
  return apps.where((app) {
    final matchesSpeed = _matchesSpeed(app, filter.speed);
    final matchesMethod = _matchesTransferMethod(app, filter.transferMethod);
    final matchesCommission =
        _matchesCommissionRange(app, filter.commissionFrom, filter.commissionTo);
    return matchesSpeed && matchesMethod && matchesCommission;
  }).toList();
}

List<TransferApp> _applyLocalSorting(
  List<TransferApp> apps,
  TransferAppFilter filter,
) {
  final sortField = filter.sort;
  if (sortField == null || sortField.isEmpty) {
    return apps;
  }

  final sorted = List<TransferApp>.from(apps);
  if (sortField == _kDefaultSortField) {
    sorted.sort((a, b) {
      final aValue = _commissionSortValue(a);
      final bValue = _commissionSortValue(b);
      return aValue.compareTo(bValue);
    });
  }

  if ((filter.direction ?? '').toLowerCase() == 'desc') {
    return sorted.reversed.toList();
  }
  return sorted;
}

bool _matchesSpeed(TransferApp app, String? speedFilter) {
  if (speedFilter == null || speedFilter.isEmpty) return true;
  final normalizedFilter = _normalize(speedFilter);
  final speedValue = app.speed?.isNotEmpty == true
      ? app.speed
      : app.displaySpeed;
  final normalizedValue = _normalize(speedValue);
  return normalizedValue.contains(normalizedFilter);
}

bool _matchesTransferMethod(TransferApp app, String? methodFilter) {
  if (methodFilter == null || methodFilter.isEmpty) return true;
  final normalizedFilter = _normalize(methodFilter);
  final channel = _normalize(app.channel);
  if (channel.contains(normalizedFilter)) return true;

  for (final tag in app.tags) {
    if (_normalize(tag).contains(normalizedFilter)) {
      return true;
    }
  }
  return false;
}

bool _matchesCommissionRange(
  TransferApp app,
  double? from,
  double? to,
) {
  if (from == null && to == null) return true;
  final values = _extractCommissionValues(app.commission);
  if (values.isEmpty) return false;
  final value = values.first;

  if (from != null && value + _kCommissionEpsilon < from) return false;
  if (to != null && value - _kCommissionEpsilon > to) return false;
  return true;
}

double _commissionSortValue(TransferApp app) {
  final values = _extractCommissionValues(app.commission);
  if (values.isEmpty) return double.maxFinite;
  return values.first;
}

List<double> _extractCommissionValues(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  final matches = RegExp(r'[\d.,]+').allMatches(raw);
  final values = matches
      .map(
        (match) => double.tryParse(
          match.group(0)!.replaceAll(' ', '').replaceAll(',', '.'),
        ),
      )
      .whereType<double>()
      .toList();
  values.sort();
  return values;
}

String _normalize(String? value) {
  if (value == null) return '';
  return value
      .toLowerCase()
      .replaceAll(RegExp(r"[ '\-_\s]"), '')
      .replaceAll('’', '')
      .trim();
}


