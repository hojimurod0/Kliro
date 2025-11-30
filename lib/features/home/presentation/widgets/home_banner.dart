import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // Locale o'zgarganda rebuild qilish uchun
    final locale = context.locale;
    
    return Container(
      height: 220.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?auto=format&fit=crop&q=80&w=1000',
          ),
          fit: BoxFit.cover,
        ),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24.r),
                bottomRight: Radius.circular(24.r),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.black.withOpacity(0.1),
                  AppColors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BannerChip(key: ValueKey(locale.toString())),
                const Spacer(),
                Text(
                  'home.banner.title'.tr(),
                  style: AppTypography.headingXL.copyWith(color: AppColors.white),
                  key: ValueKey('title_${locale.toString()}'),
                ),
                SizedBox(height: 4.h),
                Text(
                  'home.banner.subtitle'.tr(),
                  style: AppTypography.bodyPrimary.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                    fontSize: 14.sp,
                  ),
                  key: ValueKey('subtitle_${locale.toString()}'),
                ),
                SizedBox(height: 16.h),
                _BannerButton(key: ValueKey('button_${locale.toString()}')),
              ],
            ),
          ),
          Positioned(
            top: 20.h,
            right: 20.w,
            child: Icon(
              Icons.more_horiz,
              color: AppColors.white,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerChip extends StatelessWidget {
  const _BannerChip({super.key});

  @override
  Widget build(BuildContext context) {
    // Locale o'zgarganda rebuild qilish uchun
    final locale = context.locale;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flight_takeoff, color: AppColors.white, size: 14.sp),
          SizedBox(width: 4.w),
          Text(
            'home.banner.travel'.tr(),
            key: ValueKey('travel_${locale.toString()}'),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerButton extends StatelessWidget {
  const _BannerButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Locale o'zgarganda rebuild qilish uchun
    final locale = context.locale;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: AppColors.white.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'home.banner.book'.tr(),
            key: ValueKey('book_${locale.toString()}'),
            style: AppTypography.bodyPrimary.copyWith(
              color: AppColors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.arrow_forward, color: AppColors.white, size: 18.sp),
        ],
      ),
    );
  }
}

