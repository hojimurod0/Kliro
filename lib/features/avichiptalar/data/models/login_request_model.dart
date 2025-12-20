import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_request_model.g.dart';

@JsonSerializable()
class LoginRequestModel extends Equatable {
  final String email;
  final String password;
  @JsonKey(name: 'access_type')
  final String accessType;

  const LoginRequestModel({
    required this.email,
    required this.password,
    this.accessType = 'avia',
  });

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);

  LoginRequestModel copyWith({
    String? email,
    String? password,
    String? accessType,
  }) {
    return LoginRequestModel(
      email: email ?? this.email,
      password: password ?? this.password,
      accessType: accessType ?? this.accessType,
    );
  }

  @override
  List<Object?> get props => [email, password, accessType];
}




