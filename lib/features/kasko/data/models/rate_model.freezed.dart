// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rate_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RateModel _$RateModelFromJson(Map<String, dynamic> json) {
  return _RateModel.fromJson(json);
}

/// @nodoc
mixin _$RateModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description =>
      throw _privateConstructorUsedError; // Optional, default empty
  @JsonKey(name: 'min_premium')
  double? get minPremium => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_premium')
  double? get maxPremium => throw _privateConstructorUsedError;
  double get franchise => throw _privateConstructorUsedError;
  double? get percent => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RateModelCopyWith<RateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RateModelCopyWith<$Res> {
  factory $RateModelCopyWith(RateModel value, $Res Function(RateModel) then) =
      _$RateModelCopyWithImpl<$Res, RateModel>;
  @useResult
  $Res call(
      {int id,
      String name,
      String description,
      @JsonKey(name: 'min_premium') double? minPremium,
      @JsonKey(name: 'max_premium') double? maxPremium,
      double franchise,
      double? percent});
}

/// @nodoc
class _$RateModelCopyWithImpl<$Res, $Val extends RateModel>
    implements $RateModelCopyWith<$Res> {
  _$RateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? minPremium = freezed,
    Object? maxPremium = freezed,
    Object? franchise = null,
    Object? percent = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      minPremium: freezed == minPremium
          ? _value.minPremium
          : minPremium // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPremium: freezed == maxPremium
          ? _value.maxPremium
          : maxPremium // ignore: cast_nullable_to_non_nullable
              as double?,
      franchise: null == franchise
          ? _value.franchise
          : franchise // ignore: cast_nullable_to_non_nullable
              as double,
      percent: freezed == percent
          ? _value.percent
          : percent // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RateModelImplCopyWith<$Res>
    implements $RateModelCopyWith<$Res> {
  factory _$$RateModelImplCopyWith(
          _$RateModelImpl value, $Res Function(_$RateModelImpl) then) =
      __$$RateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String description,
      @JsonKey(name: 'min_premium') double? minPremium,
      @JsonKey(name: 'max_premium') double? maxPremium,
      double franchise,
      double? percent});
}

/// @nodoc
class __$$RateModelImplCopyWithImpl<$Res>
    extends _$RateModelCopyWithImpl<$Res, _$RateModelImpl>
    implements _$$RateModelImplCopyWith<$Res> {
  __$$RateModelImplCopyWithImpl(
      _$RateModelImpl _value, $Res Function(_$RateModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? minPremium = freezed,
    Object? maxPremium = freezed,
    Object? franchise = null,
    Object? percent = freezed,
  }) {
    return _then(_$RateModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      minPremium: freezed == minPremium
          ? _value.minPremium
          : minPremium // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPremium: freezed == maxPremium
          ? _value.maxPremium
          : maxPremium // ignore: cast_nullable_to_non_nullable
              as double?,
      franchise: null == franchise
          ? _value.franchise
          : franchise // ignore: cast_nullable_to_non_nullable
              as double,
      percent: freezed == percent
          ? _value.percent
          : percent // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RateModelImpl implements _RateModel {
  const _$RateModelImpl(
      {required this.id,
      required this.name,
      this.description = '',
      @JsonKey(name: 'min_premium') this.minPremium,
      @JsonKey(name: 'max_premium') this.maxPremium,
      this.franchise = 0,
      this.percent});

  factory _$RateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RateModelImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  @JsonKey()
  final String description;
// Optional, default empty
  @override
  @JsonKey(name: 'min_premium')
  final double? minPremium;
  @override
  @JsonKey(name: 'max_premium')
  final double? maxPremium;
  @override
  @JsonKey()
  final double franchise;
  @override
  final double? percent;

  @override
  String toString() {
    return 'RateModel(id: $id, name: $name, description: $description, minPremium: $minPremium, maxPremium: $maxPremium, franchise: $franchise, percent: $percent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RateModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.minPremium, minPremium) ||
                other.minPremium == minPremium) &&
            (identical(other.maxPremium, maxPremium) ||
                other.maxPremium == maxPremium) &&
            (identical(other.franchise, franchise) ||
                other.franchise == franchise) &&
            (identical(other.percent, percent) || other.percent == percent));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description,
      minPremium, maxPremium, franchise, percent);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RateModelImplCopyWith<_$RateModelImpl> get copyWith =>
      __$$RateModelImplCopyWithImpl<_$RateModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RateModelImplToJson(
      this,
    );
  }
}

abstract class _RateModel implements RateModel {
  const factory _RateModel(
      {required final int id,
      required final String name,
      final String description,
      @JsonKey(name: 'min_premium') final double? minPremium,
      @JsonKey(name: 'max_premium') final double? maxPremium,
      final double franchise,
      final double? percent}) = _$RateModelImpl;

  factory _RateModel.fromJson(Map<String, dynamic> json) =
      _$RateModelImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get description;
  @override // Optional, default empty
  @JsonKey(name: 'min_premium')
  double? get minPremium;
  @override
  @JsonKey(name: 'max_premium')
  double? get maxPremium;
  @override
  double get franchise;
  @override
  double? get percent;
  @override
  @JsonKey(ignore: true)
  _$$RateModelImplCopyWith<_$RateModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
