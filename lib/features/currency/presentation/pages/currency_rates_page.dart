import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../common/utils/bank_assets.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_size.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../bank/domain/entities/currency_entity.dart';
import '../../../bank/presentation/bloc/currency_bloc.dart';
import '../../../bank/presentation/bloc/currency_event.dart';
import '../../../bank/presentation/bloc/currency_state.dart';

@RoutePage()
class CurrencyRatesPage extends StatefulWidget {
  CurrencyRatesPage({super.key});

  @override
  State<CurrencyRatesPage> createState() => _CurrencyRatesPageState();
}

class _CurrencyRatesPageState extends State<CurrencyRatesPage> {
  String _selectedCurrencyCode = 'USD'; // USD по умолчанию
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  static const int _pageSize = 10;
  int _currentPage = 1;
  bool _isLoadingMore = false;

  Widget _getCurrencyFlagWidget(String code, {double size = 16.0}) {
    switch (code.toUpperCase()) {
      case 'USD':
        return SvgPicture.asset(
          'assets/images/brinatya.svg',
          width: size,
          height: size,
          fit: BoxFit.contain,
        );
      case 'EUR':
        return Text('🇪🇺', style: TextStyle(fontSize: size));
      case 'RUB':
        return Text('🇷🇺', style: TextStyle(fontSize: size));
      case 'KZT':
        return Text('🇰🇿', style: TextStyle(fontSize: size));
      case 'KGS':
        return Text('🇰🇬', style: TextStyle(fontSize: size));
      default:
        return const SizedBox.shrink();
    }
  }

