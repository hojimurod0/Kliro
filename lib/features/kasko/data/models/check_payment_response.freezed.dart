// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_payment_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CheckPaymentResponse _$CheckPaymentResponseFromJson(Map<String, dynamic> json) {
  return _CheckPaymentResponse.fromJson(json);
}

/// @nodoc
mixin _$CheckPaymentResponse {
  @JsonKey(name: 'order_id')
  String get orderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_id')
  String? get transactionId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_paid')
  bool get isPaid => throw _privateConstructorUsedError;
  double? get amount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CheckPaymentResponseCopyWith<CheckPaymentResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckPaymentResponseCopyWith<$Res> {
  factory $CheckPaymentResponseCopyWith(CheckPaymentResponse value,
          $Res Function(CheckPaymentResponse) then) =
      _$CheckPaymentResponseCopyWithImpl<$Res, CheckPaymentResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'order_id') String orderId,
      @JsonKey(name: 'transaction_id') String? transactionId,
      String status,
      @JsonKey(name: 'is_paid') bool isPaid,
      double? amount});
}

/// @nodoc
class _$CheckPaymentResponseCopyWithImpl<$Res,
        $Val extends CheckPaymentResponse>
    implements $CheckPaymentResponseCopyWith<$Res> {
  _$CheckPaymentResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? transactionId = freezed,
    Object? status = null,
    Object? isPaid = null,
    Object? amount = freezed,
  }) {
    return _then(_value.copyWith(
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isPaid: null == isPaid
          ? _value.isPaid
          : isPaid // ignore: cast_nullable_to_non_nullable
              as bool,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CheckPaymentResponseImplCopyWith<$Res>
    implements $CheckPaymentResponseCopyWith<$Res> {
  factory _$$CheckPaymentResponseImplCopyWith(_$CheckPaymentResponseImpl value,
          $Res Function(_$CheckPaymentResponseImpl) then) =
      __$$CheckPaymentResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'order_id') String orderId,
      @JsonKey(name: 'transaction_id') String? transactionId,
      String status,
      @JsonKey(name: 'is_paid') bool isPaid,
      double? amount});
}

/// @nodoc
class __$$CheckPaymentResponseImplCopyWithImpl<$Res>
    extends _$CheckPaymentResponseCopyWithImpl<$Res, _$CheckPaymentResponseImpl>
    implements _$$CheckPaymentResponseImplCopyWith<$Res> {
  __$$CheckPaymentResponseImplCopyWithImpl(_$CheckPaymentResponseImpl _value,
      $Res Function(_$CheckPaymentResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? transactionId = freezed,
    Object? status = null,
    Object? isPaid = null,
    Object? amount = freezed,
  }) {
    return _then(_$CheckPaymentResponseImpl(
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isPaid: null == isPaid
          ? _value.isPaid
          : isPaid // ignore: cast_nullable_to_non_nullable
              as bool,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CheckPaymentResponseImpl implements _CheckPaymentResponse {
  const _$CheckPaymentResponseImpl(
      {@JsonKey(name: 'order_id') required this.orderId,
      @JsonKey(name: 'transaction_id') this.transactionId,
      required this.status,
      @JsonKey(name: 'is_paid') this.isPaid = false,
      this.amount});

  factory _$CheckPaymentResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckPaymentResponseImplFromJson(json);

  @override
  @JsonKey(name: 'order_id')
  final String orderId;
  @override
  @JsonKey(name: 'transaction_id')
  final String? transactionId;
  @override
  final String status;
  @override
  @JsonKey(name: 'is_paid')
  final bool isPaid;
  @override
  final double? amount;

  @override
  String toString() {
    return 'CheckPaymentResponse(orderId: $orderId, transactionId: $transactionId, status: $status, isPaid: $isPaid, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckPaymentResponseImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isPaid, isPaid) || other.isPaid == isPaid) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, orderId, transactionId, status, isPaid, amount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckPaymentResponseImplCopyWith<_$CheckPaymentResponseImpl>
      get copyWith =>
          __$$CheckPaymentResponseImplCopyWithImpl<_$CheckPaymentResponseImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckPaymentResponseImplToJson(
      this,
    );
  }
}

abstract class _CheckPaymentResponse implements CheckPaymentResponse {
  const factory _CheckPaymentResponse(
      {@JsonKey(name: 'order_id') required final String orderId,
      @JsonKey(name: 'transaction_id') final String? transactionId,
      required final String status,
      @JsonKey(name: 'is_paid') final bool isPaid,
      final double? amount}) = _$CheckPaymentResponseImpl;

  factory _CheckPaymentResponse.fromJson(Map<String, dynamic> json) =
      _$CheckPaymentResponseImpl.fromJson;

  @override
  @JsonKey(name: 'order_id')
  String get orderId;
  @override
  @JsonKey(name: 'transaction_id')
  String? get transactionId;
  @override
  String get status;
  @override
  @JsonKey(name: 'is_paid')
  bool get isPaid;
  @override
  double? get amount;
  @override
  @JsonKey(ignore: true)
  _$$CheckPaymentResponseImplCopyWith<_$CheckPaymentResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
