import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../bank/domain/entities/currency_entity.dart';
import '../../../bank/presentation/bloc/currency_bloc.dart';
import '../../../bank/presentation/bloc/currency_event.dart';
import '../../../bank/presentation/bloc/currency_state.dart';

class HomeServicesGrid extends StatelessWidget {
  final VoidCallback onBankTap;
  final VoidCallback? onInsuranceTap;
  const HomeServicesGrid({
    super.key,
    required this.onBankTap,
    this.onInsuranceTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280.h,
      child: Row(
        children: [
          Flexible(
            flex: 55,
            child: _LargeServiceCard(
              title: 'home.bank'.tr(),
              subtitle: 'home.bank_services_count'.tr(),
              icon: Icons.business_rounded,
              iconColor: AppColors.lilacIcon,
              iconBgColor: AppColors.lilacSurface,
              onTap: onBankTap,
              isBankCard: true,
            ),
          ),
          SizedBox(width: 16.w),
          Flexible(
            flex: 45,
            child: Column(
              children: [
                _MiniServiceCard(
                  title: 'home.insurance'.tr(),
                  subtitle: 'home.insurance_types'.tr(),
                  icon: Icons.shield_outlined,
                  iconColor: AppColors.pinkAccent,
                  iconBgColor: AppColors.pinkSurface,
                  onTap: onInsuranceTap,
                ),
                SizedBox(height: 12.h),
                _MiniServiceCard(
                  title: 'home.flights'.tr(),
                  subtitle: 'home.flights_subtitle'.tr(),
                  icon: Icons.flight_rounded,
                  iconColor: AppColors.skyAccent,
                  iconBgColor: AppColors.skySurface,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LargeServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback onTap;
  final bool isBankCard;

  const _LargeServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.onTap,
    this.isBankCard = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isBankCard) {
      return BlocProvider(
        create: (context) =>
            ServiceLocator.resolve<CurrencyBloc>()
              ..add(const LoadCurrenciesEvent()),
        child: _BankCardWithCurrency(
          title: title,
          subtitle: subtitle,
          icon: icon,
          iconColor: iconColor,
          iconBgColor: iconBgColor,
          onTap: onTap,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: _cardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ServiceIcon(icon: icon, iconColor: iconColor, bgColor: iconBgColor),
            const Spacer(),
            Text(
              title,
              style: AppTypography.headingL.copyWith(
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              style: AppTypography.bodySecondary.copyWith(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankCardWithCurrency extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback onTap;

  const _BankCardWithCurrency({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.onTap,
  });

  CurrencyEntity? _getCheapestUSDCurrency(List<CurrencyEntity> currencies) {
    final usdCurrencies = currencies
        .where((c) => c.currencyCode.toUpperCase() == 'USD')
        .toList();
    if (usdCurrencies.isEmpty) return null;
    usdCurrencies.sort((a, b) => a.buyRate.compareTo(b.buyRate));
    return usdCurrencies.first;
  }

  String _formatCurrency(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final greenBg = isDark ? const Color(0xFF1A3A2E) : const Color(0xFFECFDF5);
    const greenText = Color(0xFF059669);
    final redBg = isDark ? const Color(0xFF3A1E1E) : const Color(0xFFFEF2F2);
    const redText = Color(0xFFDC2626);

    return BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (context, state) {
        CurrencyEntity? cheapestCurrency;
        if (state is CurrencyLoaded) {
          cheapestCurrency = _getCheapestUSDCurrency(state.currencies);
        }

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: _cardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ServiceIcon(icon: icon, iconColor: iconColor, bgColor: iconBgColor),
                SizedBox(height: 10.h),
                Text(
                  title,
                  style: AppTypography.headingL.copyWith(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                SizedBox(height: 6.h),
                const Spacer(),
                if (cheapestCurrency != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 14.sp,
                        color: Theme.of(context).textTheme.bodyMedium?.color ??
                            const Color(0xFF6B7280),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Valyuta kursi',
                        style: AppTypography.bodySecondary.copyWith(
                          fontSize: 12.sp,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: greenBg,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.trending_up_rounded,
                                    color: greenText,
                                    size: 12.sp,
                                  ),
                                  SizedBox(width: 3.w),
                                  Flexible(
                                    child: Text(
                                      tr('currency.buy'),
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Theme.of(context)
                                                .textTheme.bodyMedium?.color ??
                                            const Color(0xFF374151),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 3.h),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _formatCurrency(cheapestCurrency.buyRate),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: greenText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: redBg,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.trending_down_rounded,
                                    color: redText,
                                    size: 12.sp,
                                  ),
                                  SizedBox(width: 3.w),
                                  Flexible(
                                    child: Text(
                                      tr('currency.sell'),
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Theme.of(context)
                                                .textTheme.bodyMedium?.color ??
                                            const Color(0xFF374151),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 3.h),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _formatCurrency(cheapestCurrency.sellRate),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: redText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Placeholder для kurslar yuklanmaganda ham bir xil o'lcham saqlash uchun
                  SizedBox(
                    height: 60.h,
                    child: Center(
                      child: Text(
                        subtitle,
                        style: AppTypography.bodySecondary.copyWith(
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MiniServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback? onTap;

  _MiniServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: _cardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _ServiceIcon(
                icon: icon,
                iconColor: iconColor,
                bgColor: iconBgColor,
                size: 40,
                radius: 14,
              ),
              SizedBox(height: 8.h),
              Flexible(
                child: Text(
                  title,
                  style: AppTypography.headingL.copyWith(
                    fontSize: 16.sp,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 2.h),
              Flexible(
                child: Text(
                  subtitle,
                  style: AppTypography.bodySecondary.copyWith(
                    fontSize: 12.sp,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final double size;
  final double radius;

  const _ServiceIcon({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.size = 56,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius.r),
      ),
      child: Icon(icon, color: iconColor, size: 0.5 * size.sp),
    );
  }
}

BoxDecoration _cardDecoration(BuildContext context) {
  return BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(28.r),
    boxShadow: [
      BoxShadow(
        color: Theme.of(context).shadowColor.withOpacity(0.04),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

class HomeWideServiceCard extends StatelessWidget {
  const HomeWideServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: _cardDecoration(context),
      child: Row(
        children: [
          _ServiceIcon(
            icon: Icons.apartment,
            iconColor: AppColors.greenIcon,
            bgColor: AppColors.greenBg,
            size: 48,
            radius: 16,
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'home.hotels'.tr(),
                style: AppTypography.headingL.copyWith(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              Text(
                'home.hotels_subtitle'.tr(),
                style: AppTypography.bodyPrimary.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).iconTheme.color ?? AppColors.grayText,
          ),
        ],
      ),
    );
  }
}

