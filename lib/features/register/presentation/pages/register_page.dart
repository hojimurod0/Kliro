import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
import '../widgets/common_back_button.dart';

@RoutePage()
class RegisterPage extends StatefulWidget implements AutoRouteWrapper {
  const RegisterPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceLocator.resolve<RegisterBloc>(),
      child: this,
    );
  }

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isPhoneMode = true;
  final TextEditingController _phoneOrEmailController = TextEditingController();
  String? _lastContact;

  @override
  void dispose() {
    _phoneOrEmailController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {Color background = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: background,
      ),
    );
  }

  void _submit() {
    final bloc = context.read<RegisterBloc>();
    final phoneOrEmail = _phoneOrEmailController.text.trim();

    if (phoneOrEmail.isEmpty) {
      _showSnackBar('auth.register.snack_contact'.tr());
      return;
    }

    // Agar telefon rejimi bo'lsa va faqat raqam kiritilgan bo'lsa, +998 qo'shamiz
    String contactToFormat = phoneOrEmail;
    if (isPhoneMode && !phoneOrEmail.contains('@')) {
      // Agar +998 bilan boshlanmasa, qo'shamiz
      if (!phoneOrEmail.startsWith('+998') && !phoneOrEmail.startsWith('998')) {
        contactToFormat = '+998$phoneOrEmail';
      } else if (phoneOrEmail.startsWith('998')) {
        contactToFormat = '+$phoneOrEmail';
      }
    }

    final formattedContact = AuthService.normalizeContact(contactToFormat);
    if (formattedContact.isEmpty) {
      _showSnackBar('auth.register.snack_contact'.tr());
      return;
    }

    final params = SendOtpParams(
      email: formattedContact.contains('@') ? formattedContact : null,
      phone: formattedContact.contains('@') ? null : formattedContact,
    );

    setState(() => _lastContact = formattedContact);
    bloc.add(SendRegisterOtpRequested(params));
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final googleAccount = await GoogleSignInService.instance.signIn();
      if (googleAccount == null) return;

      final email = googleAccount.email;
      if (email.isEmpty) {
        _showSnackBar('Google akkaunt email topilmadi');
        return;
      }

      final redirectUrl = 'https://kliro.uz/auth/google/callback';
      context.read<RegisterBloc>().add(
        GoogleRedirectRequested(redirectUrl),
      );
    } catch (e) {
      _showSnackBar('Google login xatolik: ${e.toString()}');
    }
  }

  Future<void> _handleGoogleRedirect(GoogleAuthRedirect redirect) async {
    try {
      final googleAccount = GoogleSignInService.instance.currentUser;
      if (googleAccount == null) {
        _showSnackBar('Google akkaunt topilmadi');
        return;
      }

      final displayName = googleAccount.displayName ?? '';
      final nameParts = displayName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      if (redirect.sessionId != null && redirect.sessionId!.isNotEmpty) {
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
      } else {
        final url = Uri.parse(redirect.url);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      _showSnackBar('Google redirect xatolik: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.flow == RegisterFlow.registerSendOtp) {
          if (state.status == RegisterStatus.failure && state.error != null) {
            _showSnackBar(state.error!);
          } else if (state.status == RegisterStatus.success) {
            final contact = _lastContact;
            if (contact != null) {
              _showSnackBar(
                state.message ?? 'OTP yuborildi',
                background: Colors.green,
              );
              context.router.push(
                RegisterVerificationRoute(contactInfo: contact),
              );
              context.read<RegisterBloc>().add(const RegisterMessageCleared());
            }
          }
        } else if (state.flow == RegisterFlow.googleRedirect) {
          if (state.status == RegisterStatus.success && state.googleRedirect != null) {
            _handleGoogleRedirect(state.googleRedirect!);
          } else if (state.status == RegisterStatus.failure) {
            _showSnackBar(state.error ?? 'Google redirect xatolik');
          }
        } else if (state.flow == RegisterFlow.googleComplete) {
          if (state.status == RegisterStatus.failure) {
            _showSnackBar(state.error ?? 'Google registration xatolik');
          } else if (state.status == RegisterStatus.success) {
            context.router.replace(HomeRoute());
          }
        }
      },
      builder: (context, state) {
        final isLoading = state.isLoading &&
            state.flow == RegisterFlow.registerSendOtp;
        return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.sm),
              const CommonBackButton(),
              SizedBox(height: AppSpacing.lg),
              Text('auth.register.title'.tr(), style: AppTypography.headingXL),
              SizedBox(height: AppSpacing.xs),
              Text(
                'auth.register.subtitle'.tr(),
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
                isFirstSelected: isPhoneMode,
                onChanged: (value) {
                  setState(() {
                    isPhoneMode = value;
                    _phoneOrEmailController.clear();
                  });
                },
              ),
              SizedBox(height: AppSpacing.lg),
              Padding(
                padding: EdgeInsets.only(left: 2.w),
                child: Text(
                  isPhoneMode
                      ? 'auth.field.phone_label'.tr()
                      : 'auth.field.email_label'.tr(),
                  style: AppTypography.labelSmall,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _phoneOrEmailController,
                keyboardType: isPhoneMode
                    ? TextInputType.phone
                    : TextInputType.emailAddress,
                inputFormatters: isPhoneMode
                    ? [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9), // Faqat 9 ta raqam (+998 dan keyin)
                      ]
                    : null,
                decoration: AppInputDecoration.outline(
                  hint: isPhoneMode
                      ? '901234567'
                      : 'auth.field.email_hint'.tr(),
                  prefix: isPhoneMode
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
                                  color: AppColors.black,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                  prefixIcon: isPhoneMode ? null : Icons.email_outlined,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              AuthPrimaryButton(
                label: 'auth.common.cta'.tr(),
                onPressed: _submit,
                isLoading: isLoading,
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
              SizedBox(height: AppSpacing.lg),
              Center(
                child: GestureDetector(
                  onTap: () {
                    context.router.maybePop();
                  },
                  child: RichText(
                    text: TextSpan(
                      style: AppTypography.bodySecondary,
                      children: [
                        TextSpan(text: 'auth.register.have_account'.tr()),
                        TextSpan(
                          text: 'auth.register.login'.tr(),
                          style: AppTypography.buttonLink,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
        );
      },
    );
  }
}
