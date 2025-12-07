import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import 'login_reset_password_page.dart';
import '../widgets/common_back_button.dart';

class LoginForgotPasswordPage extends StatefulWidget {
  const LoginForgotPasswordPage({super.key});

  @override
  State<LoginForgotPasswordPage> createState() =>
      _LoginForgotPasswordPageState();
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final horizontalPadding =
        screenWidth * 0.06; // 6% от ширины экрана, минимум 20

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding.clamp(20.0, 24.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // 1. Orqaga tugmasi
              const CommonBackButton(),

              const SizedBox(height: 20),

              // 2. Sarlavha
              const Text(
                "Parolni unutdingizmi?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 8),

              // 3. Izoh matni
              Text(
                "Parolni tiklash uchun email yoki telefon raqamingizni kiriting",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.grayText,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),
              // 4. Custom Tab Switcher (Email / Telefon)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.grayBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.grayLight, width: 1),
                ),
                child: Row(
                  children: [
                    // Email Tab
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isEmailMode = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: isEmailMode ? null : null,
                            color: isEmailMode
                                ? AppColors.primaryBlue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isEmailMode
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryBlue.withOpacity(
                                        0.25,
                                      ),
                                      blurRadius: 6,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.email_outlined,
                                color: isEmailMode ? null : AppColors.grayText,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Email",
                                style: TextStyle(
                                  color: isEmailMode
                                      ? null
                                      : AppColors.grayText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Telefon Tab
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isEmailMode = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: !isEmailMode
                                ? AppColors.phoneGradient
                                : null,
                            color: !isEmailMode ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: !isEmailMode
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryBlue.withOpacity(
                                        0.25,
                                      ),
                                      blurRadius: 6,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: !isEmailMode
                                    ? BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.white,
                                          width: 1.2,
                                        ),
                                        borderRadius: BorderRadius.circular(3),
                                      )
                                    : null,
                                child: Icon(
                                  Icons.phone,
                                  color: !isEmailMode
                                      ? null
                                      : AppColors.grayText,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Telefon",
                                style: TextStyle(
                                  color: !isEmailMode
                                      ? null
                                      : AppColors.grayText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 5. Input Label (Sarlavha)
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Text(
                  isEmailMode ? "Email" : "Telefon raqam",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray500,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // 6. Input Field (Kiritish maydoni)
              TextFormField(
                controller: _emailOrPhoneController,

                style: TextStyle(color: Colors.blueGrey),
                keyboardType: isEmailMode
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
                inputFormatters: !isEmailMode
                    ? [
                        FilteringTextInputFormatter.digitsOnly,

                        LengthLimitingTextInputFormatter(12),
                      ]
                    : null,
                decoration: InputDecoration(
                  hintText: isEmailMode
                      ? "Emailingizni kiriting"
                      : "+998 99 999 99 99",
                  hintStyle: TextStyle(color: AppColors.grayText, fontSize: 13),
                  prefixIcon: Icon(
                    isEmailMode ? Icons.email_outlined : Icons.phone,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.grayBorder.withOpacity(0.8),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primaryBlue,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  filled: true,
                  // fillColor: AppColors.white,
                ),
              ),
              const SizedBox(height: 20),
              // 7. Asosiy Tugma (Kodni yuborish)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Bu yerda API chaqiruvini amalga oshirish kerak
                    final emailOrPhone = _emailOrPhoneController.text.trim();
                    if (emailOrPhone.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Iltimos, email yoki telefon raqamini kiriting',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Telefon raqamini formatlash
                    String contactInfo = emailOrPhone;
                    if (!isEmailMode) {
                      final cleaned = emailOrPhone.replaceAll(
                        RegExp(r'[^\d]'),
                        '',
                      );
                      if (cleaned.startsWith('998')) {
                        contactInfo = '+$cleaned';
                      } else if (!cleaned.startsWith('+')) {
                        contactInfo = '+998$cleaned';
                      }
                    }

                    // Kod yuborish logikasi va LoginResetPasswordPage ga o'tish
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            LoginResetPasswordPage(contactInfo: contactInfo),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.send_rounded, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Kodni yuborish",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
