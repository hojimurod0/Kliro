// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mortgage_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MortgageEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(String query) searchChanged,
    required TResult Function(MortgageFilter filter) filterApplied,
    required TResult Function(int size) pageSizeChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Completer<void>? completer)? refreshRequested,
    TResult? Function()? loadMoreRequested,
    TResult? Function(String query)? searchChanged,
    TResult? Function(MortgageFilter filter)? filterApplied,
    TResult? Function(int size)? pageSizeChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Completer<void>? completer)? refreshRequested,
    TResult Function()? loadMoreRequested,
    TResult Function(String query)? searchChanged,
    TResult Function(MortgageFilter filter)? filterApplied,
    TResult Function(int size)? pageSizeChanged,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MortgageStarted value) started,
    required TResult Function(MortgageRefreshRequested value) refreshRequested,
    required TResult Function(MortgageLoadMoreRequested value)
        loadMoreRequested,
    required TResult Function(MortgageSearchChanged value) searchChanged,
    required TResult Function(MortgageFilterApplied value) filterApplied,
    required TResult Function(MortgagePageSizeChanged value) pageSizeChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MortgageStarted value)? started,
    TResult? Function(MortgageRefreshRequested value)? refreshRequested,
    TResult? Function(MortgageLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(MortgageSearchChanged value)? searchChanged,
    TResult? Function(MortgageFilterApplied value)? filterApplied,
    TResult? Function(MortgagePageSizeChanged value)? pageSizeChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MortgageStarted value)? started,
    TResult Function(MortgageRefreshRequested value)? refreshRequested,
    TResult Function(MortgageLoadMoreRequested value)? loadMoreRequested,
    TResult Function(MortgageSearchChanged value)? searchChanged,
    TResult Function(MortgageFilterApplied value)? filterApplied,
    TResult Function(MortgagePageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MortgageEventCopyWith<$Res> {
  factory $MortgageEventCopyWith(
          MortgageEvent value, $Res Function(MortgageEvent) then) =
      _$MortgageEventCopyWithImpl<$Res, MortgageEvent>;
}

/// @nodoc
class _$MortgageEventCopyWithImpl<$Res, $Val extends MortgageEvent>
    implements $MortgageEventCopyWith<$Res> {
  _$MortgageEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$MortgageStartedImplCopyWith<$Res> {
  factory _$$MortgageStartedImplCopyWith(_$MortgageStartedImpl value,
          $Res Function(_$MortgageStartedImpl) then) =
      __$$MortgageStartedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MortgageStartedImplCopyWithImpl<$Res>
    extends _$MortgageEventCopyWithImpl<$Res, _$MortgageStartedImpl>
    implements _$$MortgageStartedImplCopyWith<$Res> {
  __$$MortgageStartedImplCopyWithImpl(
      _$MortgageStartedImpl _value, $Res Function(_$MortgageStartedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$MortgageStartedImpl
    with DiagnosticableTreeMixin
    implements MortgageStarted {
  const _$MortgageStartedImpl();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MortgageEvent.started()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('type', 'MortgageEvent.started'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$MortgageStartedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(String query) searchChanged,
    required TResult Function(MortgageFilter filter) filterApplied,
    required TResult Function(int size) pageSizeChanged,
  }) {
    return started();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Completer<void>? completer)? refreshRequested,
    TResult? Function()? loadMoreRequested,
    TResult? Function(String query)? searchChanged,
    TResult? Function(MortgageFilter filter)? filterApplied,
    TResult? Function(int size)? pageSizeChanged,
  }) {
    return started?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Completer<void>? completer)? refreshRequested,
    TResult Function()? loadMoreRequested,
    TResult Function(String query)? searchChanged,
    TResult Function(MortgageFilter filter)? filterApplied,
    TResult Function(int size)? pageSizeChanged,
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
    required TResult Function(MortgageStarted value) started,
    required TResult Function(MortgageRefreshRequested value) refreshRequested,
    required TResult Function(MortgageLoadMoreRequested value)
        loadMoreRequested,
    required TResult Function(MortgageSearchChanged value) searchChanged,
    required TResult Function(MortgageFilterApplied value) filterApplied,
    required TResult Function(MortgagePageSizeChanged value) pageSizeChanged,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MortgageStarted value)? started,
    TResult? Function(MortgageRefreshRequested value)? refreshRequested,
    TResult? Function(MortgageLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(MortgageSearchChanged value)? searchChanged,
    TResult? Function(MortgageFilterApplied value)? filterApplied,
    TResult? Function(MortgagePageSizeChanged value)? pageSizeChanged,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MortgageStarted value)? started,
    TResult Function(MortgageRefreshRequested value)? refreshRequested,
    TResult Function(MortgageLoadMoreRequested value)? loadMoreRequested,
    TResult Function(MortgageSearchChanged value)? searchChanged,
    TResult Function(MortgageFilterApplied value)? filterApplied,
    TResult Function(MortgagePageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class MortgageStarted implements MortgageEvent {
  const factory MortgageStarted() = _$MortgageStartedImpl;
}

/// @nodoc
abstract class _$$MortgageRefreshRequestedImplCopyWith<$Res> {
  factory _$$MortgageRefreshRequestedImplCopyWith(
          _$MortgageRefreshRequestedImpl value,
          $Res Function(_$MortgageRefreshRequestedImpl) then) =
      __$$MortgageRefreshRequestedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Completer<void>? completer});
}

/// @nodoc
class __$$MortgageRefreshRequestedImplCopyWithImpl<$Res>
    extends _$MortgageEventCopyWithImpl<$Res, _$MortgageRefreshRequestedImpl>
    implements _$$MortgageRefreshRequestedImplCopyWith<$Res> {
  __$$MortgageRefreshRequestedImplCopyWithImpl(
      _$MortgageRefreshRequestedImpl _value,
      $Res Function(_$MortgageRefreshRequestedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completer = freezed,
  }) {
    return _then(_$MortgageRefreshRequestedImpl(
      completer: freezed == completer
          ? _value.completer
          : completer // ignore: cast_nullable_to_non_nullable
              as Completer<void>?,
    ));
  }
}

/// @nodoc

class _$MortgageRefreshRequestedImpl
    with DiagnosticableTreeMixin
    implements MortgageRefreshRequested {
  const _$MortgageRefreshRequestedImpl({this.completer});

  @override
  final Completer<void>? completer;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MortgageEvent.refreshRequested(completer: $completer)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MortgageEvent.refreshRequested'))
      ..add(DiagnosticsProperty('completer', completer));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MortgageRefreshRequestedImpl &&
            (identical(other.completer, completer) ||
                other.completer == completer));
  }

  @override
  int get hashCode => Object.hash(runtimeType, completer);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MortgageRefreshRequestedImplCopyWith<_$MortgageRefreshRequestedImpl>
      get copyWith => __$$MortgageRefreshRequestedImplCopyWithImpl<
          _$MortgageRefreshRequestedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(String query) searchChanged,
    required TResult Function(MortgageFilter filter) filterApplied,
    required TResult Function(int size) pageSizeChanged,
  }) {
    return refreshRequested(completer);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Completer<void>? completer)? refreshRequested,
    TResult? Function()? loadMoreRequested,
    TResult? Function(String query)? searchChanged,
    TResult? Function(MortgageFilter filter)? filterApplied,
    TResult? Function(int size)? pageSizeChanged,
  }) {
    return refreshRequested?.call(completer);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Completer<void>? completer)? refreshRequested,
    TResult Function()? loadMoreRequested,
    TResult Function(String query)? searchChanged,
    TResult Function(MortgageFilter filter)? filterApplied,
    TResult Function(int size)? pageSizeChanged,
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
    required TResult Function(MortgageStarted value) started,
    required TResult Function(MortgageRefreshRequested value) refreshRequested,
    required TResult Function(MortgageLoadMoreRequested value)
        loadMoreRequested,
    required TResult Function(MortgageSearchChanged value) searchChanged,
    required TResult Function(MortgageFilterApplied value) filterApplied,
    required TResult Function(MortgagePageSizeChanged value) pageSizeChanged,
  }) {
    return refreshRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MortgageStarted value)? started,
    TResult? Function(MortgageRefreshRequested value)? refreshRequested,
    TResult? Function(MortgageLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(MortgageSearchChanged value)? searchChanged,
    TResult? Function(MortgageFilterApplied value)? filterApplied,
    TResult? Function(MortgagePageSizeChanged value)? pageSizeChanged,
  }) {
    return refreshRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MortgageStarted value)? started,
    TResult Function(MortgageRefreshRequested value)? refreshRequested,
    TResult Function(MortgageLoadMoreRequested value)? loadMoreRequested,
    TResult Function(MortgageSearchChanged value)? searchChanged,
    TResult Function(MortgageFilterApplied value)? filterApplied,
    TResult Function(MortgagePageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) {
    if (refreshRequested != null) {
      return refreshRequested(this);
    }
    return orElse();
  }
}

