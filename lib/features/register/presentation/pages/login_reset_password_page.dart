import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../domain/params/auth_params.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/common_back_button.dart';
import '../widgets/otp_input_box.dart';

@RoutePage()
class LoginResetPasswordPage extends StatefulWidget
    implements AutoRouteWrapper {
  final String contactInfo;

  const LoginResetPasswordPage({
    super.key,
    required this.contactInfo,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceLocator.resolve<RegisterBloc>(),
      child: this,
    );
  }

  @override
  State<LoginResetPasswordPage> createState() => _LoginResetPasswordPageState();
}

class _LoginResetPasswordPageState extends State<LoginResetPasswordPage> {
  static const int _otpLength = 6;
  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  Timer? _timer;
  int _remainingSeconds = 59;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Birinchi katakchaga fokus qilish
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 59;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  String _formatContactInfo(String contact) {
    // Email yoki telefon raqamini formatlash
    if (contact.contains('@')) {
      // Email bo'lsa, faqat email qaytaradi
      return contact;
    } else {
      // Telefon raqamini formatlash: +998 99 999 ** **
      final cleaned = contact.replaceAll(RegExp(r'[^\d]'), '');
      if (cleaned.length >= 9) {
        return '+998 ${cleaned.substring(cleaned.length - 9, cleaned.length - 7)} ${cleaned.substring(cleaned.length - 7, cleaned.length - 4)} ** **';
      }
    }
    return contact;
  }

  void _onCodeChanged(int index, String value) {
    if (value.isNotEmpty) {
      // Keyingi katakchaga o'tish
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Oxirgi katakcha to'ldirilganda fokusni olib tashlash
        _focusNodes[index].unfocus();
        // Avtomatik tasdiqlash
        _verifyCode();
      }
    } else {
      // Oldingi katakchaga qaytish
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  void _verifyCode() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length == _otpLength) {
      context.router.push(
        LoginNewPasswordRoute(
          contactInfo: widget.contactInfo,
          otp: code,
        ),
      );
    }
  }

  void _resendCode() {
    if (_canResend) {
      final contact = widget.contactInfo;
      final isEmail = contact.contains('@');
      context.read<RegisterBloc>().add(
            ForgotPasswordOtpRequested(
              ForgotPasswordParams(
                email: isEmail ? contact : null,
                phone: isEmail ? null : contact,
              ),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.flow == RegisterFlow.forgotPasswordOtp) {
          if (state.status == RegisterStatus.success) {
            _startTimer();
            SnackbarHelper.showInfo(
              context,
              state.message ?? 'auth.verification.snack_resent'.tr(),
            );
          } else if (state.status == RegisterStatus.failure) {
            SnackbarHelper.showError(
              context,
              state.error ?? tr('common.error_occurred_simple'),
            );
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.sm),
                  // Orqaga qaytish tugmasi
                  const CommonBackButton(),
                  SizedBox(height: AppSpacing.xl),

                  // Sarlavha
                  Text(
                    'auth.verification.title_reset'.tr(),
                    style: AppTypography.headingXL(context).copyWith(
                      color: isDark ? AppColors.white : AppColors.black,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),

                  // Izoh matni (Dinamik - Email yoki raqam ko'rsatiladi)
                  Builder(
                    builder: (_) {
                      final contact = _formatContactInfo(widget.contactInfo);
                      final before = 'auth.verification.subtitle_before'.tr();
                      final after = 'auth.verification.subtitle_after'.tr();
                      return RichText(
                        text: TextSpan(
                          style: AppTypography.bodyPrimary(context)
                              .copyWith(fontSize: 14.sp),
                          children: [
                            if (before.isNotEmpty)
                              TextSpan(
                                text: before,
                              ),
                            TextSpan(
                              text: contact,
                              style:
                                  AppTypography.bodyPrimary(context).copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    isDark ? AppColors.white : AppColors.black,
                              ),
                            ),
                            if (after.isNotEmpty)
                              TextSpan(
                                text: after,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: AppSpacing.xxl),

                  // Kod kiritish maydonchalari (6 ta katak)
                  SizedBox(
                    height: 60.w,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final spacing = 8.w;
                        final totalSpacing = spacing * (_otpLength - 1);
                        final boxSize =
                            ((constraints.maxWidth - totalSpacing) / _otpLength)
                                .clamp(40.w, 54.w);
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _otpLength,
                            (index) => Padding(
                              padding: EdgeInsets.only(
                                right: index == _otpLength - 1 ? 0 : spacing,
                              ),
                              child: SizedBox(
                                width: boxSize,
                                height: boxSize,
                                child: OtpInputBox(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  boxSize: boxSize,
                                  onChanged: (value) =>
                                      _onCodeChanged(index, value),
                                  onTap: () {
                                    if (_controllers[index].text.isEmpty) {
                                      for (int i = 0; i < index; i++) {
                                        if (_controllers[i].text.isEmpty) {
                                          _focusNodes[i].requestFocus();
                                          return;
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: AppSpacing.lg),

                  // Timer va qayta yuborish matni
                  Center(
                    child: Column(
                      children: [
                        if (!_canResend)
                          Text(
                            '00:${_remainingSeconds.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          )
                        else
                          SizedBox(height: AppSpacing.lg),
                        SizedBox(height: AppSpacing.xs),
                        GestureDetector(
                          onTap: _canResend ? _resendCode : null,
                          child: Text(
                            'auth.verification.resend'.tr(),
                            style: AppTypography.caption(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSpacing.xxl),

                  // Tasdiqlash tugmasi (Och moviy fon)
                  AuthPrimaryButton(
                    label: 'auth.verification.cta'.tr(),
                    onPressed: _verifyCode,
                    backgroundColor: AppColors.lightBlue.withOpacity(0.2),
                    textColor: AppColors.primaryBlue,
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
