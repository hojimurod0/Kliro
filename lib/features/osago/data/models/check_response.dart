import 'package:freezed_annotation/freezed_annotation.dart';

// ignore_for_file: invalid_annotation_target

import 'model_utils.dart';

part 'check_response.freezed.dart';
part 'check_response.g.dart';

@freezed
class CheckResponse with _$CheckResponse {
  const CheckResponse._();

  const factory CheckResponse({
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'policy_number') String? policyNumber,
    @JsonKey(name: 'status') required String status,
    @JsonKey(
      name: 'issued_at',
      fromJson: parseNullableOsagoDate,
      toJson: formatNullableOsagoDate,
    )
    DateTime? issuedAt,
    @JsonKey(name: 'amount') double? amount,
    @JsonKey(name: 'currency') String? currency,
    @JsonKey(name: 'download_url') String? downloadUrl,
  }) = _CheckResponse;

  factory CheckResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckResponseFromJson(json);

  bool get isReady {
    final normalized = status.toLowerCase();
    return normalized == 'success' ||
        normalized == 'issued' ||
        normalized == 'completed';
  }
}
