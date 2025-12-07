import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart'; // AppColors manzili to'g'ri ekanligini tekshiring
import '../widgets/common_back_button.dart';

class LoginResetPasswordPage extends StatefulWidget {
  final String contactInfo;

  const LoginResetPasswordPage({super.key, required this.contactInfo});

  @override
  State<LoginResetPasswordPage> createState() => _LoginResetPasswordPageState();
}

class _LoginResetPasswordPageState extends State<LoginResetPasswordPage> {
  static const int _otpLength = 6;

  // Controller va FocusNode'larni saqlash
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  Timer? _timer;
  int _remainingSeconds = 59;
  bool _canResend = false;
  bool _isLoading = false; // API chaqiruv vaqti uchun

  @override
  void initState() {
    super.initState();

    // Listlarni generatsiya qilamiz
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());

    _startTimer();

    // Sahifa ochilganda birinchi katakchaga klaviatura chiqaramiz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  // --- TIMER LOGIC ---
  void _startTimer() {
    setState(() {
      _remainingSeconds = 59;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  // --- FORMATTING LOGIC ---
  String _formatContactInfo(String contact) {
    if (contact.contains('@')) return contact; // Email bo'lsa o'zi qaytadi

    // Telefon: +998901234567 -> +998 90 123 ** **
    final cleaned = contact.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length >= 9) {
      // Oxirgi 4 ta raqamni yashirish
      String prefix = cleaned.length > 9 ? "+${cleaned.substring(0, 3)} " : "";
      // Bu yerda logika loyihangizga qarab o'zgarishi mumkin,
      // lekin chiroyli ko'rinish uchun oddiy maskirovka:
      return "$contact raqamiga";
    }
    return contact;
  }

  // --- INPUT LOGIC ---
  void _onCodeChanged(int index, String value) {
    if (value.isNotEmpty) {
      // Agar raqam yozilsa, keyingisiga o'tish
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Oxirgi katakcha bo'lsa, klaviaturani tushurish va tekshirish
        _focusNodes[index].unfocus();
        _verifyCode();
      }
    }
    // Agar o'chirilgan bo'lsa (backspace), bu yerda handle qilinmaydi,
    // chunki onChanged faqat text o'zgarganda ishlaydi.
    // Backspace logikasi RawKeyboardListener da bo'lishi kerak,
    // lekin oddiy holatda foydalanuvchi o'zi bosib o'chiradi.
  }

  // --- API / VERIFY LOGIC ---
  void _verifyCode() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length == _otpLength) {
      setState(() => _isLoading = true);

      // Simulyatsiya (API o'rniga)
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() => _isLoading = false);

        print("Tasdiqlangan kod: $code");
        // Muvaffaqiyatli o'tish
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kod to'g'ri!"),
            backgroundColor: Colors.green,
          ),
        );
        // Navigator.pushNamed(context, '/reset-password');
      });
    }
  }

  void _resendCode() {
    if (!_canResend) return;

    // Qayta yuborish logikasi
    _startTimer();

    // Controllerlarni tozalash va boshiga qaytish
    for (var c in _controllers) c.clear();
    _focusNodes[0].requestFocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Kod qayta yuborildi"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ekran o'lchamlari
    final screenWidth = MediaQuery.of(context).size.width;
    // Kichik ekranlarda inputlar sig'ishi uchun o'lchamni hisoblash
    final boxSize = (screenWidth - 48 - (8 * (_otpLength - 1))) / _otpLength;
    final responsiveSize = boxSize.clamp(40.0, 50.0); // Minimum 40, Maximum 50

    return Scaffold(
      // 1. Asosiy fonni OQ rangda qotiramiz
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const CommonBackButton(),
              const SizedBox(height: 30),

              // Sarlavha
              const Text(
                "Kodni tasdiqlash",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black, // Matn doim qora
                ),
              ),
              const SizedBox(height: 10),

              // Izoh
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.grayText,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: widget.contactInfo,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const TextSpan(
                      text: " ga yuborilgan 6 xonali kodni kiriting.",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- OTP INPUT FIELDS (FIXED UI) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (index) {
                  return SizedBox(
                    width: responsiveSize,
                    height: responsiveSize + 10, // balandroq joy
                    child: _buildSingleOtpBox(index),
                  );
                }),
              ),

              const SizedBox(height: 30),

              // --- TIMER & RESEND ---
              Center(
                child: _canResend
                    ? TextButton.icon(
                        onPressed: _resendCode,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text("Kodni qayta yuborish"),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryBlue,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Kodni qayta yuborish: ",
                            style: TextStyle(
                              color: AppColors.grayText,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            "00:${_remainingSeconds.toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 40),

              // --- TASDIQLASH TUGMASI ---
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    disabledBackgroundColor: AppColors.primaryBlue.withOpacity(
                      0.5,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Tasdiqlash",
                          style: TextStyle(
                            fontSize: 16,
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

  // --- CUSTOM OTP BOX WIDGET ---
  // Dark Modeda ham chiroyli turishi uchun maxsus widget
  Widget _buildSingleOtpBox(int index) {
    return RawKeyboardListener(
      focusNode: FocusNode(), // Dummy focus node for listener
      onKey: (event) {
        // Backspace bosilganda orqaga qaytish logikasi
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _controllers[index].text.isEmpty &&
            index > 0) {
          _focusNodes[index - 1].requestFocus();
        }
      },
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        // 1. Klaviaturada faqat raqam
        keyboardType: TextInputType.number,
        // 2. Formatlash (faqat 1 ta raqam)
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        // 3. Matnni o'rtaga joylash
        textAlign: TextAlign.center,
        // 4. Cursor rangi
        cursorColor: AppColors.primaryBlue,

        // --- DARK MODE FIX (ENG MUHIM QISM) ---
        style: const TextStyle(
          color: Colors.black, // Input ichidagi raqam doim qora
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),

        onChanged: (value) => _onCodeChanged(index, value),

        // Dizayn
        decoration: InputDecoration(
          // Input orqa foni (Dark modeda ham och rangda bo'ladi)
          filled: true,
          fillColor: AppColors.grayBackground, // Yoki Color(0xFFF5F6F8)

          contentPadding: EdgeInsets.zero,

          // Borderlar
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.grayLight, // Kulrang hoshiya
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primaryBlue, // Aktiv holatda ko'k
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
