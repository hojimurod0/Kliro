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
  // PageView controller for smooth slide animation
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // PageView controller initialization
    _pageController = PageController(initialPage: 0);
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
    _pageController.dispose();
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

              // Находим лучшие банки для покупки и продажи
              final bestBuyBank = filteredCurrencies.isNotEmpty
                  ? filteredCurrencies.reduce((a, b) => a.buyRate > b.buyRate ? a : b)
                  : null;
              final bestSellBank = filteredCurrencies.isNotEmpty
                  ? filteredCurrencies.reduce((a, b) => a.sellRate < b.sellRate ? a : b)
                  : null;

              return ValueListenableBuilder<CurrencyEntity?>(
                valueListenable: _selectedCurrencyNotifier,
                builder: (context, selectedCurrency, child) {
                  return SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'currency.bank_rates'.tr(),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.charcoal,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // Лучшие банки для покупки и продажи (выше переключателя) - Bitta card ichida
                        if (bestBuyBank != null && bestSellBank != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                ),
                                boxShadow: Theme.of(context).brightness == Brightness.dark ? null : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _BestBankCard(
                                      currency: bestBuyBank,
                                      isBuy: true,
                                      onTap: () => _onBankSelected(bestBuyBank),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: _BestBankCard(
                                      currency: bestSellBank,
                                      isBuy: false,
                                      onTap: () => _onBankSelected(bestSellBank),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Toggle Button (State bilan ulangan)
                        ValueListenableBuilder<int>(
                          valueListenable: _tabIndexNotifier,
                          builder: (context, index, child) {
                            return CustomToggleSwitch(
                              selectedIndex: index,
                              onChanged: (newIndex) {
                                _tabIndexNotifier.value = newIndex;
                                // Smooth page transition
                                _pageController.animateToPage(
                                  newIndex,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(height: 16.h),
                        // PageView for smooth slide animation between Buy and Sell
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.55,
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (index) {
                              _tabIndexNotifier.value = index;
                            },
                            physics: const BouncingScrollPhysics(),
                            children: [
                              // Buy Page
                              BankListView(
                                currencies: filteredCurrencies,
                                isSelling: false,
                                selectedBankName: selectedCurrency?.bankName,
                                excludeBankNames: bestBuyBank != null && bestSellBank != null
                                    ? [bestBuyBank.bankName, bestSellBank.bankName]
                                    : [],
                                onBankSelected: _onBankSelected,
                              ),
                              // Sell Page
                              BankListView(
                                currencies: filteredCurrencies,
                                isSelling: true,
                                selectedBankName: selectedCurrency?.bankName,
                                excludeBankNames: bestBuyBank != null && bestSellBank != null
                                    ? [bestBuyBank.bankName, bestSellBank.bankName]
                                    : [],
                                onBankSelected: _onBankSelected,
                              ),
                            ],
                          ),
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
                "11 902 ${tr('common.soum')}",
                subtitle: "+20,70 ${tr('currency.per_day')}",
                subtitleColor: AppColors.accentGreen,
              ),
              _buildInfoItem(
                context,
                'currency.best_buy'.tr(),
                "11 900 ${tr('common.soum')}",
                subtitle: tr('currency.bank_name_hamkorbank'),
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
                "11 910 ${tr('common.soum')}",
                subtitle: tr('currency.bank_name_universal'),
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
  final List<String> excludeBankNames; // Исключаемые банки (лучшие банки)
  final Function(CurrencyEntity)? onBankSelected; // Bank tanlanganda callback

  const BankListView({
    super.key,
    required this.currencies,
    required this.isSelling,
    this.selectedBankName,
    this.excludeBankNames = const [],
    this.onBankSelected,
  });

  String? _getBankLogoAsset(String bankName) => bankLogoAsset(bankName);
  bool _shouldUseContainFit(String bankName) => bankLogoUsesContainFit(bankName);

  @override
  Widget build(BuildContext context) {
    // Tanlangan bankni va исключаемые банки ro'yxatdan chiqaramiz
    var filteredBanks = currencies.where((currency) {
      if (selectedBankName != null && currency.bankName == selectedBankName) {
        return false;
      }
      if (excludeBankNames.contains(currency.bankName)) {
        return false;
      }
      return true;
    }).toList();
    
    if (filteredBanks.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: Padding(
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
        ),
      );
    }

    // Сортируем банки
    filteredBanks.sort((a, b) {
      if (isSelling) {
        // Sell uchun eng arzonlari tepada (oshib borish tartibida)
        return a.sellRate.compareTo(b.sellRate);
      } else {
        // Buy uchun eng balandlari tepada (tushib borish tartibida)
        return b.buyRate.compareTo(a.buyRate);
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: filteredBanks.length,
        separatorBuilder: (c, i) => Divider(
          height: 1,
          indent: 60.w,
          endIndent: 16.w,
          color: Theme.of(context).dividerColor,
        ),
        itemBuilder: (context, index) {
          final currency = filteredBanks[index];
          return _buildBankListItem(context, currency, isSelling);
        },
      ),
    );
  }

  Widget _buildBankListItem(BuildContext context, CurrencyEntity currency, bool isSelling) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onlineBadgeBg = isDark ? const Color(0xFF1E3A5F) : AppColors.skySurface;
    final onlineBadgeText = AppColors.skyAccent;
    final greenText = AppColors.accentGreen;
    final redText = AppColors.dangerRed;
    
    final displayPrice = isSelling ? currency.sellRate : currency.buyRate;
    final priceColor = isSelling ? redText : greenText;

    return Padding(
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
              child: Text(
                currency.bankName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                  color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.charcoal,
                ),
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
    );
  }
}

// Виджет для отображения лучших банков
class _BestBankCard extends StatelessWidget {
  final CurrencyEntity currency;
  final bool isBuy;
  final VoidCallback onTap;

  const _BestBankCard({
    required this.currency,
    required this.isBuy,
    required this.onTap,
  });

  String? _getBankLogoAsset(String bankName) => bankLogoAsset(bankName);
  bool _shouldUseContainFit(String bankName) => bankLogoUsesContainFit(bankName);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onlineBadgeBg = isDark ? const Color(0xFF1E3A5F) : AppColors.skySurface;
    final onlineBadgeText = AppColors.skyAccent;
    final greenText = AppColors.accentGreen;
    final redText = AppColors.dangerRed;
    final greenBg = isDark ? const Color(0xFF1A3A2E) : AppColors.greenBg;
    final redBg = isDark ? const Color(0xFF3A1E1E) : const Color(0xFFFEF2F2);
    
    final price = isBuy ? currency.buyRate : currency.sellRate;
    final priceColor = isBuy ? greenText : redText;
    final bgColor = isBuy ? greenBg : redBg;
    final label = isBuy ? 'currency.buy'.tr() : 'currency.sell'.tr();
    final icon = isBuy ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: priceColor,
                  size: 16.sp,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.midnight,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            // Bank logo va nomi
            Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: onlineBadgeBg,
                    borderRadius: BorderRadius.circular(10.r),
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
                            padding: EdgeInsets.all(4.w),
                            child: image,
                          );
                        }
                        return image;
                      }
                      return Icon(
                        Icons.account_balance,
                        color: onlineBadgeText,
                        size: 18.sp,
                      );
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    currency.bankName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: Theme.of(context).textTheme.titleLarge?.color ?? AppColors.charcoal,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              price
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
  }
}


