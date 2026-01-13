import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Empty state widget when no flight results are found
class FlightEmptyStateWidget extends StatelessWidget {
  final VoidCallback onBack;

  const FlightEmptyStateWidget({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight_takeoff_rounded,
              size: 80.sp,
              color: AppColors.grayText.withValues(alpha: 0.5),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'avia.results.not_found'.tr(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'avia.results.change_search'.tr(),
              style: TextStyle(fontSize: 14.sp, color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: onBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 2,
              ),
              child: Text(
                'avia.common.back'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

