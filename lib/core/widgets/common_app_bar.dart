import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? titleKey;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CommonAppBar({
    super.key,
    this.title,
    this.titleKey,
    this.showBackButton = true,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
  }) : assert(title != null || titleKey != null, 'Either title or titleKey must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AppBar(
      backgroundColor: backgroundColor ?? 
          (theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: foregroundColor ?? 
                        (theme.iconTheme.color ?? 
                            (isDark ? AppColors.white : AppColors.black)),
                    size: 24.sp,
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              : null),
      title: Text(
        title ?? (titleKey != null ? tr(titleKey!) : ''),
        style: AppTypography.headingL.copyWith(
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? 
              (theme.textTheme.titleLarge?.color ?? 
                  (isDark ? AppColors.white : AppColors.black)),
        ),
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Divider(
          height: 1,
          thickness: 1,
          color: isDark ? AppColors.gray500 : AppColors.divider,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}

