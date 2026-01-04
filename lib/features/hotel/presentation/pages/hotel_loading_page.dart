import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/hotel_filter.dart';

class HotelLoadingPage extends StatelessWidget {
  final HotelFilter filter;

  const HotelLoadingPage({
    super.key,
    required this.filter,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    try {
      final months = [
        'avia.months.full.january'.tr(),
        'avia.months.full.february'.tr(),
        'avia.months.full.march'.tr(),
        'avia.months.full.april'.tr(),
        'avia.months.full.may'.tr(),
        'avia.months.full.june'.tr(),
        'avia.months.full.july'.tr(),
        'avia.months.full.august'.tr(),
        'avia.months.full.september'.tr(),
        'avia.months.full.october'.tr(),
        'avia.months.full.november'.tr(),
        'avia.months.full.december'.tr(),
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return DateFormat('dd.MM.yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextColor : AppColors.lightTextColor;
    final secondaryTextColor =
        isDark ? AppColors.darkSubtitle : AppColors.lightSubtitle;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              SizedBox(
                height: 48.h,
                child: SvgPicture.asset(
                  'assets/images/klero_logo.svg',
                  fit: BoxFit.contain,
                  placeholderBuilder: (context) => RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      children: [
                        TextSpan(
                          text: "K",
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        TextSpan(
                          text: "LiRO",
                          style: TextStyle(
                              color:
                                  isDark ? AppColors.white : AppColors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 48.h),

              // City Name (Search destination)
              Text(
                filter.city ?? 'hotel.common.anywhere'.tr(),
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 32.h),

              // Check-in Date
              Text(
                '${"hotel.search.check_in".tr()}: ${_formatDate(filter.checkInDate)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: textColor,
                ),
              ),
              SizedBox(height: 8.h),

              // Check-out Date
              Text(
                '${"hotel.search.check_out".tr()}: ${_formatDate(filter.checkOutDate)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: textColor,
                ),
              ),
              SizedBox(height: 8.h),

              // Guests
              Text(
                '${"hotel.search.person".tr()}: ${filter.guests}',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: textColor,
                ),
              ),
              SizedBox(height: 48.h),

              // Loading Spinner
              SizedBox(
                width: 48.w,
                height: 48.w,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                ),
              ),
              SizedBox(height: 32.h),

              // Loading Text
              Text(
                'hotel.results.loading'
                    .tr(), // "Eng yaxshi variantlarni qidiryapmiz..."
                style: TextStyle(
                  fontSize: 16.sp,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'hotel.results.please_wait'.tr(), // "Iltimos, kuting."
                style: TextStyle(
                  fontSize: 16.sp,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'hotel.results.may_take_time'
                    .tr(), // "Bu 60 soniyagacha vaqt olishi mumkin"
                style: TextStyle(
                  fontSize: 14.sp,
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
