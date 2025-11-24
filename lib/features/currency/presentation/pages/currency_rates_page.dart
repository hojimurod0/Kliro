import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/dio/singletons/service_locator.dart';
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

  String _getCurrencyFlag(String code) {
    switch (code.toUpperCase()) {
      case 'USD':
        return '🇺🇸';
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
    {'code': 'USD', 'flag': '🇺🇸', 'name': 'Dollar'},
    {'code': 'EUR', 'flag': '🇪🇺', 'name': 'Yevro'},
    {'code': 'RUB', 'flag': '🇷🇺', 'name': 'Rubl'},
    {'code': 'KGS', 'flag': '🇰🇬', 'name': 'Som'},
  ];

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
                                  color: const Color(0xFF3B82F6),
                                  size: 20.sp,
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Bank nomini qidirish...',
                                      hintStyle: TextStyle(
                                        color: Theme.of(context).textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF),
                                        fontSize: 13.sp,
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
                                      color: Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF111827),
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
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      currency['flag'] as String,
                                      style: TextStyle(fontSize: 18.sp),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      currency['code'] as String,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? const Color(0xFF3B82F6)
                                            : Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF111827),
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      currency['name'] as String,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF6B7280),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (isSelected)
                                      Icon(
                                        Icons.check,
                                        color: const Color(0xFF3B82F6),
                                        size: 16.sp,
                                      ),
                                  ],
                                ),
                              );
                            }).toList();
                          },
                          onSelected: (String value) {
                            setState(() {
                              _selectedCurrencyCode = value;
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
                                Text(
                                  _getCurrencyFlag(_selectedCurrencyCode),
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  _selectedCurrencyCode,
                                  style: TextStyle(
                                    color: const Color(0xFF3B82F6),
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Icon(
                                  Icons.arrow_drop_up,
                                  color: const Color(0xFF3B82F6),
                                  size: 18.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- BANKLAR RO'YXATI ---
                  Expanded(
                    child: sortedCurrencies.isEmpty
                        ? EmptyStateWidget(
                            messageKey: 'currency.empty',
                            icon: Icons.currency_exchange_outlined,
                          )
                        : ListView.separated(
                            padding: EdgeInsets.all(16.w),
                            itemCount: sortedCurrencies.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 16.h),
                            itemBuilder: (context, index) {
                              return _BankRateCard(
                                currency: sortedCurrencies[index],
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

  IconData _getBankIcon() {
    final name = currency.bankName.toLowerCase();
    if (name.contains('ipak')) return Icons.apartment_rounded;
    if (name.contains('kapital')) return Icons.savings_outlined;
    if (name.contains('asaka')) return Icons.domain;
    return Icons.account_balance;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Rasmga mos ranglar
    final onlineBadgeBg = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE0F2FE);
    const onlineBadgeText = Color(0xFF0284C7);
    final greenBg = isDark ? const Color(0xFF1A3A2E) : const Color(0xFFECFDF5);
    const greenText = Color(0xFF059669);
    final redBg = isDark ? const Color(0xFF3A1E1E) : const Color(0xFFFEF2F2);
    const redText = Color(0xFFDC2626);
    final greyText = Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF6B7280);
    final titleColor = Theme.of(context).textTheme.titleLarge?.color ?? const Color(0xFF111827);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: isDark ? null : [
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
          // --- 1. HEADER: Logo, Nom, Joylashuv, Reyting ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bank Logosi
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: onlineBadgeBg,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  _getBankIcon(),
                  color: onlineBadgeText,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),

              // Ma'lumotlar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bank Nomi
                    Text(
                      currency.bankName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    SizedBox(height: 6.h),

                    // Location • Rating qatori
                    Row(
                      children: [
                        // Joylashuv
                        Icon(
                          Icons.location_on_outlined,
                          size: 14.sp,
                          color: greyText,
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            // API dan null kelsa ham 'Toshkent shahar' chiqadi
                            currency.location ?? 'Toshkent shahar',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: greyText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // Ajratuvchi nuqta
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          width: 4.w,
                          height: 4.w,
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            shape: BoxShape.circle,
                          ),
                        ),

                        // Reyting (Yulduzcha)
                        Icon(
                          Icons.star_rounded,
                          size: 16.sp,
                          color: const Color(0xFFF59E0B),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          // API dan null kelsa ham '4.8' chiqadi
                          (currency.rating ?? 4.8).toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // --- 2. INFO: Soat va Online Status ---
          Row(
            children: [
              // Soat
              Icon(Icons.access_time_rounded, size: 16.sp, color: greyText),
              SizedBox(width: 6.w),
              Text(
                // API dan null kelsa ham vaqt chiqadi
                currency.schedule ?? '9:00 - 17:00',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: greyText,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(width: 12.w),

              // Online Badge
              // Rasmda har doim bor, agar api null bersa ham ko'rsatish uchun true deb olamiz
              if (currency.isOnline ?? true)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: onlineBadgeBg,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.language, size: 14.sp, color: onlineBadgeText),
                      SizedBox(width: 4.w),
                      Text(
                        tr('currency.online'), // "Online"
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: onlineBadgeText,
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
                          Text(
                            tr('currency.buy'),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF374151),
                              fontWeight: FontWeight.w500,
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
                          Text(
                            tr('currency.sell'),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).textTheme.bodyMedium?.color ?? const Color(0xFF374151),
                              fontWeight: FontWeight.w500,
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
