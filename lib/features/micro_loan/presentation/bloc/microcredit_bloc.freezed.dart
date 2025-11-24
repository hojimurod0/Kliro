// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'microcredit_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MicrocreditEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(String query) searchChanged,
    required TResult Function(MicrocreditFilter filter) filterApplied,
    required TResult Function(int size) pageSizeChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Completer<void>? completer)? refreshRequested,
    TResult? Function()? loadMoreRequested,
    TResult? Function(String query)? searchChanged,
    TResult? Function(MicrocreditFilter filter)? filterApplied,
    TResult? Function(int size)? pageSizeChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Completer<void>? completer)? refreshRequested,
    TResult Function()? loadMoreRequested,
    TResult Function(String query)? searchChanged,
    TResult Function(MicrocreditFilter filter)? filterApplied,
    TResult Function(int size)? pageSizeChanged,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(MicrocreditStarted value) started,
    required TResult Function(MicrocreditRefreshRequested value)
        refreshRequested,
    required TResult Function(MicrocreditLoadMoreRequested value)
        loadMoreRequested,
    required TResult Function(MicrocreditSearchChanged value) searchChanged,
    required TResult Function(MicrocreditFilterApplied value) filterApplied,
    required TResult Function(MicrocreditPageSizeChanged value) pageSizeChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MicrocreditStarted value)? started,
    TResult? Function(MicrocreditRefreshRequested value)? refreshRequested,
    TResult? Function(MicrocreditLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(MicrocreditSearchChanged value)? searchChanged,
    TResult? Function(MicrocreditFilterApplied value)? filterApplied,
    TResult? Function(MicrocreditPageSizeChanged value)? pageSizeChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MicrocreditStarted value)? started,
    TResult Function(MicrocreditRefreshRequested value)? refreshRequested,
    TResult Function(MicrocreditLoadMoreRequested value)? loadMoreRequested,
    TResult Function(MicrocreditSearchChanged value)? searchChanged,
    TResult Function(MicrocreditFilterApplied value)? filterApplied,
    TResult Function(MicrocreditPageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MicrocreditEventCopyWith<$Res> {
  factory $MicrocreditEventCopyWith(
          MicrocreditEvent value, $Res Function(MicrocreditEvent) then) =
      _$MicrocreditEventCopyWithImpl<$Res, MicrocreditEvent>;
}

/// @nodoc
class _$MicrocreditEventCopyWithImpl<$Res, $Val extends MicrocreditEvent>
    implements $MicrocreditEventCopyWith<$Res> {
  _$MicrocreditEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$MicrocreditStartedImplCopyWith<$Res> {
  factory _$$MicrocreditStartedImplCopyWith(_$MicrocreditStartedImpl value,
          $Res Function(_$MicrocreditStartedImpl) then) =
      __$$MicrocreditStartedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MicrocreditStartedImplCopyWithImpl<$Res>
    extends _$MicrocreditEventCopyWithImpl<$Res, _$MicrocreditStartedImpl>
    implements _$$MicrocreditStartedImplCopyWith<$Res> {
  __$$MicrocreditStartedImplCopyWithImpl(_$MicrocreditStartedImpl _value,
      $Res Function(_$MicrocreditStartedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$MicrocreditStartedImpl
    with DiagnosticableTreeMixin
    implements MicrocreditStarted {
  const _$MicrocreditStartedImpl();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MicrocreditEvent.started()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('type', 'MicrocreditEvent.started'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$MicrocreditStartedImpl);
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
    required TResult Function(MicrocreditFilter filter) filterApplied,
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
    TResult? Function(MicrocreditFilter filter)? filterApplied,
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
    TResult Function(MicrocreditFilter filter)? filterApplied,
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
    required TResult Function(MicrocreditStarted value) started,
    required TResult Function(MicrocreditRefreshRequested value)
        refreshRequested,
    required TResult Function(MicrocreditLoadMoreRequested value)
        loadMoreRequested,
    required TResult Function(MicrocreditSearchChanged value) searchChanged,
    required TResult Function(MicrocreditFilterApplied value) filterApplied,
    required TResult Function(MicrocreditPageSizeChanged value) pageSizeChanged,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MicrocreditStarted value)? started,
    TResult? Function(MicrocreditRefreshRequested value)? refreshRequested,
    TResult? Function(MicrocreditLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(MicrocreditSearchChanged value)? searchChanged,
    TResult? Function(MicrocreditFilterApplied value)? filterApplied,
    TResult? Function(MicrocreditPageSizeChanged value)? pageSizeChanged,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MicrocreditStarted value)? started,
    TResult Function(MicrocreditRefreshRequested value)? refreshRequested,
    TResult Function(MicrocreditLoadMoreRequested value)? loadMoreRequested,
    TResult Function(MicrocreditSearchChanged value)? searchChanged,
    TResult Function(MicrocreditFilterApplied value)? filterApplied,
    TResult Function(MicrocreditPageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class MicrocreditStarted implements MicrocreditEvent {
  const factory MicrocreditStarted() = _$MicrocreditStartedImpl;
}

/// @nodoc
abstract class _$$MicrocreditRefreshRequestedImplCopyWith<$Res> {
  factory _$$MicrocreditRefreshRequestedImplCopyWith(
          _$MicrocreditRefreshRequestedImpl value,
          $Res Function(_$MicrocreditRefreshRequestedImpl) then) =
      __$$MicrocreditRefreshRequestedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Completer<void>? completer});
}

/// @nodoc
class __$$MicrocreditRefreshRequestedImplCopyWithImpl<$Res>
    extends _$MicrocreditEventCopyWithImpl<$Res,
        _$MicrocreditRefreshRequestedImpl>
    implements _$$MicrocreditRefreshRequestedImplCopyWith<$Res> {
  __$$MicrocreditRefreshRequestedImplCopyWithImpl(
      _$MicrocreditRefreshRequestedImpl _value,
      $Res Function(_$MicrocreditRefreshRequestedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completer = freezed,
  }) {
    return _then(_$MicrocreditRefreshRequestedImpl(
      completer: freezed == completer
          ? _value.completer
          : completer // ignore: cast_nullable_to_non_nullable
              as Completer<void>?,
    ));
  }
}

/// @nodoc

class _$MicrocreditRefreshRequestedImpl
    with DiagnosticableTreeMixin
    implements MicrocreditRefreshRequested {
  const _$MicrocreditRefreshRequestedImpl({this.completer});

  @override
  final Completer<void>? completer;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MicrocreditEvent.refreshRequested(completer: $completer)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MicrocreditEvent.refreshRequested'))
      ..add(DiagnosticsProperty('completer', completer));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MicrocreditRefreshRequestedImpl &&
            (identical(other.completer, completer) ||
                other.completer == completer));
  }

  @override
  int get hashCode => Object.hash(runtimeType, completer);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MicrocreditRefreshRequestedImplCopyWith<_$MicrocreditRefreshRequestedImpl>
      get copyWith => __$$MicrocreditRefreshRequestedImplCopyWithImpl<
          _$MicrocreditRefreshRequestedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(String query) searchChanged,
    required TResult Function(MicrocreditFilter filter) filterApplied,
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
    TResult? Function(MicrocreditFilter filter)? filterApplied,
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
    TResult Function(MicrocreditFilter filter)? filterApplied,
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
    required TResult Function(MicrocreditStarted value) started,
    required TResult Function(MicrocreditRefreshRequested value)
        refreshRequested,
    required TResult Function(MicrocreditLoadMoreRequested value)
        loadMoreRequested,
    required TResult Function(MicrocreditSearchChanged value) searchChanged,
    required TResult Function(MicrocreditFilterApplied value) filterApplied,
    required TResult Function(MicrocreditPageSizeChanged value) pageSizeChanged,
  }) {
    return refreshRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MicrocreditStarted value)? started,
    TResult? Function(MicrocreditRefreshRequested value)? refreshRequested,
    TResult? Function(MicrocreditLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(MicrocreditSearchChanged value)? searchChanged,
    TResult? Function(MicrocreditFilterApplied value)? filterApplied,
    TResult? Function(MicrocreditPageSizeChanged value)? pageSizeChanged,
  }) {
    return refreshRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MicrocreditStarted value)? started,
    TResult Function(MicrocreditRefreshRequested value)? refreshRequested,
    TResult Function(MicrocreditLoadMoreRequested value)? loadMoreRequested,
    TResult Function(MicrocreditSearchChanged value)? searchChanged,
    TResult Function(MicrocreditFilterApplied value)? filterApplied,
    TResult Function(MicrocreditPageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) {
    if (refreshRequested != null) {
      return refreshRequested(this);
    }
    return orElse();
  }
}

