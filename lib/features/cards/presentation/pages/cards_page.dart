import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/datasources/card_local_data_source.dart';
import '../../data/repositories/card_repository_impl.dart';
import '../../domain/entities/card_offer.dart';
import '../../domain/usecases/get_card_offers.dart';

@RoutePage()
class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  late final GetCardOffers _getCardOffers;
  List<CardOffer> _offers = [];
  bool _isLoading = true;
  int _selectedFilterIndex = 0;

  final List<String> cardTypes = const [
    'Uzcard',
    'Humo',
    'Visa',
    'Mastercard',
    'UnionPay',
  ];
  
  String _getCardTypeLabel(String type) {
    switch (type) {
      case 'Uzcard':
        return 'cards.uzcard'.tr();
      case 'Humo':
        return 'cards.humo'.tr();
      case 'Visa':
        return 'cards.visa'.tr();
      case 'Mastercard':
        return 'cards.mastercard'.tr();
      case 'UnionPay':
        return 'cards.unionpay'.tr();
      default:
        return type;
    }
  }

  @override
  void initState() {
    super.initState();
    _getCardOffers = GetCardOffers(
      CardRepositoryImpl(
        localDataSource: const CardLocalDataSource(),
      ),
    );
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final offers = await _getCardOffers();
      setState(() {
        _offers = offers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('common.error'.tr()),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CommonAppBar(
        titleKey: 'cards.title',
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: SearchBarWidget(
              hintText: tr('cards.search_hint'),
            ),
          ),
          SizedBox(
            height: 40.h,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              itemCount: cardTypes.length,
              itemBuilder: (context, index) {
                return CardTypeTag(
                  label: _getCardTypeLabel(cardTypes[index]),
                  isSelected: index == _selectedFilterIndex,
                  onTap: () {
                    setState(() {
                      _selectedFilterIndex = index;
                    });
                  },
                );
              },
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: _isLoading
                ? LoadingStateWidget(message: 'common.loading'.tr())
                : _offers.isEmpty
                    ? EmptyStateWidget(
                        messageKey: 'cards.empty',
                        icon: Icons.credit_card_outlined,
                      )
                    : ListView(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        children: [
                          ..._offers.map(
                            (offer) => Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: CardOfferWidget(offer: offer),
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

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key, required this.hintText});

  final String hintText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.bodyPrimary.copyWith(
            color: theme.textTheme.bodySmall?.color ??
                (isDark ? AppColors.gray500 : AppColors.mutedText),
            fontSize: 16.sp,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.primary,
            size: 24.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: 14.h,
            horizontal: 8.w,
          ),
        ),
        style: AppTypography.bodyPrimary.copyWith(
          color: theme.textTheme.bodyLarge?.color ??
              (isDark ? AppColors.white : AppColors.darkText),
        ),
      ),
    );
  }
}

class CardTypeTag extends StatelessWidget {
  const CardTypeTag({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: InkWell(
        onTap: onTap,
        child: Chip(
          label: Text(
            label,
            style: AppTypography.chip.copyWith(
              color: isSelected 
                  ? AppColors.primaryBlue 
                  : (theme.textTheme.bodyLarge?.color ??
                      (isDark ? AppColors.white : AppColors.darkText)),
              fontSize: 14.sp,
            ),
          ),
          backgroundColor: isSelected
              ? (isDark
                  ? AppColors.primaryBlue.withOpacity(0.2)
                  : AppColors.secondaryBlue)
              : theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
            side: BorderSide(
              color: isSelected
                  ? AppColors.primaryBlue
                  : theme.dividerColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0),
        ),
      ),
    );
  }
}

class CardOfferWidget extends StatelessWidget {
  const CardOfferWidget({super.key, required this.offer});

  final CardOffer offer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(isDark ? 0.1 : 0.04),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopCardSection(),
          _buildMetricsGrid(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                _buildAdvantagesRow(context),
                SizedBox(height: 16.h),
                _buildActionButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCardSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: offer.isPrimaryCard
            ? const Color(0xFF2196F3)
            : AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                offer.bankName,
                style: AppTypography.bodyPrimary.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              CardCornerTag(
                label: offer.cardTag,
                backgroundColor: AppColors.cardBackground,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            offer.cardName,
            style: AppTypography.headingXL.copyWith(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('cards.currency'),
                    style: AppTypography.bodySecondary.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        offer.currency,
                        style: AppTypography.headingL.copyWith(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.star, color: Colors.amber, size: 18.sp),
                      Text(
                        '${offer.rating}',
                        style: AppTypography.headingL.copyWith(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              CardCornerTag(
                label: offer.typeTag,
                icon: Icons.ssid_chart,
                backgroundColor: AppColors.cardBackground,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
          childAspectRatio: 2.2,
        ),
        itemCount: offer.metrics.length,
        itemBuilder: (context, index) {
          final metric = offer.metrics[index];
          return CardMetricBox(
            icon: metric.icon,
            label: metric.label,
            value: metric.value,
            valueColor: metric.valueColor,
          );
        },
      ),
    );
  }

  Widget _buildAdvantagesRow(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: isDark
            ? AppColors.midnight
            : AppColors.metricBoxBackground,
      ),
      padding: EdgeInsets.all(15.w),
      child: Row(
        children: [
          Text(
            tr('cards.advantages', namedArgs: {'count': offer.advantagesCount.toString()}),
            style: AppTypography.headingL.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.titleLarge?.color ??
                  (isDark ? AppColors.white : AppColors.darkText),
            ),
          ),
          const Spacer(),
          Icon(
            Icons.keyboard_arrow_down,
            color: theme.iconTheme.color ??
                (isDark ? AppColors.white : AppColors.darkText),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (!offer.isPrimaryCard) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Navigate to order page
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Text(
          tr('cards.order'),
          style: AppTypography.buttonPrimary.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

class CardMetricBox extends StatelessWidget {
  const CardMetricBox({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.midnight
            : AppColors.metricBoxBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: theme.textTheme.bodySmall?.color ??
                    (isDark ? AppColors.gray500 : AppColors.mutedText),
                size: 16.sp,
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.bodySecondary.copyWith(
                    fontSize: 12.sp,
                    color: theme.textTheme.bodySmall?.color ??
                        (isDark ? AppColors.gray500 : AppColors.mutedText),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: AppTypography.headingL.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class CardCornerTag extends StatelessWidget {
  const CardCornerTag({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor = AppColors.cardTagBackground,
  });

  final String label;
  final IconData? icon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: Icon(icon, color: AppColors.primaryBlue, size: 14.sp),
            ),
          Text(
            label,
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

