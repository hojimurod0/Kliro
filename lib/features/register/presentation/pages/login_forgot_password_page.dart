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
class LoginForgotPasswordPage extends StatefulWidget
    implements AutoRouteWrapper {
  const LoginForgotPasswordPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceLocator.resolve<RegisterBloc>(),
      child: this,
    );
  }

  @override
  State<LoginForgotPasswordPage> createState() =>
      _LoginForgotPasswordPageState();
}

class _LoginForgotPasswordPageState extends State<LoginForgotPasswordPage> {
  // Formni validatsiya qilish uchun kalit
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isEmailMode = true;
  final TextEditingController _emailOrPhoneController = TextEditingController();

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    super.dispose();
  }

  // Telefon raqamni chiroyli formatlash (Maskirovka)
  // Input: 901234567 -> Output: 90 123 45 67
  void _formatPhoneNumber(String value) {
    if (isEmailMode) return;

    // Faqat raqamlarni qoldiramiz
    String digits = value.replaceAll(RegExp(r'\D'), '');

    // Agar 998 prefixi kiritilgan bo'lsa, olib tashlaymiz (bizda UI da +998 bor)
    if (digits.startsWith('998')) {
      digits = digits.substring(3);
    }

    // Maksimum 9 ta raqam
    if (digits.length > 9) {
      digits = digits.substring(0, 9);
    }

    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5 || i == 7) {
        formatted += ' ';
      }
      formatted += digits[i];
    }

    // Kursor joylashuvini to'g'irlash
    if (_emailOrPhoneController.text != formatted) {
      _emailOrPhoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
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
          // Muvaffaqiyatli bo'lsa keyingi sahifaga o'tish
          final rawInput = _emailOrPhoneController.text.trim();
          String contactInfo = rawInput;

          if (!isEmailMode) {
            // Telefon bo'lsa tozalab, formatlab jo'natamiz
            final justDigits = rawInput.replaceAll(RegExp(r'\D'), '');
            contactInfo = "+998$justDigits";
          }

          context.router.push(
            LoginResetPasswordRoute(contactInfo: contactInfo),
          );
        }
      },
      builder: (context, state) {
        final isLoading =
            state.isLoading && state.flow == RegisterFlow.forgotPasswordOtp;

        return Scaffold(
          // Dark Mode uchun fix: Fonni oq rangda qotiramiz
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Form(
                key: _formKey,
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
                      style: AppTypography.headingXL.copyWith(
                        color: AppColors.black, // Matn rangi aniq qora
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),

                    // 3. Izoh matni
                    Text(
                      'auth.forgot.subtitle'.tr(),
                      style: AppTypography.bodyPrimary,
                    ),

                    SizedBox(height: AppSpacing.lg),

                    // 4. Custom Tab Switcher
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
                      onChanged: (value) {
                        setState(() {
                          isEmailMode = value;
                          _emailOrPhoneController.clear();
                          // Formdagi xatoliklarni tozalash
                          _formKey.currentState?.reset();
                        });
                      },
                    ),
                    SizedBox(height: AppSpacing.lg),

                    // 5. Input Label
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

                    // 6. Input Field (MUKAMMAL TEXTFORMFIELD)
                    TextFormField(
                      controller: _emailOrPhoneController,
                      // --- DARK MODE FIX START ---
                      // Input ichidagi yozuv doim qora bo'lishi kerak
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      cursorColor: AppColors.primaryBlue,

                      // --- DARK MODE FIX END ---
                      keyboardType: isEmailMode
                          ? TextInputType.emailAddress
                          : TextInputType.phone,

                      inputFormatters: !isEmailMode
                          ? [
                              LengthLimitingTextInputFormatter(
                                12,
                              ), // Probellar bilan hisoblaganda
                            ]
                          : [],

                      onChanged: (value) {
                        if (!isEmailMode) {
                          _formatPhoneNumber(value);
                        }
                      },

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return isEmailMode
                              ? 'auth.validation.email_required'
                                    .tr() // "Email kiriting"
                              : 'auth.validation.phone_required'
                                    .tr(); // "Telefon raqam kiriting"
                        }

                        if (isEmailMode) {
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'auth.validation.email_invalid'
                                .tr(); // "Noto'g'ri email formati"
                          }
                        } else {
                          // Telefon raqam uzunligi (probellarsiz 9 ta bo'lishi kerak)
                          final digits = value.replaceAll(RegExp(r'\D'), '');
                          if (digits.length < 9) {
                            return 'auth.validation.phone_length'
                                .tr(); // "Raqam to'liq emas"
                          }
                        }
                        return null;
                      },

                      decoration: AppInputDecoration.outline(
                        hint: isEmailMode
                            ? 'auth.field.email_hint'.tr()
                            : '90 123 45 67', // Aniq misol
                        // Prefix Icon Logic
                        prefix: isEmailMode
                            ? Icon(
                                Icons.email_outlined,
                                color: AppColors.primaryBlue,
                              )
                            : Container(
                                width: 65,
                                alignment: Alignment.center,
                                child: Text(
                                  "+998",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black, // Prefix ham qora
                                  ),
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),

                    // 7. Asosiy Tugma
                    AuthPrimaryButton(
                      label: 'auth.forgot.cta'.tr(),
                      isLoading: isLoading,
                      onPressed: () {
                        // 1. Validatsiyani tekshiramiz
                        if (_formKey.currentState?.validate() != true) {
                          return;
                        }

                        final rawInput = _emailOrPhoneController.text.trim();

                        String contactInfo;
                        bool isEmail;

                        if (isEmailMode) {
                          contactInfo = rawInput;
                          isEmail = true;
                        } else {
                          // 2. Telefon raqamni server formatiga o'tkazamiz (+998...)
                          // Foydalanuvchi "90 123 45 67" kiritgan -> "+998901234567"
                          final justDigits = rawInput.replaceAll(
                            RegExp(r'\D'),
                            '',
                          );
                          contactInfo = "+998$justDigits";
                          isEmail = false;
                        }

                        // 3. Bloc event yuboramiz
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
          ),
        );
      },
    );
  }
}
