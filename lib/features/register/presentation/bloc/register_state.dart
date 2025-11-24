import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/google_auth_redirect.dart';
import '../../domain/entities/user_profile.dart';

enum RegisterStatus { initial, loading, success, failure }

enum RegisterFlow {
  none,
  registerSendOtp,
  registerConfirmOtp,
  registrationFinalize,
  login,
  forgotPasswordOtp,
  resetPassword,
  googleRedirect,
  googleComplete,
  profileFetch,
  profileUpdate,
  regionChange,
  passwordChange,
  contactUpdate,
  contactConfirm,
  logout,
}

class RegisterState extends Equatable {
  const RegisterState({
    this.status = RegisterStatus.initial,
    this.flow = RegisterFlow.none,
    this.tokens,
    this.profile,
    this.googleRedirect,
    this.message,
    this.error,
  });

  factory RegisterState.initial() => const RegisterState();

  final RegisterStatus status;
  final RegisterFlow flow;
  final AuthTokens? tokens;
  final UserProfile? profile;
  final GoogleAuthRedirect? googleRedirect;
  final String? message;
  final String? error;

  bool get isLoading => status == RegisterStatus.loading;

  RegisterState copyWith({
    RegisterStatus? status,
    RegisterFlow? flow,
    AuthTokens? tokens,
    bool clearTokens = false,
    UserProfile? profile,
    bool clearProfile = false,
    GoogleAuthRedirect? googleRedirect,
    bool clearGoogleRedirect = false,
    String? message,
    bool clearMessage = false,
    String? error,
    bool clearError = false,
  }) {
    return RegisterState(
      status: status ?? this.status,
      flow: flow ?? this.flow,
      tokens: clearTokens ? null : (tokens ?? this.tokens),
      profile: clearProfile ? null : (profile ?? this.profile),
      googleRedirect:
          clearGoogleRedirect ? null : (googleRedirect ?? this.googleRedirect),
      message: clearMessage ? null : (message ?? this.message),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        status,
        flow,
        tokens,
        profile,
        googleRedirect,
        message,
        error,
      ];
}

