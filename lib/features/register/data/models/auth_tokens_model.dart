import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/auth_tokens.dart';

part 'auth_tokens_model.g.dart';

/// Data model for authentication tokens returned from API.
@JsonSerializable(fieldRename: FieldRename.snake)
class AuthTokensModel extends AuthTokens {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
    super.tokenType,
    super.expiresIn,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);

    // API ba'zida camelCase qaytarishi mumkin, shuning uchun moslashtiramiz
    if (!normalized.containsKey('access_token') &&
        normalized.containsKey('accessToken')) {
      normalized['access_token'] = normalized['accessToken'];
    }
    if (!normalized.containsKey('refresh_token') &&
        normalized.containsKey('refreshToken')) {
      normalized['refresh_token'] = normalized['refreshToken'];
    }
    if (!normalized.containsKey('token_type') &&
        normalized.containsKey('tokenType')) {
      normalized['token_type'] = normalized['tokenType'];
    }
    if (!normalized.containsKey('expires_in') &&
        normalized.containsKey('expiresIn')) {
      normalized['expires_in'] = normalized['expiresIn'];
    }

    return _$AuthTokensModelFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$AuthTokensModelToJson(this);
}
