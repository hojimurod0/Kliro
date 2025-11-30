// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CardEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String query) searchChanged,
    required TResult Function(CardFilter filter) filterApplied,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(int size) pageSizeChanged,
    required TResult Function(String? network) networkChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String query)? searchChanged,
    TResult? Function(CardFilter filter)? filterApplied,
    TResult? Function(Completer<void>? completer)? refreshRequested,
    TResult? Function()? loadMoreRequested,
    TResult? Function(int size)? pageSizeChanged,
    TResult? Function(String? network)? networkChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String query)? searchChanged,
    TResult Function(CardFilter filter)? filterApplied,
    TResult Function(Completer<void>? completer)? refreshRequested,
    TResult Function()? loadMoreRequested,
    TResult Function(int size)? pageSizeChanged,
    TResult Function(String? network)? networkChanged,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CardStarted value) started,
    required TResult Function(CardSearchChanged value) searchChanged,
    required TResult Function(CardFilterApplied value) filterApplied,
    required TResult Function(CardRefreshRequested value) refreshRequested,
    required TResult Function(CardLoadMoreRequested value) loadMoreRequested,
    required TResult Function(CardPageSizeChanged value) pageSizeChanged,
    required TResult Function(CardNetworkChanged value) networkChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CardStarted value)? started,
    TResult? Function(CardSearchChanged value)? searchChanged,
    TResult? Function(CardFilterApplied value)? filterApplied,
    TResult? Function(CardRefreshRequested value)? refreshRequested,
    TResult? Function(CardLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(CardPageSizeChanged value)? pageSizeChanged,
    TResult? Function(CardNetworkChanged value)? networkChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CardStarted value)? started,
    TResult Function(CardSearchChanged value)? searchChanged,
    TResult Function(CardFilterApplied value)? filterApplied,
    TResult Function(CardRefreshRequested value)? refreshRequested,
    TResult Function(CardLoadMoreRequested value)? loadMoreRequested,
    TResult Function(CardPageSizeChanged value)? pageSizeChanged,
    TResult Function(CardNetworkChanged value)? networkChanged,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CardEventCopyWith<$Res> {
  factory $CardEventCopyWith(CardEvent value, $Res Function(CardEvent) then) =
      _$CardEventCopyWithImpl<$Res, CardEvent>;
}

/// @nodoc
class _$CardEventCopyWithImpl<$Res, $Val extends CardEvent>
    implements $CardEventCopyWith<$Res> {
  _$CardEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$CardStartedImplCopyWith<$Res> {
  factory _$$CardStartedImplCopyWith(
          _$CardStartedImpl value, $Res Function(_$CardStartedImpl) then) =
      __$$CardStartedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CardStartedImplCopyWithImpl<$Res>
    extends _$CardEventCopyWithImpl<$Res, _$CardStartedImpl>
    implements _$$CardStartedImplCopyWith<$Res> {
  __$$CardStartedImplCopyWithImpl(
      _$CardStartedImpl _value, $Res Function(_$CardStartedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$CardStartedImpl implements CardStarted {
  const _$CardStartedImpl();

  @override
  String toString() {
    return 'CardEvent.started()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$CardStartedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String query) searchChanged,
    required TResult Function(CardFilter filter) filterApplied,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(int size) pageSizeChanged,
    required TResult Function(String? network) networkChanged,
  }) {
    return started();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String query)? searchChanged,
    TResult? Function(CardFilter filter)? filterApplied,
    TResult? Function(Completer<void>? completer)? refreshRequested,
    TResult? Function()? loadMoreRequested,
    TResult? Function(int size)? pageSizeChanged,
    TResult? Function(String? network)? networkChanged,
  }) {
    return started?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String query)? searchChanged,
    TResult Function(CardFilter filter)? filterApplied,
    TResult Function(Completer<void>? completer)? refreshRequested,
    TResult Function()? loadMoreRequested,
    TResult Function(int size)? pageSizeChanged,
    TResult Function(String? network)? networkChanged,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CardStarted value) started,
    required TResult Function(CardSearchChanged value) searchChanged,
    required TResult Function(CardFilterApplied value) filterApplied,
    required TResult Function(CardRefreshRequested value) refreshRequested,
    required TResult Function(CardLoadMoreRequested value) loadMoreRequested,
    required TResult Function(CardPageSizeChanged value) pageSizeChanged,
    required TResult Function(CardNetworkChanged value) networkChanged,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CardStarted value)? started,
    TResult? Function(CardSearchChanged value)? searchChanged,
    TResult? Function(CardFilterApplied value)? filterApplied,
    TResult? Function(CardRefreshRequested value)? refreshRequested,
    TResult? Function(CardLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(CardPageSizeChanged value)? pageSizeChanged,
    TResult? Function(CardNetworkChanged value)? networkChanged,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CardStarted value)? started,
    TResult Function(CardSearchChanged value)? searchChanged,
    TResult Function(CardFilterApplied value)? filterApplied,
    TResult Function(CardRefreshRequested value)? refreshRequested,
    TResult Function(CardLoadMoreRequested value)? loadMoreRequested,
    TResult Function(CardPageSizeChanged value)? pageSizeChanged,
    TResult Function(CardNetworkChanged value)? networkChanged,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class CardStarted implements CardEvent {
  const factory CardStarted() = _$CardStartedImpl;
}

/// @nodoc
abstract class _$$CardSearchChangedImplCopyWith<$Res> {
  factory _$$CardSearchChangedImplCopyWith(_$CardSearchChangedImpl value,
          $Res Function(_$CardSearchChangedImpl) then) =
      __$$CardSearchChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String query});
}