abstract class MicrocreditRefreshRequested implements MicrocreditEvent {
  const factory MicrocreditRefreshRequested(
      {final Completer<void>? completer}) = _$MicrocreditRefreshRequestedImpl;

  Completer<void>? get completer;
  @JsonKey(ignore: true)
  _$$MicrocreditRefreshRequestedImplCopyWith<_$MicrocreditRefreshRequestedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MicrocreditLoadMoreRequestedImplCopyWith<$Res> {
  factory _$$MicrocreditLoadMoreRequestedImplCopyWith(
          _$MicrocreditLoadMoreRequestedImpl value,
          $Res Function(_$MicrocreditLoadMoreRequestedImpl) then) =
      __$$MicrocreditLoadMoreRequestedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MicrocreditLoadMoreRequestedImplCopyWithImpl<$Res>
    extends _$MicrocreditEventCopyWithImpl<$Res,
        _$MicrocreditLoadMoreRequestedImpl>
    implements _$$MicrocreditLoadMoreRequestedImplCopyWith<$Res> {
  __$$MicrocreditLoadMoreRequestedImplCopyWithImpl(
      _$MicrocreditLoadMoreRequestedImpl _value,
      $Res Function(_$MicrocreditLoadMoreRequestedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$MicrocreditLoadMoreRequestedImpl
    with DiagnosticableTreeMixin
    implements MicrocreditLoadMoreRequested {
  const _$MicrocreditLoadMoreRequestedImpl();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MicrocreditEvent.loadMoreRequested()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty('type', 'MicrocreditEvent.loadMoreRequested'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MicrocreditLoadMoreRequestedImpl);
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
    required TResult Function(MicrocreditFilter filter) filterApplied,
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
    TResult? Function(MicrocreditFilter filter)? filterApplied,
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
    TResult Function(MicrocreditFilter filter)? filterApplied,
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
    required TResult Function(MicrocreditStarted value) started,
    required TResult Function(MicrocreditRefreshRequested value)
        refreshRequested,
    required TResult Function(MicrocreditLoadMoreRequested value)
        loadMoreRequested,
    required TResult Function(MicrocreditSearchChanged value) searchChanged,
    required TResult Function(MicrocreditFilterApplied value) filterApplied,
    required TResult Function(MicrocreditPageSizeChanged value) pageSizeChanged,
  }) {
    return loadMoreRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MicrocreditStarted value)? started,
    TResult? Function(MicrocreditRefreshRequested value)? refreshRequested,
    TResult? Function(MicrocreditLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(MicrocreditSearchChanged value)? searchChanged,
    TResult? Function(MicrocreditFilterApplied value)? filterApplied,
    TResult? Function(MicrocreditPageSizeChanged value)? pageSizeChanged,
  }) {
    return loadMoreRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MicrocreditStarted value)? started,
    TResult Function(MicrocreditRefreshRequested value)? refreshRequested,
    TResult Function(MicrocreditLoadMoreRequested value)? loadMoreRequested,
    TResult Function(MicrocreditSearchChanged value)? searchChanged,
    TResult Function(MicrocreditFilterApplied value)? filterApplied,
    TResult Function(MicrocreditPageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) {
    if (loadMoreRequested != null) {
      return loadMoreRequested(this);
    }
    return orElse();
  }
}

abstract class MicrocreditLoadMoreRequested implements MicrocreditEvent {
  const factory MicrocreditLoadMoreRequested() =
      _$MicrocreditLoadMoreRequestedImpl;
}

/// @nodoc
abstract class _$$MicrocreditSearchChangedImplCopyWith<$Res> {
  factory _$$MicrocreditSearchChangedImplCopyWith(
          _$MicrocreditSearchChangedImpl value,
          $Res Function(_$MicrocreditSearchChangedImpl) then) =
      __$$MicrocreditSearchChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String query});
}

