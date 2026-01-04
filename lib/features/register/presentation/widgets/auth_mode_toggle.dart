import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

class AuthModeOption {
  final String label;
  final IconData icon;
  final Gradient? gradient;
  final Color? activeColor;

  const AuthModeOption({
    required this.label,
    required this.icon,
    this.gradient,
    this.activeColor,
  });
}

class AuthModeToggle extends StatelessWidget {
  final AuthModeOption first;
  final AuthModeOption second;
  final bool isFirstSelected;
  final ValueChanged<bool> onChanged;

  const AuthModeToggle({
    super.key,
    required this.first,
    required this.second,
    required this.isFirstSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : AppColors.grayBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.grayLight,
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleItem(
              option: first,
              isSelected: isFirstSelected,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _ToggleItem(
              option: second,
              isSelected: !isFirstSelected,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final AuthModeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      gradient: isSelected ? option.gradient ?? AppColors.phoneGradient : null,
      color: isSelected ? option.activeColor : Colors.transparent,
      borderRadius: BorderRadius.circular(14.r),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.35),
                blurRadius: 16.r,
                offset: Offset(0, 6.h),
              ),
            ]
          : null,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: decoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              option.icon,
              color: isSelected ? AppColors.white : AppColors.grayText,
              size: 18.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              option.label,
              style: TextStyle(
                color: isSelected 
                    ? AppColors.white 
                    : (Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.grayText 
                        : AppColors.grayText),
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

