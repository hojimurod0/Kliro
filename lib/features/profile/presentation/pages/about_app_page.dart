import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import 'privacy_policy_page.dart';
import 'terms_of_use_page.dart';

@RoutePage()
class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ??
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
          tr('about_app.title'),
          style: AppTypography.headingL(context).copyWith(
            fontSize: 18.sp,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 25.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: _buildKliroLogo(context),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              tr('about_app.description'),
              style: AppTypography.bodyPrimary(context).copyWith(
                fontSize: 16.sp,
                color:
                    Theme.of(context).textTheme.bodyLarge?.color ??
                    AppColors.bodyText,
                height: 1.4,
              ),
            ),
            SizedBox(height: 30.h),
            _buildLinkItem(context, tr('about_app.terms')),
            _buildLinkItem(context, tr('about_app.privacy')),
            _buildLinkItem(context, tr('about_app.license'), isLast: true),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildKliroLogo(BuildContext context) {
    return SizedBox(
      height: 60.h,
      child: SvgPicture.asset(
        'assets/images/klero_logo.svg',
        fit: BoxFit.contain,
        placeholderBuilder: (context) {
          final TextStyle baseStyle = AppTypography.headingL(context).copyWith(
            fontSize: 48.sp,
            letterSpacing: -1,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).textTheme.titleLarge?.color ??
                const Color(0xFF333333),
          );

          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('K', style: baseStyle),
              Text('L', style: baseStyle),
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Text('I', style: baseStyle),
                  Positioned(
                    top: 8.h,
                    child: Container(
                      width: 7.w,
                      height: 7.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(3.5.r),
                      ),
                    ),
                  ),
                ],
              ),
              Text('R', style: baseStyle),
              Text('O', style: baseStyle),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLinkItem(
    BuildContext context,
    String title, {
    bool isLast = false,
  }) {
    final isTerms = title == tr('about_app.terms');
    final isPrivacy = title == tr('about_app.privacy');
    
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (isTerms) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsOfUsePage(),
                ),
              );
            } else if (isPrivacy) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyPage(),
                ),
              );
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 15.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyPrimary(context).copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        AppColors.linkText,
                  ),
                ),
                Icon(
                  Icons.open_in_new_outlined,
                  color: AppColors.iconMuted,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            color: Theme.of(context).dividerColor,
            height: 10.h,
            thickness: 1,
          ),
      ],
    );
  }
}
