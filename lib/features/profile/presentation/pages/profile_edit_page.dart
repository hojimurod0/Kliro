import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../../../../core/utils/input_formatters.dart';
import '../../../../core/utils/snackbar_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../register/domain/params/auth_params.dart';
import '../../../register/domain/usecases/get_profile.dart';
import '../../../register/domain/entities/user_profile.dart';
import '../../../register/presentation/bloc/register_bloc.dart';
import '../../../register/presentation/bloc/register_event.dart';
import '../../../register/presentation/bloc/register_state.dart';

@RoutePage()
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  static const double _buttonHeight = 50.0;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;

  String _formatUzPhoneForDisplay(String raw) {
    final normalized = AuthService.normalizeContact(raw);
    if (normalized.isEmpty) return '';
    if (normalized.contains('@')) return normalized;
    final digits = normalized.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    // Expecting 998 + 9 digits; fall back gracefully for partials.
    final limited = digits.length > 12 ? digits.substring(0, 12) : digits;
    String out = '+';
    out += limited.substring(0, limited.length > 3 ? 3 : limited.length);
    if (limited.length > 3) {
      out +=
          ' ${limited.substring(3, limited.length > 5 ? 5 : limited.length)}';
    }
    if (limited.length > 5) {
      out +=
          ' ${limited.substring(5, limited.length > 8 ? 8 : limited.length)}';
    }
    if (limited.length > 8) {
      out +=
          ' ${limited.substring(8, limited.length > 10 ? 10 : limited.length)}';
    }
    if (limited.length > 10) {
      out +=
          ' ${limited.substring(10, limited.length > 12 ? 12 : limited.length)}';
    }
    return out;
  }

  String _trOrFallback(String key, String fallback) {
    final value = tr(key);
    return value == key ? fallback : value;
  }

  @override
  void initState() {
    super.initState();
    _prefillFromAuth();
  }

  Future<void> _prefillFromAuth() async {
    try {
      final user = await AuthService.instance.fetchActiveUser();
      if (!mounted || user == null) return;

      // Profile'ni yuklab, email va telefon alohida olish
      UserProfile? profile;
      try {
        final getProfile = ServiceLocator.resolve<GetProfile>();
        profile = await getProfile();
      } catch (_) {
        // Profile yuklanmasa, faqat user.contact ishlatish
      }

      // Local extra fields (birth date, address)
      final birth = await AuthService.instance.getLocalBirthDate();
      final address = await AuthService.instance.getLocalAddress();
      final pendingEmail = await AuthService.instance.getPendingEmail();

      setState(() {
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;

        // Email va telefon alohida olish (user.email va user.phone birinchi o'ringa)
        if (pendingEmail != null && pendingEmail.isNotEmpty) {
          _emailController.text = pendingEmail;
        } else if (user.email != null && user.email!.isNotEmpty) {
          _emailController.text = user.email!;
        } else if (profile?.email != null && profile!.email!.isNotEmpty) {
          _emailController.text = profile.email!;
        } else if (user.contact.contains('@')) {
          _emailController.text = user.contact;
        }

        if (user.phone != null && user.phone!.isNotEmpty) {
          _phoneController.text = _formatUzPhoneForDisplay(user.phone!);
        } else if (profile?.phone != null && profile!.phone!.isNotEmpty) {
          _phoneController.text = _formatUzPhoneForDisplay(profile.phone!);
        } else if (!user.contact.contains('@')) {
          _phoneController.text = _formatUzPhoneForDisplay(user.contact);
        } else {
          _phoneController.text = '+998';
        }

        // Prefill local-only fields
        if (birth != null && birth.isNotEmpty) {
          _birthDateController.text = birth;
        }
        if (address != null && address.isNotEmpty) {
          _addressController.text = address;
        }
      });
    } catch (_) {
      // Ignore – profile can still be edited manually.
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty) {
      SnackbarHelper.showError(
        context,
        tr('profile_edit.fill_required_fields'),
      );
      return;
    }

    try {
      // Compare local-only fields before save to detect changes
      final prevBirth = await AuthService.instance.getLocalBirthDate();
      final prevAddress = await AuthService.instance.getLocalAddress();
      final newBirth = _birthDateController.text.trim();
      final newAddress = _addressController.text.trim();

      // Always persist local-only fields
      await AuthService.instance.saveLocalExtras(
        birthDate: newBirth,
        address: newAddress,
      );

      final user = await AuthService.instance.fetchActiveUser();
      final getProfile = ServiceLocator.resolve<GetProfile>();
      final profile = await getProfile();

      final email = _emailController.text.trim();
      final phoneInput = _phoneController.text.trim();
      final phone = AuthService.normalizeContact(phoneInput);

      // Email yoki telefon o'zgarganda UpdateContact API'ni chaqirish
      final emailChanged =
          email.isNotEmpty && profile.email != email && email != user?.contact;
      final profilePhoneNormalized =
          AuthService.normalizeContact(profile.phone ?? '');
      final userContactNormalized =
          AuthService.normalizeContact(user?.contact ?? '');
      final phoneChanged = phone.isNotEmpty &&
          phone != '+998' &&
          profilePhoneNormalized != phone &&
          phone != userContactNormalized;

      if (emailChanged || phoneChanged) {
        // OTP yuborish
        setState(() {
          _isLoading = true;
        });
        if (emailChanged) {
          await AuthService.instance.savePendingEmail(email);
        }
        context.read<RegisterBloc>().add(
              ContactUpdateRequested(
                UpdateContactParams(
                  email: emailChanged ? email : null,
                  phone: phoneChanged ? phone : null,
                ),
              ),
            );
        return;
      }

      // Faqat ism o'zgarganda UpdateProfile API'ni chaqirish
      // Ism o'zgarmagan bo'lsa ham saqlash kerak
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      if (firstName == profile.firstName && lastName == profile.lastName) {
        // No server-side name change. If local-only fields changed, show success and pop.
        final localChanged =
            (prevBirth ?? '') != newBirth || (prevAddress ?? '') != newAddress;
        if (mounted) {
          if (localChanged) {
            SnackbarHelper.showSuccess(
              context,
              tr('profile_edit.saved_successfully'),
            );
            Navigator.pop(context);
          } else {
            SnackbarHelper.showInfo(
              context,
              tr('profile_edit.no_changes'),
            );
          }
        }
        return;
      }

      setState(() {
        _isLoading = true;
      });
      context.read<RegisterBloc>().add(
            ProfileUpdated(
              UpdateProfileParams(
                firstName: firstName,
                lastName: lastName,
              ),
            ),
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        SnackbarHelper.showError(
          context,
          'Xatolik: ${e.toString()}',
        );
      }
    }
  }

  void _showOtpVerificationDialog() {
    final otpController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(tr('profile_edit.verify_otp')),
        content: TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: tr('profile_edit.otp_hint'),
            border: const OutlineInputBorder(),
          ),
          maxLength: 6,
        ),
        actions: [
          TextButton(
            onPressed: () {
              otpController.dispose();
              Navigator.pop(context);
            },
            child: Text(tr('profile_edit.cancel')),
          ),
          TextButton(
            onPressed: () {
              if (otpController.text.trim().length == 6) {
                context.read<RegisterBloc>().add(
                      ContactUpdateConfirmed(
                        ConfirmUpdateContactParams(
                          otp: otpController.text.trim(),
                        ),
                      ),
                    );
                otpController.dispose();
                Navigator.pop(context);
              }
            },
            child: Text(tr('profile_edit.confirm')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceLocator.resolve<RegisterBloc>(),
      child: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state.flow == RegisterFlow.profileUpdate) {
            if (state.status == RegisterStatus.success) {
              // Loading state ni false qilish
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
                SnackbarHelper.showSuccess(
                  context,
                  tr('profile_edit.saved_successfully'),
                );
                Navigator.pop(context);
              }
            } else if (state.status == RegisterStatus.failure) {
              // Xatolik holatida ham loading state ni false qilish
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
                SnackbarHelper.showError(
                  context,
                  state.error ?? tr('profile_edit.update_failed'),
                );
              }
            }
          } else if (state.flow == RegisterFlow.contactUpdate) {
            if (state.status == RegisterStatus.success) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
                SnackbarHelper.showInfo(
                  context,
                  tr('profile_edit.otp_sent'),
                );
                // OTP verification dialog ochish
                _showOtpVerificationDialog();
              }
            } else if (state.status == RegisterStatus.failure) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
                SnackbarHelper.showError(
                  context,
                  state.error ?? tr('profile_edit.update_failed'),
                );
              }
            }
          } else if (state.flow == RegisterFlow.contactConfirm) {
            if (state.status == RegisterStatus.success) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });

                AuthService.instance.savePendingEmail(null);
                SnackbarHelper.showSuccess(
                  context,
                  tr('profile_edit.contact_updated'),
                );
                Navigator.pop(context);
              }
            } else if (state.status == RegisterStatus.failure) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
                SnackbarHelper.showError(
                  context,
                  state.error ?? tr('profile_edit.update_failed'),
                );
              }
            }
          }
        },
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.getCardBg(true) : Theme.of(context).cardColor;
    final borderColor = AppColors.getBorderColor(isDark);
    final textColor = AppColors.getTextColor(isDark);
    final subtitleColor = AppColors.getSubtitleColor(isDark);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          tr('profile_edit.title'),
          style: AppTypography.headingL(context).copyWith(
            fontSize: 18.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 20.h),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('profile_edit.profile_info'),
                style: AppTypography.headingL(context).copyWith(
                  fontSize: 22.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: _ProfileInputField(
                      controller: _firstNameController,
                      label: tr('profile_edit.first_name'),
                      icon: Icons.person_outline,
                      hintText:
                          _trOrFallback('profile_edit.first_name_hint', ''),
                      fillColor: bg,
                      borderColor: borderColor,
                      textColor: textColor,
                      hintColor: subtitleColor.withValues(alpha: 0.65),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _ProfileInputField(
                      controller: _lastNameController,
                      label: tr('profile_edit.last_name'),
                      icon: Icons.person_outline,
                      hintText:
                          _trOrFallback('profile_edit.last_name_hint', ''),
                      fillColor: bg,
                      borderColor: borderColor,
                      textColor: textColor,
                      hintColor: subtitleColor.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              _ProfileInputField(
                controller: _emailController,
                label: tr('profile_edit.email'),
                icon: Icons.email_outlined,
                hintText: _trOrFallback('profile_edit.email_hint', ''),
                keyboardType: TextInputType.emailAddress,
                fillColor: bg,
                borderColor: borderColor,
                textColor: textColor,
                hintColor: subtitleColor.withValues(alpha: 0.65),
              ),
              SizedBox(height: 15.h),
              _ProfileInputField(
                controller: _phoneController,
                label: tr('profile_edit.phone'),
                icon: Icons.call_outlined,
                hintText: _trOrFallback('profile_edit.phone_hint', '+998'),
                keyboardType: TextInputType.phone,
                inputFormatters: [UzPhoneSpaceFormatter()],
                fillColor: bg,
                borderColor: borderColor,
                textColor: textColor,
                hintColor: subtitleColor.withValues(alpha: 0.65),
              ),
              SizedBox(height: 15.h),
              _ProfileInputField(
                controller: _birthDateController,
                label: tr('profile_edit.birth_date'),
                icon: Icons.calendar_today_outlined,
                hintText:
                    _trOrFallback('profile_edit.birth_date_hint', 'DD.MM.YYYY'),
                keyboardType: TextInputType.number,
                inputFormatters: [DateFormatterWithDots()],
                fillColor: bg,
                borderColor: borderColor,
                textColor: textColor,
                hintColor: subtitleColor.withValues(alpha: 0.65),
              ),
              SizedBox(height: 15.h),
              _ProfileInputField(
                controller: _addressController,
                label: tr('profile_edit.address'),
                icon: Icons.location_on_outlined,
                hintText: _trOrFallback('profile_edit.address_hint', ''),
                fillColor: bg,
                borderColor: borderColor,
                textColor: textColor,
                hintColor: subtitleColor.withValues(alpha: 0.65),
              ),
              SizedBox(height: 40.h),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: _buttonHeight.h,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).iconTheme.color ??
                              (Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.white
                                  : AppColors.black),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: borderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        label: Text(
                          tr('profile_edit.cancel'),
                          style: AppTypography.bodyPrimary(context).copyWith(
                            color: textColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: SizedBox(
                      height: _buttonHeight.h,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryBlue,
                              AppColors.accentCyan
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(
                                  Icons.save_outlined,
                                  color: Colors.white,
                                ),
                          label: Text(
                            tr('profile_edit.save'),
                            style: AppTypography.bodyPrimary(context).copyWith(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInputField extends StatelessWidget {
  const _ProfileInputField({
    this.controller,
    required this.label,
    required this.icon,
    required this.hintText,
    this.keyboardType,
    this.inputFormatters,
    required this.fillColor,
    required this.borderColor,
    required this.textColor,
    required this.hintColor,
  });

  final TextEditingController? controller;
  final String label;
  final IconData icon;
  final String hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Color fillColor;
  final Color borderColor;
  final Color textColor;
  final Color hintColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyPrimary(context).copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: AppTypography.bodyPrimary(context).copyWith(
            color: textColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: fillColor,
            contentPadding: EdgeInsets.symmetric(
              vertical: 14.h,
              horizontal: 12.w,
            ),
            prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20.sp),
            hintText: hintText,
            hintStyle: AppTypography.bodyPrimary(context).copyWith(
              color: hintColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: borderColor, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: borderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide:
                  const BorderSide(color: AppColors.primaryBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
