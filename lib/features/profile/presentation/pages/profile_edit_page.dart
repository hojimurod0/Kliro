import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../register/domain/params/auth_params.dart';
import '../../../register/domain/usecases/update_profile.dart';

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
      final updateProfile = ServiceLocator.resolve<UpdateProfile>();
      await updateProfile(
        UpdateProfileParams(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
        ),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('profile_edit.saved_successfully')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      hintText: 'Behruz',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _ProfileInputField(
                      controller: _lastNameController,
                      label: tr('profile_edit.last_name'),
                      icon: Icons.person_outline,
                      hintText: 'Dilmurodov',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              _ProfileInputField(
                controller: _emailController,
                label: tr('profile_edit.email'),
                icon: Icons.email_outlined,
                hintText: 'example@gmail.com',
              ),
              SizedBox(height: 15.h),
              _ProfileInputField(
                controller: _phoneController,
                label: tr('profile_edit.phone'),
                icon: Icons.call_outlined,
                hintText: '+998 99 999-99-99',
              ),
              SizedBox(height: 15.h),
              _ProfileInputField(
                controller: _birthDateController,
                label: tr('profile_edit.birth_date'),
                icon: Icons.calendar_today_outlined,
                hintText: '01.12.2000',
              ),
              SizedBox(height: 15.h),
              _ProfileInputField(
                controller: _addressController,
                label: tr('profile_edit.address'),
                icon: Icons.location_on_outlined,
                hintText: 'Toshkent, Uzbekistan',
              ),
              SizedBox(height: 40.h),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: _buttonHeight.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).iconTheme.color ?? Colors.black,
                        ),
                        label: Text(
                          tr('profile_edit.cancel'),
                          style: AppTypography.bodyPrimary.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge?.color ??
                                Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      height: _buttonHeight.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        gradient: LinearGradient(
                          colors: [AppColors.primaryBlue, AppColors.accentCyan],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: TextButton.icon(
                        onPressed: _isLoading ? null : _saveProfile,
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
  });

  final TextEditingController? controller;
  final String label;
  final IconData icon;
  final String hintText;

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
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
          child: TextField(
            controller: controller,
            style: AppTypography.bodyPrimary.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              prefixIcon: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Icon(icon, color: AppColors.primaryBlue, size: 20.sp),
              ),
              prefixIconConstraints: BoxConstraints(
                minWidth: 0.w,
                minHeight: 0.h,
              ),
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: AppTypography.bodyPrimary.copyWith(
                color: Colors.grey,
                fontSize: 16.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
