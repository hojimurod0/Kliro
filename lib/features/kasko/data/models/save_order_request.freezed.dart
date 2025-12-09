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

Sugurtalovchi _$SugurtalovchiFromJson(Map<String, dynamic> json) {
  return _Sugurtalovchi.fromJson(json);
}

/// @nodoc
mixin _$Sugurtalovchi {
  @JsonKey(name: 'passportSeries')
  String get passportSeries => throw _privateConstructorUsedError;
  @JsonKey(name: 'passportNumber')
  String get passportNumber => throw _privateConstructorUsedError;
  String get birthday => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SugurtalovchiCopyWith<Sugurtalovchi> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SugurtalovchiCopyWith<$Res> {
  factory $SugurtalovchiCopyWith(
          Sugurtalovchi value, $Res Function(Sugurtalovchi) then) =
      _$SugurtalovchiCopyWithImpl<$Res, Sugurtalovchi>;
  @useResult
  $Res call(
      {@JsonKey(name: 'passportSeries') String passportSeries,
      @JsonKey(name: 'passportNumber') String passportNumber,
      String birthday,
      String phone});
}

/// @nodoc
class _$SugurtalovchiCopyWithImpl<$Res, $Val extends Sugurtalovchi>
    implements $SugurtalovchiCopyWith<$Res> {
  _$SugurtalovchiCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? passportSeries = null,
    Object? passportNumber = null,
    Object? birthday = null,
    Object? phone = null,
  }) {
    return _then(_value.copyWith(
      passportSeries: null == passportSeries
          ? _value.passportSeries
          : passportSeries // ignore: cast_nullable_to_non_nullable
              as String,
      passportNumber: null == passportNumber
          ? _value.passportNumber
          : passportNumber // ignore: cast_nullable_to_non_nullable
              as String,
      birthday: null == birthday
          ? _value.birthday
          : birthday // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SugurtalovchiImplCopyWith<$Res>
    implements $SugurtalovchiCopyWith<$Res> {
  factory _$$SugurtalovchiImplCopyWith(
          _$SugurtalovchiImpl value, $Res Function(_$SugurtalovchiImpl) then) =
      __$$SugurtalovchiImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'passportSeries') String passportSeries,
      @JsonKey(name: 'passportNumber') String passportNumber,
      String birthday,
      String phone});
}

/// @nodoc
class __$$SugurtalovchiImplCopyWithImpl<$Res>
    extends _$SugurtalovchiCopyWithImpl<$Res, _$SugurtalovchiImpl>
    implements _$$SugurtalovchiImplCopyWith<$Res> {
  __$$SugurtalovchiImplCopyWithImpl(
      _$SugurtalovchiImpl _value, $Res Function(_$SugurtalovchiImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? passportSeries = null,
    Object? passportNumber = null,
    Object? birthday = null,
    Object? phone = null,
  }) {
    return _then(_$SugurtalovchiImpl(
      passportSeries: null == passportSeries
          ? _value.passportSeries
          : passportSeries // ignore: cast_nullable_to_non_nullable
              as String,
      passportNumber: null == passportNumber
          ? _value.passportNumber
          : passportNumber // ignore: cast_nullable_to_non_nullable
              as String,
      birthday: null == birthday
          ? _value.birthday
          : birthday // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SugurtalovchiImpl implements _Sugurtalovchi {
  const _$SugurtalovchiImpl(
      {@JsonKey(name: 'passportSeries') required this.passportSeries,
      @JsonKey(name: 'passportNumber') required this.passportNumber,
      required this.birthday,
      required this.phone});

  factory _$SugurtalovchiImpl.fromJson(Map<String, dynamic> json) =>
      _$$SugurtalovchiImplFromJson(json);

  @override
  @JsonKey(name: 'passportSeries')
  final String passportSeries;
  @override
  @JsonKey(name: 'passportNumber')
  final String passportNumber;
  @override
  final String birthday;
  @override
  final String phone;

  @override
  String toString() {
    return 'Sugurtalovchi(passportSeries: $passportSeries, passportNumber: $passportNumber, birthday: $birthday, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SugurtalovchiImpl &&
            (identical(other.passportSeries, passportSeries) ||
                other.passportSeries == passportSeries) &&
            (identical(other.passportNumber, passportNumber) ||
                other.passportNumber == passportNumber) &&
            (identical(other.birthday, birthday) ||
                other.birthday == birthday) &&
            (identical(other.phone, phone) || other.phone == phone));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, passportSeries, passportNumber, birthday, phone);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SugurtalovchiImplCopyWith<_$SugurtalovchiImpl> get copyWith =>
      __$$SugurtalovchiImplCopyWithImpl<_$SugurtalovchiImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SugurtalovchiImplToJson(
      this,
    );
  }
}

abstract class _Sugurtalovchi implements Sugurtalovchi {
  const factory _Sugurtalovchi(
      {@JsonKey(name: 'passportSeries') required final String passportSeries,
      @JsonKey(name: 'passportNumber') required final String passportNumber,
      required final String birthday,
      required final String phone}) = _$SugurtalovchiImpl;

  factory _Sugurtalovchi.fromJson(Map<String, dynamic> json) =
      _$SugurtalovchiImpl.fromJson;

  @override
  @JsonKey(name: 'passportSeries')
  String get passportSeries;
  @override
  @JsonKey(name: 'passportNumber')
  String get passportNumber;
  @override
  String get birthday;
  @override
  String get phone;
  @override
  @JsonKey(ignore: true)
  _$$SugurtalovchiImplCopyWith<_$SugurtalovchiImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CarData _$CarDataFromJson(Map<String, dynamic> json) {
  return _CarData.fromJson(json);
}

/// @nodoc
mixin _$CarData {
  @JsonKey(name: 'car_nomer')
  String get carNomer => throw _privateConstructorUsedError;
  String get seria => throw _privateConstructorUsedError;
  String get number => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_of_car')
  String get priceOfCar => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CarDataCopyWith<CarData> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CarDataCopyWith<$Res> {
  factory $CarDataCopyWith(CarData value, $Res Function(CarData) then) =
      _$CarDataCopyWithImpl<$Res, CarData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'car_nomer') String carNomer,
      String seria,
      String number,
      @JsonKey(name: 'price_of_car') String priceOfCar});
}

