// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'insurance_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InsuranceModel _$InsuranceModelFromJson(Map<String, dynamic> json) {
  return _InsuranceModel.fromJson(json);
}

/// @nodoc
mixin _$InsuranceModel {
  String get provider => throw _privateConstructorUsedError;
  @JsonKey(name: 'company_name')
  String get companyName => throw _privateConstructorUsedError;
  @JsonKey(name: 'period_id')
  String get periodId => throw _privateConstructorUsedError;
  @JsonKey(name: 'number_drivers_id')
  String get numberDriversId => throw _privateConstructorUsedError;
  @JsonKey(
      name: 'start_date', fromJson: parseOsagoDate, toJson: formatOsagoDate)
  DateTime get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'phone_number')
  String get phoneNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner__inn')
  String? get ownerInn => throw _privateConstructorUsedError;
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get isUnlimited => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InsuranceModelCopyWith<InsuranceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InsuranceModelCopyWith<$Res> {
  factory $InsuranceModelCopyWith(
          InsuranceModel value, $Res Function(InsuranceModel) then) =
      _$InsuranceModelCopyWithImpl<$Res, InsuranceModel>;
  @useResult
  $Res call(
      {String provider,
      @JsonKey(name: 'company_name') String companyName,
      @JsonKey(name: 'period_id') String periodId,
      @JsonKey(name: 'number_drivers_id') String numberDriversId,
      @JsonKey(
          name: 'start_date', fromJson: parseOsagoDate, toJson: formatOsagoDate)
      DateTime startDate,
      @JsonKey(name: 'phone_number') String phoneNumber,
      @JsonKey(name: 'owner__inn') String? ownerInn,
      @JsonKey(includeToJson: false, includeFromJson: false) bool isUnlimited});
}