abstract class MortgageRefreshRequested implements MortgageEvent {
  const factory MortgageRefreshRequested({final Completer<void>? completer}) =
      _$MortgageRefreshRequestedImpl;

  Completer<void>? get completer;
  @JsonKey(ignore: true)
  _$$MortgageRefreshRequestedImplCopyWith<_$MortgageRefreshRequestedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MortgageLoadMoreRequestedImplCopyWith<$Res> {
  factory _$$MortgageLoadMoreRequestedImplCopyWith(
          _$MortgageLoadMoreRequestedImpl value,
          $Res Function(_$MortgageLoadMoreRequestedImpl) then) =
      __$$MortgageLoadMoreRequestedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MortgageLoadMoreRequestedImplCopyWithImpl<$Res>
    extends _$MortgageEventCopyWithImpl<$Res, _$MortgageLoadMoreRequestedImpl>
    implements _$$MortgageLoadMoreRequestedImplCopyWith<$Res> {
  __$$MortgageLoadMoreRequestedImplCopyWithImpl(
      _$MortgageLoadMoreRequestedImpl _value,
      $Res Function(_$MortgageLoadMoreRequestedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$MortgageLoadMoreRequestedImpl
    with DiagnosticableTreeMixin
    implements MortgageLoadMoreRequested {
  const _$MortgageLoadMoreRequestedImpl();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MortgageEvent.loadMoreRequested()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty('type', 'MortgageEvent.loadMoreRequested'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MortgageLoadMoreRequestedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(String query) searchChanged,
    required TResult Function(MortgageFilter filter) filterApplied,
    required TResult Function(int size) pageSizeChanged,
  }) {
    return loadMoreRequested();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Completer<void>? completer)? refreshRequested,
    TResult? Function()? loadMoreRequested,
    TResult? Function(String query)? searchChanged,
    TResult? Function(MortgageFilter filter)? filterApplied,
    TResult? Function(int size)? pageSizeChanged,
  }) {
    return loadMoreRequested?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Completer<void>? completer)? refreshRequested,
    TResult Function()? loadMoreRequested,
    TResult Function(String query)? searchChanged,
    TResult Function(MortgageFilter filter)? filterApplied,
    TResult Function(int size)? pageSizeChanged,
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
    required TResult Function(MortgageStarted value) started,
    required TResult Function(MortgageRefreshRequested value) refreshRequested,
    required TResult Function(MortgageLoadMoreRequested value)
        loadMoreRequested,
    required TResult Function(MortgageSearchChanged value) searchChanged,
    required TResult Function(MortgageFilterApplied value) filterApplied,
    required TResult Function(MortgagePageSizeChanged value) pageSizeChanged,
  }) {
    return loadMoreRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MortgageStarted value)? started,
    TResult? Function(MortgageRefreshRequested value)? refreshRequested,
    TResult? Function(MortgageLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(MortgageSearchChanged value)? searchChanged,
    TResult? Function(MortgageFilterApplied value)? filterApplied,
    TResult? Function(MortgagePageSizeChanged value)? pageSizeChanged,
  }) {
    return loadMoreRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MortgageStarted value)? started,
    TResult Function(MortgageRefreshRequested value)? refreshRequested,
    TResult Function(MortgageLoadMoreRequested value)? loadMoreRequested,
    TResult Function(MortgageSearchChanged value)? searchChanged,
    TResult Function(MortgageFilterApplied value)? filterApplied,
    TResult Function(MortgagePageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) {
    if (loadMoreRequested != null) {
      return loadMoreRequested(this);
    }
    return orElse();
  }
}