/// @nodoc
class __$$MicrocreditSearchChangedImplCopyWithImpl<$Res>
    extends _$MicrocreditEventCopyWithImpl<$Res, _$MicrocreditSearchChangedImpl>
    implements _$$MicrocreditSearchChangedImplCopyWith<$Res> {
  __$$MicrocreditSearchChangedImplCopyWithImpl(
      _$MicrocreditSearchChangedImpl _value,
      $Res Function(_$MicrocreditSearchChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
  }) {
    return _then(_$MicrocreditSearchChangedImpl(
      null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$MicrocreditSearchChangedImpl
    with DiagnosticableTreeMixin
    implements MicrocreditSearchChanged {
  const _$MicrocreditSearchChangedImpl(this.query);

  @override
  final String query;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MicrocreditEvent.searchChanged(query: $query)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MicrocreditEvent.searchChanged'))
      ..add(DiagnosticsProperty('query', query));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MicrocreditSearchChangedImpl &&
            (identical(other.query, query) || other.query == query));
  }

  @override
  int get hashCode => Object.hash(runtimeType, query);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MicrocreditSearchChangedImplCopyWith<_$MicrocreditSearchChangedImpl>
      get copyWith => __$$MicrocreditSearchChangedImplCopyWithImpl<
          _$MicrocreditSearchChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(String query) searchChanged,
    required TResult Function(MicrocreditFilter filter) filterApplied,
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
    TResult? Function(MicrocreditFilter filter)? filterApplied,
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
    TResult Function(MicrocreditFilter filter)? filterApplied,
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
    required TResult Function(MicrocreditStarted value) started,
    required TResult Function(MicrocreditRefreshRequested value)
        refreshRequested,
    required TResult Function(MicrocreditLoadMoreRequested value)
        loadMoreRequested,
    required TResult Function(MicrocreditSearchChanged value) searchChanged,
    required TResult Function(MicrocreditFilterApplied value) filterApplied,
    required TResult Function(MicrocreditPageSizeChanged value) pageSizeChanged,
  }) {
    return searchChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MicrocreditStarted value)? started,
    TResult? Function(MicrocreditRefreshRequested value)? refreshRequested,
    TResult? Function(MicrocreditLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(MicrocreditSearchChanged value)? searchChanged,
    TResult? Function(MicrocreditFilterApplied value)? filterApplied,
    TResult? Function(MicrocreditPageSizeChanged value)? pageSizeChanged,
  }) {
    return searchChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MicrocreditStarted value)? started,
    TResult Function(MicrocreditRefreshRequested value)? refreshRequested,
    TResult Function(MicrocreditLoadMoreRequested value)? loadMoreRequested,
    TResult Function(MicrocreditSearchChanged value)? searchChanged,
    TResult Function(MicrocreditFilterApplied value)? filterApplied,
    TResult Function(MicrocreditPageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) {
    if (searchChanged != null) {
      return searchChanged(this);
    }
    return orElse();
  }
}

