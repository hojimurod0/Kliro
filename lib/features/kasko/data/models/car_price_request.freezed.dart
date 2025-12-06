// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'car_price_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CarPriceRequest _$CarPriceRequestFromJson(Map<String, dynamic> json) {
  return _CarPriceRequest.fromJson(json);
}

/// @nodoc
mixin _$CarPriceRequest {
  @JsonKey(name: 'car_position_id')
  int get carPositionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'tarif_id')
  int get tarifId => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CarPriceRequestCopyWith<CarPriceRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CarPriceRequestCopyWith<$Res> {
  factory $CarPriceRequestCopyWith(
          CarPriceRequest value, $Res Function(CarPriceRequest) then) =
      _$CarPriceRequestCopyWithImpl<$Res, CarPriceRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: 'car_position_id') int carPositionId,
      @JsonKey(name: 'tarif_id') int tarifId,
      int year});
}

/// @nodoc
class _$CarPriceRequestCopyWithImpl<$Res, $Val extends CarPriceRequest>
    implements $CarPriceRequestCopyWith<$Res> {
  _$CarPriceRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? carPositionId = null,
    Object? tarifId = null,
    Object? year = null,
  }) {
    return _then(_value.copyWith(
      carPositionId: null == carPositionId
          ? _value.carPositionId
          : carPositionId // ignore: cast_nullable_to_non_nullable
              as int,
      tarifId: null == tarifId
          ? _value.tarifId
          : tarifId // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CarPriceRequestImplCopyWith<$Res>
    implements $CarPriceRequestCopyWith<$Res> {
  factory _$$CarPriceRequestImplCopyWith(_$CarPriceRequestImpl value,
          $Res Function(_$CarPriceRequestImpl) then) =
      __$$CarPriceRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'car_position_id') int carPositionId,
      @JsonKey(name: 'tarif_id') int tarifId,
      int year});
}

/// @nodoc
class __$$CarPriceRequestImplCopyWithImpl<$Res>
    extends _$CarPriceRequestCopyWithImpl<$Res, _$CarPriceRequestImpl>
    implements _$$CarPriceRequestImplCopyWith<$Res> {
  __$$CarPriceRequestImplCopyWithImpl(
      _$CarPriceRequestImpl _value, $Res Function(_$CarPriceRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? carPositionId = null,
    Object? tarifId = null,
    Object? year = null,
  }) {
    return _then(_$CarPriceRequestImpl(
      carPositionId: null == carPositionId
          ? _value.carPositionId
          : carPositionId // ignore: cast_nullable_to_non_nullable
              as int,
      tarifId: null == tarifId
          ? _value.tarifId
          : tarifId // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CarPriceRequestImpl implements _CarPriceRequest {
  const _$CarPriceRequestImpl(
      {@JsonKey(name: 'car_position_id') required this.carPositionId,
      @JsonKey(name: 'tarif_id') required this.tarifId,
      required this.year});

  factory _$CarPriceRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CarPriceRequestImplFromJson(json);

  @override
  @JsonKey(name: 'car_position_id')
  final int carPositionId;
  @override
  @JsonKey(name: 'tarif_id')
  final int tarifId;
  @override
  final int year;

  @override
  String toString() {
    return 'CarPriceRequest(carPositionId: $carPositionId, tarifId: $tarifId, year: $year)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CarPriceRequestImpl &&
            (identical(other.carPositionId, carPositionId) ||
                other.carPositionId == carPositionId) &&
            (identical(other.tarifId, tarifId) || other.tarifId == tarifId) &&
            (identical(other.year, year) || other.year == year));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, carPositionId, tarifId, year);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CarPriceRequestImplCopyWith<_$CarPriceRequestImpl> get copyWith =>
      __$$CarPriceRequestImplCopyWithImpl<_$CarPriceRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CarPriceRequestImplToJson(
      this,
    );
  }
}

abstract class _CarPriceRequest implements CarPriceRequest {
  const factory _CarPriceRequest(
      {@JsonKey(name: 'car_position_id') required final int carPositionId,
      @JsonKey(name: 'tarif_id') required final int tarifId,
      required final int year}) = _$CarPriceRequestImpl;

  factory _CarPriceRequest.fromJson(Map<String, dynamic> json) =
      _$CarPriceRequestImpl.fromJson;

  @override
  @JsonKey(name: 'car_position_id')
  int get carPositionId;
  @override
  @JsonKey(name: 'tarif_id')
  int get tarifId;
  @override
  int get year;
  @override
  @JsonKey(ignore: true)
  _$$CarPriceRequestImplCopyWith<_$CarPriceRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
