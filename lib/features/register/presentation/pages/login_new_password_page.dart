import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../../domain/params/auth_params.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/common_back_button.dart';

@RoutePage()
class LoginNewPasswordPage extends StatefulWidget implements AutoRouteWrapper {
  final String contactInfo;
  final String otp;

  const LoginNewPasswordPage({
    super.key,
    required this.contactInfo,
    required this.otp,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceLocator.resolve<RegisterBloc>(),
      child: this,
    );
  }

  @override
  State<LoginNewPasswordPage> createState() => _LoginNewPasswordPageState();
}

class _LoginNewPasswordPageState extends State<LoginNewPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {Color background = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: background,
      ),
    );
  }

  void _submit() {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      _showSnack('auth.user_details.snack_password'.tr());
      return;
    }

    if (password != confirmPassword) {
      _showSnack('auth.user_details.snack_password_match'.tr());
      return;
    }

    final normalizedContact = AuthService.normalizeContact(widget.contactInfo);
    if (normalizedContact.isEmpty) {
      _showSnack("Kontakt ma'lumotini to'g'ri kiriting.");
      return;
    }

    final isEmail = normalizedContact.contains('@');
    context.read<RegisterBloc>().add(
          ResetPasswordRequested(
            ResetPasswordParams(
              email: isEmail ? normalizedContact : null,
              phone: isEmail ? null : normalizedContact,
              otp: widget.otp,
              password: password,
              confirmPassword: confirmPassword,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.flow != RegisterFlow.resetPassword) return;

        if (state.status == RegisterStatus.success) {
          _showSnack(
            state.message ?? 'auth.reset_password.success'.tr(),
            background: Colors.green,
          );
          context.router.replaceAll([const LoginRoute()]);
        } else if (state.status == RegisterStatus.failure) {
          _showSnack(state.error ?? 'Xatolik yuz berdi');
        }
      },
      builder: (context, state) {
        final isLoading =
            state.isLoading && state.flow == RegisterFlow.resetPassword;
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
                  SizedBox(height: AppSpacing.xl),
                  Text(
                    'auth.reset_password.title'.tr(),
                    style: AppTypography.headingXL,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'auth.reset_password.subtitle'.tr(),
                    style: AppTypography.bodyPrimary,
                  ),
                  SizedBox(height: AppSpacing.xxl),
                  Text(
                    'auth.field.password_label'.tr(),
                    style: AppTypography.labelSmall,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'auth.field.password_hint'.tr(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'auth.field.confirm_password_label'.tr(),
                    style: AppTypography.labelSmall,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'auth.field.confirm_password_hint'.tr(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxl),
                  AuthPrimaryButton(
                    label: 'auth.reset_password.submit'.tr(),
                    onPressed: _submit,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

