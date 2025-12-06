// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'car_price_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CarPriceResponse _$CarPriceResponseFromJson(Map<String, dynamic> json) {
  return _CarPriceResponse.fromJson(json);
}

/// @nodoc
mixin _$CarPriceResponse {
  double get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'car_id')
  int? get carId => throw _privateConstructorUsedError;
  int? get year => throw _privateConstructorUsedError;
  String? get currency => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CarPriceResponseCopyWith<CarPriceResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CarPriceResponseCopyWith<$Res> {
  factory $CarPriceResponseCopyWith(
          CarPriceResponse value, $Res Function(CarPriceResponse) then) =
      _$CarPriceResponseCopyWithImpl<$Res, CarPriceResponse>;
  @useResult
  $Res call(
      {double price,
      @JsonKey(name: 'car_id') int? carId,
      int? year,
      String? currency});
}

/// @nodoc
class _$CarPriceResponseCopyWithImpl<$Res, $Val extends CarPriceResponse>
    implements $CarPriceResponseCopyWith<$Res> {
  _$CarPriceResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? price = null,
    Object? carId = freezed,
    Object? year = freezed,
    Object? currency = freezed,
  }) {
    return _then(_value.copyWith(
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      carId: freezed == carId
          ? _value.carId
          : carId // ignore: cast_nullable_to_non_nullable
              as int?,
      year: freezed == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CarPriceResponseImplCopyWith<$Res>
    implements $CarPriceResponseCopyWith<$Res> {
  factory _$$CarPriceResponseImplCopyWith(_$CarPriceResponseImpl value,
          $Res Function(_$CarPriceResponseImpl) then) =
      __$$CarPriceResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double price,
      @JsonKey(name: 'car_id') int? carId,
      int? year,
      String? currency});
}

/// @nodoc
class __$$CarPriceResponseImplCopyWithImpl<$Res>
    extends _$CarPriceResponseCopyWithImpl<$Res, _$CarPriceResponseImpl>
    implements _$$CarPriceResponseImplCopyWith<$Res> {
  __$$CarPriceResponseImplCopyWithImpl(_$CarPriceResponseImpl _value,
      $Res Function(_$CarPriceResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? price = null,
    Object? carId = freezed,
    Object? year = freezed,
    Object? currency = freezed,
  }) {
    return _then(_$CarPriceResponseImpl(
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      carId: freezed == carId
          ? _value.carId
          : carId // ignore: cast_nullable_to_non_nullable
              as int?,
      year: freezed == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CarPriceResponseImpl implements _CarPriceResponse {
  const _$CarPriceResponseImpl(
      {required this.price,
      @JsonKey(name: 'car_id') this.carId,
      this.year,
      this.currency});

  factory _$CarPriceResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CarPriceResponseImplFromJson(json);

  @override
  final double price;
  @override
  @JsonKey(name: 'car_id')
  final int? carId;
  @override
  final int? year;
  @override
  final String? currency;

  @override
  String toString() {
    return 'CarPriceResponse(price: $price, carId: $carId, year: $year, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CarPriceResponseImpl &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.carId, carId) || other.carId == carId) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, price, carId, year, currency);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CarPriceResponseImplCopyWith<_$CarPriceResponseImpl> get copyWith =>
      __$$CarPriceResponseImplCopyWithImpl<_$CarPriceResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CarPriceResponseImplToJson(
      this,
    );
  }
}

abstract class _CarPriceResponse implements CarPriceResponse {
  const factory _CarPriceResponse(
      {required final double price,
      @JsonKey(name: 'car_id') final int? carId,
      final int? year,
      final String? currency}) = _$CarPriceResponseImpl;

  factory _CarPriceResponse.fromJson(Map<String, dynamic> json) =
      _$CarPriceResponseImpl.fromJson;

  @override
  double get price;
  @override
  @JsonKey(name: 'car_id')
  int? get carId;
  @override
  int? get year;
  @override
  String? get currency;
  @override
  @JsonKey(ignore: true)
  _$$CarPriceResponseImplCopyWith<_$CarPriceResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
