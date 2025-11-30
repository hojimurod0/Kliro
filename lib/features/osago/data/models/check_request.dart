import 'package:freezed_annotation/freezed_annotation.dart';

// ignore_for_file: invalid_annotation_target

part 'check_request.freezed.dart';
part 'check_request.g.dart';

@freezed
class CheckRequest with _$CheckRequest {
  const factory CheckRequest({
    @JsonKey(name: 'session_id') required String sessionId,
  }) = _CheckRequest;

  factory CheckRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckRequestFromJson(json);
}
