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
import '../../../common/utils/bank_assets.dart';

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
            _ServiceIcon(
              icon: icon,
              iconColor: iconColor,
              bgColor: iconBgColor,
            ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final greenBg = isDark ? const Color(0xFF1A3A2E) : const Color(0xFFECFDF5);
    const greenText = Color(0xFF059669);
    final redBg = isDark ? const Color(0xFF3A1E1E) : const Color(0xFFFEF2F2);
    const redText = Color(0xFFDC2626);

    return BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (context, state) {
        CurrencyEntity? bestBuyBank;
        CurrencyEntity? bestSellBank;
        bool isLoading = state is CurrencyLoading;

        if (state is CurrencyLoaded) {
          // Valyuta sahifasidagi kabi bir xil logika
          // USD bo'yicha filtrlash (valyuta sahifasidagi kabi)
          var filteredCurrencies = List<CurrencyEntity>.from(state.currencies);
          filteredCurrencies = filteredCurrencies
              .where((currency) => currency.currencyCode.toUpperCase() == 'USD')
              .toList();

          // Eng arzon sotib olish kursi va eng baland sotish kursi
          // (valyuta sahifasidagi kabi reduce metodi)
          if (filteredCurrencies.isNotEmpty) {
            bestBuyBank = filteredCurrencies.reduce(
              (a, b) => a.buyRate < b.buyRate ? a : b,
            );
            bestSellBank = filteredCurrencies.reduce(
              (a, b) => a.sellRate > b.sellRate ? a : b,
            );
          }
        }

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: _cardDecoration(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ServiceIcon(
                  icon: icon,
                  iconColor: iconColor,
                  bgColor: iconBgColor,
                ),
                SizedBox(height: 10.h),
                Text(
                  title,
                  style: AppTypography.headingL.copyWith(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                SizedBox(height: 6.h),
                const Spacer(),
                if (isLoading) ...[
                  // Loading state
                  SizedBox(
                    height: 60.h,
                    child: Center(
                      child: SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ] else if (bestBuyBank != null && bestSellBank != null) ...[
                  // Best Buy Bank - eng past buyRate
                  _MiniBankCard(
                    bank: bestBuyBank,
                    isBuy: true,
                    greenBg: greenBg,
                    greenText: greenText,
                  ),
                  SizedBox(height: 8.h),
                  // Best Sell Bank - eng baland sellRate
                  _MiniBankCard(
                    bank: bestSellBank,
                    isBuy: false,
                    greenBg: redBg,
                    greenText: redText,
                  ),
                ] else if (bestBuyBank != null || bestSellBank != null) ...[
                  // Agar faqat bitta bank topilsa
                  if (bestBuyBank != null)
                    _MiniBankCard(
                      bank: bestBuyBank,
                      isBuy: true,
                      greenBg: greenBg,
                      greenText: greenText,
                    ),
                  if (bestBuyBank != null && bestSellBank != null)
                    SizedBox(height: 8.h),
                  if (bestSellBank != null)
                    _MiniBankCard(
                      bank: bestSellBank,
                      isBuy: false,
                      greenBg: redBg,
                      greenText: redText,
                    ),
                ] else ...[
                  // Placeholder - agar kurslar topilmasa
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

class _MiniBankCard extends StatelessWidget {
  final CurrencyEntity bank;
  final bool isBuy;
  final Color greenBg;
  final Color greenText;

  const _MiniBankCard({
    required this.bank,
    required this.isBuy,
    required this.greenBg,
    required this.greenText,
  });

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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: greenBg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Bank logo
          _MiniBankLogo(bankName: bank.bankName),
          SizedBox(width: 8.w),
          // Bank name and rate
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isBuy
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: greenText,
                      size: 10.sp,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        bank.bankName,
                        style: AppTypography.bodySecondary.copyWith(
                          fontSize: 11.sp,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(isBuy ? bank.buyRate : bank.sellRate),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: greenText,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Text(
                        tr('currency.som'),
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: greenText.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBankLogo extends StatelessWidget {
  final String bankName;

  const _MiniBankLogo({required this.bankName});

  @override
  Widget build(BuildContext context) {
    final logoAsset = bankLogoAsset(bankName);
    final shouldContain = bankLogoUsesContainFit(bankName);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEFF6FF);

    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: logoAsset != null
          ? Builder(
              builder: (context) {
                final image = Image.asset(
                  logoAsset,
                  fit: shouldContain ? BoxFit.contain : BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder();
                  },
                );
                if (shouldContain) {
                  return Padding(padding: EdgeInsets.all(4.w), child: image);
                }
                return image;
              },
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Text(
        bankName.isNotEmpty ? bankName[0].toUpperCase() : 'B',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.skyAccent,
        ),
      ),
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
