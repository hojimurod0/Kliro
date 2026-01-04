import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

class OtpInputBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final double boxSize;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const OtpInputBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.boxSize,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.grayBorder.withOpacity(0.5),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            spreadRadius: 1.r,
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: TextStyle(
            fontSize: boxSize * 0.35,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.white : AppColors.black,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: "",
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: onChanged,
          onTap: onTap,
        ),
      ),
    );
  }
}

