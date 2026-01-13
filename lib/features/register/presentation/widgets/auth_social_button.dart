import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/safe_network_image.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.grayBorder,
          width: 1.w,
        ),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SafeNetworkImage(
              imageUrl: iconUrl,
              height: 20.h,
              width: 20.w,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 10.w),
            Text(
              label,
              style: AppTypography.googleButton(context),
            ),
          ],
        ),
      ),
    );
  }
}

