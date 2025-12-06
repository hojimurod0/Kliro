// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_payment_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CheckPaymentRequest _$CheckPaymentRequestFromJson(Map<String, dynamic> json) {
  return _CheckPaymentRequest.fromJson(json);
}

/// @nodoc
mixin _$CheckPaymentRequest {
  @JsonKey(name: 'order_id')
  String get orderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_id')
  String get transactionId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CheckPaymentRequestCopyWith<CheckPaymentRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckPaymentRequestCopyWith<$Res> {
  factory $CheckPaymentRequestCopyWith(
          CheckPaymentRequest value, $Res Function(CheckPaymentRequest) then) =
      _$CheckPaymentRequestCopyWithImpl<$Res, CheckPaymentRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: 'order_id') String orderId,
      @JsonKey(name: 'transaction_id') String transactionId});
}

/// @nodoc
class _$CheckPaymentRequestCopyWithImpl<$Res, $Val extends CheckPaymentRequest>
    implements $CheckPaymentRequestCopyWith<$Res> {
  _$CheckPaymentRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? transactionId = null,
  }) {
    return _then(_value.copyWith(
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      transactionId: null == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CheckPaymentRequestImplCopyWith<$Res>
    implements $CheckPaymentRequestCopyWith<$Res> {
  factory _$$CheckPaymentRequestImplCopyWith(_$CheckPaymentRequestImpl value,
          $Res Function(_$CheckPaymentRequestImpl) then) =
      __$$CheckPaymentRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'order_id') String orderId,
      @JsonKey(name: 'transaction_id') String transactionId});
}

/// @nodoc
class __$$CheckPaymentRequestImplCopyWithImpl<$Res>
    extends _$CheckPaymentRequestCopyWithImpl<$Res, _$CheckPaymentRequestImpl>
    implements _$$CheckPaymentRequestImplCopyWith<$Res> {
  __$$CheckPaymentRequestImplCopyWithImpl(_$CheckPaymentRequestImpl _value,
      $Res Function(_$CheckPaymentRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? transactionId = null,
  }) {
    return _then(_$CheckPaymentRequestImpl(
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      transactionId: null == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CheckPaymentRequestImpl implements _CheckPaymentRequest {
  const _$CheckPaymentRequestImpl(
      {@JsonKey(name: 'order_id') required this.orderId,
      @JsonKey(name: 'transaction_id') required this.transactionId});

  factory _$CheckPaymentRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckPaymentRequestImplFromJson(json);

  @override
  @JsonKey(name: 'order_id')
  final String orderId;
  @override
  @JsonKey(name: 'transaction_id')
  final String transactionId;

  @override
  String toString() {
    return 'CheckPaymentRequest(orderId: $orderId, transactionId: $transactionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckPaymentRequestImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, orderId, transactionId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckPaymentRequestImplCopyWith<_$CheckPaymentRequestImpl> get copyWith =>
      __$$CheckPaymentRequestImplCopyWithImpl<_$CheckPaymentRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckPaymentRequestImplToJson(
      this,
    );
  }
}

abstract class _CheckPaymentRequest implements CheckPaymentRequest {
  const factory _CheckPaymentRequest(
      {@JsonKey(name: 'order_id') required final String orderId,
      @JsonKey(name: 'transaction_id')
      required final String transactionId}) = _$CheckPaymentRequestImpl;

  factory _CheckPaymentRequest.fromJson(Map<String, dynamic> json) =
      _$CheckPaymentRequestImpl.fromJson;

  @override
  @JsonKey(name: 'order_id')
  String get orderId;
  @override
  @JsonKey(name: 'transaction_id')
  String get transactionId;
  @override
  @JsonKey(ignore: true)
  _$$CheckPaymentRequestImplCopyWith<_$CheckPaymentRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
