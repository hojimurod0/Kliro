import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/common_back_button.dart';
import '../widgets/otp_input_box.dart';

class LoginResetPasswordPage extends StatefulWidget {
  final String contactInfo;

  const LoginResetPasswordPage({
    super.key,
    required this.contactInfo,
  });

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
      // Bu yerda API chaqiruvini amalga oshirish kerak
      // Keyingi bosqichga o'tish (Yangi parol o'rnatish)
      print('Tasdiqlash kodi: $code');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kod tasdiqlandi! Yangi parol o\'rnatish sahifasiga o\'tamiz...'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Bu yerda yangi parol o'rnatish sahifasiga o'tish kerak
      // Navigator.of(context).pushReplacement(...);
    }
  }

  void _resendCode() {
    if (_canResend) {
      _startTimer();
      // Bu yerda API chaqiruvini amalga oshirish kerak
      print('Kod qayta yuborildi: ${widget.contactInfo}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kod qayta yuborildi!'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final horizontalPadding = screenWidth * 0.06; // 6% от ширины экрана, минимум 20

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding.clamp(20.0, 24.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Orqaga qaytish tugmasi
              const CommonBackButton(),
              const SizedBox(height: 24),

              // Sarlavha
              const Text(
                "Parolni tiklash",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),

              // Izoh matni (Dinamik - Email yoki raqam ko'rsatiladi)
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.grayText,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text: _formatContactInfo(widget.contactInfo),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const TextSpan(text: " ga yuborilgan tasdiqlash kodini kiriting"),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Kod kiritish maydonchalari (6 ta katak)
              SizedBox(
                height: 60,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 8.0;
                    final totalSpacing = spacing * (_otpLength - 1);
                    final boxSize =
                        ((constraints.maxWidth - totalSpacing) / _otpLength)
                            .clamp(44.0, 56.0);
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

              const SizedBox(height: 24),

              // Timer va qayta yuborish matni
              Center(
                child: Column(
                  children: [
                    if (!_canResend)
                      Text(
                        '00:${_remainingSeconds.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      )
                    else
                      const SizedBox(height: 20),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _canResend ? _resendCode : null,
                      child: Text(
                        "Kodni qayta yuborish",
                        style: TextStyle(
                          color: AppColors.gray500,
                          fontSize: 11,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Tasdiqlash tugmasi (Och moviy fon)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _verifyCode();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightBlue.withOpacity(0.2), // Och moviy fon
                    foregroundColor: AppColors.primaryBlue, // To'q moviy yozuv
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Tasdiqlash",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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

