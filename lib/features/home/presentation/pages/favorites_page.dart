import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('home.favorites'.tr()),
        automaticallyImplyLeading: false,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 110.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 80.sp,
                color: isDark ? AppColors.gray500 : AppColors.grayText,
              ),
              SizedBox(height: 20.h),
              Text(
                tr('home.favorites_empty'),
                style: TextStyle(
                  fontSize: 18.sp,
                  color: theme.textTheme.titleMedium?.color ?? 
                      (isDark ? AppColors.white : AppColors.black),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                tr('home.favorites_empty_subtitle'),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: theme.textTheme.bodySmall?.color ?? 
                      (isDark ? AppColors.gray500 : AppColors.grayText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

