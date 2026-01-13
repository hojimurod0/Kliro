import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/navigation/app_router.dart';

enum BannerType { travel, bank, insurance }

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;

    return Container(
      height: 220.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
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
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: 3,
            itemBuilder: (context, index) {
              final bannerType = BannerType.values[index];
              return _BannerPage(
                key: ValueKey('${bannerType.toString()}_${locale.toString()}'),
                bannerType: bannerType,
              );
            },
          ),
          // Page indicators
          Positioned(
            bottom: 16.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => _PageIndicator(
                  isActive: index == _currentPage,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerPage extends StatelessWidget {
  final BannerType bannerType;

  const _BannerPage({super.key, required this.bannerType});

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;

    // Har bir banner turi uchun rang va ikon
    Color primaryColor;
    IconData icon;
    String? imagePath;

    switch (bannerType) {
      case BannerType.travel:
        primaryColor = AppColors.primaryBlue;
        icon = Icons.flight_takeoff;
        imagePath = 'assets/images/homebannerr.png';
        break;
      case BannerType.bank:
        primaryColor = const Color(0xFF10B981); // Green
        icon = Icons.account_balance;
        imagePath = null; // Rasm yo'q, faqat kulrang fon
        break;
      case BannerType.insurance:
        primaryColor = const Color(0xFFF59E0B); // Orange
        icon = Icons.shield;
        imagePath = null; // Rasm yo'q, faqat kulrang fon
        break;
    }

    return Stack(
      children: [
        // Background image yoki kulrang fon
        ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24.r),
            bottomRight: Radius.circular(24.r),
          ),
          child: bannerType == BannerType.travel
              ? ColorFiltered(
                  colorFilter: ColorFilter.matrix([
                    1.7, 0, 0, 0, 0,
                    0, 1.7, 0, 0, 0,
                    0, 0, 1.7, 0, 0,
                    0, 0, 0, 1, 0.7,
                  ]),
                  child: Image.asset(
                    imagePath!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Travel uchun gradient fallback
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryColor.withOpacity(0.8),
                              primaryColor.withOpacity(0.6),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Container(
                  // Bank va sug'urta uchun qoraroq fon (textlar ko'rinishi uchun)
                  color: Colors.grey[800],
                ),
        ),
        // Gradient overlay
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
                AppColors.black.withOpacity(0.0),
                AppColors.black.withOpacity(0.08),
              ],
            ),
          ),
        ),
        // Content
        Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BannerChip(
                key: ValueKey('chip_${bannerType.toString()}_${locale.toString()}'),
                bannerType: bannerType,
                icon: icon,
              ),
              const Spacer(),
              Text(
                _getTitle(bannerType),
                style: AppTypography.headingXL(context).copyWith(
                  color: AppColors.white,
                ),
                key: ValueKey('title_${bannerType.toString()}_${locale.toString()}'),
              ),
              SizedBox(height: 4.h),
              Text(
                _getSubtitle(bannerType),
                style: AppTypography.bodyPrimary(context).copyWith(
                  color: AppColors.white.withOpacity(0.8),
                  fontSize: 14.sp,
                ),
                key: ValueKey('subtitle_${bannerType.toString()}_${locale.toString()}'),
              ),
              SizedBox(height: 16.h),
              _BannerButton(
                key: ValueKey('button_${bannerType.toString()}_${locale.toString()}'),
                bannerType: bannerType,
              ),
            ],
          ),
        ),
        Positioned(
          top: 20.h,
          right: 20.w,
          child: Icon(Icons.more_horiz, color: AppColors.white, size: 24.sp),
        ),
      ],
    );
  }

  String _getTitle(BannerType type) {
    switch (type) {
      case BannerType.travel:
        return 'home.banner.travel.title'.tr();
      case BannerType.bank:
        return 'home.banner.bank.title'.tr();
      case BannerType.insurance:
        return 'home.banner.insurance.title'.tr();
    }
  }

  String _getSubtitle(BannerType type) {
    switch (type) {
      case BannerType.travel:
        return 'home.banner.travel.subtitle'.tr();
      case BannerType.bank:
        return 'home.banner.bank.subtitle'.tr();
      case BannerType.insurance:
        return 'home.banner.insurance.subtitle'.tr();
    }
  }
}

class _BannerChip extends StatelessWidget {
  final BannerType bannerType;
  final IconData icon;

  const _BannerChip({
    super.key,
    required this.bannerType,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;

    String label;
    switch (bannerType) {
      case BannerType.travel:
        label = 'home.banner.travel.label'.tr();
        break;
      case BannerType.bank:
        label = 'home.banner.bank.label'.tr();
        break;
      case BannerType.insurance:
        label = 'home.banner.insurance.label'.tr();
        break;
    }

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
          Icon(icon, color: AppColors.white, size: 14.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            key: ValueKey('label_${bannerType.toString()}_${locale.toString()}'),
            style: AppTypography.labelSmall(context).copyWith(
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
  final BannerType bannerType;

  const _BannerButton({super.key, required this.bannerType});

  void _navigateToRoute(BuildContext context) {
    switch (bannerType) {
      case BannerType.travel:
        context.router.push(const AvichiptalarModuleRoute());
        break;
      case BannerType.bank:
        context.router.push(BankServicesRoute());
        break;
      case BannerType.insurance:
        context.router.push(InsuranceServicesRoute());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;

    String buttonText;
    switch (bannerType) {
      case BannerType.travel:
        buttonText = 'home.banner.travel.book'.tr();
        break;
      case BannerType.bank:
        buttonText = 'home.banner.bank.book'.tr();
        break;
      case BannerType.insurance:
        buttonText = 'home.banner.insurance.book'.tr();
        break;
    }

    return GestureDetector(
      onTap: () {
        _navigateToRoute(context);
      },
      child: Container(
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
              buttonText,
              key: ValueKey('book_${bannerType.toString()}_${locale.toString()}'),
              style: AppTypography.bodyPrimary(context).copyWith(
                color: AppColors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward, color: AppColors.white, size: 18.sp),
          ],
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final bool isActive;

  const _PageIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      width: isActive ? 24.w : 8.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.white
            : AppColors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
