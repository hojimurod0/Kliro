// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calc_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CalcResponse _$CalcResponseFromJson(Map<String, dynamic> json) {
  return _CalcResponse.fromJson(json);
}

/// @nodoc
mixin _$CalcResponse {
  @JsonKey(name: 'session_id')
  String get sessionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount')
  double get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'currency')
  String get currency => throw _privateConstructorUsedError;
  @JsonKey(name: 'provider')
  String? get provider => throw _privateConstructorUsedError;
  @JsonKey(name: 'vehicle')
  VehicleModel? get vehicle => throw _privateConstructorUsedError;
  @JsonKey(name: 'insurance')
  InsuranceModel? get insurance => throw _privateConstructorUsedError;
  @JsonKey(name: 'available_providers')
  List<InsuranceModel> get availableProviders =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_name')
  String? get ownerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'number_drivers_id')
  String? get numberDriversId => throw _privateConstructorUsedError;
  @JsonKey(name: 'issue_year')
  int? get issueYear => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CalcResponseCopyWith<CalcResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalcResponseCopyWith<$Res> {
  factory $CalcResponseCopyWith(
          CalcResponse value, $Res Function(CalcResponse) then) =
      _$CalcResponseCopyWithImpl<$Res, CalcResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'session_id') String sessionId,
      @JsonKey(name: 'amount') double amount,
      @JsonKey(name: 'currency') String currency,
      @JsonKey(name: 'provider') String? provider,
      @JsonKey(name: 'vehicle') VehicleModel? vehicle,
      @JsonKey(name: 'insurance') InsuranceModel? insurance,
      @JsonKey(name: 'available_providers')
      List<InsuranceModel> availableProviders,
      @JsonKey(name: 'owner_name') String? ownerName,
      @JsonKey(name: 'number_drivers_id') String? numberDriversId,
      @JsonKey(name: 'issue_year') int? issueYear});

  $VehicleModelCopyWith<$Res>? get vehicle;
  $InsuranceModelCopyWith<$Res>? get insurance;
}

