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

class HomeBestBanksCard extends StatelessWidget {
  const HomeBestBanksCard({super.key});

  CurrencyEntity? _getBestBuyBank(List<CurrencyEntity> currencies) {
    final usdCurrencies = currencies
        .where((c) => c.currencyCode.toUpperCase() == 'USD' && c.buyRate > 0)
        .toList();
    if (usdCurrencies.isEmpty) return null;
    // Eng baland buyRate - eng yaxshi narx
    usdCurrencies.sort((a, b) => b.buyRate.compareTo(a.buyRate));
    return usdCurrencies.first;
  }

  CurrencyEntity? _getBestSellBank(List<CurrencyEntity> currencies) {
    final usdCurrencies = currencies
        .where((c) => c.currencyCode.toUpperCase() == 'USD' && c.sellRate > 0)
        .toList();
    if (usdCurrencies.isEmpty) return null;
    // Eng arzon sellRate - eng yaxshi narx
    usdCurrencies.sort((a, b) => a.sellRate.compareTo(b.sellRate));
    return usdCurrencies.first;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceLocator.resolve<CurrencyBloc>()
        ..add(const LoadCurrenciesEvent()),
      child: BlocBuilder<CurrencyBloc, CurrencyState>(
        builder: (context, state) {
          CurrencyEntity? bestBuyBank;
          CurrencyEntity? bestSellBank;

          if (state is CurrencyLoaded) {
            bestBuyBank = _getBestBuyBank(state.currencies);
            bestSellBank = _getBestSellBank(state.currencies);
          }

          // Agar hech qanday bank topilmasa, widget ko'rsatilmaydi
          if (bestBuyBank == null && bestSellBank == null) {
            return const SizedBox.shrink();
          }

          return Row(
            children: [
              if (bestBuyBank != null)
                Expanded(
                  child: _BestRateCard(
                    bank: bestBuyBank,
                    isBuy: true,
                  ),
                ),
              if (bestBuyBank != null && bestSellBank != null)
                SizedBox(width: 12.w),
              if (bestSellBank != null)
                Expanded(
                  child: _BestRateCard(
                    bank: bestSellBank,
                    isBuy: false,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BestRateCard extends StatelessWidget {
  final CurrencyEntity bank;
  final bool isBuy;

  const _BestRateCard({
    required this.bank,
    required this.isBuy,
  });

  String _formatCurrency(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Ranglar: buy uchun yashil, sell uchun qizil
    final bgColor = isBuy
        ? (isDark ? const Color(0xFF1A3A2E) : const Color(0xFFECFDF5))
        : (isDark ? const Color(0xFF3A1E1E) : const Color(0xFFFEF2F2));

    final textColor = isBuy ? const Color(0xFF059669) : const Color(0xFFDC2626);

    final iconColor = isBuy ? const Color(0xFF059669) : const Color(0xFFDC2626);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: textColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isBuy ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: iconColor,
                size: 16.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                isBuy ? tr('currency.buy') : tr('currency.sell'),
                style: AppTypography.bodySecondary(context).copyWith(
                  fontSize: 12.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                      const Color(0xFF374151),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _BankLogo(
                bankName: bank.bankName,
                isDark: isDark,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  bank.bankName,
                  style: AppTypography.bodyPrimary(context).copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(isBuy ? bank.buyRate : bank.sellRate),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(width: 4.w),
              Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Text(
                  tr('currency.som'),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: textColor.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BankLogo extends StatelessWidget {
  final String bankName;
  final bool isDark;

  const _BankLogo({
    required this.bankName,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final logoAsset = bankLogoAsset(bankName);
    final shouldContain = bankLogoUsesContainFit(bankName);
    final bgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEFF6FF);

    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r),
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
                  return Padding(
                    padding: EdgeInsets.all(6.w),
                    child: image,
                  );
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
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.skyAccent,
        ),
      ),
    );
  }
}