abstract class MicrocreditSearchChanged implements MicrocreditEvent {
  const factory MicrocreditSearchChanged(final String query) =
      _$MicrocreditSearchChangedImpl;

  String get query;
  @JsonKey(ignore: true)
  _$$MicrocreditSearchChangedImplCopyWith<_$MicrocreditSearchChangedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MicrocreditFilterAppliedImplCopyWith<$Res> {
  factory _$$MicrocreditFilterAppliedImplCopyWith(
          _$MicrocreditFilterAppliedImpl value,
          $Res Function(_$MicrocreditFilterAppliedImpl) then) =
      __$$MicrocreditFilterAppliedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({MicrocreditFilter filter});
}

/// @nodoc
class __$$MicrocreditFilterAppliedImplCopyWithImpl<$Res>
    extends _$MicrocreditEventCopyWithImpl<$Res, _$MicrocreditFilterAppliedImpl>
    implements _$$MicrocreditFilterAppliedImplCopyWith<$Res> {
  __$$MicrocreditFilterAppliedImplCopyWithImpl(
      _$MicrocreditFilterAppliedImpl _value,
      $Res Function(_$MicrocreditFilterAppliedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filter = null,
  }) {
    return _then(_$MicrocreditFilterAppliedImpl(
      null == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as MicrocreditFilter,
    ));
  }
}

/// @nodoc

class _$MicrocreditFilterAppliedImpl
    with DiagnosticableTreeMixin
    implements MicrocreditFilterApplied {
  const _$MicrocreditFilterAppliedImpl(this.filter);

  @override
  final MicrocreditFilter filter;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MicrocreditEvent.filterApplied(filter: $filter)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MicrocreditEvent.filterApplied'))
      ..add(DiagnosticsProperty('filter', filter));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MicrocreditFilterAppliedImpl &&
            (identical(other.filter, filter) || other.filter == filter));
  }

  @override
  int get hashCode => Object.hash(runtimeType, filter);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MicrocreditFilterAppliedImplCopyWith<_$MicrocreditFilterAppliedImpl>
      get copyWith => __$$MicrocreditFilterAppliedImplCopyWithImpl<
          _$MicrocreditFilterAppliedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(String query) searchChanged,
    required TResult Function(MicrocreditFilter filter) filterApplied,
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
    TResult? Function(MicrocreditFilter filter)? filterApplied,
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
    TResult Function(MicrocreditFilter filter)? filterApplied,
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
    required TResult Function(MicrocreditStarted value) started,
    required TResult Function(MicrocreditRefreshRequested value)
        refreshRequested,
    required TResult Function(MicrocreditLoadMoreRequested value)
        loadMoreRequested,
    required TResult Function(MicrocreditSearchChanged value) searchChanged,
    required TResult Function(MicrocreditFilterApplied value) filterApplied,
    required TResult Function(MicrocreditPageSizeChanged value) pageSizeChanged,
  }) {
    return filterApplied(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MicrocreditStarted value)? started,
    TResult? Function(MicrocreditRefreshRequested value)? refreshRequested,
    TResult? Function(MicrocreditLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(MicrocreditSearchChanged value)? searchChanged,
    TResult? Function(MicrocreditFilterApplied value)? filterApplied,
    TResult? Function(MicrocreditPageSizeChanged value)? pageSizeChanged,
  }) {
    return filterApplied?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MicrocreditStarted value)? started,
    TResult Function(MicrocreditRefreshRequested value)? refreshRequested,
    TResult Function(MicrocreditLoadMoreRequested value)? loadMoreRequested,
    TResult Function(MicrocreditSearchChanged value)? searchChanged,
    TResult Function(MicrocreditFilterApplied value)? filterApplied,
    TResult Function(MicrocreditPageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) {
    if (filterApplied != null) {
      return filterApplied(this);
    }
    return orElse();
  }
}

