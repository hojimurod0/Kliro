import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

@RoutePage()
class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  // Oferta shartlari URL - agar alohida bo'lsa, bu yerga qo'shing
  // Hozircha privacy policy bilan bir xil URL ishlatilmoqda
  static const String termsUrl =
      'https://docs.google.com/document/d/1UcdZv5QTRs2AheZlvroe0d86Dk2oILYB4R41Rp2pocE/edit?usp=sharing';

  Future<void> _openTerms(BuildContext context) async {
    try {
      final uri = Uri.parse(termsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('auth.terms.cannot_open'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('auth.terms.error'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          tr('about_app.terms'),
          style: AppTypography.headingL.copyWith(
            fontSize: 18.sp,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardBg : AppColors.white,
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.grayBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 48.sp,
                    color: AppColors.primaryBlue,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    tr('auth.terms.title'),
                    style: AppTypography.headingL.copyWith(
                      fontSize: 20.sp,
                      color: isDark ? AppColors.white : AppColors.black,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    tr('auth.terms.description'),
                    style: AppTypography.bodyPrimary.copyWith(
                      fontSize: 14.sp,
                      color: isDark ? AppColors.grayText : AppColors.bodyText,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _openTerms(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.open_in_new, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            tr('auth.terms.open_document'),
                            style: AppTypography.buttonPrimary.copyWith(
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              tr('auth.terms.note'),
              style: AppTypography.bodySecondary.copyWith(
                fontSize: 12.sp,
                color: isDark ? AppColors.grayText : AppColors.labelText,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