/// @nodoc
class __$$CardSearchChangedImplCopyWithImpl<$Res>
    extends _$CardEventCopyWithImpl<$Res, _$CardSearchChangedImpl>
    implements _$$CardSearchChangedImplCopyWith<$Res> {
  __$$CardSearchChangedImplCopyWithImpl(_$CardSearchChangedImpl _value,
      $Res Function(_$CardSearchChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
  }) {
    return _then(_$CardSearchChangedImpl(
      null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CardSearchChangedImpl implements CardSearchChanged {
  const _$CardSearchChangedImpl(this.query);

  @override
  final String query;

  @override
  String toString() {
    return 'CardEvent.searchChanged(query: $query)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardSearchChangedImpl &&
            (identical(other.query, query) || other.query == query));
  }

  @override
  int get hashCode => Object.hash(runtimeType, query);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CardSearchChangedImplCopyWith<_$CardSearchChangedImpl> get copyWith =>
      __$$CardSearchChangedImplCopyWithImpl<_$CardSearchChangedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String query) searchChanged,
    required TResult Function(CardFilter filter) filterApplied,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(int size) pageSizeChanged,
    required TResult Function(String? network) networkChanged,
  }) {
    return searchChanged(query);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String query)? searchChanged,
    TResult? Function(CardFilter filter)? filterApplied,
    TResult? Function(Completer<void>? completer)? refreshRequested,
    TResult? Function()? loadMoreRequested,
    TResult? Function(int size)? pageSizeChanged,
    TResult? Function(String? network)? networkChanged,
  }) {
    return searchChanged?.call(query);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String query)? searchChanged,
    TResult Function(CardFilter filter)? filterApplied,
    TResult Function(Completer<void>? completer)? refreshRequested,
    TResult Function()? loadMoreRequested,
    TResult Function(int size)? pageSizeChanged,
    TResult Function(String? network)? networkChanged,
    required TResult orElse(),
  }) {
    if (searchChanged != null) {
      return searchChanged(query);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CardStarted value) started,
    required TResult Function(CardSearchChanged value) searchChanged,
    required TResult Function(CardFilterApplied value) filterApplied,
    required TResult Function(CardRefreshRequested value) refreshRequested,
    required TResult Function(CardLoadMoreRequested value) loadMoreRequested,
    required TResult Function(CardPageSizeChanged value) pageSizeChanged,
    required TResult Function(CardNetworkChanged value) networkChanged,
  }) {
    return searchChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CardStarted value)? started,
    TResult? Function(CardSearchChanged value)? searchChanged,
    TResult? Function(CardFilterApplied value)? filterApplied,
    TResult? Function(CardRefreshRequested value)? refreshRequested,
    TResult? Function(CardLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(CardPageSizeChanged value)? pageSizeChanged,
    TResult? Function(CardNetworkChanged value)? networkChanged,
  }) {
    return searchChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CardStarted value)? started,
    TResult Function(CardSearchChanged value)? searchChanged,
    TResult Function(CardFilterApplied value)? filterApplied,
    TResult Function(CardRefreshRequested value)? refreshRequested,
    TResult Function(CardLoadMoreRequested value)? loadMoreRequested,
    TResult Function(CardPageSizeChanged value)? pageSizeChanged,
    TResult Function(CardNetworkChanged value)? networkChanged,
    required TResult orElse(),
  }) {
    if (searchChanged != null) {
      return searchChanged(this);
    }
    return orElse();
  }
}

abstract class CardSearchChanged implements CardEvent {
  const factory CardSearchChanged(final String query) = _$CardSearchChangedImpl;

