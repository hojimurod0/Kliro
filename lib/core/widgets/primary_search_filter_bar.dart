import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PrimarySearchFilterBar extends StatelessWidget {
  const PrimarySearchFilterBar({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    this.onFilterTap,
    this.hasActiveFilter = false,
    this.hintText = 'Qidirish...',
    this.padding,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilter;
  final String hintText;
  final EdgeInsetsGeometry? padding;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor =
        isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB);
    final searchBg =
        isDark ? const Color(0xFF1E1E1E) : theme.cardColor.withOpacity(0.95);
    final hintColor =
        theme.textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF);

    final content = Row(
      children: [
        Expanded(
          child: Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: searchBg,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: controller,
              onChanged: onSearchChanged,
              inputFormatters: inputFormatters,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color ?? const Color(0xFF111827),
                fontSize: 14.sp,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: hintColor, fontSize: 14.sp),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: const Color(0xFF0085FF),
                  size: 20.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                isCollapsed: true,
              ),
            ),
          ),
        ),
        if (onFilterTap != null) ...[
          SizedBox(width: 12.w),
          Container(
            height: 50.h,
            width: 50.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: hasActiveFilter ? const Color(0xFF0085FF) : borderColor,
              ),
              color: hasActiveFilter
                  ? const Color(0xFF0085FF).withOpacity(0.08)
                  : searchBg,
            ),
            child: IconButton(
              onPressed: onFilterTap,
              splashRadius: 24.r,
              icon: SvgPicture.asset(
                'assets/images/filtericon.svg',
                width: 20.w,
                height: 20.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ],
    );

    final resolvedPadding =
        padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h);

    return Padding(
      padding: resolvedPadding,
      child: content,
    );
  }
}

