// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VehicleModel _$VehicleModelFromJson(Map<String, dynamic> json) {
  return _VehicleModel.fromJson(json);
}

/// @nodoc
mixin _$VehicleModel {
  String get brand => throw _privateConstructorUsedError;
  String get model => throw _privateConstructorUsedError;
  @JsonKey(name: 'gos_number')
  String get gosNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'tech_sery')
  String get techSeria => throw _privateConstructorUsedError;
  @JsonKey(name: 'tech_number')
  String get techNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner__pass_seria')
  String get ownerPassportSeria => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner__pass_number')
  String get ownerPassportNumber => throw _privateConstructorUsedError;
  @JsonKey(
      name: 'owner_birth_date',
      fromJson: parseOsagoDate,
      toJson: formatOsagoDate)
  DateTime get ownerBirthDate => throw _privateConstructorUsedError;
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get isOwner => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VehicleModelCopyWith<VehicleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VehicleModelCopyWith<$Res> {
  factory $VehicleModelCopyWith(
          VehicleModel value, $Res Function(VehicleModel) then) =
      _$VehicleModelCopyWithImpl<$Res, VehicleModel>;
  @useResult
  $Res call(
      {String brand,
      String model,
      @JsonKey(name: 'gos_number') String gosNumber,
      @JsonKey(name: 'tech_sery') String techSeria,
      @JsonKey(name: 'tech_number') String techNumber,
      @JsonKey(name: 'owner__pass_seria') String ownerPassportSeria,
      @JsonKey(name: 'owner__pass_number') String ownerPassportNumber,
      @JsonKey(
          name: 'owner_birth_date',
          fromJson: parseOsagoDate,
          toJson: formatOsagoDate)
      DateTime ownerBirthDate,
      @JsonKey(includeToJson: false, includeFromJson: false) bool isOwner});
}

