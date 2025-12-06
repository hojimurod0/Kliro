import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_upload_response.freezed.dart';
part 'image_upload_response.g.dart';

@freezed
class ImageUploadResponse with _$ImageUploadResponse {
  const factory ImageUploadResponse({
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'image_type') required String imageType,
  }) = _ImageUploadResponse;

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$ImageUploadResponseFromJson(json);
}
