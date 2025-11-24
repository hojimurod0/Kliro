import '../entities/auth_tokens.dart';
import '../entities/google_auth_redirect.dart';
import '../params/auth_params.dart';

abstract class AuthRepository {
  Future<void> sendRegisterOtp(SendOtpParams params);
  Future<void> confirmRegisterOtp(ConfirmOtpParams params);
  Future<AuthTokens> finalizeRegistration(RegistrationFinalizeParams params);
  Future<AuthTokens> login(LoginParams params);
  Future<void> sendForgotPasswordOtp(ForgotPasswordParams params);
  Future<void> resetPassword(ResetPasswordParams params);
  Future<GoogleAuthRedirect> getGoogleAuthRedirect(String redirectUrl);
  Future<AuthTokens> completeGoogleRegistration(GoogleCompleteParams params);
}

