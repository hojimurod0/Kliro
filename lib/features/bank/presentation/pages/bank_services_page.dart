import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../bank/domain/entities/bank_service.dart';
import '../../../bank/domain/repositories/bank_repository.dart';
import '../../../bank/domain/usecases/get_bank_services.dart';
import '../../../bank/domain/usecases/get_currencies.dart';

@RoutePage()
class BankServicesPage extends StatefulWidget {
  BankServicesPage({super.key});

  @override
  State<BankServicesPage> createState() => _BankServicesPageState();
}

class _BankServicesPageState extends State<BankServicesPage> {
  late final GetBankServices _getBankServices;
  late final GetCurrencies _getCurrencies;
  Future<List<BankService>>? _servicesFuture;
  Locale? _currentLocale;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final bankRepository = ServiceLocator.resolve<BankRepository>();
    _getBankServices = GetBankServices(bankRepository);
    _getCurrencies = GetCurrencies(bankRepository);
  }

  Future<void> _navigateToCurrencyDetail(BuildContext context) async {
    try {
      // Загружаем данные о валютах
      final currencies = await _getCurrencies();
      
      // Фильтруем по USD
      final usdCurrencies = currencies.where((c) => 
        c.currencyCode.toUpperCase() == 'USD'
      ).toList();
      
      if (usdCurrencies.isNotEmpty) {
        // Находим банк с лучшим (самым дешевым) курсом покупки
        usdCurrencies.sort((a, b) => a.buyRate.compareTo(b.buyRate));
        final bestBuyBank = usdCurrencies.first;
        
        // Открываем детальную страницу с этим банком
        if (mounted) {
          context.router.push(CurrencyDetailRoute(
            bankName: bestBuyBank.bankName,
            currencyCode: bestBuyBank.currencyCode,
            buyRate: bestBuyBank.buyRate,
            sellRate: bestBuyBank.sellRate,
          ));
        }
      } else {
        // Если USD не найден, открываем детальную страницу без банка
        if (mounted) {
          context.router.push(CurrencyDetailRoute(
            currencyCode: 'USD',
          ));
        }
      }
    } catch (e) {
      // При ошибке открываем детальную страницу без банка
      if (mounted) {
        context.router.push(CurrencyDetailRoute(
          currencyCode: 'USD',
        ));
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Инициализируем или обновляем данные при смене языка
    final newLocale = context.locale;

    if (!_isInitialized) {
      // Первая инициализация
      _currentLocale = newLocale;
      _servicesFuture = _getBankServices.callFromApi();
      _isInitialized = true;
    } else {
      // Проверяем, изменился ли язык
      final localeChanged =
          _currentLocale?.languageCode != newLocale.languageCode ||
          _currentLocale?.countryCode != newLocale.countryCode;

      if (localeChanged) {
        _currentLocale = newLocale;
        setState(() {
          _servicesFuture = _getBankServices.callFromApi();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: Center(
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color:
                    Theme.of(context).iconTheme.color ??
                    (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : AppColors.charcoal),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          tr('bank.services'),
          style: TextStyle(
            color:
                Theme.of(context).textTheme.titleLarge?.color ??
                AppColors.charcoal,
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<List<BankService>>(
        future: _servicesFuture ?? _getBankServices.callFromApi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48.sp,
                      color: AppColors.dangerRed,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      tr('bank.error_title'),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color:
                            Theme.of(context).textTheme.titleLarge?.color ??
                            AppColors.charcoal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _servicesFuture = _getBankServices.callFromApi();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(tr('bank.error_retry')),
                    ),
                  ],
                ),
              ),
            );
          }

          final services = snapshot.data ?? [];

          if (services.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(
                  tr('bank.empty_title'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color:
                        Theme.of(context).textTheme.bodyMedium?.color ??
                        AppColors.gray500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            itemCount: services.length,
            separatorBuilder: (context, index) => SizedBox(height: 20.h),
            itemBuilder: (context, index) {
              final service = services[index];
              VoidCallback? onTap;
              final titleKey = service.titleKey;
              if (titleKey == 'currency') {
                onTap = () => _navigateToCurrencyDetail(context);
              } else if (titleKey == 'micro_loan') {
                onTap = () => context.router.push(MicroLoanRoute());
              } else if (titleKey == 'deposit') {
                onTap = () => context.router.push(DepositRoute());
              } else if (titleKey == 'auto_credit') {
                onTap = () => context.router.push(const AutoCreditRoute());
              } else if (titleKey == 'mortgage') {
                onTap = () => context.router.push(const MortgageRoute());
              } else if (titleKey == 'cards') {
                onTap = () => context.router.push(const CardsRoute());
              } else if (titleKey == 'transfers') {
                onTap = () => context.router.push(const TransferAppsRoute());
              }
              return _ServiceCard(service: service, onTap: onTap);
            },
          );
        },
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, this.onTap});

  final BankService service;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 6.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [service.color.withOpacity(0.6), service.color],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 14.w, 20.w, 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: service.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          service.icon,
                          color: service.color,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.title,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.color ??
                                    const Color(0xFF111827),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              service.subtitle,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: service.color,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    service.description,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color:
                          Theme.of(context).textTheme.bodyMedium?.color ??
                          const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('bank.advantages'),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color ??
                                const Color(0xFF374151),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        _FeaturesGrid(service: service),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: service.color,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tr('bank.open'),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(Icons.arrow_outward_rounded, size: 16.sp),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturesGrid extends StatelessWidget {
  const _FeaturesGrid({required this.service});

  final BankService service;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16.w,
      runSpacing: 8.h,
      children: service.features.map((feature) {
        return FractionallySizedBox(
          widthFactor: 0.48,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 16.sp,
                color: service.color,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  feature,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color:
                        Theme.of(context).textTheme.bodyMedium?.color ??
                        const Color(0xFF4B5563),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
