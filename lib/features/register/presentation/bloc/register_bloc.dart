import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/auth/auth_service.dart';
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
        await _authService.saveProfile(
          AuthUser(
            firstName: event.params.firstName,
            lastName: event.params.lastName,
            contact: event.params.email ?? event.params.phone ?? '',
            password: event.params.password,
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
        final tokens = await _loginUser(event.params);
        await _persistTokens(tokens);
        
        // Profile'ni yuklab, ma'lumotlarni saqlash
        try {
          final profile = await _getProfile();
          await _cacheProfile(profile);
          
          // Password'ni saqlash (login qilganda)
          final contact = event.params.email ?? event.params.phone ?? '';
          final cachedUser = await _authService.getStoredUser();
          await _authService.saveProfile(
            AuthUser(
              firstName: profile.firstName,
              lastName: profile.lastName,
              contact: profile.email ?? profile.phone ?? contact,
              password: event.params.password,
              region: profile.regionName ?? cachedUser?.region,
            ),
          );
        } catch (e) {
          // Profile yuklanmasa ham, mavjud ma'lumotlarni saqlash
          final contact = event.params.email ?? event.params.phone ?? '';
          final cachedUser = await _authService.getStoredUser();
          
          // Agar cachedUser mavjud bo'lsa va uning ismi bo'lsa, uni saqlash
          if (cachedUser != null && 
              cachedUser.firstName.isNotEmpty && 
              cachedUser.lastName.isNotEmpty) {
            await _authService.saveProfile(
              AuthUser(
                firstName: cachedUser.firstName,
                lastName: cachedUser.lastName,
                contact: contact.isNotEmpty ? contact : cachedUser.contact,
                password: event.params.password,
                region: cachedUser.region,
              ),
            );
          } else {
            // Agar ism yo'q bo'lsa, faqat contact va password'ni saqlash
            // Keyinroq profile yuklanganda ism qo'shiladi
            await _authService.saveProfile(
              AuthUser(
                firstName: '',
                lastName: '',
                contact: contact,
                password: event.params.password,
                region: cachedUser?.region,
              ),
            );
            
            // Profile'ni keyinroq yuklashga harakat qilish
            try {
              final profile = await _getProfile();
              await _cacheProfile(profile);
              await _authService.saveProfile(
                AuthUser(
                  firstName: profile.firstName,
                  lastName: profile.lastName,
                  contact: profile.email ?? profile.phone ?? contact,
                  password: event.params.password,
                  region: profile.regionName ?? cachedUser?.region,
                ),
              );
            } catch (_) {
              // Ikkinchi marta ham yuklanmasa, xatolikni e'tiborsiz qoldirish
            }
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
        
        // Password o'zgargandan keyin, yangi password'ni saqlash
        final contact = event.params.email ?? event.params.phone ?? '';
        final cachedUser = await _authService.getStoredUser();
        if (cachedUser != null) {
          await _authService.saveProfile(
            AuthUser(
              firstName: cachedUser.firstName,
              lastName: cachedUser.lastName,
              contact: contact.isNotEmpty ? contact : cachedUser.contact,
              password: event.params.password,
              region: cachedUser.region,
            ),
          );
        }
        
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
              password: '', // Google login uchun password bo'lmaydi
              region: profile.regionName,
            ),
          );
        } catch (e) {
          // Profile yuklanmasa ham, Google'dan olingan ma'lumotlarni saqlash
          await _authService.saveProfile(
            AuthUser(
              firstName: event.params.firstName,
              lastName: event.params.lastName,
              contact: '',
              password: '', // Google login uchun password bo'lmaydi
              region: null,
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
    await _authService.saveProfile(
      AuthUser(
        firstName: profile.firstName,
        lastName: profile.lastName,
        contact: profile.email ?? profile.phone ?? cachedUser?.contact ?? '',
        password: cachedUser?.password ?? '',
        region: profile.regionName ?? cachedUser?.region,
      ),
    );
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
