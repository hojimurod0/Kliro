// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deposit_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DepositEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(String query) searchChanged,
    required TResult Function(DepositFilter filter) filterApplied,
    required TResult Function(int size) pageSizeChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Completer<void>? completer)? refreshRequested,
    TResult? Function()? loadMoreRequested,
    TResult? Function(String query)? searchChanged,
    TResult? Function(DepositFilter filter)? filterApplied,
    TResult? Function(int size)? pageSizeChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Completer<void>? completer)? refreshRequested,
    TResult Function()? loadMoreRequested,
    TResult Function(String query)? searchChanged,
    TResult Function(DepositFilter filter)? filterApplied,
    TResult Function(int size)? pageSizeChanged,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DepositStarted value) started,
    required TResult Function(DepositRefreshRequested value) refreshRequested,
    required TResult Function(DepositLoadMoreRequested value) loadMoreRequested,
    required TResult Function(DepositSearchChanged value) searchChanged,
    required TResult Function(DepositFilterApplied value) filterApplied,
    required TResult Function(DepositPageSizeChanged value) pageSizeChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DepositStarted value)? started,
    TResult? Function(DepositRefreshRequested value)? refreshRequested,
    TResult? Function(DepositLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(DepositSearchChanged value)? searchChanged,
    TResult? Function(DepositFilterApplied value)? filterApplied,
    TResult? Function(DepositPageSizeChanged value)? pageSizeChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DepositStarted value)? started,
    TResult Function(DepositRefreshRequested value)? refreshRequested,
    TResult Function(DepositLoadMoreRequested value)? loadMoreRequested,
    TResult Function(DepositSearchChanged value)? searchChanged,
    TResult Function(DepositFilterApplied value)? filterApplied,
    TResult Function(DepositPageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DepositEventCopyWith<$Res> {
  factory $DepositEventCopyWith(
          DepositEvent value, $Res Function(DepositEvent) then) =
      _$DepositEventCopyWithImpl<$Res, DepositEvent>;
}

/// @nodoc
class _$DepositEventCopyWithImpl<$Res, $Val extends DepositEvent>
    implements $DepositEventCopyWith<$Res> {
  _$DepositEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$DepositStartedImplCopyWith<$Res> {
  factory _$$DepositStartedImplCopyWith(_$DepositStartedImpl value,
          $Res Function(_$DepositStartedImpl) then) =
      __$$DepositStartedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DepositStartedImplCopyWithImpl<$Res>
    extends _$DepositEventCopyWithImpl<$Res, _$DepositStartedImpl>
    implements _$$DepositStartedImplCopyWith<$Res> {
  __$$DepositStartedImplCopyWithImpl(
      _$DepositStartedImpl _value, $Res Function(_$DepositStartedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$DepositStartedImpl
    with DiagnosticableTreeMixin
    implements DepositStarted {
  const _$DepositStartedImpl();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DepositEvent.started()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('type', 'DepositEvent.started'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$DepositStartedImpl);
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
    required TResult Function(DepositFilter filter) filterApplied,
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
    TResult? Function(DepositFilter filter)? filterApplied,
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
    TResult Function(DepositFilter filter)? filterApplied,
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
    required TResult Function(DepositStarted value) started,
    required TResult Function(DepositRefreshRequested value) refreshRequested,
    required TResult Function(DepositLoadMoreRequested value) loadMoreRequested,
    required TResult Function(DepositSearchChanged value) searchChanged,
    required TResult Function(DepositFilterApplied value) filterApplied,
    required TResult Function(DepositPageSizeChanged value) pageSizeChanged,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DepositStarted value)? started,
    TResult? Function(DepositRefreshRequested value)? refreshRequested,
    TResult? Function(DepositLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(DepositSearchChanged value)? searchChanged,
    TResult? Function(DepositFilterApplied value)? filterApplied,
    TResult? Function(DepositPageSizeChanged value)? pageSizeChanged,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DepositStarted value)? started,
    TResult Function(DepositRefreshRequested value)? refreshRequested,
    TResult Function(DepositLoadMoreRequested value)? loadMoreRequested,
    TResult Function(DepositSearchChanged value)? searchChanged,
    TResult Function(DepositFilterApplied value)? filterApplied,
    TResult Function(DepositPageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class DepositStarted implements DepositEvent {
  const factory DepositStarted() = _$DepositStartedImpl;
}

/// @nodoc
abstract class _$$DepositRefreshRequestedImplCopyWith<$Res> {
  factory _$$DepositRefreshRequestedImplCopyWith(
          _$DepositRefreshRequestedImpl value,
          $Res Function(_$DepositRefreshRequestedImpl) then) =
      __$$DepositRefreshRequestedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Completer<void>? completer});
}

/// @nodoc
class __$$DepositRefreshRequestedImplCopyWithImpl<$Res>
    extends _$DepositEventCopyWithImpl<$Res, _$DepositRefreshRequestedImpl>
    implements _$$DepositRefreshRequestedImplCopyWith<$Res> {
  __$$DepositRefreshRequestedImplCopyWithImpl(
      _$DepositRefreshRequestedImpl _value,
      $Res Function(_$DepositRefreshRequestedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completer = freezed,
  }) {
    return _then(_$DepositRefreshRequestedImpl(
      completer: freezed == completer
          ? _value.completer
          : completer // ignore: cast_nullable_to_non_nullable
              as Completer<void>?,
    ));
  }
}

/// @nodoc

class _$DepositRefreshRequestedImpl
    with DiagnosticableTreeMixin
    implements DepositRefreshRequested {
  const _$DepositRefreshRequestedImpl({this.completer});

  @override
  final Completer<void>? completer;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DepositEvent.refreshRequested(completer: $completer)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'DepositEvent.refreshRequested'))
      ..add(DiagnosticsProperty('completer', completer));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DepositRefreshRequestedImpl &&
            (identical(other.completer, completer) ||
                other.completer == completer));
  }

  @override
  int get hashCode => Object.hash(runtimeType, completer);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DepositRefreshRequestedImplCopyWith<_$DepositRefreshRequestedImpl>
      get copyWith => __$$DepositRefreshRequestedImplCopyWithImpl<
          _$DepositRefreshRequestedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(String query) searchChanged,
    required TResult Function(DepositFilter filter) filterApplied,
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
    TResult? Function(DepositFilter filter)? filterApplied,
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
    TResult Function(DepositFilter filter)? filterApplied,
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
    required TResult Function(DepositStarted value) started,
    required TResult Function(DepositRefreshRequested value) refreshRequested,
    required TResult Function(DepositLoadMoreRequested value) loadMoreRequested,
    required TResult Function(DepositSearchChanged value) searchChanged,
    required TResult Function(DepositFilterApplied value) filterApplied,
    required TResult Function(DepositPageSizeChanged value) pageSizeChanged,
  }) {
    return refreshRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DepositStarted value)? started,
    TResult? Function(DepositRefreshRequested value)? refreshRequested,
    TResult? Function(DepositLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(DepositSearchChanged value)? searchChanged,
    TResult? Function(DepositFilterApplied value)? filterApplied,
    TResult? Function(DepositPageSizeChanged value)? pageSizeChanged,
  }) {
    return refreshRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DepositStarted value)? started,
    TResult Function(DepositRefreshRequested value)? refreshRequested,
    TResult Function(DepositLoadMoreRequested value)? loadMoreRequested,
    TResult Function(DepositSearchChanged value)? searchChanged,
    TResult Function(DepositFilterApplied value)? filterApplied,
    TResult Function(DepositPageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) {
    if (refreshRequested != null) {
      return refreshRequested(this);
    }
    return orElse();
  }
}

