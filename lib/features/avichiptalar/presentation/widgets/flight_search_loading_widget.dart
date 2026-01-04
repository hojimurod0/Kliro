import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/search_offers_request_model.dart';

class FlightSearchLoadingWidget extends StatelessWidget {
  final SearchOffersRequestModel searchRequest;

  const FlightSearchLoadingWidget({
    super.key,
    required this.searchRequest,
  });

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
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
      return dateStr;
    }
  }

  String _getPassengerText() {
    final total = searchRequest.adults + searchRequest.children + searchRequest.infants;
    if (total == 1) {
      return '1';
    }
    return total.toString();
  }

  String _getRoute() {
    if (searchRequest.directions.isEmpty) return '';
    final firstDirection = searchRequest.directions.first;
    return '${firstDirection.departureAirport} → ${firstDirection.arrivalAirport}';
  }

  String? _getReturnDate() {
    if (searchRequest.directions.length < 2) return null;
    return _formatDate(searchRequest.directions[1].date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextColor : AppColors.lightTextColor;
    final secondaryTextColor = isDark 
        ? AppColors.darkSubtitle 
        : AppColors.lightSubtitle;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // KLIRO Logo
            // KLIRO Logo
            SizedBox(
              height: 48.h, // Adjusted height for visibility
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
                        style: TextStyle(color: isDark ? AppColors.white : AppColors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 48.h),
            
            // Route
            Text(
              _getRoute(),
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 32.h),
            
            // Departure Date
            Text(
              'Departure: ${_formatDate(searchRequest.directions.first.date)}',
              style: TextStyle(
                fontSize: 16.sp,
                color: textColor,
              ),
            ),
            SizedBox(height: 8.h),
            
            // Return Date (if exists)
            if (_getReturnDate() != null) ...[
              Text(
                'Return: ${_getReturnDate()}',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: textColor,
                ),
              ),
              SizedBox(height: 8.h),
            ],
            
            // Passengers
            Text(
              'Number of passengers: ${_getPassengerText()}',
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
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
            ),
            SizedBox(height: 32.h),
            
            // Loading Text
            Text(
              'We are looking for the best options for you.',
              style: TextStyle(
                fontSize: 16.sp,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Please wait.',
              style: TextStyle(
                fontSize: 16.sp,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'This may take up to 60 seconds',
              style: TextStyle(
                fontSize: 14.sp,
                color: secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

}

