import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_response_model.g.dart';

@JsonSerializable()
class LoginResponseModel extends Equatable {
  final String? token;
  final String? accessToken;
  final String? refreshToken;
  final UserModel? user;

  const LoginResponseModel({
    this.token,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);

  LoginResponseModel copyWith({
    String? token,
    String? accessToken,
    String? refreshToken,
    UserModel? user,
  }) {
    return LoginResponseModel(
      token: token ?? this.token,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [token, accessToken, refreshToken, user];
}

@JsonSerializable()
class UserModel extends Equatable {
  final String? id;
  final String? email;
  final String? name;

  const UserModel({
    this.id,
    this.email,
    this.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }

  @override
  List<Object?> get props => [id, email, name];
}