  String get query;
  @JsonKey(ignore: true)
  _$$CardSearchChangedImplCopyWith<_$CardSearchChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CardFilterAppliedImplCopyWith<$Res> {
  factory _$$CardFilterAppliedImplCopyWith(_$CardFilterAppliedImpl value,
          $Res Function(_$CardFilterAppliedImpl) then) =
      __$$CardFilterAppliedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({CardFilter filter});
}

/// @nodoc
class __$$CardFilterAppliedImplCopyWithImpl<$Res>
    extends _$CardEventCopyWithImpl<$Res, _$CardFilterAppliedImpl>
    implements _$$CardFilterAppliedImplCopyWith<$Res> {
  __$$CardFilterAppliedImplCopyWithImpl(_$CardFilterAppliedImpl _value,
      $Res Function(_$CardFilterAppliedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filter = null,
  }) {
    return _then(_$CardFilterAppliedImpl(
      null == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as CardFilter,
    ));
  }
}

/// @nodoc

class _$CardFilterAppliedImpl implements CardFilterApplied {
  const _$CardFilterAppliedImpl(this.filter);

  @override
  final CardFilter filter;

  @override
  String toString() {
    return 'CardEvent.filterApplied(filter: $filter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardFilterAppliedImpl &&
            (identical(other.filter, filter) || other.filter == filter));
  }

  @override
  int get hashCode => Object.hash(runtimeType, filter);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CardFilterAppliedImplCopyWith<_$CardFilterAppliedImpl> get copyWith =>
      __$$CardFilterAppliedImplCopyWithImpl<_$CardFilterAppliedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String query) searchChanged,
    required TResult Function(CardFilter filter) filterApplied,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(int size) pageSizeChanged,
    required TResult Function(String? network) networkChanged,
  }) {
    return filterApplied(filter);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String query)? searchChanged,
    TResult? Function(CardFilter filter)? filterApplied,
    TResult? Function(Completer<void>? completer)? refreshRequested,
    TResult? Function()? loadMoreRequested,
    TResult? Function(int size)? pageSizeChanged,
    TResult? Function(String? network)? networkChanged,
  }) {
    return filterApplied?.call(filter);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String query)? searchChanged,
    TResult Function(CardFilter filter)? filterApplied,
    TResult Function(Completer<void>? completer)? refreshRequested,
    TResult Function()? loadMoreRequested,
    TResult Function(int size)? pageSizeChanged,
    TResult Function(String? network)? networkChanged,
    required TResult orElse(),
  }) {
    if (filterApplied != null) {
      return filterApplied(filter);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CardStarted value) started,
    required TResult Function(CardSearchChanged value) searchChanged,
    required TResult Function(CardFilterApplied value) filterApplied,
    required TResult Function(CardRefreshRequested value) refreshRequested,
    required TResult Function(CardLoadMoreRequested value) loadMoreRequested,
    required TResult Function(CardPageSizeChanged value) pageSizeChanged,
    required TResult Function(CardNetworkChanged value) networkChanged,
  }) {
    return filterApplied(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CardStarted value)? started,
    TResult? Function(CardSearchChanged value)? searchChanged,
    TResult? Function(CardFilterApplied value)? filterApplied,
    TResult? Function(CardRefreshRequested value)? refreshRequested,
    TResult? Function(CardLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(CardPageSizeChanged value)? pageSizeChanged,
    TResult? Function(CardNetworkChanged value)? networkChanged,
  }) {
    return filterApplied?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CardStarted value)? started,
    TResult Function(CardSearchChanged value)? searchChanged,
    TResult Function(CardFilterApplied value)? filterApplied,
    TResult Function(CardRefreshRequested value)? refreshRequested,
    TResult Function(CardLoadMoreRequested value)? loadMoreRequested,
    TResult Function(CardPageSizeChanged value)? pageSizeChanged,
    TResult Function(CardNetworkChanged value)? networkChanged,
    required TResult orElse(),
  }) {
    if (filterApplied != null) {
      return filterApplied(this);
    }
    return orElse();
  }
}

abstract class CardFilterApplied implements CardEvent {
  const factory CardFilterApplied(final CardFilter filter) =
      _$CardFilterAppliedImpl;

  CardFilter get filter;
  @JsonKey(ignore: true)
  _$$CardFilterAppliedImplCopyWith<_$CardFilterAppliedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CardRefreshRequestedImplCopyWith<$Res> {
  factory _$$CardRefreshRequestedImplCopyWith(_$CardRefreshRequestedImpl value,
          $Res Function(_$CardRefreshRequestedImpl) then) =
      __$$CardRefreshRequestedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Completer<void>? completer});
}

