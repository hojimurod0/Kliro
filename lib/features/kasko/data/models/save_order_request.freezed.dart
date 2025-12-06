// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'save_order_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SaveOrderRequest _$SaveOrderRequestFromJson(Map<String, dynamic> json) {
  return _SaveOrderRequest.fromJson(json);
}

/// @nodoc
mixin _$SaveOrderRequest {
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
  double get premium => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_name')
  String get ownerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_phone')
  String get ownerPhone => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_passport')
  String get ownerPassport => throw _privateConstructorUsedError;
  @JsonKey(name: 'car_number')
  String get carNumber => throw _privateConstructorUsedError;
  String get vin => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SaveOrderRequestCopyWith<SaveOrderRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SaveOrderRequestCopyWith<$Res> {
  factory $SaveOrderRequestCopyWith(
          SaveOrderRequest value, $Res Function(SaveOrderRequest) then) =
      _$SaveOrderRequestCopyWithImpl<$Res, SaveOrderRequest>;
  @useResult
  $Res call(
      {@JsonKey(name: 'car_id') int carId,
      int year,
      double price,
      @JsonKey(name: 'begin_date') String beginDate,
      @JsonKey(name: 'end_date') String endDate,
      @JsonKey(name: 'driver_count') int driverCount,
      double franchise,
      double premium,
      @JsonKey(name: 'owner_name') String ownerName,
      @JsonKey(name: 'owner_phone') String ownerPhone,
      @JsonKey(name: 'owner_passport') String ownerPassport,
      @JsonKey(name: 'car_number') String carNumber,
      String vin});
}

/// @nodoc
class _$SaveOrderRequestCopyWithImpl<$Res, $Val extends SaveOrderRequest>
    implements $SaveOrderRequestCopyWith<$Res> {
  _$SaveOrderRequestCopyWithImpl(this._value, this._then);

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
    Object? premium = null,
    Object? ownerName = null,
    Object? ownerPhone = null,
    Object? ownerPassport = null,
    Object? carNumber = null,
    Object? vin = null,
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
      premium: null == premium
          ? _value.premium
          : premium // ignore: cast_nullable_to_non_nullable
              as double,
      ownerName: null == ownerName
          ? _value.ownerName
          : ownerName // ignore: cast_nullable_to_non_nullable
              as String,
      ownerPhone: null == ownerPhone
          ? _value.ownerPhone
          : ownerPhone // ignore: cast_nullable_to_non_nullable
              as String,
      ownerPassport: null == ownerPassport
          ? _value.ownerPassport
          : ownerPassport // ignore: cast_nullable_to_non_nullable
              as String,
      carNumber: null == carNumber
          ? _value.carNumber
          : carNumber // ignore: cast_nullable_to_non_nullable
              as String,
      vin: null == vin
          ? _value.vin
          : vin // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SaveOrderRequestImplCopyWith<$Res>
    implements $SaveOrderRequestCopyWith<$Res> {
  factory _$$SaveOrderRequestImplCopyWith(_$SaveOrderRequestImpl value,
          $Res Function(_$SaveOrderRequestImpl) then) =
      __$$SaveOrderRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'car_id') int carId,
      int year,
      double price,
      @JsonKey(name: 'begin_date') String beginDate,
      @JsonKey(name: 'end_date') String endDate,
      @JsonKey(name: 'driver_count') int driverCount,
      double franchise,
      double premium,
      @JsonKey(name: 'owner_name') String ownerName,
      @JsonKey(name: 'owner_phone') String ownerPhone,
      @JsonKey(name: 'owner_passport') String ownerPassport,
      @JsonKey(name: 'car_number') String carNumber,
      String vin});
}