abstract class DepositRefreshRequested implements DepositEvent {
  const factory DepositRefreshRequested({final Completer<void>? completer}) =
      _$DepositRefreshRequestedImpl;

  Completer<void>? get completer;
  @JsonKey(ignore: true)
  _$$DepositRefreshRequestedImplCopyWith<_$DepositRefreshRequestedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DepositLoadMoreRequestedImplCopyWith<$Res> {
  factory _$$DepositLoadMoreRequestedImplCopyWith(
          _$DepositLoadMoreRequestedImpl value,
          $Res Function(_$DepositLoadMoreRequestedImpl) then) =
      __$$DepositLoadMoreRequestedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DepositLoadMoreRequestedImplCopyWithImpl<$Res>
    extends _$DepositEventCopyWithImpl<$Res, _$DepositLoadMoreRequestedImpl>
    implements _$$DepositLoadMoreRequestedImplCopyWith<$Res> {
  __$$DepositLoadMoreRequestedImplCopyWithImpl(
      _$DepositLoadMoreRequestedImpl _value,
      $Res Function(_$DepositLoadMoreRequestedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$DepositLoadMoreRequestedImpl
    with DiagnosticableTreeMixin
    implements DepositLoadMoreRequested {
  const _$DepositLoadMoreRequestedImpl();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DepositEvent.loadMoreRequested()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty('type', 'DepositEvent.loadMoreRequested'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DepositLoadMoreRequestedImpl);
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
    required TResult Function(DepositFilter filter) filterApplied,
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
    TResult? Function(DepositFilter filter)? filterApplied,
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
    TResult Function(DepositFilter filter)? filterApplied,
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
    required TResult Function(DepositStarted value) started,
    required TResult Function(DepositRefreshRequested value) refreshRequested,
    required TResult Function(DepositLoadMoreRequested value) loadMoreRequested,
    required TResult Function(DepositSearchChanged value) searchChanged,
    required TResult Function(DepositFilterApplied value) filterApplied,
    required TResult Function(DepositPageSizeChanged value) pageSizeChanged,
  }) {
    return loadMoreRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DepositStarted value)? started,
    TResult? Function(DepositRefreshRequested value)? refreshRequested,
    TResult? Function(DepositLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(DepositSearchChanged value)? searchChanged,
    TResult? Function(DepositFilterApplied value)? filterApplied,
    TResult? Function(DepositPageSizeChanged value)? pageSizeChanged,
  }) {
    return loadMoreRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DepositStarted value)? started,
    TResult Function(DepositRefreshRequested value)? refreshRequested,
    TResult Function(DepositLoadMoreRequested value)? loadMoreRequested,
    TResult Function(DepositSearchChanged value)? searchChanged,
    TResult Function(DepositFilterApplied value)? filterApplied,
    TResult Function(DepositPageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) {
    if (loadMoreRequested != null) {
      return loadMoreRequested(this);
    }
    return orElse();
  }
}

abstract class DepositLoadMoreRequested implements DepositEvent {
  const factory DepositLoadMoreRequested() = _$DepositLoadMoreRequestedImpl;
}

/// @nodoc
abstract class _$$DepositSearchChangedImplCopyWith<$Res> {
  factory _$$DepositSearchChangedImplCopyWith(_$DepositSearchChangedImpl value,
          $Res Function(_$DepositSearchChangedImpl) then) =
      __$$DepositSearchChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String query});
}