/// @nodoc
class __$$CardRefreshRequestedImplCopyWithImpl<$Res>
    extends _$CardEventCopyWithImpl<$Res, _$CardRefreshRequestedImpl>
    implements _$$CardRefreshRequestedImplCopyWith<$Res> {
  __$$CardRefreshRequestedImplCopyWithImpl(_$CardRefreshRequestedImpl _value,
      $Res Function(_$CardRefreshRequestedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completer = freezed,
  }) {
    return _then(_$CardRefreshRequestedImpl(
      completer: freezed == completer
          ? _value.completer
          : completer // ignore: cast_nullable_to_non_nullable
              as Completer<void>?,
    ));
  }
}

/// @nodoc

class _$CardRefreshRequestedImpl implements CardRefreshRequested {
  const _$CardRefreshRequestedImpl({this.completer});

  @override
  final Completer<void>? completer;

  @override
  String toString() {
    return 'CardEvent.refreshRequested(completer: $completer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardRefreshRequestedImpl &&
            (identical(other.completer, completer) ||
                other.completer == completer));
  }

  @override
  int get hashCode => Object.hash(runtimeType, completer);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CardRefreshRequestedImplCopyWith<_$CardRefreshRequestedImpl>
      get copyWith =>
          __$$CardRefreshRequestedImplCopyWithImpl<_$CardRefreshRequestedImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String query) searchChanged,
    required TResult Function(CardFilter filter) filterApplied,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(int size) pageSizeChanged,
    required TResult Function(String? network) networkChanged,
  }) {
    return refreshRequested(completer);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String query)? searchChanged,
    TResult? Function(CardFilter filter)? filterApplied,
    TResult? Function(Completer<void>? completer)? refreshRequested,
    TResult? Function()? loadMoreRequested,
    TResult? Function(int size)? pageSizeChanged,
    TResult? Function(String? network)? networkChanged,
  }) {
    return refreshRequested?.call(completer);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String query)? searchChanged,
    TResult Function(CardFilter filter)? filterApplied,
    TResult Function(Completer<void>? completer)? refreshRequested,
    TResult Function()? loadMoreRequested,
    TResult Function(int size)? pageSizeChanged,
    TResult Function(String? network)? networkChanged,
    required TResult orElse(),
  }) {
    if (refreshRequested != null) {
      return refreshRequested(completer);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CardStarted value) started,
    required TResult Function(CardSearchChanged value) searchChanged,
    required TResult Function(CardFilterApplied value) filterApplied,
    required TResult Function(CardRefreshRequested value) refreshRequested,
    required TResult Function(CardLoadMoreRequested value) loadMoreRequested,
    required TResult Function(CardPageSizeChanged value) pageSizeChanged,
    required TResult Function(CardNetworkChanged value) networkChanged,
  }) {
    return refreshRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CardStarted value)? started,
    TResult? Function(CardSearchChanged value)? searchChanged,
    TResult? Function(CardFilterApplied value)? filterApplied,
    TResult? Function(CardRefreshRequested value)? refreshRequested,
    TResult? Function(CardLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(CardPageSizeChanged value)? pageSizeChanged,
    TResult? Function(CardNetworkChanged value)? networkChanged,
  }) {
    return refreshRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CardStarted value)? started,
    TResult Function(CardSearchChanged value)? searchChanged,
    TResult Function(CardFilterApplied value)? filterApplied,
    TResult Function(CardRefreshRequested value)? refreshRequested,
    TResult Function(CardLoadMoreRequested value)? loadMoreRequested,
    TResult Function(CardPageSizeChanged value)? pageSizeChanged,
    TResult Function(CardNetworkChanged value)? networkChanged,
    required TResult orElse(),
  }) {
    if (refreshRequested != null) {
      return refreshRequested(this);
    }
    return orElse();
  }
}

abstract class CardRefreshRequested implements CardEvent {
  const factory CardRefreshRequested({final Completer<void>? completer}) =
      _$CardRefreshRequestedImpl;