/// @nodoc
class _$CarDataCopyWithImpl<$Res, $Val extends CarData>
    implements $CarDataCopyWith<$Res> {
  _$CarDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? carNomer = null,
    Object? seria = null,
    Object? number = null,
    Object? priceOfCar = null,
  }) {
    return _then(_value.copyWith(
      carNomer: null == carNomer
          ? _value.carNomer
          : carNomer // ignore: cast_nullable_to_non_nullable
              as String,
      seria: null == seria
          ? _value.seria
          : seria // ignore: cast_nullable_to_non_nullable
              as String,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String,
      priceOfCar: null == priceOfCar
          ? _value.priceOfCar
          : priceOfCar // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CarDataImplCopyWith<$Res> implements $CarDataCopyWith<$Res> {
  factory _$$CarDataImplCopyWith(
          _$CarDataImpl value, $Res Function(_$CarDataImpl) then) =
      __$$CarDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'car_nomer') String carNomer,
      String seria,
      String number,
      @JsonKey(name: 'price_of_car') String priceOfCar});
}

/// @nodoc
class __$$CarDataImplCopyWithImpl<$Res>
    extends _$CarDataCopyWithImpl<$Res, _$CarDataImpl>
    implements _$$CarDataImplCopyWith<$Res> {
  __$$CarDataImplCopyWithImpl(
      _$CarDataImpl _value, $Res Function(_$CarDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? carNomer = null,
    Object? seria = null,
    Object? number = null,
    Object? priceOfCar = null,
  }) {
    return _then(_$CarDataImpl(
      carNomer: null == carNomer
          ? _value.carNomer
          : carNomer // ignore: cast_nullable_to_non_nullable
              as String,
      seria: null == seria
          ? _value.seria
          : seria // ignore: cast_nullable_to_non_nullable
              as String,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String,
      priceOfCar: null == priceOfCar
          ? _value.priceOfCar
          : priceOfCar // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CarDataImpl implements _CarData {
  const _$CarDataImpl(
      {@JsonKey(name: 'car_nomer') required this.carNomer,
      required this.seria,
      required this.number,
      @JsonKey(name: 'price_of_car') required this.priceOfCar});

  factory _$CarDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CarDataImplFromJson(json);

  @override
  @JsonKey(name: 'car_nomer')
  final String carNomer;
  @override
  final String seria;
  @override
  final String number;
  @override
  @JsonKey(name: 'price_of_car')
  final String priceOfCar;

  @override
  String toString() {
    return 'CarData(carNomer: $carNomer, seria: $seria, number: $number, priceOfCar: $priceOfCar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CarDataImpl &&
            (identical(other.carNomer, carNomer) ||
                other.carNomer == carNomer) &&
            (identical(other.seria, seria) || other.seria == seria) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.priceOfCar, priceOfCar) ||
                other.priceOfCar == priceOfCar));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, carNomer, seria, number, priceOfCar);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CarDataImplCopyWith<_$CarDataImpl> get copyWith =>
      __$$CarDataImplCopyWithImpl<_$CarDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CarDataImplToJson(
      this,
    );
  }
}