/// @nodoc
class _$VehicleModelCopyWithImpl<$Res, $Val extends VehicleModel>
    implements $VehicleModelCopyWith<$Res> {
  _$VehicleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? brand = null,
    Object? model = null,
    Object? gosNumber = null,
    Object? techSeria = null,
    Object? techNumber = null,
    Object? ownerPassportSeria = null,
    Object? ownerPassportNumber = null,
    Object? ownerBirthDate = null,
    Object? isOwner = null,
  }) {
    return _then(_value.copyWith(
      brand: null == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      gosNumber: null == gosNumber
          ? _value.gosNumber
          : gosNumber // ignore: cast_nullable_to_non_nullable
              as String,
      techSeria: null == techSeria
          ? _value.techSeria
          : techSeria // ignore: cast_nullable_to_non_nullable
              as String,
      techNumber: null == techNumber
          ? _value.techNumber
          : techNumber // ignore: cast_nullable_to_non_nullable
              as String,
      ownerPassportSeria: null == ownerPassportSeria
          ? _value.ownerPassportSeria
          : ownerPassportSeria // ignore: cast_nullable_to_non_nullable
              as String,
      ownerPassportNumber: null == ownerPassportNumber
          ? _value.ownerPassportNumber
          : ownerPassportNumber // ignore: cast_nullable_to_non_nullable
              as String,
      ownerBirthDate: null == ownerBirthDate
          ? _value.ownerBirthDate
          : ownerBirthDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isOwner: null == isOwner
          ? _value.isOwner
          : isOwner // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VehicleModelImplCopyWith<$Res>
    implements $VehicleModelCopyWith<$Res> {
  factory _$$VehicleModelImplCopyWith(
          _$VehicleModelImpl value, $Res Function(_$VehicleModelImpl) then) =
      __$$VehicleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String brand,
      String model,
      @JsonKey(name: 'gos_number') String gosNumber,
      @JsonKey(name: 'tech_sery') String techSeria,
      @JsonKey(name: 'tech_number') String techNumber,
      @JsonKey(name: 'owner__pass_seria') String ownerPassportSeria,
      @JsonKey(name: 'owner__pass_number') String ownerPassportNumber,
      @JsonKey(
          name: 'owner_birth_date',
          fromJson: parseOsagoDate,
          toJson: formatOsagoDate)
      DateTime ownerBirthDate,
      @JsonKey(includeToJson: false, includeFromJson: false) bool isOwner});
}

/// @nodoc
class __$$VehicleModelImplCopyWithImpl<$Res>
    extends _$VehicleModelCopyWithImpl<$Res, _$VehicleModelImpl>
    implements _$$VehicleModelImplCopyWith<$Res> {
  __$$VehicleModelImplCopyWithImpl(
      _$VehicleModelImpl _value, $Res Function(_$VehicleModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? brand = null,
    Object? model = null,
    Object? gosNumber = null,
    Object? techSeria = null,
    Object? techNumber = null,
    Object? ownerPassportSeria = null,
    Object? ownerPassportNumber = null,
    Object? ownerBirthDate = null,
    Object? isOwner = null,
  }) {
    return _then(_$VehicleModelImpl(
      brand: null == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      gosNumber: null == gosNumber
          ? _value.gosNumber
          : gosNumber // ignore: cast_nullable_to_non_nullable
              as String,
      techSeria: null == techSeria
          ? _value.techSeria
          : techSeria // ignore: cast_nullable_to_non_nullable
              as String,
      techNumber: null == techNumber
          ? _value.techNumber
          : techNumber // ignore: cast_nullable_to_non_nullable
              as String,
      ownerPassportSeria: null == ownerPassportSeria
          ? _value.ownerPassportSeria
          : ownerPassportSeria // ignore: cast_nullable_to_non_nullable
              as String,
      ownerPassportNumber: null == ownerPassportNumber
          ? _value.ownerPassportNumber
          : ownerPassportNumber // ignore: cast_nullable_to_non_nullable
              as String,
      ownerBirthDate: null == ownerBirthDate
          ? _value.ownerBirthDate
          : ownerBirthDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isOwner: null == isOwner
          ? _value.isOwner
          : isOwner // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VehicleModelImpl implements _VehicleModel {
  const _$VehicleModelImpl(
      {required this.brand,
      required this.model,
      @JsonKey(name: 'gos_number') required this.gosNumber,
      @JsonKey(name: 'tech_sery') required this.techSeria,
      @JsonKey(name: 'tech_number') required this.techNumber,
      @JsonKey(name: 'owner__pass_seria') required this.ownerPassportSeria,
      @JsonKey(name: 'owner__pass_number') required this.ownerPassportNumber,
      @JsonKey(
          name: 'owner_birth_date',
          fromJson: parseOsagoDate,
          toJson: formatOsagoDate)
      required this.ownerBirthDate,
      @JsonKey(includeToJson: false, includeFromJson: false)
      this.isOwner = true});

  factory _$VehicleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VehicleModelImplFromJson(json);

  @override
  final String brand;
  @override
  final String model;
  @override
  @JsonKey(name: 'gos_number')
  final String gosNumber;
  @override
  @JsonKey(name: 'tech_sery')
  final String techSeria;
  @override
  @JsonKey(name: 'tech_number')
  final String techNumber;
  @override
  @JsonKey(name: 'owner__pass_seria')
  final String ownerPassportSeria;
  @override
  @JsonKey(name: 'owner__pass_number')
  final String ownerPassportNumber;
  @override
  @JsonKey(
      name: 'owner_birth_date',
      fromJson: parseOsagoDate,
      toJson: formatOsagoDate)
  final DateTime ownerBirthDate;
  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  final bool isOwner;

  @override
  String toString() {
    return 'VehicleModel(brand: $brand, model: $model, gosNumber: $gosNumber, techSeria: $techSeria, techNumber: $techNumber, ownerPassportSeria: $ownerPassportSeria, ownerPassportNumber: $ownerPassportNumber, ownerBirthDate: $ownerBirthDate, isOwner: $isOwner)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VehicleModelImpl &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.gosNumber, gosNumber) ||
                other.gosNumber == gosNumber) &&
            (identical(other.techSeria, techSeria) ||
                other.techSeria == techSeria) &&
            (identical(other.techNumber, techNumber) ||
                other.techNumber == techNumber) &&
            (identical(other.ownerPassportSeria, ownerPassportSeria) ||
                other.ownerPassportSeria == ownerPassportSeria) &&
            (identical(other.ownerPassportNumber, ownerPassportNumber) ||
                other.ownerPassportNumber == ownerPassportNumber) &&
            (identical(other.ownerBirthDate, ownerBirthDate) ||
                other.ownerBirthDate == ownerBirthDate) &&
            (identical(other.isOwner, isOwner) || other.isOwner == isOwner));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      brand,
      model,
      gosNumber,
      techSeria,
      techNumber,
      ownerPassportSeria,
      ownerPassportNumber,
      ownerBirthDate,
      isOwner);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VehicleModelImplCopyWith<_$VehicleModelImpl> get copyWith =>
      __$$VehicleModelImplCopyWithImpl<_$VehicleModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VehicleModelImplToJson(
      this,
    );
  }
}

abstract class _VehicleModel implements VehicleModel {
  const factory _VehicleModel(
      {required final String brand,
      required final String model,
      @JsonKey(name: 'gos_number') required final String gosNumber,
      @JsonKey(name: 'tech_sery') required final String techSeria,
      @JsonKey(name: 'tech_number') required final String techNumber,
      @JsonKey(name: 'owner__pass_seria')
      required final String ownerPassportSeria,
      @JsonKey(name: 'owner__pass_number')
      required final String ownerPassportNumber,
      @JsonKey(
          name: 'owner_birth_date',
          fromJson: parseOsagoDate,
          toJson: formatOsagoDate)
      required final DateTime ownerBirthDate,
      @JsonKey(includeToJson: false, includeFromJson: false)
      final bool isOwner}) = _$VehicleModelImpl;

  factory _VehicleModel.fromJson(Map<String, dynamic> json) =
      _$VehicleModelImpl.fromJson;

  @override
  String get brand;
  @override
  String get model;
  @override
  @JsonKey(name: 'gos_number')
  String get gosNumber;
  @override
  @JsonKey(name: 'tech_sery')
  String get techSeria;
  @override
  @JsonKey(name: 'tech_number')
  String get techNumber;
  @override
  @JsonKey(name: 'owner__pass_seria')
  String get ownerPassportSeria;
  @override
  @JsonKey(name: 'owner__pass_number')
  String get ownerPassportNumber;
  @override
  @JsonKey(
      name: 'owner_birth_date',
      fromJson: parseOsagoDate,
      toJson: formatOsagoDate)
  DateTime get ownerBirthDate;
  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get isOwner;
  @override
  @JsonKey(ignore: true)
  _$$VehicleModelImplCopyWith<_$VehicleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
