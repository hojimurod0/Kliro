// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calculate_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CalculateResponse _$CalculateResponseFromJson(Map<String, dynamic> json) {
  return _CalculateResponse.fromJson(json);
}

/// @nodoc
mixin _$CalculateResponse {
  double get premium => throw _privateConstructorUsedError;
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
  String? get currency =>
      throw _privateConstructorUsedError; // Tariflar - calculate response'da keladi
  @JsonKey(name: 'rates')
  List<RateModel> get rates => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CalculateResponseCopyWith<CalculateResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalculateResponseCopyWith<$Res> {
  factory $CalculateResponseCopyWith(
          CalculateResponse value, $Res Function(CalculateResponse) then) =
      _$CalculateResponseCopyWithImpl<$Res, CalculateResponse>;
  @useResult
  $Res call(
      {double premium,
      @JsonKey(name: 'car_id') int carId,
      int year,
      double price,
      @JsonKey(name: 'begin_date') String beginDate,
      @JsonKey(name: 'end_date') String endDate,
      @JsonKey(name: 'driver_count') int driverCount,
      double franchise,
      String? currency,
      @JsonKey(name: 'rates') List<RateModel> rates});
}

/// @nodoc
class _$CalculateResponseCopyWithImpl<$Res, $Val extends CalculateResponse>
    implements $CalculateResponseCopyWith<$Res> {
  _$CalculateResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? premium = null,
    Object? carId = null,
    Object? year = null,
    Object? price = null,
    Object? beginDate = null,
    Object? endDate = null,
    Object? driverCount = null,
    Object? franchise = null,
    Object? currency = freezed,
    Object? rates = null,
  }) {
    return _then(_value.copyWith(
      premium: null == premium
          ? _value.premium
          : premium // ignore: cast_nullable_to_non_nullable
              as double,
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
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      rates: null == rates
          ? _value.rates
          : rates // ignore: cast_nullable_to_non_nullable
              as List<RateModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CalculateResponseImplCopyWith<$Res>
    implements $CalculateResponseCopyWith<$Res> {
  factory _$$CalculateResponseImplCopyWith(_$CalculateResponseImpl value,
          $Res Function(_$CalculateResponseImpl) then) =
      __$$CalculateResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double premium,
      @JsonKey(name: 'car_id') int carId,
      int year,
      double price,
      @JsonKey(name: 'begin_date') String beginDate,
      @JsonKey(name: 'end_date') String endDate,
      @JsonKey(name: 'driver_count') int driverCount,
      double franchise,
      String? currency,
      @JsonKey(name: 'rates') List<RateModel> rates});
}

/// @nodoc
class __$$CalculateResponseImplCopyWithImpl<$Res>
    extends _$CalculateResponseCopyWithImpl<$Res, _$CalculateResponseImpl>
    implements _$$CalculateResponseImplCopyWith<$Res> {
  __$$CalculateResponseImplCopyWithImpl(_$CalculateResponseImpl _value,
      $Res Function(_$CalculateResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? premium = null,
    Object? carId = null,
    Object? year = null,
    Object? price = null,
    Object? beginDate = null,
    Object? endDate = null,
    Object? driverCount = null,
    Object? franchise = null,
    Object? currency = freezed,
    Object? rates = null,
  }) {
    return _then(_$CalculateResponseImpl(
      premium: null == premium
          ? _value.premium
          : premium // ignore: cast_nullable_to_non_nullable
              as double,
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
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      rates: null == rates
          ? _value._rates
          : rates // ignore: cast_nullable_to_non_nullable
              as List<RateModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CalculateResponseImpl implements _CalculateResponse {
  const _$CalculateResponseImpl(
      {required this.premium,
      @JsonKey(name: 'car_id') required this.carId,
      required this.year,
      required this.price,
      @JsonKey(name: 'begin_date') required this.beginDate,
      @JsonKey(name: 'end_date') required this.endDate,
      @JsonKey(name: 'driver_count') required this.driverCount,
      required this.franchise,
      this.currency,
      @JsonKey(name: 'rates') final List<RateModel> rates = const []})
      : _rates = rates;

  factory _$CalculateResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalculateResponseImplFromJson(json);

  @override
  final double premium;
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
  final String? currency;
// Tariflar - calculate response'da keladi
  final List<RateModel> _rates;
// Tariflar - calculate response'da keladi
  @override
  @JsonKey(name: 'rates')
  List<RateModel> get rates {
    if (_rates is EqualUnmodifiableListView) return _rates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rates);
  }

  @override
  String toString() {
    return 'CalculateResponse(premium: $premium, carId: $carId, year: $year, price: $price, beginDate: $beginDate, endDate: $endDate, driverCount: $driverCount, franchise: $franchise, currency: $currency, rates: $rates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalculateResponseImpl &&
            (identical(other.premium, premium) || other.premium == premium) &&
            (identical(other.carId, carId) || other.carId == carId) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.beginDate, beginDate) ||
                other.beginDate == beginDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.driverCount, driverCount) ||
                other.driverCount == driverCount) &&
            (identical(other.franchise, franchise) ||
                other.franchise == franchise) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            const DeepCollectionEquality().equals(other._rates, _rates));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      premium,
      carId,
      year,
      price,
      beginDate,
      endDate,
      driverCount,
      franchise,
      currency,
      const DeepCollectionEquality().hash(_rates));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CalculateResponseImplCopyWith<_$CalculateResponseImpl> get copyWith =>
      __$$CalculateResponseImplCopyWithImpl<_$CalculateResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalculateResponseImplToJson(
      this,
    );
  }
}

abstract class _CalculateResponse implements CalculateResponse {
  const factory _CalculateResponse(
          {required final double premium,
          @JsonKey(name: 'car_id') required final int carId,
          required final int year,
          required final double price,
          @JsonKey(name: 'begin_date') required final String beginDate,
          @JsonKey(name: 'end_date') required final String endDate,
          @JsonKey(name: 'driver_count') required final int driverCount,
          required final double franchise,
          final String? currency,
          @JsonKey(name: 'rates') final List<RateModel> rates}) =
      _$CalculateResponseImpl;

  factory _CalculateResponse.fromJson(Map<String, dynamic> json) =
      _$CalculateResponseImpl.fromJson;

  @override
  double get premium;
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
  String? get currency;
  @override // Tariflar - calculate response'da keladi
  @JsonKey(name: 'rates')
  List<RateModel> get rates;
  @override
  @JsonKey(ignore: true)
  _$$CalculateResponseImplCopyWith<_$CalculateResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