abstract class _CarData implements CarData {
  const factory _CarData(
          {@JsonKey(name: 'car_nomer') required final String carNomer,
          required final String seria,
          required final String number,
          @JsonKey(name: 'price_of_car') required final String priceOfCar}) =
      _$CarDataImpl;

  factory _CarData.fromJson(Map<String, dynamic> json) = _$CarDataImpl.fromJson;

  @override
  @JsonKey(name: 'car_nomer')
  String get carNomer;
  @override
  String get seria;
  @override
  String get number;
  @override
  @JsonKey(name: 'price_of_car')
  String get priceOfCar;
  @override
  @JsonKey(ignore: true)
  _$$CarDataImplCopyWith<_$CarDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SaveOrderRequest _$SaveOrderRequestFromJson(Map<String, dynamic> json) {
  return _SaveOrderRequest.fromJson(json);
}

/// @nodoc
mixin _$SaveOrderRequest {
  Sugurtalovchi get sugurtalovchi => throw _privateConstructorUsedError;
  CarData get car => throw _privateConstructorUsedError;
  @JsonKey(name: 'begin_date')
  String get beginDate => throw _privateConstructorUsedError;
  int get liability => throw _privateConstructorUsedError;
  int get premium => throw _privateConstructorUsedError;
  @JsonKey(name: 'tarif_id')
  int get tarifId => throw _privateConstructorUsedError;
  @JsonKey(name: 'tarif_type')
  int get tarifType => throw _privateConstructorUsedError;

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
      {Sugurtalovchi sugurtalovchi,
      CarData car,
      @JsonKey(name: 'begin_date') String beginDate,
      int liability,
      int premium,
      @JsonKey(name: 'tarif_id') int tarifId,
      @JsonKey(name: 'tarif_type') int tarifType});

