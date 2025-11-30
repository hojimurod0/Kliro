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
import '../../../../core/services/auth/auth_service.dart';
import '../../domain/params/auth_params.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';
import '../widgets/auth_mode_toggle.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/common_back_button.dart';

@RoutePage()
class LoginForgotPasswordPage extends StatefulWidget implements AutoRouteWrapper {
  const LoginForgotPasswordPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceLocator.resolve<RegisterBloc>(),
      child: this,
    );
  }

  @override
  State<LoginForgotPasswordPage> createState() => _LoginForgotPasswordPageState();
}

class _LoginForgotPasswordPageState extends State<LoginForgotPasswordPage> {
  // Hozir qaysi tab tanlanganini bilish uchun o'zgaruvchi
  bool isEmailMode = true;
  final TextEditingController _emailOrPhoneController = TextEditingController();

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.flow != RegisterFlow.forgotPasswordOtp) return;

        if (state.status == RegisterStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? tr('common.error_occurred_simple')),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state.status == RegisterStatus.success) {
          final emailOrPhone = _emailOrPhoneController.text.trim();
          String contactInfo = emailOrPhone;
          if (!isEmailMode) {
            contactInfo = AuthService.normalizeContact(emailOrPhone);
          }
          context.router.push(
            LoginResetPasswordRoute(contactInfo: contactInfo),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.isLoading &&
            state.flow == RegisterFlow.forgotPasswordOtp;
        return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.sm),
              // 1. Orqaga tugmasi
              const CommonBackButton(),
              SizedBox(height: AppSpacing.lg),
              
              // 2. Sarlavha
              Text(
                'auth.forgot.title'.tr(),
                style: AppTypography.headingXL,
              ),
              SizedBox(height: AppSpacing.xs),
              
              // 3. Izoh matni
              Text(
                'auth.forgot.subtitle'.tr(),
                style: AppTypography.bodyPrimary,
              ),
              
              SizedBox(height: AppSpacing.lg),
              // 4. Custom Tab Switcher (Email / Telefon)
              AuthModeToggle(
                first: AuthModeOption(
                  label: 'auth.tab.email'.tr(),
                  icon: Icons.email_outlined,
                  activeColor: AppColors.primaryBlue,
                ),
                second: AuthModeOption(
                  label: 'auth.tab.phone'.tr(),
                  icon: Icons.phone,
                  gradient: AppColors.phoneGradient,
                ),
                isFirstSelected: isEmailMode,
                onChanged: (value) => setState(() => isEmailMode = value),
              ),
              SizedBox(height: AppSpacing.lg),
              // 5. Input Label (Sarlavha)
              Padding(
                padding: EdgeInsets.only(left: 2.w),
                child: Text(
                  isEmailMode
                      ? 'auth.field.email_label'.tr()
                      : 'auth.field.phone_label'.tr(),
                  style: AppTypography.labelSmall,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              // 6. Input Field (Kiritish maydoni)
              TextFormField(
                controller: _emailOrPhoneController,
                keyboardType: isEmailMode 
                    ? TextInputType.emailAddress 
                    : TextInputType.phone,
                inputFormatters: !isEmailMode
                    ? [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(12),
                      ]
                    : null,
                decoration: AppInputDecoration.outline(
                  hint: isEmailMode
                      ? 'auth.field.email_hint'.tr()
                      : 'auth.field.phone_hint'.tr(),
                  prefixIcon: isEmailMode ? Icons.email_outlined : Icons.phone,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              // 7. Asosiy Tugma (Kodni yuborish)
              AuthPrimaryButton(
                label: 'auth.forgot.cta'.tr(),
                isLoading: isLoading,
                onPressed: () {
                  final emailOrPhone = _emailOrPhoneController.text.trim();
                  if (emailOrPhone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('auth.forgot.snack_contact'.tr()),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  String contactInfo = emailOrPhone;
                  if (!isEmailMode) {
                    contactInfo = AuthService.normalizeContact(emailOrPhone);
                  }

                  final isEmail = contactInfo.contains('@');
                  context.read<RegisterBloc>().add(
                    ForgotPasswordOtpRequested(
                      ForgotPasswordParams(
                        email: isEmail ? contactInfo : null,
                        phone: isEmail ? null : contactInfo,
                      ),
                    ),
                  );
                },
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
}