/// @nodoc
class __$$SaveOrderRequestImplCopyWithImpl<$Res>
    extends _$SaveOrderRequestCopyWithImpl<$Res, _$SaveOrderRequestImpl>
    implements _$$SaveOrderRequestImplCopyWith<$Res> {
  __$$SaveOrderRequestImplCopyWithImpl(_$SaveOrderRequestImpl _value,
      $Res Function(_$SaveOrderRequestImpl) _then)
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
    Object? premium = null,
    Object? ownerName = null,
    Object? ownerPhone = null,
    Object? ownerPassport = null,
    Object? carNumber = null,
    Object? vin = null,
  }) {
    return _then(_$SaveOrderRequestImpl(
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
      premium: null == premium
          ? _value.premium
          : premium // ignore: cast_nullable_to_non_nullable
              as double,
      ownerName: null == ownerName
          ? _value.ownerName
          : ownerName // ignore: cast_nullable_to_non_nullable
              as String,
      ownerPhone: null == ownerPhone
          ? _value.ownerPhone
          : ownerPhone // ignore: cast_nullable_to_non_nullable
              as String,
      ownerPassport: null == ownerPassport
          ? _value.ownerPassport
          : ownerPassport // ignore: cast_nullable_to_non_nullable
              as String,
      carNumber: null == carNumber
          ? _value.carNumber
          : carNumber // ignore: cast_nullable_to_non_nullable
              as String,
      vin: null == vin
          ? _value.vin
          : vin // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SaveOrderRequestImpl implements _SaveOrderRequest {
  const _$SaveOrderRequestImpl(
      {@JsonKey(name: 'car_id') required this.carId,
      required this.year,
      required this.price,
      @JsonKey(name: 'begin_date') required this.beginDate,
      @JsonKey(name: 'end_date') required this.endDate,
      @JsonKey(name: 'driver_count') required this.driverCount,
      required this.franchise,
      required this.premium,
      @JsonKey(name: 'owner_name') required this.ownerName,
      @JsonKey(name: 'owner_phone') required this.ownerPhone,
      @JsonKey(name: 'owner_passport') required this.ownerPassport,
      @JsonKey(name: 'car_number') required this.carNumber,
      required this.vin});

  factory _$SaveOrderRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SaveOrderRequestImplFromJson(json);

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
  final double premium;
  @override
  @JsonKey(name: 'owner_name')
  final String ownerName;
  @override
  @JsonKey(name: 'owner_phone')
  final String ownerPhone;
  @override
  @JsonKey(name: 'owner_passport')
  final String ownerPassport;
  @override
  @JsonKey(name: 'car_number')
  final String carNumber;
  @override
  final String vin;

  @override
  String toString() {
    return 'SaveOrderRequest(carId: $carId, year: $year, price: $price, beginDate: $beginDate, endDate: $endDate, driverCount: $driverCount, franchise: $franchise, premium: $premium, ownerName: $ownerName, ownerPhone: $ownerPhone, ownerPassport: $ownerPassport, carNumber: $carNumber, vin: $vin)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaveOrderRequestImpl &&
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
            (identical(other.premium, premium) || other.premium == premium) &&
            (identical(other.ownerName, ownerName) ||
                other.ownerName == ownerName) &&
            (identical(other.ownerPhone, ownerPhone) ||
                other.ownerPhone == ownerPhone) &&
            (identical(other.ownerPassport, ownerPassport) ||
                other.ownerPassport == ownerPassport) &&
            (identical(other.carNumber, carNumber) ||
                other.carNumber == carNumber) &&
            (identical(other.vin, vin) || other.vin == vin));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      carId,
      year,
      price,
      beginDate,
      endDate,
      driverCount,
      franchise,
      premium,
      ownerName,
      ownerPhone,
      ownerPassport,
      carNumber,
      vin);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SaveOrderRequestImplCopyWith<_$SaveOrderRequestImpl> get copyWith =>
      __$$SaveOrderRequestImplCopyWithImpl<_$SaveOrderRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SaveOrderRequestImplToJson(
      this,
    );
  }
}

abstract class _SaveOrderRequest implements SaveOrderRequest {
  const factory _SaveOrderRequest(
      {@JsonKey(name: 'car_id') required final int carId,
      required final int year,
      required final double price,
      @JsonKey(name: 'begin_date') required final String beginDate,
      @JsonKey(name: 'end_date') required final String endDate,
      @JsonKey(name: 'driver_count') required final int driverCount,
      required final double franchise,
      required final double premium,
      @JsonKey(name: 'owner_name') required final String ownerName,
      @JsonKey(name: 'owner_phone') required final String ownerPhone,
      @JsonKey(name: 'owner_passport') required final String ownerPassport,
      @JsonKey(name: 'car_number') required final String carNumber,
      required final String vin}) = _$SaveOrderRequestImpl;

  factory _SaveOrderRequest.fromJson(Map<String, dynamic> json) =
      _$SaveOrderRequestImpl.fromJson;

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
  double get premium;
  @override
  @JsonKey(name: 'owner_name')
  String get ownerName;
  @override
  @JsonKey(name: 'owner_phone')
  String get ownerPhone;
  @override
  @JsonKey(name: 'owner_passport')
  String get ownerPassport;
  @override
  @JsonKey(name: 'car_number')
  String get carNumber;
  @override
  String get vin;
  @override
  @JsonKey(ignore: true)
  _$$SaveOrderRequestImplCopyWith<_$SaveOrderRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
