import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/google_auth_redirect.dart';

part 'google_auth_redirect_model.g.dart';

/// Data model for Google OAuth redirect response.
@JsonSerializable(fieldRename: FieldRename.snake)
class GoogleAuthRedirectModel extends GoogleAuthRedirect {
  const GoogleAuthRedirectModel({required super.url, super.sessionId});

  factory GoogleAuthRedirectModel.fromJson(Map<String, dynamic> json) =>
      _$GoogleAuthRedirectModelFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleAuthRedirectModelToJson(this);
}