abstract class MicrocreditFilterApplied implements MicrocreditEvent {
  const factory MicrocreditFilterApplied(final MicrocreditFilter filter) =
      _$MicrocreditFilterAppliedImpl;

  MicrocreditFilter get filter;
  @JsonKey(ignore: true)
  _$$MicrocreditFilterAppliedImplCopyWith<_$MicrocreditFilterAppliedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MicrocreditPageSizeChangedImplCopyWith<$Res> {
  factory _$$MicrocreditPageSizeChangedImplCopyWith(
          _$MicrocreditPageSizeChangedImpl value,
          $Res Function(_$MicrocreditPageSizeChangedImpl) then) =
      __$$MicrocreditPageSizeChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int size});
}

/// @nodoc
class __$$MicrocreditPageSizeChangedImplCopyWithImpl<$Res>
    extends _$MicrocreditEventCopyWithImpl<$Res,
        _$MicrocreditPageSizeChangedImpl>
    implements _$$MicrocreditPageSizeChangedImplCopyWith<$Res> {
  __$$MicrocreditPageSizeChangedImplCopyWithImpl(
      _$MicrocreditPageSizeChangedImpl _value,
      $Res Function(_$MicrocreditPageSizeChangedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? size = null,
  }) {
    return _then(_$MicrocreditPageSizeChangedImpl(
      null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$MicrocreditPageSizeChangedImpl
    with DiagnosticableTreeMixin
    implements MicrocreditPageSizeChanged {
  const _$MicrocreditPageSizeChangedImpl(this.size);

  @override
  final int size;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MicrocreditEvent.pageSizeChanged(size: $size)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MicrocreditEvent.pageSizeChanged'))
      ..add(DiagnosticsProperty('size', size));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MicrocreditPageSizeChangedImpl &&
            (identical(other.size, size) || other.size == size));
  }

  @override
  int get hashCode => Object.hash(runtimeType, size);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MicrocreditPageSizeChangedImplCopyWith<_$MicrocreditPageSizeChangedImpl>
      get copyWith => __$$MicrocreditPageSizeChangedImplCopyWithImpl<
          _$MicrocreditPageSizeChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Completer<void>? completer) refreshRequested,
    required TResult Function() loadMoreRequested,
    required TResult Function(String query) searchChanged,
    required TResult Function(MicrocreditFilter filter) filterApplied,
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
    TResult? Function(MicrocreditFilter filter)? filterApplied,
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
    TResult Function(MicrocreditFilter filter)? filterApplied,
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
    required TResult Function(MicrocreditStarted value) started,
    required TResult Function(MicrocreditRefreshRequested value)
        refreshRequested,
    required TResult Function(MicrocreditLoadMoreRequested value)
        loadMoreRequested,
    required TResult Function(MicrocreditSearchChanged value) searchChanged,
    required TResult Function(MicrocreditFilterApplied value) filterApplied,
    required TResult Function(MicrocreditPageSizeChanged value) pageSizeChanged,
  }) {
    return pageSizeChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(MicrocreditStarted value)? started,
    TResult? Function(MicrocreditRefreshRequested value)? refreshRequested,
    TResult? Function(MicrocreditLoadMoreRequested value)? loadMoreRequested,
    TResult? Function(MicrocreditSearchChanged value)? searchChanged,
    TResult? Function(MicrocreditFilterApplied value)? filterApplied,
    TResult? Function(MicrocreditPageSizeChanged value)? pageSizeChanged,
  }) {
    return pageSizeChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(MicrocreditStarted value)? started,
    TResult Function(MicrocreditRefreshRequested value)? refreshRequested,
    TResult Function(MicrocreditLoadMoreRequested value)? loadMoreRequested,
    TResult Function(MicrocreditSearchChanged value)? searchChanged,
    TResult Function(MicrocreditFilterApplied value)? filterApplied,
    TResult Function(MicrocreditPageSizeChanged value)? pageSizeChanged,
    required TResult orElse(),
  }) {
    if (pageSizeChanged != null) {
      return pageSizeChanged(this);
    }
    return orElse();
  }
}

