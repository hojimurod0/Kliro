// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_link_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PaymentLinkRequest _$PaymentLinkRequestFromJson(Map<String, dynamic> json) {
  return _PaymentLinkRequest.fromJson(json);
}

/// @nodoc
mixin _$PaymentLinkRequest {
  @JsonKey(name: 'order_id')
  String get orderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'contract_id')
  String? get contractId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'return_url')
  String get returnUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'callback_url')
  String get callbackUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PaymentLinkRequestCopyWith<PaymentLinkRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentLinkRequestCopyWith<$Res> {
  factory $PaymentLinkRequestCopyWith(
          PaymentLinkRequest value, $Res Function(PaymentLinkRequest) then) =
      _$PaymentLinkRequestCopyWithImpl<$Res, PaymentLinkRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: 'order_id') String orderId,
      @JsonKey(name: 'contract_id') String? contractId,
      double amount,
      @JsonKey(name: 'return_url') String returnUrl,
      @JsonKey(name: 'callback_url') String callbackUrl});
}

/// @nodoc
class _$PaymentLinkRequestCopyWithImpl<$Res, $Val extends PaymentLinkRequest>
    implements $PaymentLinkRequestCopyWith<$Res> {
  _$PaymentLinkRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? contractId = freezed,
    Object? amount = null,
    Object? returnUrl = null,
    Object? callbackUrl = null,
  }) {
    return _then(_value.copyWith(
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      contractId: freezed == contractId
          ? _value.contractId
          : contractId // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      returnUrl: null == returnUrl
          ? _value.returnUrl
          : returnUrl // ignore: cast_nullable_to_non_nullable
              as String,
      callbackUrl: null == callbackUrl
          ? _value.callbackUrl
          : callbackUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaymentLinkRequestImplCopyWith<$Res>
    implements $PaymentLinkRequestCopyWith<$Res> {
  factory _$$PaymentLinkRequestImplCopyWith(_$PaymentLinkRequestImpl value,
          $Res Function(_$PaymentLinkRequestImpl) then) =
      __$$PaymentLinkRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'order_id') String orderId,
      @JsonKey(name: 'contract_id') String? contractId,
      double amount,
      @JsonKey(name: 'return_url') String returnUrl,
      @JsonKey(name: 'callback_url') String callbackUrl});
}

/// @nodoc
class __$$PaymentLinkRequestImplCopyWithImpl<$Res>
    extends _$PaymentLinkRequestCopyWithImpl<$Res, _$PaymentLinkRequestImpl>
    implements _$$PaymentLinkRequestImplCopyWith<$Res> {
  __$$PaymentLinkRequestImplCopyWithImpl(_$PaymentLinkRequestImpl _value,
      $Res Function(_$PaymentLinkRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? contractId = freezed,
    Object? amount = null,
    Object? returnUrl = null,
    Object? callbackUrl = null,
  }) {
    return _then(_$PaymentLinkRequestImpl(
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      contractId: freezed == contractId
          ? _value.contractId
          : contractId // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      returnUrl: null == returnUrl
          ? _value.returnUrl
          : returnUrl // ignore: cast_nullable_to_non_nullable
              as String,
      callbackUrl: null == callbackUrl
          ? _value.callbackUrl
          : callbackUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentLinkRequestImpl implements _PaymentLinkRequest {
  const _$PaymentLinkRequestImpl(
      {@JsonKey(name: 'order_id') required this.orderId,
      @JsonKey(name: 'contract_id') this.contractId,
      required this.amount,
      @JsonKey(name: 'return_url') required this.returnUrl,
      @JsonKey(name: 'callback_url') required this.callbackUrl});

  factory _$PaymentLinkRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentLinkRequestImplFromJson(json);

  @override
  @JsonKey(name: 'order_id')
  final String orderId;
  @override
  @JsonKey(name: 'contract_id')
  final String? contractId;
  @override
  final double amount;
  @override
  @JsonKey(name: 'return_url')
  final String returnUrl;
  @override
  @JsonKey(name: 'callback_url')
  final String callbackUrl;

  @override
  String toString() {
    return 'PaymentLinkRequest(orderId: $orderId, contractId: $contractId, amount: $amount, returnUrl: $returnUrl, callbackUrl: $callbackUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentLinkRequestImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.contractId, contractId) ||
                other.contractId == contractId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.returnUrl, returnUrl) ||
                other.returnUrl == returnUrl) &&
            (identical(other.callbackUrl, callbackUrl) ||
                other.callbackUrl == callbackUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, orderId, contractId, amount, returnUrl, callbackUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentLinkRequestImplCopyWith<_$PaymentLinkRequestImpl> get copyWith =>
      __$$PaymentLinkRequestImplCopyWithImpl<_$PaymentLinkRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentLinkRequestImplToJson(
      this,
    );
  }
}

abstract class _PaymentLinkRequest implements PaymentLinkRequest {
  const factory _PaymentLinkRequest(
          {@JsonKey(name: 'order_id') required final String orderId,
          @JsonKey(name: 'contract_id') final String? contractId,
          required final double amount,
          @JsonKey(name: 'return_url') required final String returnUrl,
          @JsonKey(name: 'callback_url') required final String callbackUrl}) =
      _$PaymentLinkRequestImpl;

  factory _PaymentLinkRequest.fromJson(Map<String, dynamic> json) =
      _$PaymentLinkRequestImpl.fromJson;

  @override
  @JsonKey(name: 'order_id')
  String get orderId;
  @override
  @JsonKey(name: 'contract_id')
  String? get contractId;
  @override
  double get amount;
  @override
  @JsonKey(name: 'return_url')
  String get returnUrl;
  @override
  @JsonKey(name: 'callback_url')
  String get callbackUrl;
  @override
  @JsonKey(ignore: true)
  _$$PaymentLinkRequestImplCopyWith<_$PaymentLinkRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
