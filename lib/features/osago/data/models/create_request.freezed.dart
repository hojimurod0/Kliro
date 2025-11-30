// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreateRequest _$CreateRequestFromJson(Map<String, dynamic> json) {
  return _CreateRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateRequest {
  String get provider => throw _privateConstructorUsedError;
  @JsonKey(name: 'session_id')
  String get sessionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'drivers')
  List<DriverModel> get drivers => throw _privateConstructorUsedError;
  @JsonKey(name: 'applicant_is_driver')
  bool get applicantIsDriver => throw _privateConstructorUsedError;
  @JsonKey(name: 'phone_number')
  String get phoneNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner__inn')
  String? get ownerInn => throw _privateConstructorUsedError;
  @JsonKey(name: 'applicant__license_seria')
  String? get applicantLicenseSeria => throw _privateConstructorUsedError;
  @JsonKey(name: 'applicant__license_number')
  String? get applicantLicenseNumber => throw _privateConstructorUsedError;
  @JsonKey(
      name: 'start_date', fromJson: parseOsagoDate, toJson: formatOsagoDate)
  DateTime get startDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateRequestCopyWith<CreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateRequestCopyWith<$Res> {
  factory $CreateRequestCopyWith(
          CreateRequest value, $Res Function(CreateRequest) then) =
      _$CreateRequestCopyWithImpl<$Res, CreateRequest>;
  @useResult
  $Res call(
      {String provider,
      @JsonKey(name: 'session_id') String sessionId,
      @JsonKey(name: 'drivers') List<DriverModel> drivers,
      @JsonKey(name: 'applicant_is_driver') bool applicantIsDriver,
      @JsonKey(name: 'phone_number') String phoneNumber,
      @JsonKey(name: 'owner__inn') String? ownerInn,
      @JsonKey(name: 'applicant__license_seria') String? applicantLicenseSeria,
      @JsonKey(name: 'applicant__license_number')
      String? applicantLicenseNumber,
      @JsonKey(
          name: 'start_date', fromJson: parseOsagoDate, toJson: formatOsagoDate)
      DateTime startDate});
}