/// @nodoc
class __$$DepositSearchChangedImplCopyWithImpl<$Res>
    extends _$DepositEventCopyWithImpl<$Res, _$DepositSearchChangedImpl>
    implements _$$DepositSearchChangedImplCopyWith<$Res> {
  __$$DepositSearchChangedImplCopyWithImpl(_$DepositSearchChangedImpl _value,
      $Res Function(_$DepositSearchChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
  }) {
    return _then(_$DepositSearchChangedImpl(
      null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DepositSearchChangedImpl
    with DiagnosticableTreeMixin
    implements DepositSearchChanged {
  const _$DepositSearchChangedImpl(this.query);

  @override
  final String query;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DepositEvent.searchChanged(query: $query)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'DepositEvent.searchChanged'))
      ..add(DiagnosticsProperty('query', query));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DepositSearchChangedImpl &&
            (identical(other.query, query) || other.query == query));
  }

  @override
  int get hashCode => Object.hash(runtimeType, query);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DepositSearchChangedImplCopyWith<_$DepositSearchChangedImpl>
      get copyWith =>
          __$$DepositSearchChangedImplCopyWithImpl<_$DepositSearchChangedImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(String query) searchChanged,
    required TResult Function(DepositFilter filter) filterApplied,
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
    TResult? Function(DepositFilter filter)? filterApplied,
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
    TResult Function(DepositFilter filter)? filterApplied,
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
    required TResult Function(DepositStarted value) started,
    required TResult Function(DepositRefreshRequested value) refreshRequested,
    required TResult Function(DepositLoadMoreRequested value) loadMoreRequested,
    required TResult Function(DepositSearchChanged value) searchChanged,
    required TResult Function(DepositFilterApplied value) filterApplied,
    required TResult Function(DepositPageSizeChanged value) pageSizeChanged,
  }) {
    return searchChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DepositStarted value)? started,
    TResult? Function(DepositRefreshRequested value)? refreshRequested,
    TResult? Function(DepositLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(DepositSearchChanged value)? searchChanged,
    TResult? Function(DepositFilterApplied value)? filterApplied,
    TResult? Function(DepositPageSizeChanged value)? pageSizeChanged,
  }) {
    return searchChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DepositStarted value)? started,
    TResult Function(DepositRefreshRequested value)? refreshRequested,
    TResult Function(DepositLoadMoreRequested value)? loadMoreRequested,
    TResult Function(DepositSearchChanged value)? searchChanged,
    TResult Function(DepositFilterApplied value)? filterApplied,
    TResult Function(DepositPageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) {
    if (searchChanged != null) {
      return searchChanged(this);
    }
    return orElse();
  }
}

