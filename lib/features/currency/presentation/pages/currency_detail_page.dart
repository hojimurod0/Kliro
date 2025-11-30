import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/utils/bank_assets.dart';
import '../../../bank/domain/entities/currency_entity.dart';
import '../../../bank/presentation/bloc/currency_bloc.dart';
import '../../../bank/presentation/bloc/currency_event.dart';
import '../../../bank/presentation/bloc/currency_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/widgets/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class CurrencyDetailPage extends StatefulWidget {
  final String? bankName;
  final String? currencyCode;
  final double? buyRate;
  final double? sellRate;
  
  const CurrencyDetailPage({
    super.key,
    this.bankName,
    this.currencyCode,
    this.buyRate,
    this.sellRate,
  });

  CurrencyEntity? get selectedCurrency {
    if (bankName == null || currencyCode == null || buyRate == null || sellRate == null) {
      return null;
    }
    return CurrencyEntity(
      id: 0,
      bankName: bankName!,
      currencyCode: currencyCode!,
      currencyName: currencyCode!,
      buyRate: buyRate!,
      sellRate: sellRate!,
    );
  }

  @override
  State<CurrencyDetailPage> createState() => _CurrencyDetailPageState();
}

class _CurrencyDetailPageState extends State<CurrencyDetailPage> {
  // Tab holatini boshqarish (0: Sotib olish, 1: Sotish)
  final ValueNotifier<int> _tabIndexNotifier = ValueNotifier(0);
  // Tanlangan bank ma'lumotlari (bank list dan bosilganda yangilanadi)
  final ValueNotifier<CurrencyEntity?> _selectedCurrencyNotifier = ValueNotifier<CurrencyEntity?>(null);
  // Tanlangan valyuta kodi
  String _selectedCurrencyCode = 'USD';
  // Barcha valyutalarni saqlash (callback da ishlatish uchun)
  List<CurrencyEntity> _allCurrencies = [];

  @override
  void initState() {
    super.initState();
    // Agar widget da bank parametrlari bo'lsa, uni tanlangan bank sifatida saqlaymiz
    _selectedCurrencyNotifier.value = widget.selectedCurrency;
    // Agar widget da valyuta kodi bo'lsa, uni tanlangan valyuta sifatida saqlaymiz
    if (widget.currencyCode != null) {
      _selectedCurrencyCode = widget.currencyCode!.toUpperCase();
    }
  }


  @override
  void dispose() {
    _tabIndexNotifier.dispose();
    _selectedCurrencyNotifier.dispose();
    super.dispose();
  }

