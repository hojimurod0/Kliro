import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Umumiy empty state widget KASKO moduli uchun
class KaskoEmptyWidget extends StatelessWidget {
  final String message;
  final IconData? icon;

  const KaskoEmptyWidget({
    super.key,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtitleColor = isDark ? Colors.grey[400]! : const Color(0xFF6B7280);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.info_outline,
              size: 64.sp,
              color: subtitleColor,
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 16.sp,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