  String _getCurrencyFlag(String code) {
    switch (code.toUpperCase()) {
      case 'USD':
        return '🇬🇧';
      case 'EUR':
        return '🇪🇺';
      case 'RUB':
        return '🇷🇺';
      case 'KZT':
        return '🇰🇿';
      case 'KGS':
        return '🇰🇬';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _currencies => [
    {
      'code': 'USD',
      'flag': '🇬🇧',
      'nameKey': 'currency.usd_name',
      'isSvg': true,
    },
    {
      'code': 'EUR',
      'flag': '🇪🇺',
      'nameKey': 'currency.eur_name',
      'isSvg': false,
    },
    {
      'code': 'RUB',
      'flag': '🇷🇺',
      'nameKey': 'currency.rub_name',
      'isSvg': false,
    },
    {
      'code': 'KZT',
      'flag': '🇰🇿',
      'nameKey': 'currency.kzt_name',
      'isSvg': false,
    },
  ];

  void _loadMoreCurrencies(int totalItems) {
    if (_isLoadingMore) return;
    final currentMax = _currentPage * _pageSize;
    if (currentMax >= totalItems) return;

    setState(() {
      _isLoadingMore = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _currentPage += 1;
        _isLoadingMore = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ServiceLocator.resolve<CurrencyBloc>()
            ..add(const LoadCurrenciesEvent()),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CommonAppBar(titleKey: 'currency.title'),
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
              // Filtratsiya: tanlangan valyuta bo'yicha
              var filteredCurrencies = List<CurrencyEntity>.from(
                state.currencies,
              );

              // Valyuta kodi bo'yicha filtratsiya
              if (_selectedCurrencyCode.isNotEmpty) {
                filteredCurrencies = filteredCurrencies.where((currency) {
                  return currency.currencyCode.toUpperCase() ==
                      _selectedCurrencyCode.toUpperCase();
                }).toList();
              }

              // Bank nomi bo'yicha qidiruv
              if (_searchQuery.isNotEmpty) {
                final queryLower = _searchQuery.toLowerCase();
                filteredCurrencies = filteredCurrencies.where((currency) {
                  return currency.bankName.toLowerCase().contains(queryLower);
                }).toList();
              }

              // Sortirovka: eng arzon kurslar (eng kichik buyRate) tepada
              final sortedCurrencies = filteredCurrencies
                ..sort((a, b) => a.buyRate.compareTo(b.buyRate));
              final totalItems = sortedCurrencies.length;
              final visibleCount = min(totalItems, _currentPage * _pageSize);
              final paginatedCurrencies = sortedCurrencies
                  .take(visibleCount)
                  .toList();
              final canLoadMore = visibleCount < totalItems;

              return Column(
                children: [
                  // --- SEARCH VA CURRENCY SELECTOR QISMI ---
                  Container(
                    color: Theme.of(context).cardColor,
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                    child: Row(
                      children: [
                        // Search field
                        Expanded(
                          child: Container(
                            height: 40.h,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: AppColors.primaryBlue,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                        _currentPage = 1;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: tr('currency.search_hint'),
                                      hintStyle: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall?.color ??
                                            AppColors.grayText,
                                        fontSize: AppTextSize.bodySmall,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      focusedErrorBorder: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color ??
                                          AppColors.charcoal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Currency selector dropdown
                        PopupMenuButton<String>(
                          offset: Offset(0, -(_currencies.length * 45.0 + 10)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            side: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                          ),
                          color: Theme.of(context).cardColor,
                          elevation: 4,
                          itemBuilder: (BuildContext context) {
                            return _currencies.map((currency) {
                              final isSelected =
                                  currency['code'] == _selectedCurrencyCode;
                              return PopupMenuItem<String>(
                                value: currency['code'] as String,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                                child: Row(
                                  children: [
                                    currency['isSvg'] == true
                                        ? _getCurrencyFlagWidget(
                                            currency['code'] as String,
                                            size: 18.sp,
                                          )
                                        : Text(
                                            currency['flag'] as String,
                                            style: TextStyle(fontSize: AppTextSize.filterTitle),
                                          ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      currency['code'] as String,
                                      style: TextStyle(
                                        fontSize: AppTextSize.bodySmall,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? AppColors.primaryBlue
                                            : Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.color ??
                                                  AppColors.charcoal,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Expanded(
                                      child: Text(
                                        tr(currency['nameKey'] as String),
                                        style: TextStyle(
                                          fontSize: AppTextSize.labelMedium,
                                          color:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.color ??
                                              AppColors.gray500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    if (isSelected)
                                      Padding(
                                        padding: EdgeInsets.only(left: 4.w),
                                        child: Icon(
                                          Icons.check,
                                          color: AppColors.primaryBlue,
                                          size: 16.sp,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList();
                          },
                          onSelected: (String value) {
                            setState(() {
                              _selectedCurrencyCode = value;
                              _currentPage = 1;
                            });
                          },
                          child: Container(
                            height: 40.h,
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _selectedCurrencyCode == 'USD'
                                    ? _getCurrencyFlagWidget(
                                        _selectedCurrencyCode,
                                        size: 16.sp,
                                      )
                                    : Text(
                                        _getCurrencyFlag(_selectedCurrencyCode),
                                        style: TextStyle(fontSize: AppTextSize.bodyLarge),
                                      ),
                                SizedBox(width: 4.w),
                                Text(
                                  _selectedCurrencyCode,
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Icon(
                                  Icons.arrow_drop_up,
                                  color: AppColors.primaryBlue,
                                  size: 18.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- ENG ARZON KURS BANKA ---
                  if (sortedCurrencies.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18.sp,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color ??
                                      AppColors.midnight,
                                ),
                                children: [
                                  TextSpan(
                                    text: '${tr('currency.best_rate')}: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: sortedCurrencies.first.bankName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // --- BANKLAR RO'YXATI ---
                  Expanded(
                    child: paginatedCurrencies.isEmpty
                        ? EmptyStateWidget(
                            messageKey: 'currency.empty',
                            icon: Icons.currency_exchange_outlined,
                          )
                        : ListView.separated(
                            padding: EdgeInsets.all(16.w),
                            itemCount:
                                paginatedCurrencies.length +
                                (canLoadMore ? 1 : 0),
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 16.h),
                            itemBuilder: (context, index) {
                              if (index >= paginatedCurrencies.length) {
                                if (!_isLoadingMore) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    _loadMoreCurrencies(totalItems);
                                  });
                                }
                                return const _LoadingMoreIndicator();
                              }
                              return _BankRateCard(
                                currency: paginatedCurrencies[index],
                              );
                            },
                          ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _BankRateCard extends StatelessWidget {
  const _BankRateCard({required this.currency});

  final CurrencyEntity currency;

  String? _getBankLogoAsset() => bankLogoAsset(currency.bankName);

  bool _shouldUseContainFit() => bankLogoUsesContainFit(currency.bankName);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Rasmga mos ranglar
    final onlineBadgeBg = isDark
        ? const Color(0xFF1E3A5F)
        : AppColors.skySurface;
    final onlineBadgeText = AppColors.skyAccent;
    final greenBg = isDark ? const Color(0xFF1A3A2E) : AppColors.greenBg;
    final greenText = AppColors.accentGreen;
    final redBg = isDark ? const Color(0xFF3A1E1E) : const Color(0xFFFEF2F2);
    final redText = AppColors.dangerRed;
    final titleColor =
        Theme.of(context).textTheme.titleLarge?.color ?? AppColors.charcoal;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.router.push(
          CurrencyDetailRoute(
            bankName: currency.bankName,
            currencyCode: currency.currencyCode,
            buyRate: currency.buyRate,
            sellRate: currency.sellRate,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. HEADER: Logo va bank nomi ---
            Row(
              children: [
                // Bank Logosi
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

                // Bank nomi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currency.bankName,
                        style: TextStyle(
                          fontSize: AppTextSize.filterTitle,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${currency.currencyCode} ${tr('currency.title')} • ${currency.bankName}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color:
                              Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color?.withOpacity(0.7) ??
                              AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // --- 3. RATES: Sotib olish va Sotish ---
            Row(
              children: [
                // Sotib olish
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
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color ??
                                      AppColors.midnight,
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
                              ),
                          style: TextStyle(
                            fontSize: AppTextSize.filterTitle,
                            fontWeight: FontWeight.w700,
                            color: greenText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                // Sotish
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
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color ??
                                      AppColors.midnight,
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
                              ),
                          style: TextStyle(
                            fontSize: AppTextSize.filterTitle,
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
      ),
    );
  }
}

class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Center(
        child: SizedBox(
          width: 24.w,
          height: 24.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