  Completer<void>? get completer;
  @JsonKey(ignore: true)
  _$$CardRefreshRequestedImplCopyWith<_$CardRefreshRequestedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CardLoadMoreRequestedImplCopyWith<$Res> {
  factory _$$CardLoadMoreRequestedImplCopyWith(
          _$CardLoadMoreRequestedImpl value,
          $Res Function(_$CardLoadMoreRequestedImpl) then) =
      __$$CardLoadMoreRequestedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CardLoadMoreRequestedImplCopyWithImpl<$Res>
    extends _$CardEventCopyWithImpl<$Res, _$CardLoadMoreRequestedImpl>
    implements _$$CardLoadMoreRequestedImplCopyWith<$Res> {
  __$$CardLoadMoreRequestedImplCopyWithImpl(_$CardLoadMoreRequestedImpl _value,
      $Res Function(_$CardLoadMoreRequestedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$CardLoadMoreRequestedImpl implements CardLoadMoreRequested {
  const _$CardLoadMoreRequestedImpl();

  @override
  String toString() {
    return 'CardEvent.loadMoreRequested()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardLoadMoreRequestedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String query) searchChanged,
    required TResult Function(CardFilter filter) filterApplied,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(int size) pageSizeChanged,
    required TResult Function(String? network) networkChanged,
  }) {
    return loadMoreRequested();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String query)? searchChanged,
    TResult? Function(CardFilter filter)? filterApplied,
    TResult? Function(Completer<void>? completer)? refreshRequested,
    TResult? Function()? loadMoreRequested,
    TResult? Function(int size)? pageSizeChanged,
    TResult? Function(String? network)? networkChanged,
  }) {
    return loadMoreRequested?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String query)? searchChanged,
    TResult Function(CardFilter filter)? filterApplied,
    TResult Function(Completer<void>? completer)? refreshRequested,
    TResult Function()? loadMoreRequested,
    TResult Function(int size)? pageSizeChanged,
    TResult Function(String? network)? networkChanged,
    required TResult orElse(),
  }) {
    if (loadMoreRequested != null) {
      return loadMoreRequested();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CardStarted value) started,
    required TResult Function(CardSearchChanged value) searchChanged,
    required TResult Function(CardFilterApplied value) filterApplied,
    required TResult Function(CardRefreshRequested value) refreshRequested,
    required TResult Function(CardLoadMoreRequested value) loadMoreRequested,
    required TResult Function(CardPageSizeChanged value) pageSizeChanged,
    required TResult Function(CardNetworkChanged value) networkChanged,
  }) {
    return loadMoreRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CardStarted value)? started,
    TResult? Function(CardSearchChanged value)? searchChanged,
    TResult? Function(CardFilterApplied value)? filterApplied,
    TResult? Function(CardRefreshRequested value)? refreshRequested,
    TResult? Function(CardLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(CardPageSizeChanged value)? pageSizeChanged,
    TResult? Function(CardNetworkChanged value)? networkChanged,
  }) {
    return loadMoreRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CardStarted value)? started,
    TResult Function(CardSearchChanged value)? searchChanged,
    TResult Function(CardFilterApplied value)? filterApplied,
    TResult Function(CardRefreshRequested value)? refreshRequested,
    TResult Function(CardLoadMoreRequested value)? loadMoreRequested,
    TResult Function(CardPageSizeChanged value)? pageSizeChanged,
    TResult Function(CardNetworkChanged value)? networkChanged,
    required TResult orElse(),
  }) {
    if (loadMoreRequested != null) {
      return loadMoreRequested(this);
    }
    return orElse();
  }
}

abstract class CardLoadMoreRequested implements CardEvent {
  const factory CardLoadMoreRequested() = _$CardLoadMoreRequestedImpl;
}

/// @nodoc
abstract class _$$CardPageSizeChangedImplCopyWith<$Res> {
  factory _$$CardPageSizeChangedImplCopyWith(_$CardPageSizeChangedImpl value,
          $Res Function(_$CardPageSizeChangedImpl) then) =
      __$$CardPageSizeChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int size});
}

