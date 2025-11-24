import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Ranglar va uslublar
const Color _primaryBlue = Color(0xFF00C6FF); // Ochiqroq moviy
const Color _secondaryBlue = Color(0xFF0093E9); // To'qroq moviy
const Color _iconColor = Color(0xFF5AC8FA); // Input field ikonka rangi
const Color _lightGrey = Color(0xFFEFEFEF); // Input field background/border
const Color _darkText = Color(0xFF2C2C2C);
const Color _lightBlueWarning = Color(0xFFE5F6FF);

@RoutePage()
class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _isBiometricEnabled = true;
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color ?? Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          tr('security.title'),
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // === 1. Parolni o'zgartirish bo'limi ===
              _buildPasswordChangeSection(),
              SizedBox(height: 30.h),

              // === 2. Xavfsizlik sozlamalari bo'limi ===
              _buildSecuritySettingsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordChangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('security.change_password'),
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color ?? _darkText,
          ),
        ),
        SizedBox(height: 15.h),
        // Ogohlantirish bloki
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: _lightBlueWarning,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: _secondaryBlue, size: 20),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  tr('security.password_min_length'),
                  style: TextStyle(color: _secondaryBlue, fontSize: 13.sp),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        // Joriy parol maydoni
        Text(
          tr('security.current_password'),
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
          ),
        ),
        SizedBox(height: 8.h),
        _buildPasswordField(
          tr('security.current_password_hint'),
          _currentPasswordController,
          _isCurrentPasswordVisible,
          () {
            setState(() {
              _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
            });
          },
        ),
        SizedBox(height: 15.h),
        // Yangi parol maydoni
        Text(
          tr('security.new_password'),
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
          ),
        ),
        SizedBox(height: 8.h),
        _buildPasswordField(
          tr('security.new_password_hint'),
          _newPasswordController,
          _isNewPasswordVisible,
          () {
            setState(() {
              _isNewPasswordVisible = !_isNewPasswordVisible;
            });
          },
        ),
        SizedBox(height: 15.h),
        // Parolni tasdiqlash maydoni
        Text(
          tr('security.confirm_password'),
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
          ),
        ),
        SizedBox(height: 8.h),
        _buildPasswordField(
          tr('security.confirm_password_hint'),
          _confirmPasswordController,
          _isConfirmPasswordVisible,
          () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
        SizedBox(height: 25.h),
        // Parolni yangilash tugmasi
        _buildUpdateButton(),
      ],
    );
  }

  Widget _buildPasswordField(
    String hintText,
    TextEditingController controller,
    bool isVisible,
    VoidCallback onToggleVisibility,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color ?? _darkText,
        fontSize: 16.sp,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: EdgeInsets.symmetric(
          vertical: 15.h,
          horizontal: 10.w,
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey, fontSize: 16.sp),
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 10.w, right: 10.w),
          child: Icon(Icons.lock_outline, color: _iconColor),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible
                ? Icons.remove_red_eye_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey,
          ),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: _lightGrey, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: _lightGrey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: _iconColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        gradient: const LinearGradient(
          colors: [_primaryBlue, _secondaryBlue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          // Yangilash logikasi
          // TODO: Implement password change logic
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tr('security.password_updated')),
              backgroundColor: Colors.green,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Text(
          tr('security.update_password'),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSecuritySettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Row(
            children: [
              Container(
                width: 4.w,
                height: 24.h,
                color: _secondaryBlue, // Rasmning chap qismidagi vertikal chiziq
              ),
              SizedBox(width: 8.w),
              Text(
                tr('security.security_settings'),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color ?? _darkText,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15.h),
        // Biometrik autentifikatsiya bloki (Card/Container)
        Container(
          padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3), // pastga soyani berish
              ),
            ],
          ),
          child: Row(
            children: [
              // Barmoq izi ikonkasi (rasmdagi o'xshashlikni ta'minlash uchun Container ichida)
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: _lightBlueWarning.withOpacity(0.5), // Yengil ko'k fon
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: const Icon(
                  Icons.fingerprint,
                  color: _secondaryBlue,
                  size: 30,
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('security.biometric_auth'),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color ?? _darkText,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      tr('security.biometric_auth_desc'),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // Switch tugmasi
              Switch(
                value: _isBiometricEnabled,
                onChanged: (bool newValue) {
                  setState(() {
                    _isBiometricEnabled = newValue;
                  });
                },
                activeColor: _secondaryBlue, // Faol holatdagi rang
                activeTrackColor: _primaryBlue.withOpacity(
                  0.5,
                ), // Faol holatdagi trek rangi
              ),
            ],
          ),
        ),
      ],
    );
  }
}

