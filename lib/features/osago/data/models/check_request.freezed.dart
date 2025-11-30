// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CheckRequest _$CheckRequestFromJson(Map<String, dynamic> json) {
  return _CheckRequest.fromJson(json);
}

/// @nodoc
mixin _$CheckRequest {
  @JsonKey(name: 'session_id')
  String get sessionId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CheckRequestCopyWith<CheckRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckRequestCopyWith<$Res> {
  factory $CheckRequestCopyWith(
          CheckRequest value, $Res Function(CheckRequest) then) =
      _$CheckRequestCopyWithImpl<$Res, CheckRequest>;
  @useResult
  $Res call({@JsonKey(name: 'session_id') String sessionId});
}

/// @nodoc
class _$CheckRequestCopyWithImpl<$Res, $Val extends CheckRequest>
    implements $CheckRequestCopyWith<$Res> {
  _$CheckRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
  }) {
    return _then(_value.copyWith(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CheckRequestImplCopyWith<$Res>
    implements $CheckRequestCopyWith<$Res> {
  factory _$$CheckRequestImplCopyWith(
          _$CheckRequestImpl value, $Res Function(_$CheckRequestImpl) then) =
      __$$CheckRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'session_id') String sessionId});
}

/// @nodoc
class __$$CheckRequestImplCopyWithImpl<$Res>
    extends _$CheckRequestCopyWithImpl<$Res, _$CheckRequestImpl>
    implements _$$CheckRequestImplCopyWith<$Res> {
  __$$CheckRequestImplCopyWithImpl(
      _$CheckRequestImpl _value, $Res Function(_$CheckRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
  }) {
    return _then(_$CheckRequestImpl(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CheckRequestImpl implements _CheckRequest {
  const _$CheckRequestImpl(
      {@JsonKey(name: 'session_id') required this.sessionId});

  factory _$CheckRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckRequestImplFromJson(json);

  @override
  @JsonKey(name: 'session_id')
  final String sessionId;

  @override
  String toString() {
    return 'CheckRequest(sessionId: $sessionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckRequestImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, sessionId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckRequestImplCopyWith<_$CheckRequestImpl> get copyWith =>
      __$$CheckRequestImplCopyWithImpl<_$CheckRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckRequestImplToJson(
      this,
    );
  }
}

abstract class _CheckRequest implements CheckRequest {
  const factory _CheckRequest(
          {@JsonKey(name: 'session_id') required final String sessionId}) =
      _$CheckRequestImpl;

  factory _CheckRequest.fromJson(Map<String, dynamic> json) =
      _$CheckRequestImpl.fromJson;

  @override
  @JsonKey(name: 'session_id')
  String get sessionId;
  @override
  @JsonKey(ignore: true)
  _$$CheckRequestImplCopyWith<_$CheckRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