/// @nodoc
class __$$CardPageSizeChangedImplCopyWithImpl<$Res>
    extends _$CardEventCopyWithImpl<$Res, _$CardPageSizeChangedImpl>
    implements _$$CardPageSizeChangedImplCopyWith<$Res> {
  __$$CardPageSizeChangedImplCopyWithImpl(_$CardPageSizeChangedImpl _value,
      $Res Function(_$CardPageSizeChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? size = null,
  }) {
    return _then(_$CardPageSizeChangedImpl(
      null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$CardPageSizeChangedImpl implements CardPageSizeChanged {
  const _$CardPageSizeChangedImpl(this.size);

  @override
  final int size;

  @override
  String toString() {
    return 'CardEvent.pageSizeChanged(size: $size)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardPageSizeChangedImpl &&
            (identical(other.size, size) || other.size == size));
  }

  @override
  int get hashCode => Object.hash(runtimeType, size);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CardPageSizeChangedImplCopyWith<_$CardPageSizeChangedImpl> get copyWith =>
      __$$CardPageSizeChangedImplCopyWithImpl<_$CardPageSizeChangedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String query) searchChanged,
    required TResult Function(CardFilter filter) filterApplied,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(int size) pageSizeChanged,
    required TResult Function(String? network) networkChanged,
  }) {
    return pageSizeChanged(size);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String query)? searchChanged,
    TResult? Function(CardFilter filter)? filterApplied,
    TResult? Function(Completer<void>? completer)? refreshRequested,
    TResult? Function()? loadMoreRequested,
    TResult? Function(int size)? pageSizeChanged,
    TResult? Function(String? network)? networkChanged,
  }) {
    return pageSizeChanged?.call(size);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String query)? searchChanged,
    TResult Function(CardFilter filter)? filterApplied,
    TResult Function(Completer<void>? completer)? refreshRequested,
    TResult Function()? loadMoreRequested,
    TResult Function(int size)? pageSizeChanged,
    TResult Function(String? network)? networkChanged,
    required TResult orElse(),
  }) {
    if (pageSizeChanged != null) {
      return pageSizeChanged(size);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CardStarted value) started,
    required TResult Function(CardSearchChanged value) searchChanged,
    required TResult Function(CardFilterApplied value) filterApplied,
    required TResult Function(CardRefreshRequested value) refreshRequested,
    required TResult Function(CardLoadMoreRequested value) loadMoreRequested,
    required TResult Function(CardPageSizeChanged value) pageSizeChanged,
    required TResult Function(CardNetworkChanged value) networkChanged,
  }) {
    return pageSizeChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CardStarted value)? started,
    TResult? Function(CardSearchChanged value)? searchChanged,
    TResult? Function(CardFilterApplied value)? filterApplied,
    TResult? Function(CardRefreshRequested value)? refreshRequested,
    TResult? Function(CardLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(CardPageSizeChanged value)? pageSizeChanged,
    TResult? Function(CardNetworkChanged value)? networkChanged,
  }) {
    return pageSizeChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CardStarted value)? started,
    TResult Function(CardSearchChanged value)? searchChanged,
    TResult Function(CardFilterApplied value)? filterApplied,
    TResult Function(CardRefreshRequested value)? refreshRequested,
    TResult Function(CardLoadMoreRequested value)? loadMoreRequested,
    TResult Function(CardPageSizeChanged value)? pageSizeChanged,
    TResult Function(CardNetworkChanged value)? networkChanged,
    required TResult orElse(),
  }) {
    if (pageSizeChanged != null) {
      return pageSizeChanged(this);
    }
    return orElse();
  }
}

abstract class CardPageSizeChanged implements CardEvent {
  const factory CardPageSizeChanged(final int size) = _$CardPageSizeChangedImpl;

  int get size;
  @JsonKey(ignore: true)
  _$$CardPageSizeChangedImplCopyWith<_$CardPageSizeChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CardNetworkChangedImplCopyWith<$Res> {
  factory _$$CardNetworkChangedImplCopyWith(_$CardNetworkChangedImpl value,
          $Res Function(_$CardNetworkChangedImpl) then) =
      __$$CardNetworkChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String? network});
}

/// @nodoc
class __$$CardNetworkChangedImplCopyWithImpl<$Res>
    extends _$CardEventCopyWithImpl<$Res, _$CardNetworkChangedImpl>
    implements _$$CardNetworkChangedImplCopyWith<$Res> {
  __$$CardNetworkChangedImplCopyWithImpl(_$CardNetworkChangedImpl _value,
      $Res Function(_$CardNetworkChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? network = freezed,
  }) {
    return _then(_$CardNetworkChangedImpl(
      freezed == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CardNetworkChangedImpl implements CardNetworkChanged {
  const _$CardNetworkChangedImpl(this.network);

  @override
  final String? network;

  @override
  String toString() {
    return 'CardEvent.networkChanged(network: $network)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardNetworkChangedImpl &&
            (identical(other.network, network) || other.network == network));
  }

  @override
  int get hashCode => Object.hash(runtimeType, network);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CardNetworkChangedImplCopyWith<_$CardNetworkChangedImpl> get copyWith =>
      __$$CardNetworkChangedImplCopyWithImpl<_$CardNetworkChangedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(String query) searchChanged,
    required TResult Function(CardFilter filter) filterApplied,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(int size) pageSizeChanged,
    required TResult Function(String? network) networkChanged,
  }) {
    return networkChanged(network);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(String query)? searchChanged,
    TResult? Function(CardFilter filter)? filterApplied,
    TResult? Function(Completer<void>? completer)? refreshRequested,
    TResult? Function()? loadMoreRequested,
    TResult? Function(int size)? pageSizeChanged,
    TResult? Function(String? network)? networkChanged,
  }) {
    return networkChanged?.call(network);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(String query)? searchChanged,
    TResult Function(CardFilter filter)? filterApplied,
    TResult Function(Completer<void>? completer)? refreshRequested,
    TResult Function()? loadMoreRequested,
    TResult Function(int size)? pageSizeChanged,
    TResult Function(String? network)? networkChanged,
    required TResult orElse(),
  }) {
    if (networkChanged != null) {
      return networkChanged(network);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(CardStarted value) started,
    required TResult Function(CardSearchChanged value) searchChanged,
    required TResult Function(CardFilterApplied value) filterApplied,
    required TResult Function(CardRefreshRequested value) refreshRequested,
    required TResult Function(CardLoadMoreRequested value) loadMoreRequested,
    required TResult Function(CardPageSizeChanged value) pageSizeChanged,
    required TResult Function(CardNetworkChanged value) networkChanged,
  }) {
    return networkChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(CardStarted value)? started,
    TResult? Function(CardSearchChanged value)? searchChanged,
    TResult? Function(CardFilterApplied value)? filterApplied,
    TResult? Function(CardRefreshRequested value)? refreshRequested,
    TResult? Function(CardLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(CardPageSizeChanged value)? pageSizeChanged,
    TResult? Function(CardNetworkChanged value)? networkChanged,
  }) {
    return networkChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(CardStarted value)? started,
    TResult Function(CardSearchChanged value)? searchChanged,
    TResult Function(CardFilterApplied value)? filterApplied,
    TResult Function(CardRefreshRequested value)? refreshRequested,
    TResult Function(CardLoadMoreRequested value)? loadMoreRequested,
    TResult Function(CardPageSizeChanged value)? pageSizeChanged,
    TResult Function(CardNetworkChanged value)? networkChanged,
    required TResult orElse(),
  }) {
    if (networkChanged != null) {
      return networkChanged(this);
    }
    return orElse();
  }
}

