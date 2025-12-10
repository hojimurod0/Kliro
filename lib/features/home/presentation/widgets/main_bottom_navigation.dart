import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';

enum TabItem { home, service, favorite, profile }

class MainBottomNavigation extends StatelessWidget {
  final TabItem currentTab;
  final ValueChanged<TabItem> onTabChanged;

  static const _animationDuration = Duration(milliseconds: 350);
  static const _animationCurve = Curves.fastOutSlowIn;

  const MainBottomNavigation({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Locale o'zgarishini kuzatish uchun context.locale ni ishlatamiz
    final locale = context.locale;
    return Container(
      key: ValueKey('bottom_nav_${locale.toString()}'),
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 18.h),
      padding: EdgeInsets.all(5.w),
      height: 64.h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final partWidth = totalWidth / 6;
          final activeWidth = partWidth * 3;
          final inactiveWidth = partWidth;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: _animationDuration,
                curve: _animationCurve,
                left: currentTab.index * inactiveWidth,
                top: 0,
                bottom: 0,
                width: activeWidth,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.phoneGradient,
                    borderRadius: BorderRadius.circular(30.r),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Builder(
                builder: (context) {
                  // Locale o'zgarishini kuzatish uchun Builder ishlatamiz
                  final locale = context.locale;
                  return Row(
                    children: TabItem.values.map((item) {
                      final isActive = currentTab == item;
                      return _buildItem(
                        context,
                        item: item,
                        isActive: isActive,
                        width: isActive ? activeWidth : inactiveWidth,
                        locale: locale,
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required TabItem item,
    required bool isActive,
    required double width,
    required Locale locale,
  }) {
    late final IconData icon;
    late final String label;

    switch (item) {
      case TabItem.home:
        icon = Icons.home_rounded;
        label = context.tr('home.home');
        break;
      case TabItem.service:
        icon = Icons.grid_view_rounded;
        label = context.tr('home.services');
        break;
      case TabItem.favorite:
        icon = Icons.favorite_rounded;
        label = context.tr('home.favorites');
        break;
      case TabItem.profile:
        icon = Icons.person_rounded;
        label = context.tr('profile.title');
        break;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTabChanged(item),
      child: AnimatedContainer(
        duration: _animationDuration,
        curve: _animationCurve,
        width: width,
        alignment: Alignment.center,
        child: ClipRect(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 26.sp,
                color: isActive
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).iconTheme.color?.withOpacity(0.6),
              ),
              AnimatedContainer(
                duration: _animationDuration,
                curve: _animationCurve,
                width: isActive ? 8.w : 0,
              ),
              Flexible(
                child: AnimatedOpacity(
                  duration: _animationDuration,
                  curve: _animationCurve,
                  opacity: isActive ? 1 : 0,
                  child: isActive
                      ? Text(
                          label,
                          key: ValueKey('${item.name}_${locale.toString()}'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onPrimary,
                            height: 1.2,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
