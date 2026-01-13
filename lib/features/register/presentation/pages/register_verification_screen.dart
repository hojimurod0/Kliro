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
import '../../domain/params/auth_params.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/common_back_button.dart';

@RoutePage()
class RegisterVerificationScreen extends StatefulWidget {
  final String contactInfo; // Email yoki telefon raqam

  const RegisterVerificationScreen({super.key, required this.contactInfo});

  @override
  State<RegisterVerificationScreen> createState() =>
      _RegisterVerificationScreenState();
}

class _RegisterVerificationScreenState
    extends State<RegisterVerificationScreen> {
  static const int _otpLength = 6;
  late final RegisterBloc _registerBloc =
      ServiceLocator.resolve<RegisterBloc>();
  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

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
    _registerBloc.close();
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

  Future<void> _verifyCode() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length == _otpLength) {
      final contact = widget.contactInfo;
      final isEmail = contact.contains('@');

      _registerBloc.add(
        ConfirmRegisterOtpRequested(
          ConfirmOtpParams(
            email: isEmail ? contact : null,
            phone: isEmail ? null : contact,
            otp: code,
          ),
        ),
      );
    }
  }

  void _resendCode() {
    if (_canResend) {
      final contact = widget.contactInfo;
      final isEmail = contact.contains('@');

      _registerBloc.add(
        SendRegisterOtpRequested(
          SendOtpParams(
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
    return BlocProvider.value(
      value: _registerBloc,
      child: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state.status == RegisterStatus.success) {
            if (state.flow == RegisterFlow.registerConfirmOtp) {
              // OTP tasdiqlandi, UserDetailsScreen ga o'tish
              context.router.replace(
                UserDetailsRoute(contactInfo: widget.contactInfo),
              );
            } else if (state.flow == RegisterFlow.registerSendOtp) {
              // OTP qayta yuborildi
              _startTimer();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message ?? 'auth.verification.snack_resent'.tr(),
                  ),
                  backgroundColor: Colors.blue,
                ),
              );
            }
          } else if (state.status == RegisterStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(state.error ?? tr('common.error_occurred_simple')),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
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
                    'auth.verification.title_register'.tr(),
                    style: AppTypography.headingXL(context).copyWith(
                      color: isDark ? AppColors.white : AppColors.black,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Builder(
                    builder: (_) {
                      final contact = _formatContactInfo(widget.contactInfo);
                      final before = 'auth.verification.subtitle_before'.tr();
                      final after = 'auth.verification.subtitle_after'.tr();
                      return RichText(
                        text: TextSpan(
                          style: AppTypography.bodyPrimary(context).copyWith(
                            fontSize: 14.sp,
                          ),
                          children: [
                            if (before.isNotEmpty) TextSpan(text: before),
                            TextSpan(
                              text: contact,
                              style:
                                  AppTypography.bodyPrimary(context).copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    isDark ? AppColors.white : AppColors.black,
                              ),
                            ),
                            if (after.isNotEmpty) TextSpan(text: after),
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
                                child: _buildOtpBox(index, boxSize),
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

                  // Tasdiqlash tugmasi
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
        ),
      ),
    );
  }

  // OTP katakchasini chizish uchun yordamchi vidjet
  Widget _buildOtpBox(int index, double boxSize) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.grayBorder.withOpacity(0.5),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            spreadRadius: 1.r,
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: TextStyle(
            fontSize: boxSize * 0.35,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.white : AppColors.black,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: "", // Pastdagi raqam sanagichni o'chirish
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) => _onCodeChanged(index, value),
          onTap: () {
            // Bo'sh katakchaga bosilganda, oldingi katakchalarni to'ldirish
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
    );
  }
}
