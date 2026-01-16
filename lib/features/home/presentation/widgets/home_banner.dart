import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/navigation/app_router.dart';

enum BannerType { travel, bank, insurance, hotel }

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      _goToPage(_currentPage + 1, animated: true);
    });
  }

  // Keep `animated` optional to be hot-reload-safe with older code that may call:
  // `_goToPage(x, animated: true)`.
  void _goToPage(int index, {bool animated = false}) {
    final length = BannerType.values.length;
    final next = (index % length + length) % length; // supports negative
    if (next == _currentPage) return;
    setState(() => _currentPage = next);
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final bannerType = BannerType.values[_currentPage];

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
          GestureDetector(
            onHorizontalDragEnd: (details) {
              final v = details.primaryVelocity ?? 0;
              if (v == 0) return;
              if (v < 0) {
                _goToPage(_currentPage + 1); // swipe left -> next
              } else {
                _goToPage(_currentPage - 1); // swipe right -> prev
              }
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 650),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              transitionBuilder: (child, animation) {
                final fade = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                );
                final scale = Tween<double>(begin: 0.985, end: 1.0).animate(
                  CurvedAnimation(
                      parent: animation, curve: Curves.easeOutCubic),
                );
                return FadeTransition(
                  opacity: fade,
                  child: ScaleTransition(scale: scale, child: child),
                );
              },
              child: _BannerPage(
                key: ValueKey('${bannerType.toString()}_${locale.toString()}'),
                bannerType: bannerType,
              ),
            ),
          ),
          // Page indicators
          Positioned(
            bottom: 16.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                BannerType.values.length,
                (index) => GestureDetector(
                  onTap: () => _goToPage(index, animated: true),
                  child: _PageIndicator(isActive: index == _currentPage),
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

  // Banner rasmlarida "fon" bir xil ko'rinishi uchun hammasiga bir xil overlay/gradient qo'llaymiz.
  static const double _imageOverlayOpacity = 0.07;
  static const double _gradientTopOpacity = 0.04;
  static const double _gradientBottomOpacity = 0.14;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;

    // Har bir banner turi uchun rang va ikon
    late final Color primaryColor;
    late final IconData icon;
    late final String imagePath;

    switch (bannerType) {
      case BannerType.travel:
        primaryColor = AppColors.primaryBlue;
        icon = Icons.flight_takeoff;
        imagePath = 'assets/images/pilot1.jpeg';
        break;
      case BannerType.bank:
        primaryColor = const Color(0xFF10B981); // Green
        icon = Icons.account_balance;
        imagePath = 'assets/images/bank1.png';
        break;
      case BannerType.insurance:
        primaryColor = const Color(0xFFF59E0B); // Orange
        icon = Icons.shield;
        imagePath = 'assets/images/main.jpg';
        break;
      case BannerType.hotel:
        primaryColor = const Color(0xFF22C55E); // Green-ish
        icon = Icons.hotel_rounded;
        imagePath = 'assets/images/hilton1.jpg';
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              Builder(
                builder: (context) {
                  Widget image = Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
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
                  );

                  // Sayohatlar banneri haddan tashqari qorayib ketmasligi uchun
                  // rasmni biroz yorug'roq qilib yuboramiz (overlay hamon bir xil).
                  if (bannerType == BannerType.travel) {
                    image = ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        1.18,
                        0,
                        0,
                        0,
                        18,
                        0,
                        1.18,
                        0,
                        0,
                        18,
                        0,
                        0,
                        1.18,
                        0,
                        18,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                      child: image,
                    );
                  }

                  return image;
                },
              ),
              // Uniform "fon" (qoraytirish) overlay barcha rasmlar uchun bir xil
              Container(color: Colors.black.withOpacity(_imageOverlayOpacity)),
            ],
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
                AppColors.black.withOpacity(_gradientTopOpacity),
                AppColors.black.withOpacity(_gradientBottomOpacity),
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
                key: ValueKey(
                    'chip_${bannerType.toString()}_${locale.toString()}'),
                bannerType: bannerType,
                icon: icon,
              ),
              const Spacer(),
              Text(
                _getTitle(bannerType),
                style: AppTypography.headingXL(context).copyWith(
                  color: AppColors.white,
                ),
                key: ValueKey(
                    'title_${bannerType.toString()}_${locale.toString()}'),
              ),
              SizedBox(height: 4.h),
              Text(
                _getSubtitle(bannerType),
                style: AppTypography.bodyPrimary(context).copyWith(
                  color: AppColors.white.withOpacity(0.8),
                  fontSize: 14.sp,
                ),
                key: ValueKey(
                    'subtitle_${bannerType.toString()}_${locale.toString()}'),
              ),
              SizedBox(height: 16.h),
              Align(
                alignment: Alignment.centerRight,
                child: _BannerButton(
                  key: ValueKey(
                      'button_${bannerType.toString()}_${locale.toString()}'),
                  bannerType: bannerType,
                ),
              ),
            ],
          ),
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
      case BannerType.hotel:
        return 'home.banner.hotel.title'.tr();
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
      case BannerType.hotel:
        return 'home.banner.hotel.subtitle'.tr();
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
      case BannerType.hotel:
        label = 'home.banner.hotel.label'.tr();
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
            key:
                ValueKey('label_${bannerType.toString()}_${locale.toString()}'),
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
      case BannerType.hotel:
        context.router.push(HotelModuleRoute());
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
      case BannerType.hotel:
        buttonText = 'home.banner.hotel.book'.tr();
        break;
    }

    return GestureDetector(
      onTap: () {
        _navigateToRoute(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.white.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              buttonText,
              key: ValueKey(
                  'book_${bannerType.toString()}_${locale.toString()}'),
              style: AppTypography.bodyPrimary(context).copyWith(
                color: AppColors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 6.w),
            Icon(Icons.arrow_forward, color: AppColors.white, size: 14.sp),
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
        color: isActive ? AppColors.white : AppColors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