/// @nodoc
class _$InsuranceModelCopyWithImpl<$Res, $Val extends InsuranceModel>
    implements $InsuranceModelCopyWith<$Res> {
  _$InsuranceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? provider = null,
    Object? companyName = null,
    Object? periodId = null,
    Object? numberDriversId = null,
    Object? startDate = null,
    Object? phoneNumber = null,
    Object? ownerInn = freezed,
    Object? isUnlimited = null,
  }) {
    return _then(_value.copyWith(
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String,
      companyName: null == companyName
          ? _value.companyName
          : companyName // ignore: cast_nullable_to_non_nullable
              as String,
      periodId: null == periodId
          ? _value.periodId
          : periodId // ignore: cast_nullable_to_non_nullable
              as String,
      numberDriversId: null == numberDriversId
          ? _value.numberDriversId
          : numberDriversId // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      ownerInn: freezed == ownerInn
          ? _value.ownerInn
          : ownerInn // ignore: cast_nullable_to_non_nullable
              as String?,
      isUnlimited: null == isUnlimited
          ? _value.isUnlimited
          : isUnlimited // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InsuranceModelImplCopyWith<$Res>
    implements $InsuranceModelCopyWith<$Res> {
  factory _$$InsuranceModelImplCopyWith(_$InsuranceModelImpl value,
          $Res Function(_$InsuranceModelImpl) then) =
      __$$InsuranceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String provider,
      @JsonKey(name: 'company_name') String companyName,
      @JsonKey(name: 'period_id') String periodId,
      @JsonKey(name: 'number_drivers_id') String numberDriversId,
      @JsonKey(
          name: 'start_date', fromJson: parseOsagoDate, toJson: formatOsagoDate)
      DateTime startDate,
      @JsonKey(name: 'phone_number') String phoneNumber,
      @JsonKey(name: 'owner__inn') String? ownerInn,
      @JsonKey(includeToJson: false, includeFromJson: false) bool isUnlimited});
}

/// @nodoc
class __$$InsuranceModelImplCopyWithImpl<$Res>
    extends _$InsuranceModelCopyWithImpl<$Res, _$InsuranceModelImpl>
    implements _$$InsuranceModelImplCopyWith<$Res> {
  __$$InsuranceModelImplCopyWithImpl(
      _$InsuranceModelImpl _value, $Res Function(_$InsuranceModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? provider = null,
    Object? companyName = null,
    Object? periodId = null,
    Object? numberDriversId = null,
    Object? startDate = null,
    Object? phoneNumber = null,
    Object? ownerInn = freezed,
    Object? isUnlimited = null,
  }) {
    return _then(_$InsuranceModelImpl(
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String,
      companyName: null == companyName
          ? _value.companyName
          : companyName // ignore: cast_nullable_to_non_nullable
              as String,
      periodId: null == periodId
          ? _value.periodId
          : periodId // ignore: cast_nullable_to_non_nullable
              as String,
      numberDriversId: null == numberDriversId
          ? _value.numberDriversId
          : numberDriversId // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      ownerInn: freezed == ownerInn
          ? _value.ownerInn
          : ownerInn // ignore: cast_nullable_to_non_nullable
              as String?,
      isUnlimited: null == isUnlimited
          ? _value.isUnlimited
          : isUnlimited // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InsuranceModelImpl implements _InsuranceModel {
  const _$InsuranceModelImpl(
      {required this.provider,
      @JsonKey(name: 'company_name') required this.companyName,
      @JsonKey(name: 'period_id') required this.periodId,
      @JsonKey(name: 'number_drivers_id') required this.numberDriversId,
      @JsonKey(
          name: 'start_date', fromJson: parseOsagoDate, toJson: formatOsagoDate)
      required this.startDate,
      @JsonKey(name: 'phone_number') required this.phoneNumber,
      @JsonKey(name: 'owner__inn') this.ownerInn,
      @JsonKey(includeToJson: false, includeFromJson: false)
      this.isUnlimited = false});

  factory _$InsuranceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$InsuranceModelImplFromJson(json);

  @override
  final String provider;
  @override
  @JsonKey(name: 'company_name')
  final String companyName;
  @override
  @JsonKey(name: 'period_id')
  final String periodId;
  @override
  @JsonKey(name: 'number_drivers_id')
  final String numberDriversId;
  @override
  @JsonKey(
      name: 'start_date', fromJson: parseOsagoDate, toJson: formatOsagoDate)
  final DateTime startDate;
  @override
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  @override
  @JsonKey(name: 'owner__inn')
  final String? ownerInn;
  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  final bool isUnlimited;

  @override
  String toString() {
    return 'InsuranceModel(provider: $provider, companyName: $companyName, periodId: $periodId, numberDriversId: $numberDriversId, startDate: $startDate, phoneNumber: $phoneNumber, ownerInn: $ownerInn, isUnlimited: $isUnlimited)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InsuranceModelImpl &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.companyName, companyName) ||
                other.companyName == companyName) &&
            (identical(other.periodId, periodId) ||
                other.periodId == periodId) &&
            (identical(other.numberDriversId, numberDriversId) ||
                other.numberDriversId == numberDriversId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.ownerInn, ownerInn) ||
                other.ownerInn == ownerInn) &&
            (identical(other.isUnlimited, isUnlimited) ||
                other.isUnlimited == isUnlimited));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, provider, companyName, periodId,
      numberDriversId, startDate, phoneNumber, ownerInn, isUnlimited);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InsuranceModelImplCopyWith<_$InsuranceModelImpl> get copyWith =>
      __$$InsuranceModelImplCopyWithImpl<_$InsuranceModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InsuranceModelImplToJson(
      this,
    );
  }
}

abstract class _InsuranceModel implements InsuranceModel {
  const factory _InsuranceModel(
      {required final String provider,
      @JsonKey(name: 'company_name') required final String companyName,
      @JsonKey(name: 'period_id') required final String periodId,
      @JsonKey(name: 'number_drivers_id') required final String numberDriversId,
      @JsonKey(
          name: 'start_date', fromJson: parseOsagoDate, toJson: formatOsagoDate)
      required final DateTime startDate,
      @JsonKey(name: 'phone_number') required final String phoneNumber,
      @JsonKey(name: 'owner__inn') final String? ownerInn,
      @JsonKey(includeToJson: false, includeFromJson: false)
      final bool isUnlimited}) = _$InsuranceModelImpl;

  factory _InsuranceModel.fromJson(Map<String, dynamic> json) =
      _$InsuranceModelImpl.fromJson;

  @override
  String get provider;
  @override
  @JsonKey(name: 'company_name')
  String get companyName;
  @override
  @JsonKey(name: 'period_id')
  String get periodId;
  @override
  @JsonKey(name: 'number_drivers_id')
  String get numberDriversId;
  @override
  @JsonKey(
      name: 'start_date', fromJson: parseOsagoDate, toJson: formatOsagoDate)
  DateTime get startDate;
  @override
  @JsonKey(name: 'phone_number')
  String get phoneNumber;
  @override
  @JsonKey(name: 'owner__inn')
  String? get ownerInn;
  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get isUnlimited;
  @override
  @JsonKey(ignore: true)
  _$$InsuranceModelImplCopyWith<_$InsuranceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
