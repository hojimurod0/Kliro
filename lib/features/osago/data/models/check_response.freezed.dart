// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CheckResponse _$CheckResponseFromJson(Map<String, dynamic> json) {
  return _CheckResponse.fromJson(json);
}

/// @nodoc
mixin _$CheckResponse {
  @JsonKey(name: 'session_id')
  String get sessionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'policy_number')
  String? get policyNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'status')
  String get status => throw _privateConstructorUsedError;
  @JsonKey(
      name: 'issued_at',
      fromJson: parseNullableOsagoDate,
      toJson: formatNullableOsagoDate)
  DateTime? get issuedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount')
  double? get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'currency')
  String? get currency => throw _privateConstructorUsedError;
  @JsonKey(name: 'download_url')
  String? get downloadUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CheckResponseCopyWith<CheckResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckResponseCopyWith<$Res> {
  factory $CheckResponseCopyWith(
          CheckResponse value, $Res Function(CheckResponse) then) =
      _$CheckResponseCopyWithImpl<$Res, CheckResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'session_id') String sessionId,
      @JsonKey(name: 'policy_number') String? policyNumber,
      @JsonKey(name: 'status') String status,
      @JsonKey(
          name: 'issued_at',
          fromJson: parseNullableOsagoDate,
          toJson: formatNullableOsagoDate)
      DateTime? issuedAt,
      @JsonKey(name: 'amount') double? amount,
      @JsonKey(name: 'currency') String? currency,
      @JsonKey(name: 'download_url') String? downloadUrl});
}

/// @nodoc
class _$CheckResponseCopyWithImpl<$Res, $Val extends CheckResponse>
    implements $CheckResponseCopyWith<$Res> {
  _$CheckResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? policyNumber = freezed,
    Object? status = null,
    Object? issuedAt = freezed,
    Object? amount = freezed,
    Object? currency = freezed,
    Object? downloadUrl = freezed,
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
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      issuedAt: freezed == issuedAt
          ? _value.issuedAt
          : issuedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      downloadUrl: freezed == downloadUrl
          ? _value.downloadUrl
          : downloadUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CheckResponseImplCopyWith<$Res>
    implements $CheckResponseCopyWith<$Res> {
  factory _$$CheckResponseImplCopyWith(
          _$CheckResponseImpl value, $Res Function(_$CheckResponseImpl) then) =
      __$$CheckResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'session_id') String sessionId,
      @JsonKey(name: 'policy_number') String? policyNumber,
      @JsonKey(name: 'status') String status,
      @JsonKey(
          name: 'issued_at',
          fromJson: parseNullableOsagoDate,
          toJson: formatNullableOsagoDate)
      DateTime? issuedAt,
      @JsonKey(name: 'amount') double? amount,
      @JsonKey(name: 'currency') String? currency,
      @JsonKey(name: 'download_url') String? downloadUrl});
}

/// @nodoc
class __$$CheckResponseImplCopyWithImpl<$Res>
    extends _$CheckResponseCopyWithImpl<$Res, _$CheckResponseImpl>
    implements _$$CheckResponseImplCopyWith<$Res> {
  __$$CheckResponseImplCopyWithImpl(
      _$CheckResponseImpl _value, $Res Function(_$CheckResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? policyNumber = freezed,
    Object? status = null,
    Object? issuedAt = freezed,
    Object? amount = freezed,
    Object? currency = freezed,
    Object? downloadUrl = freezed,
  }) {
    return _then(_$CheckResponseImpl(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      policyNumber: freezed == policyNumber
          ? _value.policyNumber
          : policyNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      issuedAt: freezed == issuedAt
          ? _value.issuedAt
          : issuedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      downloadUrl: freezed == downloadUrl
          ? _value.downloadUrl
          : downloadUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CheckResponseImpl extends _CheckResponse {
  const _$CheckResponseImpl(
      {@JsonKey(name: 'session_id') required this.sessionId,
      @JsonKey(name: 'policy_number') this.policyNumber,
      @JsonKey(name: 'status') required this.status,
      @JsonKey(
          name: 'issued_at',
          fromJson: parseNullableOsagoDate,
          toJson: formatNullableOsagoDate)
      this.issuedAt,
      @JsonKey(name: 'amount') this.amount,
      @JsonKey(name: 'currency') this.currency,
      @JsonKey(name: 'download_url') this.downloadUrl})
      : super._();

  factory _$CheckResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckResponseImplFromJson(json);

  @override
  @JsonKey(name: 'session_id')
  final String sessionId;
  @override
  @JsonKey(name: 'policy_number')
  final String? policyNumber;
  @override
  @JsonKey(name: 'status')
  final String status;
  @override
  @JsonKey(
      name: 'issued_at',
      fromJson: parseNullableOsagoDate,
      toJson: formatNullableOsagoDate)
  final DateTime? issuedAt;
  @override
  @JsonKey(name: 'amount')
  final double? amount;
  @override
  @JsonKey(name: 'currency')
  final String? currency;
  @override
  @JsonKey(name: 'download_url')
  final String? downloadUrl;

  @override
  String toString() {
    return 'CheckResponse(sessionId: $sessionId, policyNumber: $policyNumber, status: $status, issuedAt: $issuedAt, amount: $amount, currency: $currency, downloadUrl: $downloadUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckResponseImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.policyNumber, policyNumber) ||
                other.policyNumber == policyNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.issuedAt, issuedAt) ||
                other.issuedAt == issuedAt) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.downloadUrl, downloadUrl) ||
                other.downloadUrl == downloadUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, sessionId, policyNumber, status,
      issuedAt, amount, currency, downloadUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckResponseImplCopyWith<_$CheckResponseImpl> get copyWith =>
      __$$CheckResponseImplCopyWithImpl<_$CheckResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckResponseImplToJson(
      this,
    );
  }
}

abstract class _CheckResponse extends CheckResponse {
  const factory _CheckResponse(
          {@JsonKey(name: 'session_id') required final String sessionId,
          @JsonKey(name: 'policy_number') final String? policyNumber,
          @JsonKey(name: 'status') required final String status,
          @JsonKey(
              name: 'issued_at',
              fromJson: parseNullableOsagoDate,
              toJson: formatNullableOsagoDate)
          final DateTime? issuedAt,
          @JsonKey(name: 'amount') final double? amount,
          @JsonKey(name: 'currency') final String? currency,
          @JsonKey(name: 'download_url') final String? downloadUrl}) =
      _$CheckResponseImpl;
  const _CheckResponse._() : super._();

  factory _CheckResponse.fromJson(Map<String, dynamic> json) =
      _$CheckResponseImpl.fromJson;

  @override
  @JsonKey(name: 'session_id')
  String get sessionId;
  @override
  @JsonKey(name: 'policy_number')
  String? get policyNumber;
  @override
  @JsonKey(name: 'status')
  String get status;
  @override
  @JsonKey(
      name: 'issued_at',
      fromJson: parseNullableOsagoDate,
      toJson: formatNullableOsagoDate)
  DateTime? get issuedAt;
  @override
  @JsonKey(name: 'amount')
  double? get amount;
  @override
  @JsonKey(name: 'currency')
  String? get currency;
  @override
  @JsonKey(name: 'download_url')
  String? get downloadUrl;
  @override
  @JsonKey(ignore: true)
  _$$CheckResponseImplCopyWith<_$CheckResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
