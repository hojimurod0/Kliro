import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class HomeNewsSection extends StatefulWidget {
  const HomeNewsSection({super.key});

  @override
  State<HomeNewsSection> createState() => _HomeNewsSectionState();
}

class _HomeNewsSectionState extends State<HomeNewsSection> {
  late PageController _controller;
  double _page = 0;
  Locale? _currentLocale;

  List<HomeNewsItem> _newsItems(BuildContext context) => [
    HomeNewsItem(
      titleKey: 'home.news_items.item1.title',
      tagKey: 'home.news_items.item1.tag',
      dateKey: 'home.news_items.item1.date',
      imagePath: 'assets/images/gazetaa.png',
    ),
    HomeNewsItem(
      titleKey: 'home.news_items.item2.title',
      tagKey: 'home.news_items.item2.tag',
      dateKey: 'home.news_items.item2.date',
      imagePath: 'assets/images/gazetaa.png',
    ),
    HomeNewsItem(
      titleKey: 'home.news_items.item3.title',
      tagKey: 'home.news_items.item3.tag',
      dateKey: 'home.news_items.item3.date',
      imagePath: 'assets/images/gazetaa.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.85)
      ..addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Locale o'zgarganda rebuild qilish
    final newLocale = context.locale;
    if (_currentLocale == null ||
        _currentLocale!.languageCode != newLocale.languageCode ||
        _currentLocale!.countryCode != newLocale.countryCode) {
      _currentLocale = newLocale;
      if (mounted) {
        setState(() {}); // Locale o'zgarganda rebuild qilish
      }
    }
  }

  void _onScroll() {
    if (!mounted) return;
    setState(() => _page = _controller.page ?? 0);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'home.news'.tr(),
                  style: AppTypography.headingL(context).copyWith(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.newspaper,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20.sp,
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'home.view_all'.tr(),
                style: AppTypography.chip(context).copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 280.h,
          child: PageView.builder(
            key: ValueKey(context.locale.toString()),
            controller: _controller,
            itemCount: _newsItems(context).length,
            padEnds: false,
            itemBuilder: (context, index) {
              final item = _newsItems(context)[index];
              final scale = (1 - ((_page - index).abs() * 0.08))
                  .clamp(0.92, 1.0)
                  .toDouble();

              return Transform.scale(
                scale: scale,
                alignment: Alignment.topCenter,
                child: _NewsCard(
                  key: ValueKey('${item.titleKey}_${context.locale}'),
                  item: item,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  final HomeNewsItem item;
  const _NewsCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 16.w, bottom: 10.h),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            child: Image.asset(
              item.imagePath,
              height: 160.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 160.h,
                color: Theme.of(context).cardColor,
                child: Icon(
                  Icons.image_not_supported,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        item.getTag(context),
                        style: AppTypography.labelSmall(context).copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Icon(
                      Icons.calendar_today,
                      size: 12.sp,
                      color:
                          Theme.of(context).textTheme.bodySmall?.color ??
                          AppColors.grayText,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      item.getDate(context),
                      style: AppTypography.caption(context).copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  item.getTitle(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headingL(context).copyWith(
                    fontSize: 16.sp,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeNewsItem {
  final String titleKey;
  final String tagKey;
  final String dateKey;
  final String imagePath;

  const HomeNewsItem({
    required this.titleKey,
    required this.tagKey,
    required this.dateKey,
    required this.imagePath,
  });

  String getTitle(BuildContext context) => context.tr(titleKey);
  String getTag(BuildContext context) => context.tr(tagKey);
  String getDate(BuildContext context) => context.tr(dateKey);
}

BoxDecoration _cardDecoration(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(24.r),
    boxShadow: [
      BoxShadow(
        color: Theme.of(context).shadowColor.withOpacity(0.03),
        blurRadius: 15,
        offset: const Offset(0, 5),
      ),
    ],
  );
}