abstract class CardNetworkChanged implements CardEvent {
  const factory CardNetworkChanged(final String? network) =
      _$CardNetworkChangedImpl;

  String? get network;
  @JsonKey(ignore: true)
  _$$CardNetworkChangedImplCopyWith<_$CardNetworkChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CardState {
  List<CardOffer> get items => throw _privateConstructorUsedError;
  List<CardOffer> get visibleItems => throw _privateConstructorUsedError;
  CardFilter get filter => throw _privateConstructorUsedError;
  CardViewStatus get status => throw _privateConstructorUsedError;
  bool get isInitialLoading => throw _privateConstructorUsedError;
  bool get isPaginating => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;
  String? get selectedNetwork => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get paginationErrorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CardStateCopyWith<CardState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CardStateCopyWith<$Res> {
  factory $CardStateCopyWith(CardState value, $Res Function(CardState) then) =
      _$CardStateCopyWithImpl<$Res, CardState>;
  @useResult
  $Res call(
      {List<CardOffer> items,
      List<CardOffer> visibleItems,
      CardFilter filter,
      CardViewStatus status,
      bool isInitialLoading,
      bool isPaginating,
      bool hasMore,
      int page,
      int pageSize,
      String? selectedNetwork,
      String? errorMessage,
      String? paginationErrorMessage});
}

/// @nodoc
class _$CardStateCopyWithImpl<$Res, $Val extends CardState>
    implements $CardStateCopyWith<$Res> {
  _$CardStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? visibleItems = null,
    Object? filter = null,
    Object? status = null,
    Object? isInitialLoading = null,
    Object? isPaginating = null,
    Object? hasMore = null,
    Object? page = null,
    Object? pageSize = null,
    Object? selectedNetwork = freezed,
    Object? errorMessage = freezed,
    Object? paginationErrorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CardOffer>,
      visibleItems: null == visibleItems
          ? _value.visibleItems
          : visibleItems // ignore: cast_nullable_to_non_nullable
              as List<CardOffer>,
      filter: null == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as CardFilter,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as CardViewStatus,
      isInitialLoading: null == isInitialLoading
          ? _value.isInitialLoading
          : isInitialLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isPaginating: null == isPaginating
          ? _value.isPaginating
          : isPaginating // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      selectedNetwork: freezed == selectedNetwork
          ? _value.selectedNetwork
          : selectedNetwork // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      paginationErrorMessage: freezed == paginationErrorMessage
          ? _value.paginationErrorMessage
          : paginationErrorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CardStateImplCopyWith<$Res>
    implements $CardStateCopyWith<$Res> {
  factory _$$CardStateImplCopyWith(
          _$CardStateImpl value, $Res Function(_$CardStateImpl) then) =
      __$$CardStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<CardOffer> items,
      List<CardOffer> visibleItems,
      CardFilter filter,
      CardViewStatus status,
      bool isInitialLoading,
      bool isPaginating,
      bool hasMore,
      int page,
      int pageSize,
      String? selectedNetwork,
      String? errorMessage,
      String? paginationErrorMessage});
}

/// @nodoc
class __$$CardStateImplCopyWithImpl<$Res>
    extends _$CardStateCopyWithImpl<$Res, _$CardStateImpl>
    implements _$$CardStateImplCopyWith<$Res> {
  __$$CardStateImplCopyWithImpl(
      _$CardStateImpl _value, $Res Function(_$CardStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? visibleItems = null,
    Object? filter = null,
    Object? status = null,
    Object? isInitialLoading = null,
    Object? isPaginating = null,
    Object? hasMore = null,
    Object? page = null,
    Object? pageSize = null,
    Object? selectedNetwork = freezed,
    Object? errorMessage = freezed,
    Object? paginationErrorMessage = freezed,
  }) {
    return _then(_$CardStateImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CardOffer>,
      visibleItems: null == visibleItems
          ? _value._visibleItems
          : visibleItems // ignore: cast_nullable_to_non_nullable
              as List<CardOffer>,
      filter: null == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as CardFilter,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as CardViewStatus,
      isInitialLoading: null == isInitialLoading
          ? _value.isInitialLoading
          : isInitialLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isPaginating: null == isPaginating
          ? _value.isPaginating
          : isPaginating // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      selectedNetwork: freezed == selectedNetwork
          ? _value.selectedNetwork
          : selectedNetwork // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      paginationErrorMessage: freezed == paginationErrorMessage
          ? _value.paginationErrorMessage
          : paginationErrorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CardStateImpl extends _CardState {
  const _$CardStateImpl(
      {required final List<CardOffer> items,
      required final List<CardOffer> visibleItems,
      required this.filter,
      required this.status,
      required this.isInitialLoading,
      required this.isPaginating,
      required this.hasMore,
      required this.page,
      required this.pageSize,
      this.selectedNetwork,
      this.errorMessage,
      this.paginationErrorMessage})
      : _items = items,
        _visibleItems = visibleItems,
        super._();

  final List<CardOffer> _items;
  @override
  List<CardOffer> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  final List<CardOffer> _visibleItems;
  @override
  List<CardOffer> get visibleItems {
    if (_visibleItems is EqualUnmodifiableListView) return _visibleItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_visibleItems);
  }

  @override
  final CardFilter filter;
  @override
  final CardViewStatus status;
  @override
  final bool isInitialLoading;
  @override
  final bool isPaginating;
  @override
  final bool hasMore;
  @override
  final int page;
  @override
  final int pageSize;
  @override
  final String? selectedNetwork;
  @override
  final String? errorMessage;
  @override
  final String? paginationErrorMessage;

  @override
  String toString() {
    return 'CardState(items: $items, visibleItems: $visibleItems, filter: $filter, status: $status, isInitialLoading: $isInitialLoading, isPaginating: $isPaginating, hasMore: $hasMore, page: $page, pageSize: $pageSize, selectedNetwork: $selectedNetwork, errorMessage: $errorMessage, paginationErrorMessage: $paginationErrorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardStateImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality()
                .equals(other._visibleItems, _visibleItems) &&
            (identical(other.filter, filter) || other.filter == filter) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isInitialLoading, isInitialLoading) ||
                other.isInitialLoading == isInitialLoading) &&
            (identical(other.isPaginating, isPaginating) ||
                other.isPaginating == isPaginating) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.selectedNetwork, selectedNetwork) ||
                other.selectedNetwork == selectedNetwork) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.paginationErrorMessage, paginationErrorMessage) ||
                other.paginationErrorMessage == paginationErrorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      const DeepCollectionEquality().hash(_visibleItems),
      filter,
      status,
      isInitialLoading,
      isPaginating,
      hasMore,
      page,
      pageSize,
      selectedNetwork,
      errorMessage,
      paginationErrorMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CardStateImplCopyWith<_$CardStateImpl> get copyWith =>
      __$$CardStateImplCopyWithImpl<_$CardStateImpl>(this, _$identity);
}

abstract class _CardState extends CardState {
  const factory _CardState(
      {required final List<CardOffer> items,
      required final List<CardOffer> visibleItems,
      required final CardFilter filter,
      required final CardViewStatus status,
      required final bool isInitialLoading,
      required final bool isPaginating,
      required final bool hasMore,
      required final int page,
      required final int pageSize,
      final String? selectedNetwork,
      final String? errorMessage,
      final String? paginationErrorMessage}) = _$CardStateImpl;
  const _CardState._() : super._();

  @override
  List<CardOffer> get items;
  @override
  List<CardOffer> get visibleItems;
  @override
  CardFilter get filter;
  @override
  CardViewStatus get status;
  @override
  bool get isInitialLoading;
  @override
  bool get isPaginating;
  @override
  bool get hasMore;
  @override
  int get page;
  @override
  int get pageSize;
  @override
  String? get selectedNetwork;
  @override
  String? get errorMessage;
  @override
  String? get paginationErrorMessage;
  @override
  @JsonKey(ignore: true)
  _$$CardStateImplCopyWith<_$CardStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
