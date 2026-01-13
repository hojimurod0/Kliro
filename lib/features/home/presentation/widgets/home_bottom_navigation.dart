import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class HomeBottomNavigation extends StatelessWidget {
  final VoidCallback onProfileTap;
  const HomeBottomNavigation({super.key, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _ActiveNavButton(),
          const _NavIcon(icon: Icons.grid_view_rounded),
          const _NavIcon(icon: Icons.favorite_border_rounded),
          _NavIcon(icon: Icons.person_outline_rounded, onTap: onProfileTap),
          SizedBox(width: 4.w),
        ],
      ),
    );
  }
}

class _ActiveNavButton extends StatelessWidget {
  const _ActiveNavButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.home_filled,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          SizedBox(width: 8.w),
          Text(
            'home.home'.tr(),
            style: AppTypography.bodyPrimary(context).copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Icon(
          icon,
          color: Theme.of(context).iconTheme.color ?? AppColors.grayText,
          size: 26.sp,
        ),
      ),
    );
  }
}

