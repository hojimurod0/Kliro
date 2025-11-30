// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DriverModel _$DriverModelFromJson(Map<String, dynamic> json) {
  return _DriverModel.fromJson(json);
}

/// @nodoc
mixin _$DriverModel {
  @JsonKey(name: 'passport__seria')
  String get passportSeria => throw _privateConstructorUsedError;
  @JsonKey(name: 'passport__number')
  String get passportNumber => throw _privateConstructorUsedError;
  @JsonKey(
      name: 'driver_birthday',
      fromJson: parseOsagoDate,
      toJson: formatOsagoDate)
  DateTime get driverBirthday => throw _privateConstructorUsedError;
  @JsonKey(name: 'relative')
  int get relative => throw _privateConstructorUsedError;
  @JsonKey(name: 'name')
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'license__seria')
  String? get licenseSeria => throw _privateConstructorUsedError;
  @JsonKey(name: 'license__number')
  String? get licenseNumber => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DriverModelCopyWith<DriverModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverModelCopyWith<$Res> {
  factory $DriverModelCopyWith(
          DriverModel value, $Res Function(DriverModel) then) =
      _$DriverModelCopyWithImpl<$Res, DriverModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'passport__seria') String passportSeria,
      @JsonKey(name: 'passport__number') String passportNumber,
      @JsonKey(
          name: 'driver_birthday',
          fromJson: parseOsagoDate,
          toJson: formatOsagoDate)
      DateTime driverBirthday,
      @JsonKey(name: 'relative') int relative,
      @JsonKey(name: 'name') String? name,
      @JsonKey(name: 'license__seria') String? licenseSeria,
      @JsonKey(name: 'license__number') String? licenseNumber});
}

/// @nodoc
class _$DriverModelCopyWithImpl<$Res, $Val extends DriverModel>
    implements $DriverModelCopyWith<$Res> {
  _$DriverModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? passportSeria = null,
    Object? passportNumber = null,
    Object? driverBirthday = null,
    Object? relative = null,
    Object? name = freezed,
    Object? licenseSeria = freezed,
    Object? licenseNumber = freezed,
  }) {
    return _then(_value.copyWith(
      passportSeria: null == passportSeria
          ? _value.passportSeria
          : passportSeria // ignore: cast_nullable_to_non_nullable
              as String,
      passportNumber: null == passportNumber
          ? _value.passportNumber
          : passportNumber // ignore: cast_nullable_to_non_nullable
              as String,
      driverBirthday: null == driverBirthday
          ? _value.driverBirthday
          : driverBirthday // ignore: cast_nullable_to_non_nullable
              as DateTime,
      relative: null == relative
          ? _value.relative
          : relative // ignore: cast_nullable_to_non_nullable
              as int,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      licenseSeria: freezed == licenseSeria
          ? _value.licenseSeria
          : licenseSeria // ignore: cast_nullable_to_non_nullable
              as String?,
      licenseNumber: freezed == licenseNumber
          ? _value.licenseNumber
          : licenseNumber // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DriverModelImplCopyWith<$Res>
    implements $DriverModelCopyWith<$Res> {
  factory _$$DriverModelImplCopyWith(
          _$DriverModelImpl value, $Res Function(_$DriverModelImpl) then) =
      __$$DriverModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'passport__seria') String passportSeria,
      @JsonKey(name: 'passport__number') String passportNumber,
      @JsonKey(
          name: 'driver_birthday',
          fromJson: parseOsagoDate,
          toJson: formatOsagoDate)
      DateTime driverBirthday,
      @JsonKey(name: 'relative') int relative,
      @JsonKey(name: 'name') String? name,
      @JsonKey(name: 'license__seria') String? licenseSeria,
      @JsonKey(name: 'license__number') String? licenseNumber});
}