abstract class MortgageLoadMoreRequested implements MortgageEvent {
  const factory MortgageLoadMoreRequested() = _$MortgageLoadMoreRequestedImpl;
}

/// @nodoc
abstract class _$$MortgageSearchChangedImplCopyWith<$Res> {
  factory _$$MortgageSearchChangedImplCopyWith(
          _$MortgageSearchChangedImpl value,
          $Res Function(_$MortgageSearchChangedImpl) then) =
      __$$MortgageSearchChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String query});
}

/// @nodoc
class __$$MortgageSearchChangedImplCopyWithImpl<$Res>
    extends _$MortgageEventCopyWithImpl<$Res, _$MortgageSearchChangedImpl>
    implements _$$MortgageSearchChangedImplCopyWith<$Res> {
  __$$MortgageSearchChangedImplCopyWithImpl(_$MortgageSearchChangedImpl _value,
      $Res Function(_$MortgageSearchChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
  }) {
    return _then(_$MortgageSearchChangedImpl(
      null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$MortgageSearchChangedImpl
    with DiagnosticableTreeMixin
    implements MortgageSearchChanged {
  const _$MortgageSearchChangedImpl(this.query);

  @override
  final String query;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MortgageEvent.searchChanged(query: $query)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MortgageEvent.searchChanged'))
      ..add(DiagnosticsProperty('query', query));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MortgageSearchChangedImpl &&
            (identical(other.query, query) || other.query == query));
  }

  @override
  int get hashCode => Object.hash(runtimeType, query);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MortgageSearchChangedImplCopyWith<_$MortgageSearchChangedImpl>
      get copyWith => __$$MortgageSearchChangedImplCopyWithImpl<
          _$MortgageSearchChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(String query) searchChanged,
    required TResult Function(MortgageFilter filter) filterApplied,
    required TResult Function(int size) pageSizeChanged,
  }) {
    return searchChanged(query);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Completer<void>? completer)? refreshRequested,
    TResult? Function()? loadMoreRequested,
    TResult? Function(String query)? searchChanged,
    TResult? Function(MortgageFilter filter)? filterApplied,
    TResult? Function(int size)? pageSizeChanged,
  }) {
    return searchChanged?.call(query);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Completer<void>? completer)? refreshRequested,
    TResult Function()? loadMoreRequested,
    TResult Function(String query)? searchChanged,
    TResult Function(MortgageFilter filter)? filterApplied,
    TResult Function(int size)? pageSizeChanged,
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
    required TResult Function(MortgageStarted value) started,
    required TResult Function(MortgageRefreshRequested value) refreshRequested,
    required TResult Function(MortgageLoadMoreRequested value)
        loadMoreRequested,
    required TResult Function(MortgageSearchChanged value) searchChanged,
    required TResult Function(MortgageFilterApplied value) filterApplied,
    required TResult Function(MortgagePageSizeChanged value) pageSizeChanged,
  }) {
    return searchChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MortgageStarted value)? started,
    TResult? Function(MortgageRefreshRequested value)? refreshRequested,
    TResult? Function(MortgageLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(MortgageSearchChanged value)? searchChanged,
    TResult? Function(MortgageFilterApplied value)? filterApplied,
    TResult? Function(MortgagePageSizeChanged value)? pageSizeChanged,
  }) {
    return searchChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MortgageStarted value)? started,
    TResult Function(MortgageRefreshRequested value)? refreshRequested,
    TResult Function(MortgageLoadMoreRequested value)? loadMoreRequested,
    TResult Function(MortgageSearchChanged value)? searchChanged,
    TResult Function(MortgageFilterApplied value)? filterApplied,
    TResult Function(MortgagePageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) {
    if (searchChanged != null) {
      return searchChanged(this);
    }
    return orElse();
  }
}

