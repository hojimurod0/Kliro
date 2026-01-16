import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_input_decoration.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/utils/snackbar_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../../../profile/presentation/widgets/language_modal.dart';
import '../../domain/params/auth_params.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_mode_toggle.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_social_button.dart';
import 'google_oauth_webview_page.dart';

@RoutePage()
class LoginPage extends StatefulWidget implements AutoRouteWrapper {
  const LoginPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceLocator.resolve<RegisterBloc>(),
      child: this,
    );
  }

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  bool _isPhoneMode = true;
  bool _agreedToTermsAndPrivacy = false;
  final TextEditingController _phoneOrEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _lastContactForOtp;
  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Locale o'zgarganda sahifani yangilash
    final currentLocale = context.locale;
    if (_currentLocale != currentLocale) {
      _currentLocale = currentLocale;
      // Locale o'zgarganda sahifani yangilash
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _phoneOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _formatContact(String contact) {
    // Agar telefon rejimi bo'lsa, +998 allaqachon bor
    String contactToFormat = contact;
    if (_isPhoneMode && !contact.contains('@')) {
      // Agar +998 bilan boshlanmasa, qo'shamiz
      if (!contact.startsWith('+998')) {
        if (contact.startsWith('998')) {
          contactToFormat = '+$contact';
        } else {
          contactToFormat = '+998$contact';
        }
      }
    }
    return AuthService.normalizeContact(contactToFormat);
  }

  void _handleLogin() {
    final phoneOrEmail = _phoneOrEmailController.text.trim();
    final password = _passwordController.text.trim();

    if (phoneOrEmail.isEmpty || password.isEmpty) {
      SnackbarHelper.showError(context, 'auth.login.snack_required'.tr());
      return;
    }

    // Rozilik tekshiruvi
    if (!_agreedToTermsAndPrivacy) {
      SnackbarHelper.showError(
        context,
        'auth.login.agree_to_terms_required'.tr(),
      );
      return;
    }

    final formattedContact = _formatContact(phoneOrEmail);

    if (formattedContact.isEmpty) {
      SnackbarHelper.showError(
        context,
        _isPhoneMode
            ? "auth.login.error_phone_format".tr()
            : 'auth.login.snack_contact_invalid'.tr(),
      );
      return;
    }

    final isEmail = formattedContact.contains('@');

    // Password complexity check
    final hasLetters = password.contains(RegExp(r'[a-zA-Z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));

    if (!hasLetters || !hasDigits) {
      SnackbarHelper.showError(
          context, 'auth.login.error_password_complexity'.tr());
      return;
    }

    context.read<RegisterBloc>().add(
          LoginRequested(
            LoginParams(
              email: isEmail ? formattedContact : null,
              phone: isEmail ? null : formattedContact,
              password: password,
            ),
          ),
        );
  }

  void _handleLoginOtp() {
    final phoneOrEmail = _phoneOrEmailController.text.trim();

    if (phoneOrEmail.isEmpty) {
      SnackbarHelper.showError(
          context, 'auth.login.snack_contact_required'.tr());
      return;
    }

    final formattedContact = _formatContact(phoneOrEmail);

    if (formattedContact.isEmpty) {
      SnackbarHelper.showError(
        context,
        _isPhoneMode
            ? "auth.login.error_phone_format".tr()
            : 'auth.login.snack_contact_invalid'.tr(),
      );
      return;
    }

    _lastContactForOtp = formattedContact;
    final isEmail = formattedContact.contains('@');

    // MOCK: Hozircha login OTP backendda yo'q, shuning uchun Register OTP ishlatyapmiz
    // Yoki shunchaki Verification pagega o'tkazamiz (u yerda resend qiladi)
    // Lekin user tajribasi uchun, avval yuborib keyin o'tgan yaxshi.
    context.read<RegisterBloc>().add(
          SendRegisterOtpRequested(
            SendOtpParams(
              email: isEmail ? formattedContact : null,
              phone: isEmail ? null : formattedContact,
            ),
          ),
        );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      // Backend API orqali Google OAuth URL ni olish
      context.read<RegisterBloc>().add(
            GoogleRedirectRequested(ApiPaths.googleOAuthRedirectUrl),
          );
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          'Google sign-in xatolik: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _openExternalDocument(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          SnackbarHelper.showError(context, 'auth.terms.cannot_open'.tr());
        }
      }
    } catch (_) {
      if (mounted) {
        SnackbarHelper.showError(context, 'auth.terms.error'.tr());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.flow == RegisterFlow.login) {
          if (state.status == RegisterStatus.failure) {
            final rawError = state.error ?? '';

            // API'dan kelgan error message'ni parse qilish va tanlangan tilda ko'rsatish
            String errorMessage;
            final errorLower = rawError.toLowerCase().trim();

            // User topilmadi xatosi - backend'dan kelgan xatoni to'g'ridan-to'g'ri ko'rsatish
            // chunki u allaqachon tushunarli va to'g'ri tilda
            if (errorLower.contains('пользователь не найден') ||
                errorLower.contains('пользователя не найден') ||
                errorLower.contains('user not found') ||
                errorLower.contains('foydalanuvchi topilmadi') ||
                errorLower.contains('user topilmadi') ||
                errorLower.contains('не найден')) {
              // Backend'dan kelgan xatoni to'g'ridan-to'g'ri ko'rsatish
              errorMessage = rawError;
            }
            // Parol xatosi - API'dan kelgan error'ni detect qilish
            else if (errorLower.contains('пароль') ||
                errorLower.contains('password') ||
                errorLower.contains('неверный') ||
                errorLower.contains('неверен') ||
                (errorLower.contains('невер') &&
                    errorLower.contains('парол')) ||
                (errorLower.contains('parol') &&
                    (errorLower.contains('noto\'g\'ri') ||
                        errorLower.contains('xato'))) ||
                errorLower == 'пароль неверный' ||
                errorLower == 'password incorrect') {
              // Tanlangan tilda ko'rsatish
              errorMessage = 'auth.login.error_password_incorrect'.tr();
            }
            // Telefon formati xatosi
            else if (errorLower.contains('телефон') ||
                errorLower.contains('phone') ||
                errorLower.contains('формат') ||
                errorLower.contains('format') ||
                errorLower.contains('контакт') ||
                errorLower.contains('contact') ||
                (errorLower.contains('telefon') &&
                    (errorLower.contains('formati') ||
                        errorLower.contains('noto\'g\'ri')))) {
              // Tanlangan tilda ko'rsatish
              errorMessage = 'auth.login.error_phone_format'.tr();
            }
            // Boshqa xatolar
            else {
              // Tanlangan tilda ko'rsatish
              // Agar backend'dan kelgan xato boshqa tilda bo'lsa, uni to'g'ridan-to'g'ri ko'rsatamiz
              errorMessage = rawError.isNotEmpty
                  ? rawError
                  : 'auth.login.error_credentials_detail'.tr();
            }

            SnackbarHelper.showError(
              context,
              errorMessage,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'auth.login.forgot'.tr(),
                textColor: Theme.of(context).colorScheme.onPrimary,
                onPressed: () {
                  context.router.push(const LoginForgotPasswordRoute());
                },
              ),
            );
          } else if (state.status == RegisterStatus.success) {
            context.router.replace(HomeRoute());
          }
        } else if (state.flow == RegisterFlow.registerSendOtp) {
          // OTP yuborilganda tekshiruvga o'tish (Login with OTP)
          if (state.status == RegisterStatus.success) {
            final contact = _lastContactForOtp;
            if (contact != null) {
              context.read<RegisterBloc>().add(const RegisterMessageCleared());
              context.router.push(LoginVerificationRoute(phoneNumber: contact));
            }
          } else if (state.status == RegisterStatus.failure) {
            // Agar ro'yxatdan o'tgan bo'lsa (User exist), demak OTP yuborilmadi (RegisterSendOtp API xususiyati).
            // Lekin biz Login qilmoqchimiz.
            // Bunday holda, baribir Verification pagega o'tkazib, u yerda resend qilamiz
            // yoki "User already exists" xatosi bo'lsa, davom ettiramiz.
            final error = state.error ?? '';
            // "user already exists" yoki shunga o'xshash xatolar
            // Agar backendda "Send Register OTP" mavjud userga fail bersa:
            // Biz "Forgot Password" orqali yuborishimiz mumkin emas (chunki u parolni o'zgartirishni talab qiladi)
            // Hozircha xatoni chiqarib, sahifaga o'tkazib yuboramiz (Mock flow)
            if (error.isNotEmpty) {
              // Xatoni chiqaramiz
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );

              // Agar xato bo'lsa ham, verificationga o'tamiz (balki user kodni biladi? Yo'q, kod bormaydi).
              // Bu yerda backend cheklovini aylanib o'tolmaymiz.
            }
          }
        } else if (state.flow == RegisterFlow.googleRedirect) {
          // Google OAuth redirect URL olingan
          if (state.status == RegisterStatus.success &&
              state.googleRedirect != null) {
            if (mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GoogleOAuthWebViewPage(
                    initialUrl: state.googleRedirect!.url,
                  ),
                ),
              );
            }
          } else if (state.status == RegisterStatus.failure) {
            SnackbarHelper.showError(
              context,
              state.error ?? 'Google sign-in xatolik',
            );
          }
        } else if (state.flow == RegisterFlow.googleComplete) {
          if (state.status == RegisterStatus.failure) {
            SnackbarHelper.showError(
              context,
              state.error ?? 'Google login xatolik',
            );
          } else if (state.status == RegisterStatus.success) {
            context.router.replace(HomeRoute());
          }
        }
      },
      builder: (context, state) {
        final topPadding = MediaQuery.of(context).padding.top;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final isLoading = state.isLoading &&
            (state.flow == RegisterFlow.login ||
                state.flow == RegisterFlow.registerSendOtp);
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            top: false,
            bottom: true,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppSpacing.screenPadding.left,
                right: AppSpacing.screenPadding.right,
                top: topPadding + AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.router.maybePop(),
                        child: Container(
                          width: 48.w,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color:
                                isDark ? AppColors.darkCardBg : AppColors.white,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.grayBorder,
                              width: 1.w,
                            ),
                            borderRadius: BorderRadius.circular(15.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.05),
                                spreadRadius: 1.r,
                                blurRadius: 5.r,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: isDark ? AppColors.white : AppColors.black,
                            size: 22.sp,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            height: 32.h,
                            child: SvgPicture.asset(
                              'assets/images/klero_logo.svg',
                              fit: BoxFit.contain,
                              placeholderBuilder: (context) => RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "K",
                                      style: TextStyle(
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "LiRO",
                                      style: TextStyle(
                                          color: isDark
                                              ? AppColors.white
                                              : AppColors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await showLanguageModal(context);
                          // Til o'zgarganda sahifani yangilash
                          // Locale o'zgarishini didChangeDependencies avtomatik kuzatadi
                        },
                        child: Container(
                          width: 48.w,
                          height: 48.h,
                          decoration: BoxDecoration(
                            color:
                                isDark ? AppColors.darkCardBg : AppColors.white,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.grayBorder,
                              width: 1.w,
                            ),
                            borderRadius: BorderRadius.circular(15.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.05),
                                spreadRadius: 1.r,
                                blurRadius: 5.r,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.language,
                            color: isDark ? AppColors.white : AppColors.black,
                            size: 22.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text('auth.login.title'.tr(),
                      style: AppTypography.headingXL(context)),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'auth.login.subtitle'.tr(),
                    style: AppTypography.bodyPrimary(context),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  AuthModeToggle(
                    first: AuthModeOption(
                      label: 'auth.tab.phone'.tr(),
                      icon: Icons.phone,
                      gradient: AppColors.phoneGradient,
                    ),
                    second: AuthModeOption(
                      label: 'auth.tab.email'.tr(),
                      icon: Icons.email_outlined,
                      gradient: AppColors.phoneGradient,
                    ),
                    isFirstSelected: _isPhoneMode,
                    onChanged: (value) {
                      setState(() {
                        _isPhoneMode = value;
                        _phoneOrEmailController.clear();
                      });
                    },
                  ),
                  SizedBox(height: AppSpacing.lg),
                  _buildLabel(
                    _isPhoneMode
                        ? 'auth.field.phone_label'.tr()
                        : 'auth.field.email_label'.tr(),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    controller: _phoneOrEmailController,
                    keyboardType: _isPhoneMode
                        ? TextInputType.phone
                        : TextInputType.emailAddress,
                    inputFormatters: _isPhoneMode
                        ? [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(
                                9), // Faqat 9 ta raqam
                          ]
                        : null,
                    maxLength: _isPhoneMode ? 9 : null,
                    buildCounter: (context,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                    style: AppTypography.bodyLarge(context),
                    decoration: AppInputDecoration.outline(
                      fillColor:
                          isDark ? AppColors.darkCardBg : AppColors.white,
                      borderColor: isDark ? AppColors.darkBorder : null,
                      hintColor: isDark ? AppColors.grayText : null,
                      prefixIconColor: isDark ? AppColors.grayText : null,
                      hint:
                          _isPhoneMode ? '_____' : 'auth.field.email_hint'.tr(),
                      prefix: _isPhoneMode
                          ? Padding(
                              padding: EdgeInsets.only(left: 16.w, right: 8.w),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color: AppColors.primaryBlue,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    '+998',
                                    style: AppTypography.bodyLarge(context),
                                  ),
                                ],
                              ),
                            )
                          : null,
                      prefixIcon: _isPhoneMode ? null : Icons.email_outlined,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  _buildLabel('auth.field.password_label'.tr()),
                  SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    style: AppTypography.bodyLarge(context),
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: AppInputDecoration.outline(
                      fillColor:
                          isDark ? AppColors.darkCardBg : AppColors.white,
                      borderColor: isDark ? AppColors.darkBorder : null,
                      hintColor: isDark ? AppColors.grayText : null,
                      prefixIconColor: isDark ? AppColors.grayText : null,
                      hint: 'auth.field.password_hint'.tr(),
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.remove_red_eye_outlined,
                          color: AppColors.grayText,
                          size: 18.sp,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _handleLoginOtp,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            "auth.login.login_with_otp".tr(),
                            style: AppTypography.buttonLink(context).copyWith(
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.router
                                .push(const LoginForgotPasswordRoute());
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'auth.login.forgot'.tr(),
                            style: AppTypography.buttonLink(context).copyWith(
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  // Rozilik checkboxlari
                  _buildAgreementCheckboxes(context, isDark),
                  SizedBox(height: AppSpacing.md),
                  AuthDivider(text: 'auth.common.divider'.tr()),
                  SizedBox(height: AppSpacing.md),
                  AuthSocialButton(
                    label: 'auth.common.google'.tr(),
                    iconUrl:
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png',
                    onPressed: _handleGoogleSignIn,
                  ),
                  SizedBox(height: AppSpacing.md),
                  AuthPrimaryButton(
                    label: 'auth.common.cta'.tr(),
                    onPressed: _handleLogin,
                    isLoading: isLoading,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'auth.login.no_account'.tr(),
                        style: AppTypography.bodySecondary(context),
                      ),
                      TextButton(
                        onPressed: () {
                          context.router.push(const RegisterRoute());
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'auth.login.register'.tr(),
                          style: AppTypography.buttonLink(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: Text(text, style: AppTypography.labelSmall(context)),
    );
  }

  Widget _buildAgreementCheckboxes(BuildContext context, bool isDark) {
    const documentUrl =
        'https://docs.google.com/document/d/1UcdZv5QTRs2AheZlvroe0d86Dk2oILYB4R41Rp2pocE/view';

    final baseStyle = AppTypography.bodySecondary(context).copyWith(
      fontSize: 12.sp,
    );

    final linkStyle = baseStyle.copyWith(
      color: AppColors.primaryBlue,
      decoration: TextDecoration.underline,
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: baseStyle,
                children: [
                  TextSpan(
                    text: 'auth.login.agree_to_terms_and_privacy_prefix'.tr(),
                  ),
                  TextSpan(
                    text: 'auth.login.agree_to_terms_and_privacy_link'.tr(),
                    style: linkStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _openExternalDocument(documentUrl),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Checkbox(
            value: _agreedToTermsAndPrivacy,
            onChanged: (value) {
              setState(() {
                _agreedToTermsAndPrivacy = value ?? false;
              });
            },
            activeColor: AppColors.primaryBlue,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