/// @nodoc
class __$$DriverModelImplCopyWithImpl<$Res>
    extends _$DriverModelCopyWithImpl<$Res, _$DriverModelImpl>
    implements _$$DriverModelImplCopyWith<$Res> {
  __$$DriverModelImplCopyWithImpl(
      _$DriverModelImpl _value, $Res Function(_$DriverModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? passportSeria = null,
    Object? passportNumber = null,
    Object? driverBirthday = null,
    Object? relative = null,
    Object? name = freezed,
    Object? licenseSeria = freezed,
    Object? licenseNumber = freezed,
  }) {
    return _then(_$DriverModelImpl(
      passportSeria: null == passportSeria
          ? _value.passportSeria
          : passportSeria // ignore: cast_nullable_to_non_nullable
              as String,
      passportNumber: null == passportNumber
          ? _value.passportNumber
          : passportNumber // ignore: cast_nullable_to_non_nullable
              as String,
      driverBirthday: null == driverBirthday
          ? _value.driverBirthday
          : driverBirthday // ignore: cast_nullable_to_non_nullable
              as DateTime,
      relative: null == relative
          ? _value.relative
          : relative // ignore: cast_nullable_to_non_nullable
              as int,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      licenseSeria: freezed == licenseSeria
          ? _value.licenseSeria
          : licenseSeria // ignore: cast_nullable_to_non_nullable
              as String?,
      licenseNumber: freezed == licenseNumber
          ? _value.licenseNumber
          : licenseNumber // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverModelImpl implements _DriverModel {
  const _$DriverModelImpl(
      {@JsonKey(name: 'passport__seria') required this.passportSeria,
      @JsonKey(name: 'passport__number') required this.passportNumber,
      @JsonKey(
          name: 'driver_birthday',
          fromJson: parseOsagoDate,
          toJson: formatOsagoDate)
      required this.driverBirthday,
      @JsonKey(name: 'relative') this.relative = 0,
      @JsonKey(name: 'name') this.name,
      @JsonKey(name: 'license__seria') this.licenseSeria,
      @JsonKey(name: 'license__number') this.licenseNumber});

  factory _$DriverModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverModelImplFromJson(json);

  @override
  @JsonKey(name: 'passport__seria')
  final String passportSeria;
  @override
  @JsonKey(name: 'passport__number')
  final String passportNumber;
  @override
  @JsonKey(
      name: 'driver_birthday',
      fromJson: parseOsagoDate,
      toJson: formatOsagoDate)
  final DateTime driverBirthday;
  @override
  @JsonKey(name: 'relative')
  final int relative;
  @override
  @JsonKey(name: 'name')
  final String? name;
  @override
  @JsonKey(name: 'license__seria')
  final String? licenseSeria;
  @override
  @JsonKey(name: 'license__number')
  final String? licenseNumber;

  @override
  String toString() {
    return 'DriverModel(passportSeria: $passportSeria, passportNumber: $passportNumber, driverBirthday: $driverBirthday, relative: $relative, name: $name, licenseSeria: $licenseSeria, licenseNumber: $licenseNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverModelImpl &&
            (identical(other.passportSeria, passportSeria) ||
                other.passportSeria == passportSeria) &&
            (identical(other.passportNumber, passportNumber) ||
                other.passportNumber == passportNumber) &&
            (identical(other.driverBirthday, driverBirthday) ||
                other.driverBirthday == driverBirthday) &&
            (identical(other.relative, relative) ||
                other.relative == relative) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.licenseSeria, licenseSeria) ||
                other.licenseSeria == licenseSeria) &&
            (identical(other.licenseNumber, licenseNumber) ||
                other.licenseNumber == licenseNumber));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, passportSeria, passportNumber,
      driverBirthday, relative, name, licenseSeria, licenseNumber);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverModelImplCopyWith<_$DriverModelImpl> get copyWith =>
      __$$DriverModelImplCopyWithImpl<_$DriverModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverModelImplToJson(
      this,
    );
  }
}

abstract class _DriverModel implements DriverModel {
  const factory _DriverModel(
      {@JsonKey(name: 'passport__seria') required final String passportSeria,
      @JsonKey(name: 'passport__number') required final String passportNumber,
      @JsonKey(
          name: 'driver_birthday',
          fromJson: parseOsagoDate,
          toJson: formatOsagoDate)
      required final DateTime driverBirthday,
      @JsonKey(name: 'relative') final int relative,
      @JsonKey(name: 'name') final String? name,
      @JsonKey(name: 'license__seria') final String? licenseSeria,
      @JsonKey(name: 'license__number')
      final String? licenseNumber}) = _$DriverModelImpl;

  factory _DriverModel.fromJson(Map<String, dynamic> json) =
      _$DriverModelImpl.fromJson;

  @override
  @JsonKey(name: 'passport__seria')
  String get passportSeria;
  @override
  @JsonKey(name: 'passport__number')
  String get passportNumber;
  @override
  @JsonKey(
      name: 'driver_birthday',
      fromJson: parseOsagoDate,
      toJson: formatOsagoDate)
  DateTime get driverBirthday;
  @override
  @JsonKey(name: 'relative')
  int get relative;
  @override
  @JsonKey(name: 'name')
  String? get name;
  @override
  @JsonKey(name: 'license__seria')
  String? get licenseSeria;
  @override
  @JsonKey(name: 'license__number')
  String? get licenseNumber;
  @override
  @JsonKey(ignore: true)
  _$$DriverModelImplCopyWith<_$DriverModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