abstract class MortgageSearchChanged implements MortgageEvent {
  const factory MortgageSearchChanged(final String query) =
      _$MortgageSearchChangedImpl;

  String get query;
  @JsonKey(ignore: true)
  _$$MortgageSearchChangedImplCopyWith<_$MortgageSearchChangedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MortgageFilterAppliedImplCopyWith<$Res> {
  factory _$$MortgageFilterAppliedImplCopyWith(
          _$MortgageFilterAppliedImpl value,
          $Res Function(_$MortgageFilterAppliedImpl) then) =
      __$$MortgageFilterAppliedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({MortgageFilter filter});
}

/// @nodoc
class __$$MortgageFilterAppliedImplCopyWithImpl<$Res>
    extends _$MortgageEventCopyWithImpl<$Res, _$MortgageFilterAppliedImpl>
    implements _$$MortgageFilterAppliedImplCopyWith<$Res> {
  __$$MortgageFilterAppliedImplCopyWithImpl(_$MortgageFilterAppliedImpl _value,
      $Res Function(_$MortgageFilterAppliedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filter = null,
  }) {
    return _then(_$MortgageFilterAppliedImpl(
      null == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as MortgageFilter,
    ));
  }
}

/// @nodoc

class _$MortgageFilterAppliedImpl
    with DiagnosticableTreeMixin
    implements MortgageFilterApplied {
  const _$MortgageFilterAppliedImpl(this.filter);

  @override
  final MortgageFilter filter;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MortgageEvent.filterApplied(filter: $filter)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MortgageEvent.filterApplied'))
      ..add(DiagnosticsProperty('filter', filter));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MortgageFilterAppliedImpl &&
            (identical(other.filter, filter) || other.filter == filter));
  }

  @override
  int get hashCode => Object.hash(runtimeType, filter);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MortgageFilterAppliedImplCopyWith<_$MortgageFilterAppliedImpl>
      get copyWith => __$$MortgageFilterAppliedImplCopyWithImpl<
          _$MortgageFilterAppliedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(String query) searchChanged,
    required TResult Function(MortgageFilter filter) filterApplied,
    required TResult Function(int size) pageSizeChanged,
  }) {
    return filterApplied(filter);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Completer<void>? completer)? refreshRequested,
    TResult? Function()? loadMoreRequested,
    TResult? Function(String query)? searchChanged,
    TResult? Function(MortgageFilter filter)? filterApplied,
    TResult? Function(int size)? pageSizeChanged,
  }) {
    return filterApplied?.call(filter);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Completer<void>? completer)? refreshRequested,
    TResult Function()? loadMoreRequested,
    TResult Function(String query)? searchChanged,
    TResult Function(MortgageFilter filter)? filterApplied,
    TResult Function(int size)? pageSizeChanged,
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
    required TResult Function(MortgageStarted value) started,
    required TResult Function(MortgageRefreshRequested value) refreshRequested,
    required TResult Function(MortgageLoadMoreRequested value)
        loadMoreRequested,
    required TResult Function(MortgageSearchChanged value) searchChanged,
    required TResult Function(MortgageFilterApplied value) filterApplied,
    required TResult Function(MortgagePageSizeChanged value) pageSizeChanged,
  }) {
    return filterApplied(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MortgageStarted value)? started,
    TResult? Function(MortgageRefreshRequested value)? refreshRequested,
    TResult? Function(MortgageLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(MortgageSearchChanged value)? searchChanged,
    TResult? Function(MortgageFilterApplied value)? filterApplied,
    TResult? Function(MortgagePageSizeChanged value)? pageSizeChanged,
  }) {
    return filterApplied?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MortgageStarted value)? started,
    TResult Function(MortgageRefreshRequested value)? refreshRequested,
    TResult Function(MortgageLoadMoreRequested value)? loadMoreRequested,
    TResult Function(MortgageSearchChanged value)? searchChanged,
    TResult Function(MortgageFilterApplied value)? filterApplied,
    TResult Function(MortgagePageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) {
    if (filterApplied != null) {
      return filterApplied(this);
    }
    return orElse();
  }
}