abstract class DepositSearchChanged implements DepositEvent {
  const factory DepositSearchChanged(final String query) =
      _$DepositSearchChangedImpl;

  String get query;
  @JsonKey(ignore: true)
  _$$DepositSearchChangedImplCopyWith<_$DepositSearchChangedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DepositFilterAppliedImplCopyWith<$Res> {
  factory _$$DepositFilterAppliedImplCopyWith(_$DepositFilterAppliedImpl value,
          $Res Function(_$DepositFilterAppliedImpl) then) =
      __$$DepositFilterAppliedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({DepositFilter filter});
}

/// @nodoc
class __$$DepositFilterAppliedImplCopyWithImpl<$Res>
    extends _$DepositEventCopyWithImpl<$Res, _$DepositFilterAppliedImpl>
    implements _$$DepositFilterAppliedImplCopyWith<$Res> {
  __$$DepositFilterAppliedImplCopyWithImpl(_$DepositFilterAppliedImpl _value,
      $Res Function(_$DepositFilterAppliedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filter = null,
  }) {
    return _then(_$DepositFilterAppliedImpl(
      null == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as DepositFilter,
    ));
  }
}

/// @nodoc

class _$DepositFilterAppliedImpl
    with DiagnosticableTreeMixin
    implements DepositFilterApplied {
  const _$DepositFilterAppliedImpl(this.filter);

  @override
  final DepositFilter filter;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DepositEvent.filterApplied(filter: $filter)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'DepositEvent.filterApplied'))
      ..add(DiagnosticsProperty('filter', filter));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DepositFilterAppliedImpl &&
            (identical(other.filter, filter) || other.filter == filter));
  }

  @override
  int get hashCode => Object.hash(runtimeType, filter);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DepositFilterAppliedImplCopyWith<_$DepositFilterAppliedImpl>
      get copyWith =>
          __$$DepositFilterAppliedImplCopyWithImpl<_$DepositFilterAppliedImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(String query) searchChanged,
    required TResult Function(DepositFilter filter) filterApplied,
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
    TResult? Function(DepositFilter filter)? filterApplied,
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
    TResult Function(DepositFilter filter)? filterApplied,
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
    required TResult Function(DepositStarted value) started,
    required TResult Function(DepositRefreshRequested value) refreshRequested,
    required TResult Function(DepositLoadMoreRequested value) loadMoreRequested,
    required TResult Function(DepositSearchChanged value) searchChanged,
    required TResult Function(DepositFilterApplied value) filterApplied,
    required TResult Function(DepositPageSizeChanged value) pageSizeChanged,
  }) {
    return filterApplied(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DepositStarted value)? started,
    TResult? Function(DepositRefreshRequested value)? refreshRequested,
    TResult? Function(DepositLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(DepositSearchChanged value)? searchChanged,
    TResult? Function(DepositFilterApplied value)? filterApplied,
    TResult? Function(DepositPageSizeChanged value)? pageSizeChanged,
  }) {
    return filterApplied?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DepositStarted value)? started,
    TResult Function(DepositRefreshRequested value)? refreshRequested,
    TResult Function(DepositLoadMoreRequested value)? loadMoreRequested,
    TResult Function(DepositSearchChanged value)? searchChanged,
    TResult Function(DepositFilterApplied value)? filterApplied,
    TResult Function(DepositPageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) {
    if (filterApplied != null) {
      return filterApplied(this);
    }
    return orElse();
  }
}

