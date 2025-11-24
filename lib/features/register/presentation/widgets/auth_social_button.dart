import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class AuthSocialButton extends StatelessWidget {
  final String label;
  final String iconUrl;
  final VoidCallback onPressed;

  const AuthSocialButton({
    super.key,
    required this.label,
    required this.iconUrl,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grayBorder, width: 1.w),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              iconUrl,
              height: 20.h,
              width: 20.w,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.g_mobiledata, size: 24.sp),
            ),
            SizedBox(width: 10.w),
            Text(
              label,
              style: AppTypography.googleButton,
            ),
          ],
        ),
      ),
    );
  }
}