abstract class MortgageFilterApplied implements MortgageEvent {
  const factory MortgageFilterApplied(final MortgageFilter filter) =
      _$MortgageFilterAppliedImpl;

  MortgageFilter get filter;
  @JsonKey(ignore: true)
  _$$MortgageFilterAppliedImplCopyWith<_$MortgageFilterAppliedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MortgagePageSizeChangedImplCopyWith<$Res> {
  factory _$$MortgagePageSizeChangedImplCopyWith(
          _$MortgagePageSizeChangedImpl value,
          $Res Function(_$MortgagePageSizeChangedImpl) then) =
      __$$MortgagePageSizeChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int size});
}

/// @nodoc
class __$$MortgagePageSizeChangedImplCopyWithImpl<$Res>
    extends _$MortgageEventCopyWithImpl<$Res, _$MortgagePageSizeChangedImpl>
    implements _$$MortgagePageSizeChangedImplCopyWith<$Res> {
  __$$MortgagePageSizeChangedImplCopyWithImpl(
      _$MortgagePageSizeChangedImpl _value,
      $Res Function(_$MortgagePageSizeChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? size = null,
  }) {
    return _then(_$MortgagePageSizeChangedImpl(
      null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$MortgagePageSizeChangedImpl
    with DiagnosticableTreeMixin
    implements MortgagePageSizeChanged {
  const _$MortgagePageSizeChangedImpl(this.size);

  @override
  final int size;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MortgageEvent.pageSizeChanged(size: $size)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MortgageEvent.pageSizeChanged'))
      ..add(DiagnosticsProperty('size', size));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MortgagePageSizeChangedImpl &&
            (identical(other.size, size) || other.size == size));
  }

  @override
  int get hashCode => Object.hash(runtimeType, size);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MortgagePageSizeChangedImplCopyWith<_$MortgagePageSizeChangedImpl>
      get copyWith => __$$MortgagePageSizeChangedImplCopyWithImpl<
          _$MortgagePageSizeChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(String query) searchChanged,
    required TResult Function(MortgageFilter filter) filterApplied,
    required TResult Function(int size) pageSizeChanged,
  }) {
    return pageSizeChanged(size);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Completer<void>? completer)? refreshRequested,
    TResult? Function()? loadMoreRequested,
    TResult? Function(String query)? searchChanged,
    TResult? Function(MortgageFilter filter)? filterApplied,
    TResult? Function(int size)? pageSizeChanged,
  }) {
    return pageSizeChanged?.call(size);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Completer<void>? completer)? refreshRequested,
    TResult Function()? loadMoreRequested,
    TResult Function(String query)? searchChanged,
    TResult Function(MortgageFilter filter)? filterApplied,
    TResult Function(int size)? pageSizeChanged,
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
    required TResult Function(MortgageStarted value) started,
    required TResult Function(MortgageRefreshRequested value) refreshRequested,
    required TResult Function(MortgageLoadMoreRequested value)
        loadMoreRequested,
    required TResult Function(MortgageSearchChanged value) searchChanged,
    required TResult Function(MortgageFilterApplied value) filterApplied,
    required TResult Function(MortgagePageSizeChanged value) pageSizeChanged,
  }) {
    return pageSizeChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MortgageStarted value)? started,
    TResult? Function(MortgageRefreshRequested value)? refreshRequested,
    TResult? Function(MortgageLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(MortgageSearchChanged value)? searchChanged,
    TResult? Function(MortgageFilterApplied value)? filterApplied,
    TResult? Function(MortgagePageSizeChanged value)? pageSizeChanged,
  }) {
    return pageSizeChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MortgageStarted value)? started,
    TResult Function(MortgageRefreshRequested value)? refreshRequested,
    TResult Function(MortgageLoadMoreRequested value)? loadMoreRequested,
    TResult Function(MortgageSearchChanged value)? searchChanged,
    TResult Function(MortgageFilterApplied value)? filterApplied,
    TResult Function(MortgagePageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) {
    if (pageSizeChanged != null) {
      return pageSizeChanged(this);
    }
    return orElse();
  }
}

