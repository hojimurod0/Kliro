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
import '../../../../core/utils/snackbar_helper.dart';
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

  // Validatsiya uchun
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _submitted = false; // Xatolikni faqat knopka bosilganda ko'rsatish uchun

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {Color background = Colors.red}) {
    if (background == Colors.green) {
      SnackbarHelper.showSuccess(context, message);
    } else {
      SnackbarHelper.showError(context, message);
    }
  }

  void _submit() {
    setState(() => _submitted = true);

    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // 1. Bo'shlikka tekshirish
    if (password.isEmpty) {
      _showSnack('auth.user_details.snack_password'.tr()); // "Parol kiriting"
      return;
    }

    // 2. Parol uzunligini tekshirish (Masalan, kamida 6 ta belgi)
    if (password.length < 6) {
      _showSnack("Parol kamida 6 ta belgidan iborat bo'lishi kerak");
      return;
    }

    // 3. Parollar mosligini tekshirish
    if (password != confirmPassword) {
      _showSnack(
        'auth.user_details.snack_password_match'.tr(),
      ); // "Parollar mos kelmadi"
      return;
    }

    final normalizedContact = AuthService.normalizeContact(widget.contactInfo);
    if (normalizedContact.isEmpty) {
      _showSnack("Kontakt ma'lumotini to'g'ri kiriting.");
      return;
    }

    final isEmail = normalizedContact.contains('@');

    // So'rov yuborish
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.flow != RegisterFlow.resetPassword) return;

        if (state.status == RegisterStatus.success) {
          _showSnack(
            state.message ?? 'auth.reset_password.success'.tr(),
            background: Colors.green,
          );
          // Login sahifasiga to'liq o'tish (Stackni tozalab)
          context.router.replaceAll([const LoginRoute()]);
        } else if (state.status == RegisterStatus.failure) {
          // Backenddan kelgan xatolikni ko'rsatish
          // Agar backend ruscha yuborsa, bu yerda o'zgartira olmaymiz,
          // lekin null bo'lsa standart xabar chiqaramiz.
          _showSnack(state.error ?? tr('common.error_occurred_simple'));
        }
      },
      builder: (context, state) {
        final isLoading =
            state.isLoading && state.flow == RegisterFlow.resetPassword;

        return Scaffold(
          // Dark Mode fix: Dynamic background
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.sm),
                  const CommonBackButton(),
                  SizedBox(height: AppSpacing.xl),

                  // Sarlavha
                  Text(
                    'auth.reset_password.title'.tr(),
                    style: AppTypography.headingXL.copyWith(
                      color: isDark ? AppColors.white : AppColors.black,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),

                  // Izoh
                  Text(
                    'auth.reset_password.subtitle'.tr(),
                    style: AppTypography.bodyPrimary,
                  ),

                  SizedBox(height: AppSpacing.xxl),

                  // 1. Parol Input Label
                  Text(
                    'auth.field.password_label'.tr(),
                    style: AppTypography.labelSmall,
                  ),
                  SizedBox(height: AppSpacing.xs),

                  // 1. Parol Input Field
                  _buildPasswordField(
                    controller: _passwordController,
                    hintText: 'auth.field.password_hint'.tr(),
                    isVisible: _isPasswordVisible,
                    onVisibilityChanged: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                    },
                  ),

                  SizedBox(height: AppSpacing.lg),

                  // 2. Parolni tasdiqlash Input Label
                  Text(
                    'auth.field.confirm_password_label'.tr(),
                    style: AppTypography.labelSmall,
                  ),
                  SizedBox(height: AppSpacing.xs),

                  // 2. Parolni tasdiqlash Input Field
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    hintText: 'auth.field.confirm_password_hint'.tr(),
                    isVisible: _isConfirmPasswordVisible,
                    onVisibilityChanged: () {
                      setState(
                        () => _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible,
                      );
                    },
                    isConfirm:
                        true, // Qizil border logikasi uchun (agar hohlasangiz)
                  ),

                  SizedBox(height: AppSpacing.xxl),

                  // Asosiy tugma
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

  // Qayta ishlatiluvchi Widget (Clean Code)
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onVisibilityChanged,
    bool isConfirm = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      // --- DARK MODE FIX START ---
      style: TextStyle(
        color: isDark ? AppColors.white : Colors.black,
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: AppColors.primaryBlue,

      // --- DARK MODE FIX END ---
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.grayText.withOpacity(0.6),
          fontSize: 14.sp,
        ),

        // Orqa fon (Kulrang)
        filled: true,
        fillColor: isDark ? AppColors.darkCardBg : AppColors.grayBackground,

        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: AppColors.primaryBlue.withOpacity(0.7),
          size: 22,
        ),

        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            color: AppColors.grayText,
            size: 22,
          ),
          onPressed: onVisibilityChanged,
          splashRadius: 20,
        ),

        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),

        // Borderlar
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.grayLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}
