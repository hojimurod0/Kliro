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
  @JsonKey(name: 'click')
  String? get clickUrl =>
      throw _privateConstructorUsedError; // Click ссылка (приоритет 1)
  @JsonKey(name: 'payme')
  String? get paymeUrl =>
      throw _privateConstructorUsedError; // Payme ссылка (приоритет 1)
  @JsonKey(name: 'url')
  String? get url =>
      throw _privateConstructorUsedError; // Click ссылка (приоритет 2) или fallback
  @JsonKey(name: 'payme_url')
  String? get paymeUrlOld =>
      throw _privateConstructorUsedError; // Payme ссылка (приоритет 2) или fallback
  @JsonKey(name: 'payment_url')
  String? get paymentUrl =>
      throw _privateConstructorUsedError; // Fallback для обратной совместимости
  @JsonKey(name: 'order_id', fromJson: _intToString)
  String? get orderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'contract_id', fromJson: _intToString)
  String? get contractId => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount', fromJson: _toDouble)
  double? get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_uzs', fromJson: _toDouble)
  double? get amountUzs => throw _privateConstructorUsedError;

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
      {@JsonKey(name: 'click') String? clickUrl,
      @JsonKey(name: 'payme') String? paymeUrl,
      @JsonKey(name: 'url') String? url,
      @JsonKey(name: 'payme_url') String? paymeUrlOld,
      @JsonKey(name: 'payment_url') String? paymentUrl,
      @JsonKey(name: 'order_id', fromJson: _intToString) String? orderId,
      @JsonKey(name: 'contract_id', fromJson: _intToString) String? contractId,
      @JsonKey(name: 'amount', fromJson: _toDouble) double? amount,
      @JsonKey(name: 'amount_uzs', fromJson: _toDouble) double? amountUzs});
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
    Object? clickUrl = freezed,
    Object? paymeUrl = freezed,
    Object? url = freezed,
    Object? paymeUrlOld = freezed,
    Object? paymentUrl = freezed,
    Object? orderId = freezed,
    Object? contractId = freezed,
    Object? amount = freezed,
    Object? amountUzs = freezed,
  }) {
    return _then(_value.copyWith(
      clickUrl: freezed == clickUrl
          ? _value.clickUrl
          : clickUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      paymeUrl: freezed == paymeUrl
          ? _value.paymeUrl
          : paymeUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      paymeUrlOld: freezed == paymeUrlOld
          ? _value.paymeUrlOld
          : paymeUrlOld // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentUrl: freezed == paymentUrl
          ? _value.paymentUrl
          : paymentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      orderId: freezed == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String?,
      contractId: freezed == contractId
          ? _value.contractId
          : contractId // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
      amountUzs: freezed == amountUzs
          ? _value.amountUzs
          : amountUzs // ignore: cast_nullable_to_non_nullable
              as double?,
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
      {@JsonKey(name: 'click') String? clickUrl,
      @JsonKey(name: 'payme') String? paymeUrl,
      @JsonKey(name: 'url') String? url,
      @JsonKey(name: 'payme_url') String? paymeUrlOld,
      @JsonKey(name: 'payment_url') String? paymentUrl,
      @JsonKey(name: 'order_id', fromJson: _intToString) String? orderId,
      @JsonKey(name: 'contract_id', fromJson: _intToString) String? contractId,
      @JsonKey(name: 'amount', fromJson: _toDouble) double? amount,
      @JsonKey(name: 'amount_uzs', fromJson: _toDouble) double? amountUzs});
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
    Object? clickUrl = freezed,
    Object? paymeUrl = freezed,
    Object? url = freezed,
    Object? paymeUrlOld = freezed,
    Object? paymentUrl = freezed,
    Object? orderId = freezed,
    Object? contractId = freezed,
    Object? amount = freezed,
    Object? amountUzs = freezed,
  }) {
    return _then(_$PaymentLinkResponseImpl(
      clickUrl: freezed == clickUrl
          ? _value.clickUrl
          : clickUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      paymeUrl: freezed == paymeUrl
          ? _value.paymeUrl
          : paymeUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      paymeUrlOld: freezed == paymeUrlOld
          ? _value.paymeUrlOld
          : paymeUrlOld // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentUrl: freezed == paymentUrl
          ? _value.paymentUrl
          : paymentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      orderId: freezed == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String?,
      contractId: freezed == contractId
          ? _value.contractId
          : contractId // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
      amountUzs: freezed == amountUzs
          ? _value.amountUzs
          : amountUzs // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentLinkResponseImpl implements _PaymentLinkResponse {
  const _$PaymentLinkResponseImpl(
      {@JsonKey(name: 'click') this.clickUrl,
      @JsonKey(name: 'payme') this.paymeUrl,
      @JsonKey(name: 'url') this.url,
      @JsonKey(name: 'payme_url') this.paymeUrlOld,
      @JsonKey(name: 'payment_url') this.paymentUrl,
      @JsonKey(name: 'order_id', fromJson: _intToString) this.orderId,
      @JsonKey(name: 'contract_id', fromJson: _intToString) this.contractId,
      @JsonKey(name: 'amount', fromJson: _toDouble) this.amount,
      @JsonKey(name: 'amount_uzs', fromJson: _toDouble) this.amountUzs});

  factory _$PaymentLinkResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentLinkResponseImplFromJson(json);

  @override
  @JsonKey(name: 'click')
  final String? clickUrl;
// Click ссылка (приоритет 1)
  @override
  @JsonKey(name: 'payme')
  final String? paymeUrl;
// Payme ссылка (приоритет 1)
  @override
  @JsonKey(name: 'url')
  final String? url;
// Click ссылка (приоритет 2) или fallback
  @override
  @JsonKey(name: 'payme_url')
  final String? paymeUrlOld;
// Payme ссылка (приоритет 2) или fallback
  @override
  @JsonKey(name: 'payment_url')
  final String? paymentUrl;
// Fallback для обратной совместимости
  @override
  @JsonKey(name: 'order_id', fromJson: _intToString)
  final String? orderId;
  @override
  @JsonKey(name: 'contract_id', fromJson: _intToString)
  final String? contractId;
  @override
  @JsonKey(name: 'amount', fromJson: _toDouble)
  final double? amount;
  @override
  @JsonKey(name: 'amount_uzs', fromJson: _toDouble)
  final double? amountUzs;

  @override
  String toString() {
    return 'PaymentLinkResponse(clickUrl: $clickUrl, paymeUrl: $paymeUrl, url: $url, paymeUrlOld: $paymeUrlOld, paymentUrl: $paymentUrl, orderId: $orderId, contractId: $contractId, amount: $amount, amountUzs: $amountUzs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentLinkResponseImpl &&
            (identical(other.clickUrl, clickUrl) ||
                other.clickUrl == clickUrl) &&
            (identical(other.paymeUrl, paymeUrl) ||
                other.paymeUrl == paymeUrl) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.paymeUrlOld, paymeUrlOld) ||
                other.paymeUrlOld == paymeUrlOld) &&
            (identical(other.paymentUrl, paymentUrl) ||
                other.paymentUrl == paymentUrl) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.contractId, contractId) ||
                other.contractId == contractId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.amountUzs, amountUzs) ||
                other.amountUzs == amountUzs));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, clickUrl, paymeUrl, url,
      paymeUrlOld, paymentUrl, orderId, contractId, amount, amountUzs);

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
      {@JsonKey(name: 'click') final String? clickUrl,
      @JsonKey(name: 'payme') final String? paymeUrl,
      @JsonKey(name: 'url') final String? url,
      @JsonKey(name: 'payme_url') final String? paymeUrlOld,
      @JsonKey(name: 'payment_url') final String? paymentUrl,
      @JsonKey(name: 'order_id', fromJson: _intToString) final String? orderId,
      @JsonKey(name: 'contract_id', fromJson: _intToString)
      final String? contractId,
      @JsonKey(name: 'amount', fromJson: _toDouble) final double? amount,
      @JsonKey(name: 'amount_uzs', fromJson: _toDouble)
      final double? amountUzs}) = _$PaymentLinkResponseImpl;

  factory _PaymentLinkResponse.fromJson(Map<String, dynamic> json) =
      _$PaymentLinkResponseImpl.fromJson;

  @override
  @JsonKey(name: 'click')
  String? get clickUrl;
  @override // Click ссылка (приоритет 1)
  @JsonKey(name: 'payme')
  String? get paymeUrl;
  @override // Payme ссылка (приоритет 1)
  @JsonKey(name: 'url')
  String? get url;
  @override // Click ссылка (приоритет 2) или fallback
  @JsonKey(name: 'payme_url')
  String? get paymeUrlOld;
  @override // Payme ссылка (приоритет 2) или fallback
  @JsonKey(name: 'payment_url')
  String? get paymentUrl;
  @override // Fallback для обратной совместимости
  @JsonKey(name: 'order_id', fromJson: _intToString)
  String? get orderId;
  @override
  @JsonKey(name: 'contract_id', fromJson: _intToString)
  String? get contractId;
  @override
  @JsonKey(name: 'amount', fromJson: _toDouble)
  double? get amount;
  @override
  @JsonKey(name: 'amount_uzs', fromJson: _toDouble)
  double? get amountUzs;
  @override
  @JsonKey(ignore: true)
  _$$PaymentLinkResponseImplCopyWith<_$PaymentLinkResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
