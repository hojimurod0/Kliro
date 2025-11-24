import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../widgets/common_back_button.dart';
import '../widgets/otp_input_box.dart';

@RoutePage()
class LoginVerificationPage extends StatefulWidget {
  final String phoneNumber;

  const LoginVerificationPage({super.key, required this.phoneNumber});

  @override
  State<LoginVerificationPage> createState() => _LoginVerificationPageState();
}

class _LoginVerificationPageState extends State<LoginVerificationPage> {
  static const int _otpLength = 6;
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

  String _formatPhoneNumber(String phone) {
    if (phone.length >= 9) {
      final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
      if (cleaned.length >= 9) {
        return '+998 ${cleaned.substring(cleaned.length - 9, cleaned.length - 7)} ${cleaned.substring(cleaned.length - 7, cleaned.length - 4)} ** **';
      }
    }
    return phone;
  }

  void _onCodeChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyCode();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  Future<void> _verifyCode() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length == _otpLength) {
      print('Tasdiqlash kodi: $code');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth.verification.snack_success'.tr()),
          backgroundColor: Colors.green,
        ),
      );
      await AuthService.instance.markLoggedIn();
      if (!mounted) return;
      context.router.replace(HomeRoute());
    }
  }

  void _resendCode() {
    if (_canResend) {
      _startTimer();
      print('Kod qayta yuborildi: ${widget.phoneNumber}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth.verification.snack_resent'.tr()),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.sm),
              const CommonBackButton(),
              SizedBox(height: AppSpacing.xl),
              Text(
                'auth.verification.title_login'.tr(),
                style: AppTypography.headingXL,
              ),
              SizedBox(height: AppSpacing.xs),
              Builder(
                builder: (_) {
                  final contact = _formatPhoneNumber(widget.phoneNumber);
                  final before = 'auth.verification.subtitle_before'.tr();
                  final after = 'auth.verification.subtitle_after'.tr();
                  return RichText(
                    text: TextSpan(
                      style: AppTypography.bodyPrimary.copyWith(
                        fontSize: 14.sp,
                      ),
                      children: [
                        if (before.isNotEmpty) TextSpan(text: before),
                        TextSpan(
                          text: contact,
                          style: AppTypography.bodyPrimary.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        if (after.isNotEmpty) TextSpan(text: after),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: AppSpacing.xxl),
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
                        style: AppTypography.caption,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightBlue.withOpacity(0.2),
                    foregroundColor: AppColors.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'auth.verification.cta'.tr(),
                    style: AppTypography.buttonPrimary.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
