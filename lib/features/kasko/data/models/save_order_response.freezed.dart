// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'save_order_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SaveOrderResponse _$SaveOrderResponseFromJson(Map<String, dynamic> json) {
  return _SaveOrderResponse.fromJson(json);
}

/// @nodoc
mixin _$SaveOrderResponse {
  @JsonKey(name: 'order_id')
  String get orderId => throw _privateConstructorUsedError;
  double get premium => throw _privateConstructorUsedError;
  @JsonKey(name: 'car_id')
  int get carId => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_name')
  String get ownerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_phone')
  String get ownerPhone => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SaveOrderResponseCopyWith<SaveOrderResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SaveOrderResponseCopyWith<$Res> {
  factory $SaveOrderResponseCopyWith(
          SaveOrderResponse value, $Res Function(SaveOrderResponse) then) =
      _$SaveOrderResponseCopyWithImpl<$Res, SaveOrderResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'order_id') String orderId,
      double premium,
      @JsonKey(name: 'car_id') int carId,
      @JsonKey(name: 'owner_name') String ownerName,
      @JsonKey(name: 'owner_phone') String ownerPhone,
      String? status});
}

/// @nodoc
class _$SaveOrderResponseCopyWithImpl<$Res, $Val extends SaveOrderResponse>
    implements $SaveOrderResponseCopyWith<$Res> {
  _$SaveOrderResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? premium = null,
    Object? carId = null,
    Object? ownerName = null,
    Object? ownerPhone = null,
    Object? status = freezed,
  }) {
    return _then(_value.copyWith(
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      premium: null == premium
          ? _value.premium
          : premium // ignore: cast_nullable_to_non_nullable
              as double,
      carId: null == carId
          ? _value.carId
          : carId // ignore: cast_nullable_to_non_nullable
              as int,
      ownerName: null == ownerName
          ? _value.ownerName
          : ownerName // ignore: cast_nullable_to_non_nullable
              as String,
      ownerPhone: null == ownerPhone
          ? _value.ownerPhone
          : ownerPhone // ignore: cast_nullable_to_non_nullable
              as String,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SaveOrderResponseImplCopyWith<$Res>
    implements $SaveOrderResponseCopyWith<$Res> {
  factory _$$SaveOrderResponseImplCopyWith(_$SaveOrderResponseImpl value,
          $Res Function(_$SaveOrderResponseImpl) then) =
      __$$SaveOrderResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'order_id') String orderId,
      double premium,
      @JsonKey(name: 'car_id') int carId,
      @JsonKey(name: 'owner_name') String ownerName,
      @JsonKey(name: 'owner_phone') String ownerPhone,
      String? status});
}

/// @nodoc
class __$$SaveOrderResponseImplCopyWithImpl<$Res>
    extends _$SaveOrderResponseCopyWithImpl<$Res, _$SaveOrderResponseImpl>
    implements _$$SaveOrderResponseImplCopyWith<$Res> {
  __$$SaveOrderResponseImplCopyWithImpl(_$SaveOrderResponseImpl _value,
      $Res Function(_$SaveOrderResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? premium = null,
    Object? carId = null,
    Object? ownerName = null,
    Object? ownerPhone = null,
    Object? status = freezed,
  }) {
    return _then(_$SaveOrderResponseImpl(
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      premium: null == premium
          ? _value.premium
          : premium // ignore: cast_nullable_to_non_nullable
              as double,
      carId: null == carId
          ? _value.carId
          : carId // ignore: cast_nullable_to_non_nullable
              as int,
      ownerName: null == ownerName
          ? _value.ownerName
          : ownerName // ignore: cast_nullable_to_non_nullable
              as String,
      ownerPhone: null == ownerPhone
          ? _value.ownerPhone
          : ownerPhone // ignore: cast_nullable_to_non_nullable
              as String,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SaveOrderResponseImpl implements _SaveOrderResponse {
  const _$SaveOrderResponseImpl(
      {@JsonKey(name: 'order_id') required this.orderId,
      required this.premium,
      @JsonKey(name: 'car_id') required this.carId,
      @JsonKey(name: 'owner_name') required this.ownerName,
      @JsonKey(name: 'owner_phone') required this.ownerPhone,
      this.status});

  factory _$SaveOrderResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SaveOrderResponseImplFromJson(json);

  @override
  @JsonKey(name: 'order_id')
  final String orderId;
  @override
  final double premium;
  @override
  @JsonKey(name: 'car_id')
  final int carId;
  @override
  @JsonKey(name: 'owner_name')
  final String ownerName;
  @override
  @JsonKey(name: 'owner_phone')
  final String ownerPhone;
  @override
  final String? status;

  @override
  String toString() {
    return 'SaveOrderResponse(orderId: $orderId, premium: $premium, carId: $carId, ownerName: $ownerName, ownerPhone: $ownerPhone, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaveOrderResponseImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.premium, premium) || other.premium == premium) &&
            (identical(other.carId, carId) || other.carId == carId) &&
            (identical(other.ownerName, ownerName) ||
                other.ownerName == ownerName) &&
            (identical(other.ownerPhone, ownerPhone) ||
                other.ownerPhone == ownerPhone) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, orderId, premium, carId, ownerName, ownerPhone, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SaveOrderResponseImplCopyWith<_$SaveOrderResponseImpl> get copyWith =>
      __$$SaveOrderResponseImplCopyWithImpl<_$SaveOrderResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SaveOrderResponseImplToJson(
      this,
    );
  }
}

abstract class _SaveOrderResponse implements SaveOrderResponse {
  const factory _SaveOrderResponse(
      {@JsonKey(name: 'order_id') required final String orderId,
      required final double premium,
      @JsonKey(name: 'car_id') required final int carId,
      @JsonKey(name: 'owner_name') required final String ownerName,
      @JsonKey(name: 'owner_phone') required final String ownerPhone,
      final String? status}) = _$SaveOrderResponseImpl;

  factory _SaveOrderResponse.fromJson(Map<String, dynamic> json) =
      _$SaveOrderResponseImpl.fromJson;

  @override
  @JsonKey(name: 'order_id')
  String get orderId;
  @override
  double get premium;
  @override
  @JsonKey(name: 'car_id')
  int get carId;
  @override
  @JsonKey(name: 'owner_name')
  String get ownerName;
  @override
  @JsonKey(name: 'owner_phone')
  String get ownerPhone;
  @override
  String? get status;
  @override
  @JsonKey(ignore: true)
  _$$SaveOrderResponseImplCopyWith<_$SaveOrderResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
