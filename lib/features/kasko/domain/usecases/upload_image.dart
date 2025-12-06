import '../entities/image_upload_entity.dart';
import '../repositories/kasko_repository.dart';

class UploadImage {
  UploadImage(this._repository);

  final KaskoRepository _repository;

  Future<ImageUploadEntity> call({
    required String filePath,
    required String orderId,
    required String imageType,
  }) {
    return _repository.uploadImage(
      filePath: filePath,
      orderId: orderId,
      imageType: imageType,
    );
  }
}

