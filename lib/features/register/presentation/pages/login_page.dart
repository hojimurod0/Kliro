import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_input_decoration.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/navigation/app_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../../../../core/services/google/google_sign_in_service.dart';
import '../../domain/entities/google_auth_redirect.dart';
import '../../domain/params/auth_params.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_mode_toggle.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_social_button.dart';

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
  final TextEditingController _phoneOrEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final phoneOrEmail = _phoneOrEmailController.text.trim();
    final password = _passwordController.text.trim();

    if (phoneOrEmail.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth.login.snack_required'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Agar telefon rejimi bo'lsa, +998 allaqachon bor
    String contactToFormat = phoneOrEmail;
    if (_isPhoneMode && !phoneOrEmail.contains('@')) {
      // Agar +998 bilan boshlanmasa, qo'shamiz
      if (!phoneOrEmail.startsWith('+998')) {
        if (phoneOrEmail.startsWith('998')) {
          contactToFormat = '+$phoneOrEmail';
        } else {
          contactToFormat = '+998$phoneOrEmail';
        }
      }
    }

    final formattedContact = AuthService.normalizeContact(contactToFormat);

    if (formattedContact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kontakt ma'lumotini to'g'ri kiriting."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final isEmail = formattedContact.contains('@');
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

  Future<void> _handleGoogleSignIn() async {
    try {
      final googleAccount = await GoogleSignInService.instance.signIn();
      if (googleAccount == null) return;

      final email = googleAccount.email;
      if (email.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google akkaunt email topilmadi'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final redirectUrl = 'https://kliro.uz/auth/google/callback';
      context.read<RegisterBloc>().add(
        GoogleRedirectRequested(redirectUrl),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google login xatolik: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleRedirect(GoogleAuthRedirect redirect) async {
    try {
      final googleAccount = GoogleSignInService.instance.currentUser;
      if (googleAccount == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google akkaunt topilmadi'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final displayName = googleAccount.displayName ?? '';
      final nameParts = displayName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      if (redirect.sessionId != null && redirect.sessionId!.isNotEmpty) {
        if (mounted) {
          context.read<RegisterBloc>().add(
            CompleteGoogleRegistrationRequested(
              GoogleCompleteParams(
                sessionId: redirect.sessionId!,
                regionId: 1,
                firstName: firstName,
                lastName: lastName,
              ),
            ),
          );
        }
      } else {
        final url = Uri.parse(redirect.url);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google redirect xatolik: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.flow == RegisterFlow.login) {
          if (state.status == RegisterStatus.failure) {
            // Xatolik xabari
            String errorMessage = state.error ?? "Login yoki parol noto'g'ri.";
            
            // Agar xatolik "Пароль неверный" yoki shunga o'xshash bo'lsa,
            // yoki telefon raqami yoki parol noto'g'ri bo'lishi mumkin
            if (errorMessage.toLowerCase().contains('пароль') || 
                errorMessage.toLowerCase().contains('password') ||
                errorMessage.toLowerCase().contains('неверный') ||
                errorMessage.toLowerCase().contains('incorrect') ||
                errorMessage.toLowerCase().contains('invalid') ||
                errorMessage.toLowerCase().contains('noto\'g\'ri')) {
              errorMessage = "Telefon raqami yoki parol noto'g'ri.\n\n"
                  "Tekshiring:\n"
                  "• Telefon raqamini to'g'ri kiritganingizni\n"
                  "• Parolni to'g'ri kiritganingizni (katta/kichik harflar)\n"
                  "• Agar parolni unutgan bo'lsangiz, 'Parolni unutdingizmi?' tugmasidan foydalaning";
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Parolni tiklash',
                  textColor: Colors.white,
                  onPressed: () {
                    context.router.push(const LoginForgotPasswordRoute());
                  },
                ),
              ),
            );
          } else if (state.status == RegisterStatus.success) {
            context.router.replace( HomeRoute());
          }
        } else if (state.flow == RegisterFlow.googleRedirect) {
          if (state.status == RegisterStatus.success && state.googleRedirect != null) {
            _handleGoogleRedirect(state.googleRedirect!);
          } else if (state.status == RegisterStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'Google redirect xatolik'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else if (state.flow == RegisterFlow.googleComplete) {
          if (state.status == RegisterStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'Google login xatolik'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.status == RegisterStatus.success) {
            context.router.replace( HomeRoute());
          }
        }
      },
      builder: (context, state) {
        final isLoading = state.isLoading && state.flow == RegisterFlow.login;
        return Scaffold(
          backgroundColor: AppColors.white,
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
                            color: AppColors.white,
                            border: Border.all(
                              color: AppColors.grayBorder,
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
                            color: AppColors.black,
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
                                      style: TextStyle(color: AppColors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 48.w),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text('auth.login.title'.tr(), style: AppTypography.headingXL),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'auth.login.subtitle'.tr(),
                    style: AppTypography.bodyPrimary,
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
                            LengthLimitingTextInputFormatter(9), // Faqat 9 ta raqam
                          ]
                        : null,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.black,
                    ),
                    decoration: AppInputDecoration.outline(
                      hint: _isPhoneMode
                          ? '_____'
                          : 'auth.field.email_hint'.tr(),
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
                                    style: TextStyle(
                                      color: AppColors.grayText,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : null,
                      prefixIcon: _isPhoneMode
                          ? null
                          : Icons.email_outlined,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  _buildLabel('auth.field.password_label'.tr()),
                  SizedBox(height: AppSpacing.xs),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: AppInputDecoration.outline(
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.router.push(const LoginForgotPasswordRoute());
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'auth.login.forgot'.tr(),
                        style: AppTypography.buttonLink.copyWith(
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
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
                        style: AppTypography.bodySecondary,
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
                          style: AppTypography.buttonLink,
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
      child: Text(text, style: AppTypography.labelSmall),
    );
  }
}

