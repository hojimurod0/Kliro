// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PaymentUrls _$PaymentUrlsFromJson(Map<String, dynamic> json) {
  return _PaymentUrls.fromJson(json);
}

/// @nodoc
mixin _$PaymentUrls {
  String? get click => throw _privateConstructorUsedError;
  String? get payme => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PaymentUrlsCopyWith<PaymentUrls> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentUrlsCopyWith<$Res> {
  factory $PaymentUrlsCopyWith(
          PaymentUrls value, $Res Function(PaymentUrls) then) =
      _$PaymentUrlsCopyWithImpl<$Res, PaymentUrls>;
  @useResult
  $Res call({String? click, String? payme});
}

/// @nodoc
class _$PaymentUrlsCopyWithImpl<$Res, $Val extends PaymentUrls>
    implements $PaymentUrlsCopyWith<$Res> {
  _$PaymentUrlsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? click = freezed,
    Object? payme = freezed,
  }) {
    return _then(_value.copyWith(
      click: freezed == click
          ? _value.click
          : click // ignore: cast_nullable_to_non_nullable
              as String?,
      payme: freezed == payme
          ? _value.payme
          : payme // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaymentUrlsImplCopyWith<$Res>
    implements $PaymentUrlsCopyWith<$Res> {
  factory _$$PaymentUrlsImplCopyWith(
          _$PaymentUrlsImpl value, $Res Function(_$PaymentUrlsImpl) then) =
      __$$PaymentUrlsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? click, String? payme});
}

/// @nodoc
class __$$PaymentUrlsImplCopyWithImpl<$Res>
    extends _$PaymentUrlsCopyWithImpl<$Res, _$PaymentUrlsImpl>
    implements _$$PaymentUrlsImplCopyWith<$Res> {
  __$$PaymentUrlsImplCopyWithImpl(
      _$PaymentUrlsImpl _value, $Res Function(_$PaymentUrlsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? click = freezed,
    Object? payme = freezed,
  }) {
    return _then(_$PaymentUrlsImpl(
      click: freezed == click
          ? _value.click
          : click // ignore: cast_nullable_to_non_nullable
              as String?,
      payme: freezed == payme
          ? _value.payme
          : payme // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentUrlsImpl implements _PaymentUrls {
  const _$PaymentUrlsImpl({this.click, this.payme});

  factory _$PaymentUrlsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentUrlsImplFromJson(json);

  @override
  final String? click;
  @override
  final String? payme;

  @override
  String toString() {
    return 'PaymentUrls(click: $click, payme: $payme)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentUrlsImpl &&
            (identical(other.click, click) || other.click == click) &&
            (identical(other.payme, payme) || other.payme == payme));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, click, payme);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentUrlsImplCopyWith<_$PaymentUrlsImpl> get copyWith =>
      __$$PaymentUrlsImplCopyWithImpl<_$PaymentUrlsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentUrlsImplToJson(
      this,
    );
  }
}

abstract class _PaymentUrls implements PaymentUrls {
  const factory _PaymentUrls({final String? click, final String? payme}) =
      _$PaymentUrlsImpl;

  factory _PaymentUrls.fromJson(Map<String, dynamic> json) =
      _$PaymentUrlsImpl.fromJson;

  @override
  String? get click;
  @override
  String? get payme;
  @override
  @JsonKey(ignore: true)
  _$$PaymentUrlsImplCopyWith<_$PaymentUrlsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateResponse _$CreateResponseFromJson(Map<String, dynamic> json) {
  return _CreateResponse.fromJson(json);
}

/// @nodoc
mixin _$CreateResponse {
  @JsonKey(name: 'session_id')
  String get sessionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'policy_number')
  String? get policyNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_url')
  String? get paymentUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'pay')
  PaymentUrls? get pay => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount')
  double? get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'currency')
  String? get currency => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateResponseCopyWith<CreateResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateResponseCopyWith<$Res> {
  factory $CreateResponseCopyWith(
          CreateResponse value, $Res Function(CreateResponse) then) =
      _$CreateResponseCopyWithImpl<$Res, CreateResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'session_id') String sessionId,
      @JsonKey(name: 'policy_number') String? policyNumber,
      @JsonKey(name: 'payment_url') String? paymentUrl,
      @JsonKey(name: 'pay') PaymentUrls? pay,
      @JsonKey(name: 'amount') double? amount,
      @JsonKey(name: 'currency') String? currency});

  $PaymentUrlsCopyWith<$Res>? get pay;
}