/// @nodoc
class _$CreateRequestCopyWithImpl<$Res, $Val extends CreateRequest>
    implements $CreateRequestCopyWith<$Res> {
  _$CreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? provider = null,
    Object? sessionId = null,
    Object? drivers = null,
    Object? applicantIsDriver = null,
    Object? phoneNumber = null,
    Object? ownerInn = freezed,
    Object? applicantLicenseSeria = freezed,
    Object? applicantLicenseNumber = freezed,
    Object? startDate = null,
  }) {
    return _then(_value.copyWith(
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      drivers: null == drivers
          ? _value.drivers
          : drivers // ignore: cast_nullable_to_non_nullable
              as List<DriverModel>,
      applicantIsDriver: null == applicantIsDriver
          ? _value.applicantIsDriver
          : applicantIsDriver // ignore: cast_nullable_to_non_nullable
              as bool,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      ownerInn: freezed == ownerInn
          ? _value.ownerInn
          : ownerInn // ignore: cast_nullable_to_non_nullable
              as String?,
      applicantLicenseSeria: freezed == applicantLicenseSeria
          ? _value.applicantLicenseSeria
          : applicantLicenseSeria // ignore: cast_nullable_to_non_nullable
              as String?,
      applicantLicenseNumber: freezed == applicantLicenseNumber
          ? _value.applicantLicenseNumber
          : applicantLicenseNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateRequestImplCopyWith<$Res>
    implements $CreateRequestCopyWith<$Res> {
  factory _$$CreateRequestImplCopyWith(
          _$CreateRequestImpl value, $Res Function(_$CreateRequestImpl) then) =
      __$$CreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String provider,
      @JsonKey(name: 'session_id') String sessionId,
      @JsonKey(name: 'drivers') List<DriverModel> drivers,
      @JsonKey(name: 'applicant_is_driver') bool applicantIsDriver,
      @JsonKey(name: 'phone_number') String phoneNumber,
      @JsonKey(name: 'owner__inn') String? ownerInn,
      @JsonKey(name: 'applicant__license_seria') String? applicantLicenseSeria,
      @JsonKey(name: 'applicant__license_number')
      String? applicantLicenseNumber,
      @JsonKey(
          name: 'start_date', fromJson: parseOsagoDate, toJson: formatOsagoDate)
      DateTime startDate});
}

/// @nodoc
class __$$CreateRequestImplCopyWithImpl<$Res>
    extends _$CreateRequestCopyWithImpl<$Res, _$CreateRequestImpl>
    implements _$$CreateRequestImplCopyWith<$Res> {
  __$$CreateRequestImplCopyWithImpl(
      _$CreateRequestImpl _value, $Res Function(_$CreateRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? provider = null,
    Object? sessionId = null,
    Object? drivers = null,
    Object? applicantIsDriver = null,
    Object? phoneNumber = null,
    Object? ownerInn = freezed,
    Object? applicantLicenseSeria = freezed,
    Object? applicantLicenseNumber = freezed,
    Object? startDate = null,
  }) {
    return _then(_$CreateRequestImpl(
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      drivers: null == drivers
          ? _value._drivers
          : drivers // ignore: cast_nullable_to_non_nullable
              as List<DriverModel>,
      applicantIsDriver: null == applicantIsDriver
          ? _value.applicantIsDriver
          : applicantIsDriver // ignore: cast_nullable_to_non_nullable
              as bool,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      ownerInn: freezed == ownerInn
          ? _value.ownerInn
          : ownerInn // ignore: cast_nullable_to_non_nullable
              as String?,
      applicantLicenseSeria: freezed == applicantLicenseSeria
          ? _value.applicantLicenseSeria
          : applicantLicenseSeria // ignore: cast_nullable_to_non_nullable
              as String?,
      applicantLicenseNumber: freezed == applicantLicenseNumber
          ? _value.applicantLicenseNumber
          : applicantLicenseNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateRequestImpl implements _CreateRequest {
  const _$CreateRequestImpl(
      {required this.provider,
      @JsonKey(name: 'session_id') required this.sessionId,
      @JsonKey(name: 'drivers') required final List<DriverModel> drivers,
      @JsonKey(name: 'applicant_is_driver') this.applicantIsDriver = false,
      @JsonKey(name: 'phone_number') required this.phoneNumber,
      @JsonKey(name: 'owner__inn') this.ownerInn,
      @JsonKey(name: 'applicant__license_seria') this.applicantLicenseSeria,
      @JsonKey(name: 'applicant__license_number') this.applicantLicenseNumber,
      @JsonKey(
          name: 'start_date', fromJson: parseOsagoDate, toJson: formatOsagoDate)
      required this.startDate})
      : _drivers = drivers;

  factory _$CreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateRequestImplFromJson(json);

  @override
  final String provider;
  @override
  @JsonKey(name: 'session_id')
  final String sessionId;
  final List<DriverModel> _drivers;
  @override
  @JsonKey(name: 'drivers')
  List<DriverModel> get drivers {
    if (_drivers is EqualUnmodifiableListView) return _drivers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_drivers);
  }

  @override
  @JsonKey(name: 'applicant_is_driver')
  final bool applicantIsDriver;
  @override
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  @override
  @JsonKey(name: 'owner__inn')
  final String? ownerInn;
  @override
  @JsonKey(name: 'applicant__license_seria')
  final String? applicantLicenseSeria;
  @override
  @JsonKey(name: 'applicant__license_number')
  final String? applicantLicenseNumber;
  @override
  @JsonKey(
      name: 'start_date', fromJson: parseOsagoDate, toJson: formatOsagoDate)
  final DateTime startDate;

  @override
  String toString() {
    return 'CreateRequest(provider: $provider, sessionId: $sessionId, drivers: $drivers, applicantIsDriver: $applicantIsDriver, phoneNumber: $phoneNumber, ownerInn: $ownerInn, applicantLicenseSeria: $applicantLicenseSeria, applicantLicenseNumber: $applicantLicenseNumber, startDate: $startDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateRequestImpl &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            const DeepCollectionEquality().equals(other._drivers, _drivers) &&
            (identical(other.applicantIsDriver, applicantIsDriver) ||
                other.applicantIsDriver == applicantIsDriver) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.ownerInn, ownerInn) ||
                other.ownerInn == ownerInn) &&
            (identical(other.applicantLicenseSeria, applicantLicenseSeria) ||
                other.applicantLicenseSeria == applicantLicenseSeria) &&
            (identical(other.applicantLicenseNumber, applicantLicenseNumber) ||
                other.applicantLicenseNumber == applicantLicenseNumber) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      provider,
      sessionId,
      const DeepCollectionEquality().hash(_drivers),
      applicantIsDriver,
      phoneNumber,
      ownerInn,
      applicantLicenseSeria,
      applicantLicenseNumber,
      startDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateRequestImplCopyWith<_$CreateRequestImpl> get copyWith =>
      __$$CreateRequestImplCopyWithImpl<_$CreateRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateRequest implements CreateRequest {
  const factory _CreateRequest(
      {required final String provider,
      @JsonKey(name: 'session_id') required final String sessionId,
      @JsonKey(name: 'drivers') required final List<DriverModel> drivers,
      @JsonKey(name: 'applicant_is_driver') final bool applicantIsDriver,
      @JsonKey(name: 'phone_number') required final String phoneNumber,
      @JsonKey(name: 'owner__inn') final String? ownerInn,
      @JsonKey(name: 'applicant__license_seria')
      final String? applicantLicenseSeria,
      @JsonKey(name: 'applicant__license_number')
      final String? applicantLicenseNumber,
      @JsonKey(
          name: 'start_date', fromJson: parseOsagoDate, toJson: formatOsagoDate)
      required final DateTime startDate}) = _$CreateRequestImpl;

  factory _CreateRequest.fromJson(Map<String, dynamic> json) =
      _$CreateRequestImpl.fromJson;

  @override
  String get provider;
  @override
  @JsonKey(name: 'session_id')
  String get sessionId;
  @override
  @JsonKey(name: 'drivers')
  List<DriverModel> get drivers;
  @override
  @JsonKey(name: 'applicant_is_driver')
  bool get applicantIsDriver;
  @override
  @JsonKey(name: 'phone_number')
  String get phoneNumber;
  @override
  @JsonKey(name: 'owner__inn')
  String? get ownerInn;
  @override
  @JsonKey(name: 'applicant__license_seria')
  String? get applicantLicenseSeria;
  @override
  @JsonKey(name: 'applicant__license_number')
  String? get applicantLicenseNumber;
  @override
  @JsonKey(
      name: 'start_date', fromJson: parseOsagoDate, toJson: formatOsagoDate)
  DateTime get startDate;
  @override
  @JsonKey(ignore: true)
  _$$CreateRequestImplCopyWith<_$CreateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