abstract class MicrocreditPageSizeChanged implements MicrocreditEvent {
  const factory MicrocreditPageSizeChanged(final int size) =
      _$MicrocreditPageSizeChangedImpl;

  int get size;
  @JsonKey(ignore: true)
  _$$MicrocreditPageSizeChangedImplCopyWith<_$MicrocreditPageSizeChangedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MicrocreditState {
  List<MicrocreditEntity> get items => throw _privateConstructorUsedError;
  MicrocreditFilter get filter => throw _privateConstructorUsedError;
  MicrocreditViewStatus get status => throw _privateConstructorUsedError;
  bool get isInitialLoading => throw _privateConstructorUsedError;
  bool get isPaginating => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get paginationErrorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MicrocreditStateCopyWith<MicrocreditState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MicrocreditStateCopyWith<$Res> {
  factory $MicrocreditStateCopyWith(
          MicrocreditState value, $Res Function(MicrocreditState) then) =
      _$MicrocreditStateCopyWithImpl<$Res, MicrocreditState>;
  @useResult
  $Res call(
      {List<MicrocreditEntity> items,
      MicrocreditFilter filter,
      MicrocreditViewStatus status,
      bool isInitialLoading,
      bool isPaginating,
      bool hasMore,
      int page,
      int pageSize,
      String? errorMessage,
      String? paginationErrorMessage});
}

/// @nodoc
class _$MicrocreditStateCopyWithImpl<$Res, $Val extends MicrocreditState>
    implements $MicrocreditStateCopyWith<$Res> {
  _$MicrocreditStateCopyWithImpl(this._value, this._then);

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
              as List<MicrocreditEntity>,
      filter: null == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as MicrocreditFilter,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MicrocreditViewStatus,
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
abstract class _$$MicrocreditStateImplCopyWith<$Res>
    implements $MicrocreditStateCopyWith<$Res> {
  factory _$$MicrocreditStateImplCopyWith(_$MicrocreditStateImpl value,
          $Res Function(_$MicrocreditStateImpl) then) =
      __$$MicrocreditStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<MicrocreditEntity> items,
      MicrocreditFilter filter,
      MicrocreditViewStatus status,
      bool isInitialLoading,
      bool isPaginating,
      bool hasMore,
      int page,
      int pageSize,
      String? errorMessage,
      String? paginationErrorMessage});
}

/// @nodoc
class __$$MicrocreditStateImplCopyWithImpl<$Res>
    extends _$MicrocreditStateCopyWithImpl<$Res, _$MicrocreditStateImpl>
    implements _$$MicrocreditStateImplCopyWith<$Res> {
  __$$MicrocreditStateImplCopyWithImpl(_$MicrocreditStateImpl _value,
      $Res Function(_$MicrocreditStateImpl) _then)
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
    return _then(_$MicrocreditStateImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<MicrocreditEntity>,
      filter: null == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as MicrocreditFilter,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MicrocreditViewStatus,
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

class _$MicrocreditStateImpl extends _MicrocreditState
    with DiagnosticableTreeMixin {
  const _$MicrocreditStateImpl(
      {required final List<MicrocreditEntity> items,
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

  final List<MicrocreditEntity> _items;
  @override
  List<MicrocreditEntity> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final MicrocreditFilter filter;
  @override
  final MicrocreditViewStatus status;
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
    return 'MicrocreditState(items: $items, filter: $filter, status: $status, isInitialLoading: $isInitialLoading, isPaginating: $isPaginating, hasMore: $hasMore, page: $page, pageSize: $pageSize, errorMessage: $errorMessage, paginationErrorMessage: $paginationErrorMessage)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MicrocreditState'))
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
            other is _$MicrocreditStateImpl &&
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
  _$$MicrocreditStateImplCopyWith<_$MicrocreditStateImpl> get copyWith =>
      __$$MicrocreditStateImplCopyWithImpl<_$MicrocreditStateImpl>(
          this, _$identity);
}

abstract class _MicrocreditState extends MicrocreditState {
  const factory _MicrocreditState(
      {required final List<MicrocreditEntity> items,
      required final MicrocreditFilter filter,
      required final MicrocreditViewStatus status,
      required final bool isInitialLoading,
      required final bool isPaginating,
      required final bool hasMore,
      required final int page,
      required final int pageSize,
      final String? errorMessage,
      final String? paginationErrorMessage}) = _$MicrocreditStateImpl;
  const _MicrocreditState._() : super._();

  @override
  List<MicrocreditEntity> get items;
  @override
  MicrocreditFilter get filter;
  @override
  MicrocreditViewStatus get status;
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
  _$$MicrocreditStateImplCopyWith<_$MicrocreditStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