  $SugurtalovchiCopyWith<$Res> get sugurtalovchi;
  $CarDataCopyWith<$Res> get car;
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
    Object? sugurtalovchi = null,
    Object? car = null,
    Object? beginDate = null,
    Object? liability = null,
    Object? premium = null,
    Object? tarifId = null,
    Object? tarifType = null,
  }) {
    return _then(_value.copyWith(
      sugurtalovchi: null == sugurtalovchi
          ? _value.sugurtalovchi
          : sugurtalovchi // ignore: cast_nullable_to_non_nullable
              as Sugurtalovchi,
      car: null == car
          ? _value.car
          : car // ignore: cast_nullable_to_non_nullable
              as CarData,
      beginDate: null == beginDate
          ? _value.beginDate
          : beginDate // ignore: cast_nullable_to_non_nullable
              as String,
      liability: null == liability
          ? _value.liability
          : liability // ignore: cast_nullable_to_non_nullable
              as int,
      premium: null == premium
          ? _value.premium
          : premium // ignore: cast_nullable_to_non_nullable
              as int,
      tarifId: null == tarifId
          ? _value.tarifId
          : tarifId // ignore: cast_nullable_to_non_nullable
              as int,
      tarifType: null == tarifType
          ? _value.tarifType
          : tarifType // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SugurtalovchiCopyWith<$Res> get sugurtalovchi {
    return $SugurtalovchiCopyWith<$Res>(_value.sugurtalovchi, (value) {
      return _then(_value.copyWith(sugurtalovchi: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $CarDataCopyWith<$Res> get car {
    return $CarDataCopyWith<$Res>(_value.car, (value) {
      return _then(_value.copyWith(car: value) as $Val);
    });
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
      {Sugurtalovchi sugurtalovchi,
      CarData car,
      @JsonKey(name: 'begin_date') String beginDate,
      int liability,
      int premium,
      @JsonKey(name: 'tarif_id') int tarifId,
      @JsonKey(name: 'tarif_type') int tarifType});

  @override
  $SugurtalovchiCopyWith<$Res> get sugurtalovchi;
  @override
  $CarDataCopyWith<$Res> get car;
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
    Object? sugurtalovchi = null,
    Object? car = null,
    Object? beginDate = null,
    Object? liability = null,
    Object? premium = null,
    Object? tarifId = null,
    Object? tarifType = null,
  }) {
    return _then(_$SaveOrderRequestImpl(
      sugurtalovchi: null == sugurtalovchi
          ? _value.sugurtalovchi
          : sugurtalovchi // ignore: cast_nullable_to_non_nullable
              as Sugurtalovchi,
      car: null == car
          ? _value.car
          : car // ignore: cast_nullable_to_non_nullable
              as CarData,
      beginDate: null == beginDate
          ? _value.beginDate
          : beginDate // ignore: cast_nullable_to_non_nullable
              as String,
      liability: null == liability
          ? _value.liability
          : liability // ignore: cast_nullable_to_non_nullable
              as int,
      premium: null == premium
          ? _value.premium
          : premium // ignore: cast_nullable_to_non_nullable
              as int,
      tarifId: null == tarifId
          ? _value.tarifId
          : tarifId // ignore: cast_nullable_to_non_nullable
              as int,
      tarifType: null == tarifType
          ? _value.tarifType
          : tarifType // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SaveOrderRequestImpl implements _SaveOrderRequest {
  const _$SaveOrderRequestImpl(
      {required this.sugurtalovchi,
      required this.car,
      @JsonKey(name: 'begin_date') required this.beginDate,
      required this.liability,
      required this.premium,
      @JsonKey(name: 'tarif_id') required this.tarifId,
      @JsonKey(name: 'tarif_type') required this.tarifType});

  factory _$SaveOrderRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SaveOrderRequestImplFromJson(json);

  @override
  final Sugurtalovchi sugurtalovchi;
  @override
  final CarData car;
  @override
  @JsonKey(name: 'begin_date')
  final String beginDate;
  @override
  final int liability;
  @override
  final int premium;
  @override
  @JsonKey(name: 'tarif_id')
  final int tarifId;
  @override
  @JsonKey(name: 'tarif_type')
  final int tarifType;

  @override
  String toString() {
    return 'SaveOrderRequest(sugurtalovchi: $sugurtalovchi, car: $car, beginDate: $beginDate, liability: $liability, premium: $premium, tarifId: $tarifId, tarifType: $tarifType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaveOrderRequestImpl &&
            (identical(other.sugurtalovchi, sugurtalovchi) ||
                other.sugurtalovchi == sugurtalovchi) &&
            (identical(other.car, car) || other.car == car) &&
            (identical(other.beginDate, beginDate) ||
                other.beginDate == beginDate) &&
            (identical(other.liability, liability) ||
                other.liability == liability) &&
            (identical(other.premium, premium) || other.premium == premium) &&
            (identical(other.tarifId, tarifId) || other.tarifId == tarifId) &&
            (identical(other.tarifType, tarifType) ||
                other.tarifType == tarifType));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, sugurtalovchi, car, beginDate,
      liability, premium, tarifId, tarifType);

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
          {required final Sugurtalovchi sugurtalovchi,
          required final CarData car,
          @JsonKey(name: 'begin_date') required final String beginDate,
          required final int liability,
          required final int premium,
          @JsonKey(name: 'tarif_id') required final int tarifId,
          @JsonKey(name: 'tarif_type') required final int tarifType}) =
      _$SaveOrderRequestImpl;

  factory _SaveOrderRequest.fromJson(Map<String, dynamic> json) =
      _$SaveOrderRequestImpl.fromJson;

  @override
  Sugurtalovchi get sugurtalovchi;
  @override
  CarData get car;
  @override
  @JsonKey(name: 'begin_date')
  String get beginDate;
  @override
  int get liability;
  @override
  int get premium;
  @override
  @JsonKey(name: 'tarif_id')
  int get tarifId;
  @override
  @JsonKey(name: 'tarif_type')
  int get tarifType;
  @override
  @JsonKey(ignore: true)
  _$$SaveOrderRequestImplCopyWith<_$SaveOrderRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
