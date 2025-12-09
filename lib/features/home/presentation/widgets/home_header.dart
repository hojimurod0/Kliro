import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/auth/auth_service.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const HomeHeader({super.key, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: FutureBuilder<AuthUser?>(
        future: AuthService.instance.fetchActiveUser(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          final initials = user?.initials;
          final firstName = user?.firstName ?? '';
          final hasValidInitials = initials != null && initials.isNotEmpty;
          return Row(
            children: [
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: hasValidInitials
                        ? Text(
                            initials,
                            style: AppTypography.headingL.copyWith(
                              color: AppColors.white,
                              fontSize: 16.sp,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: AppColors.white,
                            size: 24.sp,
                          ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'home.welcome'.tr(),
                      style: AppTypography.bodyPrimary.copyWith(
                        fontSize: 12.sp,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      firstName.isNotEmpty ? firstName : 'home.welcome'.tr(),
                      style: AppTypography.headingL.copyWith(
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              const _CircleIcon(icon: Icons.search),
              SizedBox(width: 8.w),
              Stack(
                children: [
                  const _CircleIcon(icon: Icons.notifications_none_rounded),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: AppColors.dangerRed,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  const _CircleIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Theme.of(context).iconTheme.color ?? AppColors.black,
        size: 24.sp,
      ),
    );
  }
}