/// @nodoc
class _$CreateResponseCopyWithImpl<$Res, $Val extends CreateResponse>
    implements $CreateResponseCopyWith<$Res> {
  _$CreateResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? policyNumber = freezed,
    Object? paymentUrl = freezed,
    Object? pay = freezed,
    Object? amount = freezed,
    Object? currency = freezed,
  }) {
    return _then(_value.copyWith(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      policyNumber: freezed == policyNumber
          ? _value.policyNumber
          : policyNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentUrl: freezed == paymentUrl
          ? _value.paymentUrl
          : paymentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      pay: freezed == pay
          ? _value.pay
          : pay // ignore: cast_nullable_to_non_nullable
              as PaymentUrls?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PaymentUrlsCopyWith<$Res>? get pay {
    if (_value.pay == null) {
      return null;
    }

    return $PaymentUrlsCopyWith<$Res>(_value.pay!, (value) {
      return _then(_value.copyWith(pay: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CreateResponseImplCopyWith<$Res>
    implements $CreateResponseCopyWith<$Res> {
  factory _$$CreateResponseImplCopyWith(_$CreateResponseImpl value,
          $Res Function(_$CreateResponseImpl) then) =
      __$$CreateResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'session_id') String sessionId,
      @JsonKey(name: 'policy_number') String? policyNumber,
      @JsonKey(name: 'payment_url') String? paymentUrl,
      @JsonKey(name: 'pay') PaymentUrls? pay,
      @JsonKey(name: 'amount') double? amount,
      @JsonKey(name: 'currency') String? currency});

  @override
  $PaymentUrlsCopyWith<$Res>? get pay;
}

/// @nodoc
class __$$CreateResponseImplCopyWithImpl<$Res>
    extends _$CreateResponseCopyWithImpl<$Res, _$CreateResponseImpl>
    implements _$$CreateResponseImplCopyWith<$Res> {
  __$$CreateResponseImplCopyWithImpl(
      _$CreateResponseImpl _value, $Res Function(_$CreateResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? policyNumber = freezed,
    Object? paymentUrl = freezed,
    Object? pay = freezed,
    Object? amount = freezed,
    Object? currency = freezed,
  }) {
    return _then(_$CreateResponseImpl(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      policyNumber: freezed == policyNumber
          ? _value.policyNumber
          : policyNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentUrl: freezed == paymentUrl
          ? _value.paymentUrl
          : paymentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      pay: freezed == pay
          ? _value.pay
          : pay // ignore: cast_nullable_to_non_nullable
              as PaymentUrls?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateResponseImpl implements _CreateResponse {
  const _$CreateResponseImpl(
      {@JsonKey(name: 'session_id') required this.sessionId,
      @JsonKey(name: 'policy_number') this.policyNumber,
      @JsonKey(name: 'payment_url') this.paymentUrl,
      @JsonKey(name: 'pay') this.pay,
      @JsonKey(name: 'amount') this.amount,
      @JsonKey(name: 'currency') this.currency});

  factory _$CreateResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateResponseImplFromJson(json);

  @override
  @JsonKey(name: 'session_id')
  final String sessionId;
  @override
  @JsonKey(name: 'policy_number')
  final String? policyNumber;
  @override
  @JsonKey(name: 'payment_url')
  final String? paymentUrl;
  @override
  @JsonKey(name: 'pay')
  final PaymentUrls? pay;
  @override
  @JsonKey(name: 'amount')
  final double? amount;
  @override
  @JsonKey(name: 'currency')
  final String? currency;

  @override
  String toString() {
    return 'CreateResponse(sessionId: $sessionId, policyNumber: $policyNumber, paymentUrl: $paymentUrl, pay: $pay, amount: $amount, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateResponseImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.policyNumber, policyNumber) ||
                other.policyNumber == policyNumber) &&
            (identical(other.paymentUrl, paymentUrl) ||
                other.paymentUrl == paymentUrl) &&
            (identical(other.pay, pay) || other.pay == pay) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, sessionId, policyNumber, paymentUrl, pay, amount, currency);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateResponseImplCopyWith<_$CreateResponseImpl> get copyWith =>
      __$$CreateResponseImplCopyWithImpl<_$CreateResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateResponseImplToJson(
      this,
    );
  }
}

abstract class _CreateResponse implements CreateResponse {
  const factory _CreateResponse(
          {@JsonKey(name: 'session_id') required final String sessionId,
          @JsonKey(name: 'policy_number') final String? policyNumber,
          @JsonKey(name: 'payment_url') final String? paymentUrl,
          @JsonKey(name: 'pay') final PaymentUrls? pay,
          @JsonKey(name: 'amount') final double? amount,
          @JsonKey(name: 'currency') final String? currency}) =
      _$CreateResponseImpl;

  factory _CreateResponse.fromJson(Map<String, dynamic> json) =
      _$CreateResponseImpl.fromJson;

  @override
  @JsonKey(name: 'session_id')
  String get sessionId;
  @override
  @JsonKey(name: 'policy_number')
  String? get policyNumber;
  @override
  @JsonKey(name: 'payment_url')
  String? get paymentUrl;
  @override
  @JsonKey(name: 'pay')
  PaymentUrls? get pay;
  @override
  @JsonKey(name: 'amount')
  double? get amount;
  @override
  @JsonKey(name: 'currency')
  String? get currency;
  @override
  @JsonKey(ignore: true)
  _$$CreateResponseImplCopyWith<_$CreateResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
