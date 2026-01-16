import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/register_user.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({
    required SendRegisterOtp sendRegisterOtp,
    required ConfirmRegisterOtp confirmRegisterOtp,
    required CompleteRegistration completeRegistration,
    required LoginUser loginUser,
    required SendForgotPasswordOtp sendForgotPasswordOtp,
    required ResetPassword resetPassword,
    required GetGoogleRedirect getGoogleRedirect,
    required CompleteGoogleRegistration completeGoogleRegistration,
    required GetProfile getProfile,
    required UpdateProfile updateProfile,
    required ChangeRegion changeRegion,
    required ChangePassword changePassword,
    required UpdateContact updateContact,
    required ConfirmUpdateContact confirmUpdateContact,
    required LogoutUser logoutUser,
    required AuthService authService,
  }) : _sendRegisterOtp = sendRegisterOtp,
       _confirmRegisterOtp = confirmRegisterOtp,
       _completeRegistration = completeRegistration,
       _loginUser = loginUser,
       _sendForgotPasswordOtp = sendForgotPasswordOtp,
       _resetPassword = resetPassword,
       _getGoogleRedirect = getGoogleRedirect,
       _completeGoogleRegistration = completeGoogleRegistration,
       _getProfile = getProfile,
       _updateProfile = updateProfile,
       _changeRegion = changeRegion,
       _changePassword = changePassword,
       _updateContact = updateContact,
       _confirmUpdateContact = confirmUpdateContact,
       _logoutUser = logoutUser,
       _authService = authService,
       super(RegisterState.initial()) {
    on<SendRegisterOtpRequested>(_onSendRegisterOtp);
    on<ConfirmRegisterOtpRequested>(_onConfirmRegisterOtp);
    on<CompleteRegistrationRequested>(_onCompleteRegistration);
    on<LoginRequested>(_onLoginRequested);
    on<ForgotPasswordOtpRequested>(_onForgotPasswordOtpRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<GoogleRedirectRequested>(_onGoogleRedirectRequested);
    on<CompleteGoogleRegistrationRequested>(_onCompleteGoogleRegistration);
    on<ProfileRequested>(_onProfileRequested);
    on<ProfileUpdated>(_onProfileUpdated);
    on<RegionChanged>(_onRegionChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<ContactUpdateRequested>(_onContactUpdateRequested);
    on<ContactUpdateConfirmed>(_onContactUpdateConfirmed);
    on<LogoutRequested>(_onLogoutRequested);
    on<RegisterMessageCleared>(_onMessageCleared);
  }

  final SendRegisterOtp _sendRegisterOtp;
  final ConfirmRegisterOtp _confirmRegisterOtp;
  final CompleteRegistration _completeRegistration;
  final LoginUser _loginUser;
  final SendForgotPasswordOtp _sendForgotPasswordOtp;
  final ResetPassword _resetPassword;
  final GetGoogleRedirect _getGoogleRedirect;
  final CompleteGoogleRegistration _completeGoogleRegistration;
  final GetProfile _getProfile;
  final UpdateProfile _updateProfile;
  final ChangeRegion _changeRegion;
  final ChangePassword _changePassword;
  final UpdateContact _updateContact;
  final ConfirmUpdateContact _confirmUpdateContact;
  final LogoutUser _logoutUser;
  final AuthService _authService;

  Future<void> _onSendRegisterOtp(
    SendRegisterOtpRequested event,
    Emitter<RegisterState> emit,
  ) async {
    await _runSafe(
      emit,
      flow: RegisterFlow.registerSendOtp,
      action: () async {
        await _sendRegisterOtp(event.params);
        emit(
          state.copyWith(
            status: RegisterStatus.success,
            message: 'OTP sent successfully',
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onConfirmRegisterOtp(
    ConfirmRegisterOtpRequested event,
    Emitter<RegisterState> emit,
  ) async {
    await _runSafe(
      emit,
      flow: RegisterFlow.registerConfirmOtp,
      action: () async {
        await _confirmRegisterOtp(event.params);
        emit(
          state.copyWith(
            status: RegisterStatus.success,
            message: 'OTP confirmed. Continue registration.',
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onCompleteRegistration(
    CompleteRegistrationRequested event,
    Emitter<RegisterState> emit,
  ) async {
    await _runSafe(
      emit,
      flow: RegisterFlow.registrationFinalize,
      action: () async {
        final tokens = await _completeRegistration(event.params);
        await _persistTokens(tokens);
        // SECURITY: Password is NOT stored in client
        await _authService.saveProfile(
          AuthUser(
            firstName: event.params.firstName,
            lastName: event.params.lastName,
            contact: event.params.email ?? event.params.phone ?? '',
            password: null, // Password is never stored in client
            email: event.params.email,
            phone: event.params.phone != null && event.params.phone!.isNotEmpty
                ? AuthService.normalizeContact(event.params.phone!)
                : null,
          ),
        );
        emit(
          state.copyWith(
            status: RegisterStatus.success,
            tokens: tokens,
            message: 'Registration completed',
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<RegisterState> emit,
  ) async {
    await _runSafe(
      emit,
      flow: RegisterFlow.login,
      action: () async {
        // ✅ AVVAL ESKI USER MA'LUMOTLARINI TOZALASH
        AppLogger.debug('🔐 LOGIN: Clearing previous user data...');
        await _authService.logout(); // Eski ma'lumotlarni tozalash
        
        // ✅ YANGI USER LOGIN QILISH
        final tokens = await _loginUser(event.params);
        await _persistTokens(tokens);
        
        AppLogger.debug('🔐 LOGIN: Tokens received, loading profile...');
        AppLogger.debug('🔐 LOGIN: Login method - email: ${event.params.email != null ? "YES" : "NO"}, phone: ${event.params.phone != null ? "YES" : "NO"}');
        
        // Profile'ni yuklab, ma'lumotlarni saqlash
        try {
          final profile = await _getProfile();
          AppLogger.debug('🔐 LOGIN: Profile loaded from API');
          AppLogger.debug('🔐 LOGIN: Profile email: ${profile.email ?? "null"}');
          AppLogger.debug('🔐 LOGIN: Profile phone: ${profile.phone ?? "null"}');
          AppLogger.debug('🔐 LOGIN: Profile firstName: ${profile.firstName}');
          AppLogger.debug('🔐 LOGIN: Profile lastName: ${profile.lastName}');
          
          // ✅ YANGI USER MA'LUMOTLARINI TO'LIQ SAQLASH (cachedUser'siz)
          final contact = event.params.email ?? event.params.phone ?? '';
          
          // SECURITY: Password is NOT stored in client
          final authUser = AuthUser(
            firstName: profile.firstName,
            lastName: profile.lastName,
            contact: profile.email ?? profile.phone ?? contact,
            password: null, // Password is never stored in client
            region: profile.regionName, // cachedUser'siz, to'g'ridan-to'g'ri serverdan
            email: profile.email,
            phone: profile.phone != null && profile.phone!.isNotEmpty
                ? AuthService.normalizeContact(profile.phone!)
                : null,
          );
          
          AppLogger.debug('🔐 LOGIN: Saving AuthUser to AuthService');
          AppLogger.debug('🔐 LOGIN: AuthUser.email: ${authUser.email ?? "null"}');
          AppLogger.debug('🔐 LOGIN: AuthUser.phone: ${authUser.phone ?? "null"}');
          AppLogger.debug('🔐 LOGIN: AuthUser.contact: ${authUser.contact}');
          
          await _authService.saveProfile(authUser);
          
          AppLogger.debug('🔐 LOGIN: AuthUser saved successfully');
        } catch (e) {
          AppLogger.warning('🔐 LOGIN: Failed to load profile from API: $e');
          // Profile yuklanmasa ham, minimal ma'lumotlarni saqlash
          final contact = event.params.email ?? event.params.phone ?? '';
          
          // SECURITY: Password is NOT stored in client
          AppLogger.debug('🔐 LOGIN: Saving minimal AuthUser (contact only)');
          await _authService.saveProfile(
            AuthUser(
              firstName: '',
              lastName: '',
              contact: contact,
              password: null, // Password is never stored in client
              region: null,
              email: null,
              phone: null,
            ),
          );
          
          // Profile'ni keyinroq yuklashga harakat qilish
          try {
            AppLogger.debug('🔐 LOGIN: Retrying profile load...');
            final profile = await _getProfile();
            AppLogger.debug('🔐 LOGIN: Profile loaded on retry');
            AppLogger.debug('🔐 LOGIN: Profile email: ${profile.email ?? "null"}');
            AppLogger.debug('🔐 LOGIN: Profile phone: ${profile.phone ?? "null"}');
            
            // SECURITY: Password is NOT stored in client
            final authUser = AuthUser(
              firstName: profile.firstName,
              lastName: profile.lastName,
              contact: profile.email ?? profile.phone ?? contact,
              password: null, // Password is never stored in client
              region: profile.regionName,
              email: profile.email,
              phone: profile.phone != null && profile.phone!.isNotEmpty
                  ? AuthService.normalizeContact(profile.phone!)
                  : null,
            );
            AppLogger.debug('🔐 LOGIN: Saving AuthUser from retry');
            AppLogger.debug('🔐 LOGIN: AuthUser.email: ${authUser.email ?? "null"}');
            AppLogger.debug('🔐 LOGIN: AuthUser.phone: ${authUser.phone ?? "null"}');
            await _authService.saveProfile(authUser);
          } catch (retryError) {
            AppLogger.error('🔐 LOGIN: Retry also failed: $retryError');
            // Ikkinchi marta ham yuklanmasa, xatolikni e'tiborsiz qoldirish
          }
        }
        
        emit(
          state.copyWith(
            status: RegisterStatus.success,
            tokens: tokens,
            message: 'Login successful',
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onForgotPasswordOtpRequested(
    ForgotPasswordOtpRequested event,
    Emitter<RegisterState> emit,
  ) async {
    await _runSafe(
      emit,
      flow: RegisterFlow.forgotPasswordOtp,
      action: () async {
        await _sendForgotPasswordOtp(event.params);
        emit(
          state.copyWith(
            status: RegisterStatus.success,
            message: 'OTP sent to recover password',
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<RegisterState> emit,
  ) async {
    await _runSafe(
      emit,
      flow: RegisterFlow.resetPassword,
      action: () async {
        await _resetPassword(event.params);
        
        // SECURITY: Password is NOT stored in client after reset
        // Profile remains unchanged, only server has the new password
        
        emit(
          state.copyWith(
            status: RegisterStatus.success,
            message: 'Password has been reset',
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onGoogleRedirectRequested(
    GoogleRedirectRequested event,
    Emitter<RegisterState> emit,
  ) async {
    await _runSafe(
      emit,
      flow: RegisterFlow.googleRedirect,
      action: () async {
        final redirect = await _getGoogleRedirect(event.redirectUrl);
        emit(
          state.copyWith(
            status: RegisterStatus.success,
            googleRedirect: redirect,
            message: 'Google redirect received',
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onCompleteGoogleRegistration(
    CompleteGoogleRegistrationRequested event,
    Emitter<RegisterState> emit,
  ) async {
    await _runSafe(
      emit,
      flow: RegisterFlow.googleComplete,
      action: () async {
        final tokens = await _completeGoogleRegistration(event.params);
        await _persistTokens(tokens);
        
        // Profile'ni yuklab, ma'lumotlarni saqlash
        try {
          final profile = await _getProfile();
          await _cacheProfile(profile);
          
          // Google login qilganda password bo'lmaydi, lekin ma'lumotlarni saqlash
          await _authService.saveProfile(
            AuthUser(
              firstName: profile.firstName,
              lastName: profile.lastName,
              contact: profile.email ?? profile.phone ?? '',
              password: null, // Google OAuth users don't have passwords
              region: profile.regionName,
              email: profile.email,
              phone: profile.phone != null && profile.phone!.isNotEmpty
                  ? AuthService.normalizeContact(profile.phone!)
                  : null,
            ),
          );
        } catch (e) {
          // Profile yuklanmasa ham, Google'dan olingan ma'lumotlarni saqlash
          await _authService.saveProfile(
            AuthUser(
              firstName: event.params.firstName,
              lastName: event.params.lastName,
              contact: '',
              password: null, // Google OAuth users don't have passwords
              region: null,
              email: null,
              phone: null,
            ),
          );
        }
        
        emit(
          state.copyWith(
            status: RegisterStatus.success,
            tokens: tokens,
            message: 'Google registration completed',
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onProfileRequested(
    ProfileRequested event,
    Emitter<RegisterState> emit,
  ) async {
    await _runSafe(
      emit,
      flow: RegisterFlow.profileFetch,
      action: () async {
        final profile = await _getProfile();
        await _cacheProfile(profile);
        emit(
          state.copyWith(
            status: RegisterStatus.success,
            profile: profile,
            message: 'Profile loaded',
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onProfileUpdated(
    ProfileUpdated event,
    Emitter<RegisterState> emit,
  ) async {
    await _runSafe(
      emit,
      flow: RegisterFlow.profileUpdate,
      action: () async {
        final profile = await _updateProfile(event.params);
        await _cacheProfile(profile);
        emit(
          state.copyWith(
            status: RegisterStatus.success,
            profile: profile,
            message: 'Profile updated',
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onRegionChanged(
    RegionChanged event,
    Emitter<RegisterState> emit,
  ) async {
    await _runSafe(
      emit,
      flow: RegisterFlow.regionChange,
      action: () async {
        final profile = await _changeRegion(event.params);
        await _cacheProfile(profile);
        emit(
          state.copyWith(
            status: RegisterStatus.success,
            profile: profile,
            message: 'Region updated',
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onPasswordChanged(
    PasswordChanged event,
    Emitter<RegisterState> emit,
  ) async {
    await _runSafe(
      emit,
      flow: RegisterFlow.passwordChange,
      action: () async {
        await _changePassword(event.params);
        emit(
          state.copyWith(
            status: RegisterStatus.success,
            message: 'Password changed',
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onContactUpdateRequested(
    ContactUpdateRequested event,
    Emitter<RegisterState> emit,
  ) async {
    await _runSafe(
      emit,
      flow: RegisterFlow.contactUpdate,
      action: () async {
        await _updateContact(event.params);
        emit(
          state.copyWith(
            status: RegisterStatus.success,
            message: 'Contact update OTP sent',
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onContactUpdateConfirmed(
    ContactUpdateConfirmed event,
    Emitter<RegisterState> emit,
  ) async {
    await _runSafe(
      emit,
      flow: RegisterFlow.contactConfirm,
      action: () async {
        await _confirmUpdateContact(event.params);
        // After successful confirmation, refresh profile so UI sees updated email/phone.
        try {
          final profile = await _getProfile();
          await _cacheProfile(profile);
          emit(
            state.copyWith(
              status: RegisterStatus.success,
              profile: profile,
              message: 'Contact updated',
              clearError: true,
            ),
          );
          return;
        } catch (_) {
          // Ignore profile refresh errors; contact update is already done.
        }
        emit(
          state.copyWith(
            status: RegisterStatus.success,
            message: 'Contact updated',
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<RegisterState> emit,
  ) async {
    await _runSafe(
      emit,
      flow: RegisterFlow.logout,
      action: () async {
        await _logoutUser();
        await _authService.logout();
        emit(
          RegisterState.initial().copyWith(
            status: RegisterStatus.success,
            flow: RegisterFlow.logout,
            message: 'Logged out',
          ),
        );
      },
    );
  }

  Future<void> _onMessageCleared(
    RegisterMessageCleared event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(clearMessage: true, clearError: true));
  }

  Future<void> _persistTokens(AuthTokens tokens) async {
    await _authService.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
  }

  Future<void> _cacheProfile(UserProfile profile) async {
    final cachedUser = await _authService.getStoredUser();
    // SECURITY: Password is NOT stored in client
    final authUser = AuthUser(
      firstName: profile.firstName,
      lastName: profile.lastName,
      contact: profile.email ?? profile.phone ?? cachedUser?.contact ?? '',
      password: null, // Password is never stored in client
      region: profile.regionName ?? cachedUser?.region,
      email: profile.email,
      phone: profile.phone != null && profile.phone!.isNotEmpty
          ? AuthService.normalizeContact(profile.phone!)
          : null,
    );
    AppLogger.debug('📦 CACHE_PROFILE: Caching profile data');
    AppLogger.debug('📦 CACHE_PROFILE: Profile.email: ${profile.email ?? "null"}');
    AppLogger.debug('📦 CACHE_PROFILE: Profile.phone: ${profile.phone ?? "null"}');
    AppLogger.debug('📦 CACHE_PROFILE: AuthUser.email: ${authUser.email ?? "null"}');
    AppLogger.debug('📦 CACHE_PROFILE: AuthUser.phone: ${authUser.phone ?? "null"}');
    await _authService.saveProfile(authUser);
  }

  Future<void> _runSafe(
    Emitter<RegisterState> emit, {
    required RegisterFlow flow,
    required Future<void> Function() action,
  }) async {
    emit(
      state.copyWith(
        status: RegisterStatus.loading,
        flow: flow,
        clearMessage: true,
        clearError: true,
      ),
    );
    try {
      await action();
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          error: error.message,
          clearMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          error: error.toString(),
          clearMessage: true,
        ),
      );
    }
  }
}