abstract class DepositFilterApplied implements DepositEvent {
  const factory DepositFilterApplied(final DepositFilter filter) =
      _$DepositFilterAppliedImpl;

  DepositFilter get filter;
  @JsonKey(ignore: true)
  _$$DepositFilterAppliedImplCopyWith<_$DepositFilterAppliedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DepositPageSizeChangedImplCopyWith<$Res> {
  factory _$$DepositPageSizeChangedImplCopyWith(
          _$DepositPageSizeChangedImpl value,
          $Res Function(_$DepositPageSizeChangedImpl) then) =
      __$$DepositPageSizeChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int size});
}

/// @nodoc
class __$$DepositPageSizeChangedImplCopyWithImpl<$Res>
    extends _$DepositEventCopyWithImpl<$Res, _$DepositPageSizeChangedImpl>
    implements _$$DepositPageSizeChangedImplCopyWith<$Res> {
  __$$DepositPageSizeChangedImplCopyWithImpl(
      _$DepositPageSizeChangedImpl _value,
      $Res Function(_$DepositPageSizeChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? size = null,
  }) {
    return _then(_$DepositPageSizeChangedImpl(
      null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$DepositPageSizeChangedImpl
    with DiagnosticableTreeMixin
    implements DepositPageSizeChanged {
  const _$DepositPageSizeChangedImpl(this.size);

  @override
  final int size;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DepositEvent.pageSizeChanged(size: $size)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'DepositEvent.pageSizeChanged'))
      ..add(DiagnosticsProperty('size', size));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DepositPageSizeChangedImpl &&
            (identical(other.size, size) || other.size == size));
  }

  @override
  int get hashCode => Object.hash(runtimeType, size);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DepositPageSizeChangedImplCopyWith<_$DepositPageSizeChangedImpl>
      get copyWith => __$$DepositPageSizeChangedImplCopyWithImpl<
          _$DepositPageSizeChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(String query) searchChanged,
    required TResult Function(DepositFilter filter) filterApplied,
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
    TResult? Function(DepositFilter filter)? filterApplied,
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
    TResult Function(DepositFilter filter)? filterApplied,
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
    required TResult Function(DepositStarted value) started,
    required TResult Function(DepositRefreshRequested value) refreshRequested,
    required TResult Function(DepositLoadMoreRequested value) loadMoreRequested,
    required TResult Function(DepositSearchChanged value) searchChanged,
    required TResult Function(DepositFilterApplied value) filterApplied,
    required TResult Function(DepositPageSizeChanged value) pageSizeChanged,
  }) {
    return pageSizeChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DepositStarted value)? started,
    TResult? Function(DepositRefreshRequested value)? refreshRequested,
    TResult? Function(DepositLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(DepositSearchChanged value)? searchChanged,
    TResult? Function(DepositFilterApplied value)? filterApplied,
    TResult? Function(DepositPageSizeChanged value)? pageSizeChanged,
  }) {
    return pageSizeChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DepositStarted value)? started,
    TResult Function(DepositRefreshRequested value)? refreshRequested,
    TResult Function(DepositLoadMoreRequested value)? loadMoreRequested,
    TResult Function(DepositSearchChanged value)? searchChanged,
    TResult Function(DepositFilterApplied value)? filterApplied,
    TResult Function(DepositPageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) {
    if (pageSizeChanged != null) {
      return pageSizeChanged(this);
    }
    return orElse();
  }
}