abstract class MortgagePageSizeChanged implements MortgageEvent {
  const factory MortgagePageSizeChanged(final int size) =
      _$MortgagePageSizeChangedImpl;

  int get size;
  @JsonKey(ignore: true)
  _$$MortgagePageSizeChangedImplCopyWith<_$MortgagePageSizeChangedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MortgageState {
  List<MortgageEntity> get items => throw _privateConstructorUsedError;
  MortgageFilter get filter => throw _privateConstructorUsedError;
  MortgageViewStatus get status => throw _privateConstructorUsedError;
  bool get isInitialLoading => throw _privateConstructorUsedError;
  bool get isPaginating => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get paginationErrorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MortgageStateCopyWith<MortgageState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MortgageStateCopyWith<$Res> {
  factory $MortgageStateCopyWith(
          MortgageState value, $Res Function(MortgageState) then) =
      _$MortgageStateCopyWithImpl<$Res, MortgageState>;
  @useResult
  $Res call(
      {List<MortgageEntity> items,
      MortgageFilter filter,
      MortgageViewStatus status,
      bool isInitialLoading,
      bool isPaginating,
      bool hasMore,
      int page,
      int pageSize,
      String? errorMessage,
      String? paginationErrorMessage});
}

/// @nodoc
class _$MortgageStateCopyWithImpl<$Res, $Val extends MortgageState>
    implements $MortgageStateCopyWith<$Res> {
  _$MortgageStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? filter = null,
    Object? status = null,
    Object? isInitialLoading = null,
    Object? isPaginating = null,
    Object? hasMore = null,
    Object? page = null,
    Object? pageSize = null,
    Object? errorMessage = freezed,
    Object? paginationErrorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<MortgageEntity>,
      filter: null == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as MortgageFilter,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MortgageViewStatus,
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
abstract class _$$MortgageStateImplCopyWith<$Res>
    implements $MortgageStateCopyWith<$Res> {
  factory _$$MortgageStateImplCopyWith(
          _$MortgageStateImpl value, $Res Function(_$MortgageStateImpl) then) =
      __$$MortgageStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<MortgageEntity> items,
      MortgageFilter filter,
      MortgageViewStatus status,
      bool isInitialLoading,
      bool isPaginating,
      bool hasMore,
      int page,
      int pageSize,
      String? errorMessage,
      String? paginationErrorMessage});
}

/// @nodoc
class __$$MortgageStateImplCopyWithImpl<$Res>
    extends _$MortgageStateCopyWithImpl<$Res, _$MortgageStateImpl>
    implements _$$MortgageStateImplCopyWith<$Res> {
  __$$MortgageStateImplCopyWithImpl(
      _$MortgageStateImpl _value, $Res Function(_$MortgageStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? filter = null,
    Object? status = null,
    Object? isInitialLoading = null,
    Object? isPaginating = null,
    Object? hasMore = null,
    Object? page = null,
    Object? pageSize = null,
    Object? errorMessage = freezed,
    Object? paginationErrorMessage = freezed,
  }) {
    return _then(_$MortgageStateImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<MortgageEntity>,
      filter: null == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as MortgageFilter,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MortgageViewStatus,
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

class _$MortgageStateImpl extends _MortgageState with DiagnosticableTreeMixin {
  const _$MortgageStateImpl(
      {required final List<MortgageEntity> items,
      required this.filter,
      required this.status,
      required this.isInitialLoading,
      required this.isPaginating,
      required this.hasMore,
      required this.page,
      required this.pageSize,
      this.errorMessage,
      this.paginationErrorMessage})
      : _items = items,
        super._();

  final List<MortgageEntity> _items;
  @override
  List<MortgageEntity> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final MortgageFilter filter;
  @override
  final MortgageViewStatus status;
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
  final String? errorMessage;
  @override
  final String? paginationErrorMessage;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MortgageState(items: $items, filter: $filter, status: $status, isInitialLoading: $isInitialLoading, isPaginating: $isPaginating, hasMore: $hasMore, page: $page, pageSize: $pageSize, errorMessage: $errorMessage, paginationErrorMessage: $paginationErrorMessage)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MortgageState'))
      ..add(DiagnosticsProperty('items', items))
      ..add(DiagnosticsProperty('filter', filter))
      ..add(DiagnosticsProperty('status', status))
      ..add(DiagnosticsProperty('isInitialLoading', isInitialLoading))
      ..add(DiagnosticsProperty('isPaginating', isPaginating))
      ..add(DiagnosticsProperty('hasMore', hasMore))
      ..add(DiagnosticsProperty('page', page))
      ..add(DiagnosticsProperty('pageSize', pageSize))
      ..add(DiagnosticsProperty('errorMessage', errorMessage))
      ..add(DiagnosticsProperty(
          'paginationErrorMessage', paginationErrorMessage));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MortgageStateImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
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
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.paginationErrorMessage, paginationErrorMessage) ||
                other.paginationErrorMessage == paginationErrorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      filter,
      status,
      isInitialLoading,
      isPaginating,
      hasMore,
      page,
      pageSize,
      errorMessage,
      paginationErrorMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MortgageStateImplCopyWith<_$MortgageStateImpl> get copyWith =>
      __$$MortgageStateImplCopyWithImpl<_$MortgageStateImpl>(this, _$identity);
}

abstract class _MortgageState extends MortgageState {
  const factory _MortgageState(
      {required final List<MortgageEntity> items,
      required final MortgageFilter filter,
      required final MortgageViewStatus status,
      required final bool isInitialLoading,
      required final bool isPaginating,
      required final bool hasMore,
      required final int page,
      required final int pageSize,
      final String? errorMessage,
      final String? paginationErrorMessage}) = _$MortgageStateImpl;
  const _MortgageState._() : super._();

  @override
  List<MortgageEntity> get items;
  @override
  MortgageFilter get filter;
  @override
  MortgageViewStatus get status;
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
  String? get errorMessage;
  @override
  String? get paginationErrorMessage;
  @override
  @JsonKey(ignore: true)
  _$$MortgageStateImplCopyWith<_$MortgageStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
