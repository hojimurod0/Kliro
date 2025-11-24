import 'package:equatable/equatable.dart';

import '../../domain/params/auth_params.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class SendRegisterOtpRequested extends RegisterEvent {
  const SendRegisterOtpRequested(this.params);

  final SendOtpParams params;

  @override
  List<Object?> get props => [params];
}

class ConfirmRegisterOtpRequested extends RegisterEvent {
  const ConfirmRegisterOtpRequested(this.params);

  final ConfirmOtpParams params;

  @override
  List<Object?> get props => [params];
}

class CompleteRegistrationRequested extends RegisterEvent {
  const CompleteRegistrationRequested(this.params);

  final RegistrationFinalizeParams params;

  @override
  List<Object?> get props => [params];
}

class LoginRequested extends RegisterEvent {
  const LoginRequested(this.params);

  final LoginParams params;

  @override
  List<Object?> get props => [params];
}

class ForgotPasswordOtpRequested extends RegisterEvent {
  const ForgotPasswordOtpRequested(this.params);

  final ForgotPasswordParams params;

  @override
  List<Object?> get props => [params];
}

class ResetPasswordRequested extends RegisterEvent {
  const ResetPasswordRequested(this.params);

  final ResetPasswordParams params;

  @override
  List<Object?> get props => [params];
}

class GoogleRedirectRequested extends RegisterEvent {
  const GoogleRedirectRequested(this.redirectUrl);

  final String redirectUrl;

  @override
  List<Object?> get props => [redirectUrl];
}

class CompleteGoogleRegistrationRequested extends RegisterEvent {
  const CompleteGoogleRegistrationRequested(this.params);

  final GoogleCompleteParams params;

  @override
  List<Object?> get props => [params];
}

class ProfileRequested extends RegisterEvent {
  const ProfileRequested();
}

class ProfileUpdated extends RegisterEvent {
  const ProfileUpdated(this.params);

  final UpdateProfileParams params;

  @override
  List<Object?> get props => [params];
}

class RegionChanged extends RegisterEvent {
  const RegionChanged(this.params);

  final ChangeRegionParams params;

  @override
  List<Object?> get props => [params];
}

class PasswordChanged extends RegisterEvent {
  const PasswordChanged(this.params);

  final ChangePasswordParams params;

  @override
  List<Object?> get props => [params];
}

class ContactUpdateRequested extends RegisterEvent {
  const ContactUpdateRequested(this.params);

  final UpdateContactParams params;

  @override
  List<Object?> get props => [params];
}

class ContactUpdateConfirmed extends RegisterEvent {
  const ContactUpdateConfirmed(this.params);

  final ConfirmUpdateContactParams params;

  @override
  List<Object?> get props => [params];
}

class LogoutRequested extends RegisterEvent {
  const LogoutRequested();
}

class RegisterMessageCleared extends RegisterEvent {
  const RegisterMessageCleared();
}