/// @nodoc
class _$CalcResponseCopyWithImpl<$Res, $Val extends CalcResponse>
    implements $CalcResponseCopyWith<$Res> {
  _$CalcResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? amount = null,
    Object? currency = null,
    Object? provider = freezed,
    Object? vehicle = freezed,
    Object? insurance = freezed,
    Object? availableProviders = null,
    Object? ownerName = freezed,
    Object? numberDriversId = freezed,
    Object? issueYear = freezed,
  }) {
    return _then(_value.copyWith(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      provider: freezed == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicle: freezed == vehicle
          ? _value.vehicle
          : vehicle // ignore: cast_nullable_to_non_nullable
              as VehicleModel?,
      insurance: freezed == insurance
          ? _value.insurance
          : insurance // ignore: cast_nullable_to_non_nullable
              as InsuranceModel?,
      availableProviders: null == availableProviders
          ? _value.availableProviders
          : availableProviders // ignore: cast_nullable_to_non_nullable
              as List<InsuranceModel>,
      ownerName: freezed == ownerName
          ? _value.ownerName
          : ownerName // ignore: cast_nullable_to_non_nullable
              as String?,
      numberDriversId: freezed == numberDriversId
          ? _value.numberDriversId
          : numberDriversId // ignore: cast_nullable_to_non_nullable
              as String?,
      issueYear: freezed == issueYear
          ? _value.issueYear
          : issueYear // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $VehicleModelCopyWith<$Res>? get vehicle {
    if (_value.vehicle == null) {
      return null;
    }

    return $VehicleModelCopyWith<$Res>(_value.vehicle!, (value) {
      return _then(_value.copyWith(vehicle: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $InsuranceModelCopyWith<$Res>? get insurance {
    if (_value.insurance == null) {
      return null;
    }

    return $InsuranceModelCopyWith<$Res>(_value.insurance!, (value) {
      return _then(_value.copyWith(insurance: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CalcResponseImplCopyWith<$Res>
    implements $CalcResponseCopyWith<$Res> {
  factory _$$CalcResponseImplCopyWith(
          _$CalcResponseImpl value, $Res Function(_$CalcResponseImpl) then) =
      __$$CalcResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'session_id') String sessionId,
      @JsonKey(name: 'amount') double amount,
      @JsonKey(name: 'currency') String currency,
      @JsonKey(name: 'provider') String? provider,
      @JsonKey(name: 'vehicle') VehicleModel? vehicle,
      @JsonKey(name: 'insurance') InsuranceModel? insurance,
      @JsonKey(name: 'available_providers')
      List<InsuranceModel> availableProviders,
      @JsonKey(name: 'owner_name') String? ownerName,
      @JsonKey(name: 'number_drivers_id') String? numberDriversId,
      @JsonKey(name: 'issue_year') int? issueYear});

  @override
  $VehicleModelCopyWith<$Res>? get vehicle;
  @override
  $InsuranceModelCopyWith<$Res>? get insurance;
}

/// @nodoc
class __$$CalcResponseImplCopyWithImpl<$Res>
    extends _$CalcResponseCopyWithImpl<$Res, _$CalcResponseImpl>
    implements _$$CalcResponseImplCopyWith<$Res> {
  __$$CalcResponseImplCopyWithImpl(
      _$CalcResponseImpl _value, $Res Function(_$CalcResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? amount = null,
    Object? currency = null,
    Object? provider = freezed,
    Object? vehicle = freezed,
    Object? insurance = freezed,
    Object? availableProviders = null,
    Object? ownerName = freezed,
    Object? numberDriversId = freezed,
    Object? issueYear = freezed,
  }) {
    return _then(_$CalcResponseImpl(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      provider: freezed == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicle: freezed == vehicle
          ? _value.vehicle
          : vehicle // ignore: cast_nullable_to_non_nullable
              as VehicleModel?,
      insurance: freezed == insurance
          ? _value.insurance
          : insurance // ignore: cast_nullable_to_non_nullable
              as InsuranceModel?,
      availableProviders: null == availableProviders
          ? _value._availableProviders
          : availableProviders // ignore: cast_nullable_to_non_nullable
              as List<InsuranceModel>,
      ownerName: freezed == ownerName
          ? _value.ownerName
          : ownerName // ignore: cast_nullable_to_non_nullable
              as String?,
      numberDriversId: freezed == numberDriversId
          ? _value.numberDriversId
          : numberDriversId // ignore: cast_nullable_to_non_nullable
              as String?,
      issueYear: freezed == issueYear
          ? _value.issueYear
          : issueYear // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalcResponseImpl implements _CalcResponse {
  const _$CalcResponseImpl(
      {@JsonKey(name: 'session_id') required this.sessionId,
      @JsonKey(name: 'amount') required this.amount,
      @JsonKey(name: 'currency') required this.currency,
      @JsonKey(name: 'provider') this.provider,
      @JsonKey(name: 'vehicle') this.vehicle,
      @JsonKey(name: 'insurance') this.insurance,
      @JsonKey(name: 'available_providers')
      final List<InsuranceModel> availableProviders = const <InsuranceModel>[],
      @JsonKey(name: 'owner_name') this.ownerName,
      @JsonKey(name: 'number_drivers_id') this.numberDriversId,
      @JsonKey(name: 'issue_year') this.issueYear})
      : _availableProviders = availableProviders;

  factory _$CalcResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalcResponseImplFromJson(json);

  @override
  @JsonKey(name: 'session_id')
  final String sessionId;
  @override
  @JsonKey(name: 'amount')
  final double amount;
  @override
  @JsonKey(name: 'currency')
  final String currency;
  @override
  @JsonKey(name: 'provider')
  final String? provider;
  @override
  @JsonKey(name: 'vehicle')
  final VehicleModel? vehicle;
  @override
  @JsonKey(name: 'insurance')
  final InsuranceModel? insurance;
  final List<InsuranceModel> _availableProviders;
  @override
  @JsonKey(name: 'available_providers')
  List<InsuranceModel> get availableProviders {
    if (_availableProviders is EqualUnmodifiableListView)
      return _availableProviders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableProviders);
  }

  @override
  @JsonKey(name: 'owner_name')
  final String? ownerName;
  @override
  @JsonKey(name: 'number_drivers_id')
  final String? numberDriversId;
  @override
  @JsonKey(name: 'issue_year')
  final int? issueYear;

  @override
  String toString() {
    return 'CalcResponse(sessionId: $sessionId, amount: $amount, currency: $currency, provider: $provider, vehicle: $vehicle, insurance: $insurance, availableProviders: $availableProviders, ownerName: $ownerName, numberDriversId: $numberDriversId, issueYear: $issueYear)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalcResponseImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.vehicle, vehicle) || other.vehicle == vehicle) &&
            (identical(other.insurance, insurance) ||
                other.insurance == insurance) &&
            const DeepCollectionEquality()
                .equals(other._availableProviders, _availableProviders) &&
            (identical(other.ownerName, ownerName) ||
                other.ownerName == ownerName) &&
            (identical(other.numberDriversId, numberDriversId) ||
                other.numberDriversId == numberDriversId) &&
            (identical(other.issueYear, issueYear) ||
                other.issueYear == issueYear));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      sessionId,
      amount,
      currency,
      provider,
      vehicle,
      insurance,
      const DeepCollectionEquality().hash(_availableProviders),
      ownerName,
      numberDriversId,
      issueYear);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CalcResponseImplCopyWith<_$CalcResponseImpl> get copyWith =>
      __$$CalcResponseImplCopyWithImpl<_$CalcResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalcResponseImplToJson(
      this,
    );
  }
}

abstract class _CalcResponse implements CalcResponse {
  const factory _CalcResponse(
      {@JsonKey(name: 'session_id') required final String sessionId,
      @JsonKey(name: 'amount') required final double amount,
      @JsonKey(name: 'currency') required final String currency,
      @JsonKey(name: 'provider') final String? provider,
      @JsonKey(name: 'vehicle') final VehicleModel? vehicle,
      @JsonKey(name: 'insurance') final InsuranceModel? insurance,
      @JsonKey(name: 'available_providers')
      final List<InsuranceModel> availableProviders,
      @JsonKey(name: 'owner_name') final String? ownerName,
      @JsonKey(name: 'number_drivers_id') final String? numberDriversId,
      @JsonKey(name: 'issue_year') final int? issueYear}) = _$CalcResponseImpl;

  factory _CalcResponse.fromJson(Map<String, dynamic> json) =
      _$CalcResponseImpl.fromJson;

  @override
  @JsonKey(name: 'session_id')
  String get sessionId;
  @override
  @JsonKey(name: 'amount')
  double get amount;
  @override
  @JsonKey(name: 'currency')
  String get currency;
  @override
  @JsonKey(name: 'provider')
  String? get provider;
  @override
  @JsonKey(name: 'vehicle')
  VehicleModel? get vehicle;
  @override
  @JsonKey(name: 'insurance')
  InsuranceModel? get insurance;
  @override
  @JsonKey(name: 'available_providers')
  List<InsuranceModel> get availableProviders;
  @override
  @JsonKey(name: 'owner_name')
  String? get ownerName;
  @override
  @JsonKey(name: 'number_drivers_id')
  String? get numberDriversId;
  @override
  @JsonKey(name: 'issue_year')
  int? get issueYear;
  @override
  @JsonKey(ignore: true)
  _$$CalcResponseImplCopyWith<_$CalcResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
