// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_upload_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ImageUploadResponse _$ImageUploadResponseFromJson(Map<String, dynamic> json) {
  return _ImageUploadResponse.fromJson(json);
}

/// @nodoc
mixin _$ImageUploadResponse {
  @JsonKey(name: 'image_url')
  String get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_id')
  String get orderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_type')
  String get imageType => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ImageUploadResponseCopyWith<ImageUploadResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImageUploadResponseCopyWith<$Res> {
  factory $ImageUploadResponseCopyWith(
          ImageUploadResponse value, $Res Function(ImageUploadResponse) then) =
      _$ImageUploadResponseCopyWithImpl<$Res, ImageUploadResponse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'image_url') String imageUrl,
      @JsonKey(name: 'order_id') String orderId,
      @JsonKey(name: 'image_type') String imageType});
}

/// @nodoc
class _$ImageUploadResponseCopyWithImpl<$Res, $Val extends ImageUploadResponse>
    implements $ImageUploadResponseCopyWith<$Res> {
  _$ImageUploadResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageUrl = null,
    Object? orderId = null,
    Object? imageType = null,
  }) {
    return _then(_value.copyWith(
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      imageType: null == imageType
          ? _value.imageType
          : imageType // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImageUploadResponseImplCopyWith<$Res>
    implements $ImageUploadResponseCopyWith<$Res> {
  factory _$$ImageUploadResponseImplCopyWith(_$ImageUploadResponseImpl value,
          $Res Function(_$ImageUploadResponseImpl) then) =
      __$$ImageUploadResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'image_url') String imageUrl,
      @JsonKey(name: 'order_id') String orderId,
      @JsonKey(name: 'image_type') String imageType});
}

/// @nodoc
class __$$ImageUploadResponseImplCopyWithImpl<$Res>
    extends _$ImageUploadResponseCopyWithImpl<$Res, _$ImageUploadResponseImpl>
    implements _$$ImageUploadResponseImplCopyWith<$Res> {
  __$$ImageUploadResponseImplCopyWithImpl(_$ImageUploadResponseImpl _value,
      $Res Function(_$ImageUploadResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageUrl = null,
    Object? orderId = null,
    Object? imageType = null,
  }) {
    return _then(_$ImageUploadResponseImpl(
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String,
      imageType: null == imageType
          ? _value.imageType
          : imageType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ImageUploadResponseImpl implements _ImageUploadResponse {
  const _$ImageUploadResponseImpl(
      {@JsonKey(name: 'image_url') required this.imageUrl,
      @JsonKey(name: 'order_id') required this.orderId,
      @JsonKey(name: 'image_type') required this.imageType});

  factory _$ImageUploadResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImageUploadResponseImplFromJson(json);

  @override
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @override
  @JsonKey(name: 'order_id')
  final String orderId;
  @override
  @JsonKey(name: 'image_type')
  final String imageType;

  @override
  String toString() {
    return 'ImageUploadResponse(imageUrl: $imageUrl, orderId: $orderId, imageType: $imageType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageUploadResponseImpl &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.imageType, imageType) ||
                other.imageType == imageType));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, imageUrl, orderId, imageType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageUploadResponseImplCopyWith<_$ImageUploadResponseImpl> get copyWith =>
      __$$ImageUploadResponseImplCopyWithImpl<_$ImageUploadResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImageUploadResponseImplToJson(
      this,
    );
  }
}

abstract class _ImageUploadResponse implements ImageUploadResponse {
  const factory _ImageUploadResponse(
          {@JsonKey(name: 'image_url') required final String imageUrl,
          @JsonKey(name: 'order_id') required final String orderId,
          @JsonKey(name: 'image_type') required final String imageType}) =
      _$ImageUploadResponseImpl;

  factory _ImageUploadResponse.fromJson(Map<String, dynamic> json) =
      _$ImageUploadResponseImpl.fromJson;

  @override
  @JsonKey(name: 'image_url')
  String get imageUrl;
  @override
  @JsonKey(name: 'order_id')
  String get orderId;
  @override
  @JsonKey(name: 'image_type')
  String get imageType;
  @override
  @JsonKey(ignore: true)
  _$$ImageUploadResponseImplCopyWith<_$ImageUploadResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