  void _onBankSelected(CurrencyEntity currency) {
    _selectedCurrencyNotifier.value = currency;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ServiceLocator.resolve<CurrencyBloc>()
            ..add(const LoadCurrenciesEvent()),
      child: ValueListenableBuilder<CurrencyEntity?>(
        valueListenable: _selectedCurrencyNotifier,
        builder: (context, selectedCurrency, child) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: CommonAppBar(
              title: selectedCurrency != null
                  ? selectedCurrency.bankName
                  : null,
              titleKey: selectedCurrency == null ? 'currency.title' : null,
            ),
            body: BlocBuilder<CurrencyBloc, CurrencyState>(
          builder: (context, state) {
            if (state is CurrencyLoading) {
              return LoadingStateWidget(message: 'common.loading'.tr());
            }

            if (state is CurrencyError) {
              return ErrorStateWidget(
                message: state.message,
                onRetry: () {
                  context.read<CurrencyBloc>().add(const LoadCurrenciesEvent());
                },
              );
            }

            if (state is CurrencyLoaded) {
              // Barcha valyutalarni saqlaymiz (callback da ishlatish uchun)
              _allCurrencies = state.currencies;
              
              // Tanlangan valyuta kodi bo'yicha filtratsiya
              var filteredCurrencies = List<CurrencyEntity>.from(_allCurrencies);
              
              // Tanlangan valyuta kodi bo'yicha filtratsiya
              if (_selectedCurrencyCode.isNotEmpty) {
                filteredCurrencies = filteredCurrencies.where((currency) {
                  return currency.currencyCode.toUpperCase() ==
                      _selectedCurrencyCode.toUpperCase();
                }).toList();
              }
              
              // Agar tanlangan bank boshqa valyuta uchun bo'lsa, yangi valyuta ro'yxatida shu bankni qidiramiz
              final currentSelectedCurrency = _selectedCurrencyNotifier.value;
              if (currentSelectedCurrency != null) {
                if (currentSelectedCurrency.currencyCode.toUpperCase() != _selectedCurrencyCode.toUpperCase()) {
                  // Yangi valyuta ro'yxatida shu bankni qidiramiz
                  final sameBankInNewCurrency = filteredCurrencies.firstWhere(
                    (currency) => currency.bankName == currentSelectedCurrency.bankName,
                    orElse: () => CurrencyEntity(
                      id: 0,
                      bankName: '',
                      currencyCode: '',
                      currencyName: '',
                      buyRate: 0,
                      sellRate: 0,
                    ),
                  );
                  
                  // Agar yangi valyuta uchun shu bank topilsa, uni tanlangan bank sifatida saqlaymiz
                  if (sameBankInNewCurrency.bankName.isNotEmpty) {
                    _selectedCurrencyNotifier.value = sameBankInNewCurrency;
                  } else {
                    // Agar topilmasa, null qilamiz
                    _selectedCurrencyNotifier.value = null;
                  }
                }
              }

              return ValueListenableBuilder<CurrencyEntity?>(
                valueListenable: _selectedCurrencyNotifier,
                builder: (context, selectedCurrency, child) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectedCurrency != null)
                          SelectedBankCard(currency: selectedCurrency),
                        if (selectedCurrency == null)
                          const CurrencySummaryCard(),
                        SizedBox(height: 24.h),
                        Text(
                          'currency.bank_rates'.tr(),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.charcoal,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // Toggle Button (State bilan ulangan)
                        ValueListenableBuilder<int>(
                          valueListenable: _tabIndexNotifier,
                          builder: (context, index, child) {
                            return CustomToggleSwitch(
                              selectedIndex: index,
                              onChanged: (newIndex) => _tabIndexNotifier.value = newIndex,
                            );
                          },
                        ),
                        SizedBox(height: 16.h),
                        // Bank List (State bilan ulangan)
                        ValueListenableBuilder<int>(
                          valueListenable: _tabIndexNotifier,
                          builder: (context, index, child) {
                            return BankListView(
                              currencies: filteredCurrencies,
                              isSelling: index == 1,
                              selectedBankName: selectedCurrency?.bankName,
                              onBankSelected: _onBankSelected,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
          );
        },
      ),
    );
  }
}

// --- WIDGETS ---

// 1. Tanlangan bank ma'lumotlari
class SelectedBankCard extends StatelessWidget {
  final CurrencyEntity currency;

  const SelectedBankCard({super.key, required this.currency});

  String? _getBankLogoAsset() => bankLogoAsset(currency.bankName);
  bool _shouldUseContainFit() => bankLogoUsesContainFit(currency.bankName);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onlineBadgeBg = isDark ? const Color(0xFF1E3A5F) : AppColors.skySurface;
    final onlineBadgeText = AppColors.skyAccent;
    final greenBg = isDark ? const Color(0xFF1A3A2E) : AppColors.greenBg;
    final greenText = AppColors.accentGreen;
    final redBg = isDark ? const Color(0xFF3A1E1E) : const Color(0xFFFEF2F2);
    final redText = AppColors.dangerRed;
    final titleColor = Theme.of(context).textTheme.titleLarge?.color ?? AppColors.charcoal;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bank logo va nomi
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: onlineBadgeBg,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                clipBehavior: Clip.antiAlias,
                child: Builder(
                  builder: (context) {
                    final logoAsset = _getBankLogoAsset();
                    if (logoAsset != null) {
                      final shouldContain = _shouldUseContainFit();
                      final image = Image.asset(
                        logoAsset,
                        fit: shouldContain ? BoxFit.contain : BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                      );
                      if (shouldContain) {
                        return Padding(
                          padding: EdgeInsets.all(6.w),
                          child: image,
                        );
                      }
                      return image;
                    }
                    return Icon(
                      Icons.account_balance,
                      color: onlineBadgeText,
                      size: 24.sp,
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currency.bankName,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      currency.currencyName.isNotEmpty 
                          ? currency.currencyName 
                          : '${currency.currencyCode} ${tr('currency.title')}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) ?? AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Kurslar
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: greenBg,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            color: greenText,
                            size: 18.sp,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              tr('currency.buy'),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.midnight,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        currency.buyRate
                            .toStringAsFixed(0)
                            .replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            ) + ' ${'currency.som'.tr()}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: greenText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: redBg,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_down_rounded,
                            color: redText,
                            size: 18.sp,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              tr('currency.sell'),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.midnight,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        currency.sellRate
                            .toStringAsFixed(0)
                            .replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            ) + ' ${'currency.som'.tr()}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: redText,
                        ),
                      ),
                    ],
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

// 2. Yuqori qism (Umumiy ma'lumot)
class CurrencySummaryCard extends StatelessWidget {
  const CurrencySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50.r),
                child: Image.network(
                  "https://flagcdn.com/w40/us.png",
                  width: 32.w,
                  height: 32.w,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: AppColors.skySurface,
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                      child: Icon(
                        Icons.flag,
                        size: 20.sp,
                        color: AppColors.skyAccent,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'currency.usd_name'.tr(),
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.charcoal,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoItem(
                context,
                'currency.mb_rate'.tr(),
                "11 902 so'm",
                subtitle: "+20,70 bir kunda",
                subtitleColor: AppColors.accentGreen,
              ),
              _buildInfoItem(
                context,
                'currency.best_buy'.tr(),
                "11 900 so'm",
                subtitle: "Hamkorbank",
                subtitleColor: AppColors.primaryBlue,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildInfoItem(
                context,
                'currency.best_sell'.tr(),
                "11 910 so'm",
                subtitle: "Universal bank",
                subtitleColor: AppColors.primaryBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Qayta ishlatiladigan matn bloki
  Widget _buildInfoItem(
    BuildContext context,
    String title,
    String value, {
    String? subtitle,
    Color? subtitleColor,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.gray500,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.charcoal,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                color: subtitleColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 2. Custom Toggle Switch (Sotib olish / Sotish)
class CustomToggleSwitch extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;

  const CustomToggleSwitch({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          _buildTab(context, 'currency.buy'.tr(), 0),
          _buildTab(context, 'currency.sell'.tr(), 1),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String text, int index) {
    final isActive = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).cardColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? (Theme.of(context).textTheme.titleLarge?.color ?? AppColors.charcoal)
                    : (Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.gray500),
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 3. Bank List View
class BankListView extends StatelessWidget {
  final List<CurrencyEntity> currencies;
  final bool isSelling; // Narxni o'zgartirish uchun bayroq
  final String? selectedBankName; // Tanlangan bank nomi (ro'yxatdan chiqarish uchun)
  final Function(CurrencyEntity)? onBankSelected; // Bank tanlanganda callback

  const BankListView({
    super.key,
    required this.currencies,
    required this.isSelling,
    this.selectedBankName,
    this.onBankSelected,
  });

  String? _getBankLogoAsset(String bankName) => bankLogoAsset(bankName);
  bool _shouldUseContainFit(String bankName) => bankLogoUsesContainFit(bankName);

  @override
  Widget build(BuildContext context) {
    // Tanlangan bankni ro'yxatdan chiqaramiz
    var filteredBanks = selectedBankName != null
        ? currencies.where((currency) => currency.bankName != selectedBankName).toList()
        : currencies;
    
    // Sortirovka: eng arzon kurslar tepada
    // Buy bo'lsa - buyRate bo'yicha, Sell bo'lsa - sellRate bo'yicha
    filteredBanks.sort((a, b) {
      if (isSelling) {
        // Sotish: eng arzon (kichik) sellRate tepada
        return a.sellRate.compareTo(b.sellRate);
      } else {
        // Sotib olish: eng arzon (kichik) buyRate tepada
        return a.buyRate.compareTo(b.buyRate);
      }
    });
    
    // Eng arzon kursni aniqlash (best offer ko'rsatish uchun)
    final bestRate = filteredBanks.isNotEmpty
        ? (isSelling ? filteredBanks.first.sellRate : filteredBanks.first.buyRate)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: filteredBanks.isEmpty
          ? Padding(
              padding: EdgeInsets.all(32.w),
              child: Center(
                child: Text(
                  'currency.empty'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.gray500,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredBanks.length,
              separatorBuilder: (c, i) => Divider(
                height: 1,
                indent: 60.w,
                endIndent: 16.w,
                color: Theme.of(context).dividerColor,
              ),
              itemBuilder: (context, index) {
                final currency = filteredBanks[index];
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final onlineBadgeBg = isDark ? const Color(0xFF1E3A5F) : AppColors.skySurface;
                final onlineBadgeText = AppColors.skyAccent;

                // Agar 'Sotish' tanlangan bo'lsa, narxni o'zgartiramiz
                final displayPrice = isSelling ? currency.sellRate : currency.buyRate;
                final currentRate = isSelling ? currency.sellRate : currency.buyRate;
                final isBest = bestRate != null && currentRate == bestRate;
                
                // Ranglar: Sotib olish - yashil, Sotish - qizil
                final greenText = AppColors.accentGreen;
                final redText = AppColors.dangerRed;
                // Sotib olish yashil, sotish qizil rangda
                final priceColor = isSelling ? redText : greenText;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    // Bank tanlanganda, callback orqali parent widget ga signal beramiz
                    if (onBankSelected != null) {
                      onBankSelected!(currency);
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    child: Row(
                      children: [
                        // Bank logosi
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: onlineBadgeBg,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Builder(
                            builder: (context) {
                              final logoAsset = _getBankLogoAsset(currency.bankName);
                              if (logoAsset != null) {
                                final shouldContain = _shouldUseContainFit(currency.bankName);
                                final image = Image.asset(
                                  logoAsset,
                                  fit: shouldContain ? BoxFit.contain : BoxFit.cover,
                                  filterQuality: FilterQuality.medium,
                                );
                                if (shouldContain) {
                                  return Padding(
                                    padding: EdgeInsets.all(6.w),
                                    child: image,
                                  );
                                }
                                return image;
                              }
                              return Icon(
                                Icons.account_balance,
                                color: onlineBadgeText,
                                size: 22.sp,
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currency.bankName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15.sp,
                                  color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.charcoal,
                                ),
                              ),
                              if (isBest) ...[
                                // Eng arzon kurs ko'rsatiladi
                                // Sotib olish yashil, sotish qizil rangda
                                SizedBox(height: 4.h),
                                Text(
                                  'currency.best_offer'.tr(),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: isSelling ? redText : greenText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          displayPrice
                              .toStringAsFixed(0)
                              .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ) + ' ${'currency.som'.tr()}',
                          style: TextStyle(
                            color: priceColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}


