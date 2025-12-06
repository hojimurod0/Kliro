// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calculate_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CalculateRequest _$CalculateRequestFromJson(Map<String, dynamic> json) {
  return _CalculateRequest.fromJson(json);
}

/// @nodoc
mixin _$CalculateRequest {
  @JsonKey(name: 'car_id')
  int get carId => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'begin_date')
  String get beginDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  String get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'driver_count')
  int get driverCount => throw _privateConstructorUsedError;
  double get franchise => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CalculateRequestCopyWith<CalculateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalculateRequestCopyWith<$Res> {
  factory $CalculateRequestCopyWith(
          CalculateRequest value, $Res Function(CalculateRequest) then) =
      _$CalculateRequestCopyWithImpl<$Res, CalculateRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: 'car_id') int carId,
      int year,
      double price,
      @JsonKey(name: 'begin_date') String beginDate,
      @JsonKey(name: 'end_date') String endDate,
      @JsonKey(name: 'driver_count') int driverCount,
      double franchise});
}

/// @nodoc
class _$CalculateRequestCopyWithImpl<$Res, $Val extends CalculateRequest>
    implements $CalculateRequestCopyWith<$Res> {
  _$CalculateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? carId = null,
    Object? year = null,
    Object? price = null,
    Object? beginDate = null,
    Object? endDate = null,
    Object? driverCount = null,
    Object? franchise = null,
  }) {
    return _then(_value.copyWith(
      carId: null == carId
          ? _value.carId
          : carId // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      beginDate: null == beginDate
          ? _value.beginDate
          : beginDate // ignore: cast_nullable_to_non_nullable
              as String,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String,
      driverCount: null == driverCount
          ? _value.driverCount
          : driverCount // ignore: cast_nullable_to_non_nullable
              as int,
      franchise: null == franchise
          ? _value.franchise
          : franchise // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalculateRequestImplCopyWith<$Res>
    implements $CalculateRequestCopyWith<$Res> {
  factory _$$CalculateRequestImplCopyWith(_$CalculateRequestImpl value,
          $Res Function(_$CalculateRequestImpl) then) =
      __$$CalculateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'car_id') int carId,
      int year,
      double price,
      @JsonKey(name: 'begin_date') String beginDate,
      @JsonKey(name: 'end_date') String endDate,
      @JsonKey(name: 'driver_count') int driverCount,
      double franchise});
}

/// @nodoc
class __$$CalculateRequestImplCopyWithImpl<$Res>
    extends _$CalculateRequestCopyWithImpl<$Res, _$CalculateRequestImpl>
    implements _$$CalculateRequestImplCopyWith<$Res> {
  __$$CalculateRequestImplCopyWithImpl(_$CalculateRequestImpl _value,
      $Res Function(_$CalculateRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? carId = null,
    Object? year = null,
    Object? price = null,
    Object? beginDate = null,
    Object? endDate = null,
    Object? driverCount = null,
    Object? franchise = null,
  }) {
    return _then(_$CalculateRequestImpl(
      carId: null == carId
          ? _value.carId
          : carId // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      beginDate: null == beginDate
          ? _value.beginDate
          : beginDate // ignore: cast_nullable_to_non_nullable
              as String,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String,
      driverCount: null == driverCount
          ? _value.driverCount
          : driverCount // ignore: cast_nullable_to_non_nullable
              as int,
      franchise: null == franchise
          ? _value.franchise
          : franchise // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalculateRequestImpl implements _CalculateRequest {
  const _$CalculateRequestImpl(
      {@JsonKey(name: 'car_id') required this.carId,
      required this.year,
      required this.price,
      @JsonKey(name: 'begin_date') required this.beginDate,
      @JsonKey(name: 'end_date') required this.endDate,
      @JsonKey(name: 'driver_count') required this.driverCount,
      required this.franchise});

  factory _$CalculateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalculateRequestImplFromJson(json);

  @override
  @JsonKey(name: 'car_id')
  final int carId;
  @override
  final int year;
  @override
  final double price;
  @override
  @JsonKey(name: 'begin_date')
  final String beginDate;
  @override
  @JsonKey(name: 'end_date')
  final String endDate;
  @override
  @JsonKey(name: 'driver_count')
  final int driverCount;
  @override
  final double franchise;

  @override
  String toString() {
    return 'CalculateRequest(carId: $carId, year: $year, price: $price, beginDate: $beginDate, endDate: $endDate, driverCount: $driverCount, franchise: $franchise)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalculateRequestImpl &&
            (identical(other.carId, carId) || other.carId == carId) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.beginDate, beginDate) ||
                other.beginDate == beginDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.driverCount, driverCount) ||
                other.driverCount == driverCount) &&
            (identical(other.franchise, franchise) ||
                other.franchise == franchise));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, carId, year, price, beginDate,
      endDate, driverCount, franchise);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CalculateRequestImplCopyWith<_$CalculateRequestImpl> get copyWith =>
      __$$CalculateRequestImplCopyWithImpl<_$CalculateRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalculateRequestImplToJson(
      this,
    );
  }
}

abstract class _CalculateRequest implements CalculateRequest {
  const factory _CalculateRequest(
      {@JsonKey(name: 'car_id') required final int carId,
      required final int year,
      required final double price,
      @JsonKey(name: 'begin_date') required final String beginDate,
      @JsonKey(name: 'end_date') required final String endDate,
      @JsonKey(name: 'driver_count') required final int driverCount,
      required final double franchise}) = _$CalculateRequestImpl;

  factory _CalculateRequest.fromJson(Map<String, dynamic> json) =
      _$CalculateRequestImpl.fromJson;

  @override
  @JsonKey(name: 'car_id')
  int get carId;
  @override
  int get year;
  @override
  double get price;
  @override
  @JsonKey(name: 'begin_date')
  String get beginDate;
  @override
  @JsonKey(name: 'end_date')
  String get endDate;
  @override
  @JsonKey(name: 'driver_count')
  int get driverCount;
  @override
  double get franchise;
  @override
  @JsonKey(ignore: true)
  _$$CalculateRequestImplCopyWith<_$CalculateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
