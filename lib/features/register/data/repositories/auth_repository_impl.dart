import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/google_auth_redirect.dart';
import '../../domain/params/auth_params.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<void> sendRegisterOtp(SendOtpParams params) {
    return _remote.sendRegisterOtp(params);
  }

  @override
  Future<void> confirmRegisterOtp(ConfirmOtpParams params) {
    return _remote.confirmRegisterOtp(params);
  }

  @override
  Future<AuthTokens> finalizeRegistration(RegistrationFinalizeParams params) {
    return _remote.finalizeRegistration(params);
  }

  @override
  Future<AuthTokens> login(LoginParams params) {
    return _remote.login(params);
  }

  @override
  Future<void> sendForgotPasswordOtp(ForgotPasswordParams params) {
    return _remote.sendForgotPasswordOtp(params);
  }

  @override
  Future<void> resetPassword(ResetPasswordParams params) {
    return _remote.resetPassword(params);
  }

  @override
  Future<GoogleAuthRedirect> getGoogleAuthRedirect(String redirectUrl) {
    return _remote.getGoogleRedirect(redirectUrl);
  }

  @override
  Future<AuthTokens> completeGoogleRegistration(GoogleCompleteParams params) {
    return _remote.completeGoogleRegistration(params);
  }
}