abstract class DepositPageSizeChanged implements DepositEvent {
  const factory DepositPageSizeChanged(final int size) =
      _$DepositPageSizeChangedImpl;

  int get size;
  @JsonKey(ignore: true)
  _$$DepositPageSizeChangedImplCopyWith<_$DepositPageSizeChangedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DepositState {
  List<DepositEntity> get items => throw _privateConstructorUsedError;
  DepositFilter get filter => throw _privateConstructorUsedError;
  DepositViewStatus get status => throw _privateConstructorUsedError;
  bool get isInitialLoading => throw _privateConstructorUsedError;
  bool get isPaginating => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get paginationErrorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DepositStateCopyWith<DepositState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DepositStateCopyWith<$Res> {
  factory $DepositStateCopyWith(
          DepositState value, $Res Function(DepositState) then) =
      _$DepositStateCopyWithImpl<$Res, DepositState>;
  @useResult
  $Res call(
      {List<DepositEntity> items,
      DepositFilter filter,
      DepositViewStatus status,
      bool isInitialLoading,
      bool isPaginating,
      bool hasMore,
      int page,
      int pageSize,
      String? errorMessage,
      String? paginationErrorMessage});
}

/// @nodoc
class _$DepositStateCopyWithImpl<$Res, $Val extends DepositState>
    implements $DepositStateCopyWith<$Res> {
  _$DepositStateCopyWithImpl(this._value, this._then);

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
              as List<DepositEntity>,
      filter: null == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as DepositFilter,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DepositViewStatus,
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
abstract class _$$DepositStateImplCopyWith<$Res>
    implements $DepositStateCopyWith<$Res> {
  factory _$$DepositStateImplCopyWith(
          _$DepositStateImpl value, $Res Function(_$DepositStateImpl) then) =
      __$$DepositStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<DepositEntity> items,
      DepositFilter filter,
      DepositViewStatus status,
      bool isInitialLoading,
      bool isPaginating,
      bool hasMore,
      int page,
      int pageSize,
      String? errorMessage,
      String? paginationErrorMessage});
}

/// @nodoc
class __$$DepositStateImplCopyWithImpl<$Res>
    extends _$DepositStateCopyWithImpl<$Res, _$DepositStateImpl>
    implements _$$DepositStateImplCopyWith<$Res> {
  __$$DepositStateImplCopyWithImpl(
      _$DepositStateImpl _value, $Res Function(_$DepositStateImpl) _then)
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
    return _then(_$DepositStateImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<DepositEntity>,
      filter: null == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as DepositFilter,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DepositViewStatus,
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

class _$DepositStateImpl extends _DepositState with DiagnosticableTreeMixin {
  const _$DepositStateImpl(
      {required final List<DepositEntity> items,
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

  final List<DepositEntity> _items;
  @override
  List<DepositEntity> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final DepositFilter filter;
  @override
  final DepositViewStatus status;
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
    return 'DepositState(items: $items, filter: $filter, status: $status, isInitialLoading: $isInitialLoading, isPaginating: $isPaginating, hasMore: $hasMore, page: $page, pageSize: $pageSize, errorMessage: $errorMessage, paginationErrorMessage: $paginationErrorMessage)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'DepositState'))
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
            other is _$DepositStateImpl &&
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
  _$$DepositStateImplCopyWith<_$DepositStateImpl> get copyWith =>
      __$$DepositStateImplCopyWithImpl<_$DepositStateImpl>(this, _$identity);
}

abstract class _DepositState extends DepositState {
  const factory _DepositState(
      {required final List<DepositEntity> items,
      required final DepositFilter filter,
      required final DepositViewStatus status,
      required final bool isInitialLoading,
      required final bool isPaginating,
      required final bool hasMore,
      required final int page,
      required final int pageSize,
      final String? errorMessage,
      final String? paginationErrorMessage}) = _$DepositStateImpl;
  const _DepositState._() : super._();

  @override
  List<DepositEntity> get items;
  @override
  DepositFilter get filter;
  @override
  DepositViewStatus get status;
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
  _$$DepositStateImplCopyWith<_$DepositStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
