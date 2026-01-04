import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../features/register/domain/params/auth_params.dart';
import '../../../../features/register/presentation/bloc/register_bloc.dart';
import '../../../../features/register/presentation/bloc/register_event.dart';
import '../../../../features/register/presentation/bloc/register_state.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BlocProvider(
      create: (context) => ServiceLocator.resolve<RegisterBloc>(),
      child: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state.status == RegisterStatus.success && 
              state.flow == RegisterFlow.passwordChange) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(tr('security.password_updated')),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            _currentPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();
          } else if (state.status == RegisterStatus.failure && 
                     state.flow == RegisterFlow.passwordChange) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? tr('security.password_update_failed')),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Theme.of(context).textTheme.titleLarge?.color,
                size: 20.sp,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              tr('security.title'),
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildPasswordChangeSection(isDark),
                SizedBox(height: 32.h),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordChangeSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('security.change_password'),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        SizedBox(height: 16.h),
        


        _buildInputLabel(tr('security.current_password')),
        SizedBox(height: 8.h),
        _buildPasswordField(
          tr('security.current_password_hint'),
          _currentPasswordController,
          _isCurrentPasswordVisible,
          () => setState(() => _isCurrentPasswordVisible = !_isCurrentPasswordVisible),
          isDark,
        ),
        
        SizedBox(height: 20.h),

        _buildInputLabel(tr('security.new_password')),
        SizedBox(height: 8.h),
        _buildPasswordField(
          tr('security.new_password_hint'),
          _newPasswordController,
          _isNewPasswordVisible,
          () => setState(() => _isNewPasswordVisible = !_isNewPasswordVisible),
          isDark,
        ),

        SizedBox(height: 20.h),

        _buildInputLabel(tr('security.confirm_password')),
        SizedBox(height: 8.h),
        _buildPasswordField(
          tr('security.confirm_password_hint'),
          _confirmPasswordController,
          _isConfirmPasswordVisible,
          () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
          isDark,
        ),

        SizedBox(height: 32.h),
        _buildUpdateButton(),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String hintText,
    TextEditingController controller,
    bool isVisible,
    VoidCallback onToggleVisibility,
    bool isDark,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[500] : Colors.grey[400],
          fontSize: 14.sp,
        ),
        helperText: hintText == tr('security.new_password_hint') 
            ? tr('security.password_min_length') 
            : null,
        helperMaxLines: 2,
        helperStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: 11.sp,
        ),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: isDark ? Colors.grey[400] : _iconColor,
          size: 20.sp,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey,
            size: 20.sp,
          ),
          onPressed: onToggleVisibility,
          splashRadius: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey[200]!,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (previous, current) => 
          current.flow == RegisterFlow.passwordChange,
      builder: (context, state) {
        final isLoading = state.status == RegisterStatus.loading && 
                         state.flow == RegisterFlow.passwordChange;
        
        return Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: const LinearGradient(
              colors: [_primaryBlue, _secondaryBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _secondaryBlue.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _handlePasswordChange(context),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    tr('security.update_password'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _handlePasswordChange(BuildContext context) {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('security.fill_all_fields')),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('security.passwords_do_not_match')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<RegisterBloc>().add(
      PasswordChanged(
        ChangePasswordParams(
          oldPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        ),
      ),
    );
  }


}

