import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/services/auth/auth_service.dart';
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

      setState(() {
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;

        // Email va telefon alohida olish (user.email va user.phone birinchi o'ringa)
        if (user.email != null && user.email!.isNotEmpty) {
          _emailController.text = user.email!;
        } else if (profile?.email != null && profile!.email!.isNotEmpty) {
          _emailController.text = profile.email!;
        } else if (user.contact.contains('@')) {
          _emailController.text = user.contact;
        }

        if (user.phone != null && user.phone!.isNotEmpty) {
          final normalizedPhone = AuthService.normalizeContact(user.phone!);
          _phoneController.text = normalizedPhone;
        } else if (profile?.phone != null && profile!.phone!.isNotEmpty) {
          final normalizedPhone = AuthService.normalizeContact(profile.phone!);
          _phoneController.text = normalizedPhone;
        } else if (!user.contact.contains('@')) {
          final normalizedPhone = AuthService.normalizeContact(user.contact);
          _phoneController.text = normalizedPhone;
        } else {
          _phoneController.text = '+998';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('profile_edit.fill_required_fields')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = await AuthService.instance.fetchActiveUser();
      final getProfile = ServiceLocator.resolve<GetProfile>();
      final profile = await getProfile();
      
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      
      // Email yoki telefon o'zgarganda UpdateContact API'ni chaqirish
      final emailChanged = email.isNotEmpty && 
                          profile.email != email && 
                          email != user?.contact;
      final phoneChanged = phone.isNotEmpty && 
                          phone != '+998' && 
                          profile.phone != phone && 
                          phone != user?.contact;
      
      if (emailChanged || phoneChanged) {
        // OTP yuborish
        context.read<RegisterBloc>().add(
          ContactUpdateRequested(
            UpdateContactParams(
              email: email.isNotEmpty && email.contains('@') ? email : null,
              phone: phone.isNotEmpty && phone != '+998' ? phone : null,
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Faqat ism o'zgarganda UpdateProfile API'ni chaqirish
      context.read<RegisterBloc>().add(
        ProfileUpdated(
          UpdateProfileParams(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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
          if (state.status == RegisterStatus.success) {
            if (state.flow == RegisterFlow.contactUpdate) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('profile_edit.otp_sent')),
                  backgroundColor: Colors.blue,
                ),
              );
              // OTP verification dialog ochish
              _showOtpVerificationDialog();
            } else if (state.flow == RegisterFlow.contactConfirm) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('profile_edit.contact_updated')),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else if (state.flow == RegisterFlow.profileUpdate) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('profile_edit.saved_successfully')),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            }
          } else if (state.status == RegisterStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? tr('profile_edit.update_failed')),
                backgroundColor: Colors.red,
              ),
            );
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
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
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
          style: AppTypography.headingL.copyWith(
            fontSize: 18.sp,
            color: Theme.of(context).textTheme.titleLarge?.color,
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
                style: AppTypography.headingL.copyWith(
                  fontSize: 22.sp,
                  color: Theme.of(context).textTheme.titleLarge?.color,
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
                      hintText: _trOrFallback('profile_edit.last_name_hint', ''),
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
                keyboardType: TextInputType.datetime,
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
                          color: Theme.of(context).iconTheme.color ?? Colors.black,
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: borderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        label: Text(
                          tr('profile_edit.cancel'),
                          style: AppTypography.bodyPrimary.copyWith(
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
                            colors: [AppColors.primaryBlue, AppColors.accentCyan],
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(
                                  Icons.save_outlined,
                                  color: Colors.white,
                                ),
                          label: Text(
                            tr('profile_edit.save'),
                            style: AppTypography.bodyPrimary.copyWith(
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
          style: AppTypography.bodyPrimary.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.labelText,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTypography.bodyPrimary.copyWith(
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
            hintStyle: AppTypography.bodyPrimary.copyWith(
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
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
