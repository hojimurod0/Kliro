// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_link_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PaymentLinkResponse _$PaymentLinkResponseFromJson(Map<String, dynamic> json) {
  return _PaymentLinkResponse.fromJson(json);
}

/// @nodoc
mixin _$PaymentLinkResponse {
  @JsonKey(name: 'payment_url')
  String get paymentUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_id')
  String get orderId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PaymentLinkResponseCopyWith<PaymentLinkResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentLinkResponseCopyWith<$Res> {
  factory $PaymentLinkResponseCopyWith(
          PaymentLinkResponse value, $Res Function(PaymentLinkResponse) then) =
      _$PaymentLinkResponseCopyWithImpl<$Res, PaymentLinkResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'payment_url') String paymentUrl,
      @JsonKey(name: 'order_id') String orderId,
      double amount});
}

/// @nodoc
class _$PaymentLinkResponseCopyWithImpl<$Res, $Val extends PaymentLinkResponse>
    implements $PaymentLinkResponseCopyWith<$Res> {
  _$PaymentLinkResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paymentUrl = null,
    Object? orderId = null,
    Object? amount = null,
  }) {
    return _then(_value.copyWith(
      paymentUrl: null == paymentUrl
          ? _value.paymentUrl
          : paymentUrl // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaymentLinkResponseImplCopyWith<$Res>
    implements $PaymentLinkResponseCopyWith<$Res> {
  factory _$$PaymentLinkResponseImplCopyWith(_$PaymentLinkResponseImpl value,
          $Res Function(_$PaymentLinkResponseImpl) then) =
      __$$PaymentLinkResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'payment_url') String paymentUrl,
      @JsonKey(name: 'order_id') String orderId,
      double amount});
}

/// @nodoc
class __$$PaymentLinkResponseImplCopyWithImpl<$Res>
    extends _$PaymentLinkResponseCopyWithImpl<$Res, _$PaymentLinkResponseImpl>
    implements _$$PaymentLinkResponseImplCopyWith<$Res> {
  __$$PaymentLinkResponseImplCopyWithImpl(_$PaymentLinkResponseImpl _value,
      $Res Function(_$PaymentLinkResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paymentUrl = null,
    Object? orderId = null,
    Object? amount = null,
  }) {
    return _then(_$PaymentLinkResponseImpl(
      paymentUrl: null == paymentUrl
          ? _value.paymentUrl
          : paymentUrl // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentLinkResponseImpl implements _PaymentLinkResponse {
  const _$PaymentLinkResponseImpl(
      {@JsonKey(name: 'payment_url') required this.paymentUrl,
      @JsonKey(name: 'order_id') required this.orderId,
      required this.amount});

  factory _$PaymentLinkResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentLinkResponseImplFromJson(json);

  @override
  @JsonKey(name: 'payment_url')
  final String paymentUrl;
  @override
  @JsonKey(name: 'order_id')
  final String orderId;
  @override
  final double amount;

  @override
  String toString() {
    return 'PaymentLinkResponse(paymentUrl: $paymentUrl, orderId: $orderId, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentLinkResponseImpl &&
            (identical(other.paymentUrl, paymentUrl) ||
                other.paymentUrl == paymentUrl) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, paymentUrl, orderId, amount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentLinkResponseImplCopyWith<_$PaymentLinkResponseImpl> get copyWith =>
      __$$PaymentLinkResponseImplCopyWithImpl<_$PaymentLinkResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentLinkResponseImplToJson(
      this,
    );
  }
}

abstract class _PaymentLinkResponse implements PaymentLinkResponse {
  const factory _PaymentLinkResponse(
      {@JsonKey(name: 'payment_url') required final String paymentUrl,
      @JsonKey(name: 'order_id') required final String orderId,
      required final double amount}) = _$PaymentLinkResponseImpl;

  factory _PaymentLinkResponse.fromJson(Map<String, dynamic> json) =
      _$PaymentLinkResponseImpl.fromJson;

  @override
  @JsonKey(name: 'payment_url')
  String get paymentUrl;
  @override
  @JsonKey(name: 'order_id')
  String get orderId;
  @override
  double get amount;
  @override
  @JsonKey(ignore: true)
  _$$PaymentLinkResponseImplCopyWith<_$PaymentLinkResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
