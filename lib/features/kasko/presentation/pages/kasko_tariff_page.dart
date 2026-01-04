import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/dio/singletons/service_locator.dart';
import '../../data/datasources/kasko_remote_data_source.dart';
import '../../data/repositories/kasko_repository_impl.dart';
import '../../domain/entities/rate_entity.dart';
import '../../domain/usecases/calculate_car_price.dart' as usecases;
import '../../domain/usecases/calculate_policy.dart' as usecases;
import '../../domain/usecases/check_payment_status.dart';
import '../../domain/usecases/get_cars.dart';
import '../../domain/usecases/get_cars_minimal.dart';
import '../../domain/usecases/get_payment_link.dart';
import '../../domain/usecases/get_rates.dart';
import '../../domain/usecases/save_order.dart' as usecases;
import '../../domain/usecases/upload_image.dart' as usecases;
import '../bloc/kasko_bloc.dart';
import '../bloc/kasko_event.dart';
import '../bloc/kasko_state.dart';
import 'kasko_document_data_page.dart';

// --- MA'LUMOT MODELI ---
class TariffModel {
  final String title;
  final String duration;
  final String description;
  final String price;
  final int? id;

  TariffModel({
    required this.title,
    required this.duration,
    required this.description,
    required this.price,
    this.id,
  });
}

// --- ASOSIY EKRAN ---
@RoutePage()
class KaskoTariffPage extends StatefulWidget {
  const KaskoTariffPage({super.key});

  @override
  State<KaskoTariffPage> createState() => _KaskoTariffPageState();
}

class _KaskoTariffPageState extends State<KaskoTariffPage> {
  int _selectedCardIndex = -1; // No selection by default
  List<TariffModel> _allTariffs =
      []; // Barcha tariflar (faqat Basic, Comfort, Premium)
  List<TariffModel> _standardTariffs = []; // Standart tariflar
  List<TariffModel> _otherTariffs = []; // Boshqa tariflar (bo'sh bo'ladi)
  List<TariffModel> _tariffs = []; // Ko'rsatiladigan tariflar
  double? _carPrice; // Mashina narxi (percent dan narxni hisoblash uchun)
  int? _carId; // Tanlangan mashina ID si (car_position_id)
  int? _year; // Tanlangan yil
  RateEntity? _selectedRateEntity; // Tanlangan rate entity (Bloc'dan keladi)

  static const bool _enableDebugLogs = false; // O'chirildi - performance uchun

  bool _hasInitialized =
      false; // Flag to track if we've already dispatched FetchRates

  // Optimizatsiya: debouncing uchun timer
  Timer? _updateTimer;

  // Optimizatsiya: konvertatsiya qilingan ma'lumotlarni cache'ga saqlash
  List<RateEntity>? _lastConvertedRates;
  List<TariffModel>? _cachedConvertedTariffs;

  @override
  void initState() {
    super.initState();
    if (_enableDebugLogs) {
      debugPrint('🚀🚀🚀 KaskoTariffPage initState called');
    }
    // initState'da FetchRates chaqirmaymiz - build metodida tekshiramiz
    // Bu ortiqcha chaqiruvlarni oldini oladi
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  // Tab bo'yicha tariflarni filtrlash
  // Endi faqat Basic, Comfort, Premium ko'rsatiladi, shuning uchun barchasini ko'rsatamiz
  void _filterTariffsByTab() {
    // Faqat Basic, Comfort, Premium ko'rsatiladi, shuning uchun barchasini ko'rsatamiz
    _tariffs = List.from(_standardTariffs);
  }

  // RateEntity'dan TariffModel'ga o'tkazish
  // Optimizatsiya: cache'ga saqlash va faqat kerak bo'lganda qayta hisoblash
  List<TariffModel> _convertRatesToTariffs(List<RateEntity> rates) {
    // Agar rates o'zgarmagan bo'lsa va cache mavjud bo'lsa, cache'dan qaytarish
    if (_lastConvertedRates == rates && _cachedConvertedTariffs != null) {
      if (_enableDebugLogs) {
        debugPrint('📦 Using cached tariffs');
      }
      return _cachedConvertedTariffs!;
    }

    if (_enableDebugLogs) {
      debugPrint('🔄 _convertRatesToTariffs called with ${rates.length} rates');
      debugPrint('🚗 Car ID: $_carId, Year: $_year, Car Price: $_carPrice');
    }

    if (rates.isEmpty) {
      if (_enableDebugLogs) {
        debugPrint('⚠️ Rates list is empty');
      }
      _lastConvertedRates = rates;
      _cachedConvertedTariffs = [];
      return [];
    }

    final List<TariffModel> tariffs = [];

    // Faqat Basic, Comfort va Premium ni qoldirish uchun filtrlash
    // Har birini faqat bir marta qo'shish
    final allowedTariffNames = ['basic', 'comfort', 'premium'];
    final seenNames =
        <String>{}; // Duplicate larni oldini olish uchun (nomi bo'yicha)
    final seenIds = <int>{}; // Duplicate larni oldini olish uchun (ID bo'yicha)

    // Barcha tariflarni formatlash
    for (var i = 0; i < rates.length; i++) {
      final rate = rates[i];
      final rateNameLower = rate.name.toLowerCase().trim();

      // Faqat Basic, Comfort yoki Premium ni qoldirish
      // Aniq nomlarni tekshirish - faqat to'liq mos keladigan yoki asosiy qismi bo'lgan
      bool isAllowed = false;
      String matchedName = '';

      for (final allowedName in allowedTariffNames) {
        // To'liq mos kelishi yoki nomning asosiy qismi bo'lishi kerak
        if (rateNameLower == allowedName ||
            rateNameLower.startsWith(allowedName) ||
            rateNameLower.contains(allowedName)) {
          isAllowed = true;
          matchedName = allowedName;
          break;
        }
      }

      if (!isAllowed) {
        if (_enableDebugLogs) {
          debugPrint(
            '  ⏭️ Skipping rate [$i]: ${rate.name} (not in allowed list)',
          );
        }
        continue; // Bu tarifni o'tkazib yuborish
      }

      // Duplicate larni tekshirish (nomi bo'yicha VA ID bo'yicha)
      // Agar bir xil nom yoki bir xil ID bo'lsa, o'tkazib yuborish
      if (seenNames.contains(matchedName) || seenIds.contains(rate.id)) {
        if (_enableDebugLogs) {
          debugPrint(
            '  ⏭️ Skipping duplicate rate [$i]: ${rate.name} (id: ${rate.id}, matched: $matchedName)',
          );
        }
        continue; // Duplicate ni o'tkazib yuborish
      }

      // Agar allaqachon 3 ta tarif qo'shilgan bo'lsa, to'xtatish
      if (tariffs.length >= 3) {
        if (_enableDebugLogs) {
          debugPrint(
            '  ⏭️ Maximum 3 tariffs reached, skipping rate [$i]: ${rate.name}',
          );
        }
        break; // Faqat 3 ta tarif kerak
      }

      seenNames.add(matchedName);
      seenIds.add(rate.id);

      if (_enableDebugLogs) {
        debugPrint('  Converting rate [$i]: ${rate.name}');
      }
      // Agar percent bo'lsa va car price bo'lsa, percent dan narxni hisoblash
      double calculatedPrice = 0.0;
      if (rate.percent != null && _carPrice != null) {
        // Backend'dan percent 1, 1.5, 2.5 kabi FOIZ ko'rinishida keladi,
        // shuning uchun narxni hisoblashda 100 ga bo'lamiz:
        // 1%  => carPrice * 1 / 100
        // 1.5% => carPrice * 1.5 / 100
        // 2.5% => carPrice * 2.5 / 100
        calculatedPrice = _carPrice! * rate.percent! / 100;
        if (_enableDebugLogs) {
          debugPrint(
            '💰 Calculated price for ${rate.name}: ${_carPrice} * ${rate.percent} = $calculatedPrice',
          );
        }
      } else if (rate.minPremium != null) {
        // Agar minPremium bo'lsa, uni ishlatish
        calculatedPrice = rate.minPremium!;
        if (_enableDebugLogs) {
          debugPrint('💰 Using minPremium for ${rate.name}: $calculatedPrice');
        }
      } else if (rate.percent != null) {
        // Agar faqat percent bo'lsa va car price yo'q bo'lsa,
        // faqat percent'ni ko'rsatish (narxni keyinroq hisoblaymiz)
        // Hozircha 0 qoldiramiz, chunki narxni hisoblash uchun car price kerak
        calculatedPrice = 0.0;
        if (_enableDebugLogs) {
          debugPrint(
            '⚠️ No car price available for ${rate.name}, percent: ${rate.percent}%',
          );
        }
      }

      // Agar calculatedPrice 0 bo'lsa va minPremium ham yo'q bo'lsa,
      // faqat percent'ni ko'rsatish uchun "Narx hisoblanmoqda" yozamiz
      String formattedPrice;
      if (calculatedPrice == 0.0 &&
          rate.minPremium == null &&
          rate.percent != null) {
        formattedPrice = '${rate.percent}%';
      } else if (calculatedPrice == 0.0) {
        formattedPrice = '0';
      } else {
        formattedPrice = NumberFormat('#,###').format(calculatedPrice.toInt());
      }

      // Description yaratish (percent bo'lsa)
      String description;
      if (rate.description.isNotEmpty) {
        description = rate.description;
      } else if (rate.percent != null) {
        // percent maydoni allaqachon foiz sifatida (1, 1.5, 2.5) keladi,
        // shuning uchun 100 ga ko'paytirmaymiz.
        final percentValue = rate.percent!;
        final percentString = percentValue % 1 == 0
            ? percentValue.toStringAsFixed(0)
            : percentValue.toStringAsFixed(1);
        description = '$percentString${tr('common.percent')} ${tr('insurance.kasko.tariff.coverage')}';
      } else {
        description = tr('insurance.kasko.tariff.insurance_tariff');
      }

      tariffs.add(
        TariffModel(
          id: rate.id,
          title: rate.name.isNotEmpty ? rate.name : tr('insurance.kasko.tariff.tariff'),
          duration: '12 ${tr('common.months')}', // Default duration
          description: description,
          price: formattedPrice,
        ),
      );

      if (_enableDebugLogs) {
        debugPrint(
          '📋 Tariff: ${rate.name} - ${formattedPrice} ${tr('common.soum')} (percent: ${rate.percent})',
        );
      }
    }

    if (_enableDebugLogs) {
      debugPrint('✅ Converted ${tariffs.length} tariffs');
    }

    // Cache'ga saqlash
    _lastConvertedRates = rates;
    _cachedConvertedTariffs = tariffs;

    return tariffs;
  }

  // Optimizatsiya: debounced setState - ortiqcha chaqiruvlarni oldini oladi
  void _debouncedSetState(VoidCallback fn) {
    _updateTimer?.cancel();
    _updateTimer = Timer(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(fn);
      }
    });
  }

  // Tariflarni Standart va Boshqa tariflarga ajratish
  // Endi faqat Basic, Comfort, Premium ko'rsatiladi, shuning uchun barchasini standart qilamiz
  void _categorizeTariffs(List<TariffModel> allTariffs) {
    _standardTariffs = [];
    _otherTariffs = [];

    if (allTariffs.isEmpty) {
      debugPrint('⚠️ No tariffs to categorize');
      _filterTariffsByTab();
      return;
    }

    // Duplicate larni oldini olish uchun
    final seenNames = <String>{};
    final seenIds = <int>{};
    final List<TariffModel> uniqueTariffs = [];

    // Faqat unique tariflarni qo'shish
    for (final tariff in allTariffs) {
      final tariffNameLower = tariff.title.toLowerCase().trim();

      // Faqat basic, comfort, premium ni qabul qilish
      final allowedNames = ['basic', 'comfort', 'premium'];
      bool isAllowed = false;
      String matchedName = '';

      for (final allowedName in allowedNames) {
        if (tariffNameLower == allowedName ||
            tariffNameLower.startsWith(allowedName) ||
            tariffNameLower.contains(allowedName)) {
          isAllowed = true;
          matchedName = allowedName;
          break;
        }
      }

      if (!isAllowed) {
        continue;
      }

      // Duplicate tekshirish
      if (seenNames.contains(matchedName) || seenIds.contains(tariff.id)) {
        continue;
      }

      // Agar allaqachon 3 ta tarif qo'shilgan bo'lsa, to'xtatish
      if (uniqueTariffs.length >= 3) {
        break;
      }

      seenNames.add(matchedName);
      if (tariff.id != null) {
        seenIds.add(tariff.id!);
      }
      uniqueTariffs.add(tariff);
    }

    // Faqat Basic, Comfort va Premium ko'rsatiladi, shuning uchun barchasini standart qilamiz
    _standardTariffs = uniqueTariffs;
    _otherTariffs = [];

    debugPrint(
      '📊 Categorized: ${_standardTariffs.length} standard, ${_otherTariffs.length} other',
    );
    _filterTariffsByTab();
  }

  @override
  Widget build(BuildContext context) {
    // Locale o'zgarishini kuzatish uchun context.locale ni ishlatamiz
    // Bu locale o'zgarganda widget'ni qayta build qiladi
    final currentLocale = context.locale;
    if (_enableDebugLogs) {
      debugPrint('🌍 Current locale: $currentLocale');
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? AppColors.darkScaffoldBg
        : AppColors.background;
    final cardBg = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
    final textColor = isDark ? AppColors.darkTextColor : AppColors.lightTextColor;
    final subtitleColor = isDark ? AppColors.darkSubtitle : AppColors.lightSubtitle;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Bloc'ni context'dan olish - har doim modul darajasidagi BLoC ishlatiladi
    final bloc = context.read<KaskoBloc>();
    if (_enableDebugLogs) {
      debugPrint('✅ Bloc found in context: ${bloc.hashCode}');
    }

    // Build metodida car price'ni tekshirish va state'ni yangilash
    // Build metodida og'ir ishlarni qilmaslik - faqat kerakli holatlarda
    if (!_hasInitialized) {
      _hasInitialized = true;
      // Sinxron ravishda car price'ni tekshirish
      final currentState = bloc.state;
      if (currentState is KaskoCarPriceCalculated) {
        _carPrice = currentState.carPrice.price;
        _carId = currentState.carPrice.carId;
        _year = currentState.carPrice.year;
      }

      // Agar rates allaqachon yuklangan bo'lsa, ularni darhol UI'da ko'rsatish
      if (currentState is KaskoRatesLoaded) {
        // Og'ir ishlarni microtask'ga ko'chiramiz, main thread'ni bloklamaslik uchun
        Future.microtask(() {
          if (!mounted) return;

          final convertedTariffs = _convertRatesToTariffs(currentState.rates);
          _categorizeTariffs(convertedTariffs);

          // Debounced setState
          _debouncedSetState(() {
            _allTariffs = convertedTariffs;
          });
        });
      } else {
        // Agar rates yuklanmagan bo'lsa, yuklash (cache'dan foydalanish)
        // PostFrameCallback orqali, UI render bo'lgandan keyin
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            bloc.add(const FetchRates(forceRefresh: false));
          }
        });
      }
    }

    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: scaffoldBg,
        body: SafeArea(
          child: BlocConsumer<KaskoBloc, KaskoState>(
            listener: (context, state) {
              if (_enableDebugLogs) {
                debugPrint('🔔 KaskoBloc state changed: ${state.runtimeType}');
              }

              // Car price'ni saqlash (percent dan narxni hisoblash uchun)
              if (state is KaskoCarPriceCalculated) {
                // Optimizatsiya: faqat o'zgarganda yangilash
                if (_carPrice != state.carPrice.price ||
                    _carId != state.carPrice.carId ||
                    _year != state.carPrice.year) {
                  _carPrice = state.carPrice.price;
                  _carId = state.carPrice.carId;
                  _year = state.carPrice.year;

                  if (_enableDebugLogs) {
                    debugPrint('💰 Car price saved: $_carPrice');
                    debugPrint('🚗 Car ID: $_carId, Year: $_year');
                  }

                  // Mashina narxi yangilanganda, tariflarni qayta hisoblash
                  // Og'ir ishlarni microtask'ga ko'chiramiz
                  Future.microtask(() {
                    if (!mounted) return;

                    final bloc = context.read<KaskoBloc>();
                    final currentState = bloc.state;
                    if (currentState is KaskoRatesLoaded &&
                        currentState.rates.isNotEmpty) {
                      // Cache'ni tozalash, chunki car price o'zgardi
                      _lastConvertedRates = null;
                      _cachedConvertedTariffs = null;

                      // Tariflarni yangi narx bilan qayta hisoblash
                      final convertedTariffs = _convertRatesToTariffs(
                        currentState.rates,
                      );
                      _categorizeTariffs(convertedTariffs);

                      // Debounced setState
                      _debouncedSetState(() {
                        _allTariffs = convertedTariffs;
                      });
                    }
                  });
                }
              }

              // API'dan tariflarni yuklash
              if (state is KaskoRatesLoaded) {
                if (_enableDebugLogs) {
                  debugPrint(
                    '✅✅✅ Rates loaded from API: ${state.rates.length} items',
                  );
                }

                if (state.rates.isEmpty) {
                  if (_enableDebugLogs) {
                    debugPrint('⚠️⚠️⚠️ Rates list is EMPTY!');
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('insurance.kasko.tariff.not_found'.tr()),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                // Har bir rate'ni log qilish
                if (_enableDebugLogs) {
                  debugPrint('📋📋📋 API dan kelgan tariflar:');
                  for (var i = 0; i < state.rates.length; i++) {
                    final rate = state.rates[i];
                    debugPrint(
                      '  [$i] id=${rate.id}, name="${rate.name}", percent=${rate.percent}, minPremium=${rate.minPremium}, description="${rate.description}"',
                    );
                  }
                }

                // Optimizatsiya: faqat bir marta konvertatsiya qilish
                // Agar rates o'zgarmagan bo'lsa, qayta konvertatsiya qilmaymiz
                if (_lastConvertedRates != state.rates ||
                    _cachedConvertedTariffs == null) {
                  // Og'ir ishlarni microtask'ga ko'chiramiz, main thread'ni bloklamaslik uchun
                  Future.microtask(() {
                    if (!mounted) return;

                    final convertedTariffs = _convertRatesToTariffs(
                      state.rates,
                    );

                    if (convertedTariffs.isEmpty) {
                      if (_enableDebugLogs) {
                        debugPrint(
                          '⚠️⚠️⚠️ _allTariffs is EMPTY after conversion!',
                        );
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('insurance.kasko.tariff.conversion_failed'.tr()),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Tariflarni Standart va Boshqa tariflarga ajratish
                    _categorizeTariffs(convertedTariffs);

                    // Debounced setState - ortiqcha chaqiruvlarni oldini oladi
                    _debouncedSetState(() {
                      _allTariffs = convertedTariffs;

                      // Agar selectedRate bo'lsa, uni UI'da ko'rsatish
                      if (state.selectedRate != null) {
                        _selectedRateEntity = state.selectedRate;
                        final selectedRateId = state.selectedRate!.id;
                        // _allTariffs ichida tanlangan rate'ni topish
                        final selectedIndex = convertedTariffs.indexWhere(
                          (t) => t.id == selectedRateId,
                        );
                        if (selectedIndex != -1) {
                          _selectedCardIndex = selectedIndex;
                        }
                      } else {
                        _selectedRateEntity = null;
                        _selectedCardIndex = -1;
                      }
                    });
                  });
                }
              } else if (state is KaskoError) {
                if (_enableDebugLogs) {
                  debugPrint('❌❌❌ KaskoError: ${state.message}');
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              } else if (state is KaskoLoading) {
                if (_enableDebugLogs) {
                  debugPrint('⏳ Loading rates from API...');
                }
              }
            },
            builder: (context, state) {
              // API'dan kelgan tariflarni tekshirish va UI'ni yangilash
              if (state is KaskoRatesLoaded && _enableDebugLogs) {
                // Faqat debug rejimida log yozish
                debugPrint(
                  '📊 Builder: KaskoRatesLoaded state, _tariffs.length = ${_tariffs.length}, _allTariffs.length = ${_allTariffs.length}',
                );

                // Agar tariflar bo'sh bo'lsa, yana bir bor tekshirish
                if (_allTariffs.isEmpty && state.rates.isNotEmpty) {
                  if (_enableDebugLogs) {
                    debugPrint(
                      '⚠️ Builder: _allTariffs is empty but state.rates is not empty, converting...',
                    );
                  }
                  // Og'ir ishlarni microtask'ga ko'chiramiz
                  Future.microtask(() {
                    if (!mounted) return;

                    final convertedTariffs = _convertRatesToTariffs(
                      state.rates,
                    );
                    _categorizeTariffs(convertedTariffs);

                    // Debounced setState
                    _debouncedSetState(() {
                      _allTariffs = convertedTariffs;
                    });
                  });
                }
              }

              // Loading holati - faqat birinchi marta yuklanganda ko'rsatish
              if (state is KaskoLoading && _allTariffs.isEmpty) {
                return Column(
                  children: [
                    _buildCustomAppBar(cardBg, textColor),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFF0085FF),
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 24.h),
                            Text(
                              'insurance.kasko.tariff.loading'.tr(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'insurance.kasko.tariff.please_wait'.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              // Error holati
              if (state is KaskoError && _tariffs.isEmpty) {
                return Column(
                  children: [
                    _buildCustomAppBar(cardBg, textColor),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64.sp,
                                color: Colors.red,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                state.message,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 24.h),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<KaskoBloc>().add(
                                    const FetchRates(),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0085FF),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 32.w,
                                    vertical: 12.h,
                                  ),
                                ),
                                child: Text(
                                  'insurance.kasko.tariff.retry'.tr(),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _buildCustomAppBar(cardBg, textColor),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Asosiy kontent
                        Expanded(
                          flex: 2,
                          child: CustomScrollView(
                            slivers: [
                              // Padding uchun
                              SliverPadding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 20.h,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildListDelegate([
                                    // Qadam ko'rsatkichi
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'insurance.kasko.tariff.title'.tr(),
                                              style: TextStyle(
                                                fontSize: 24.sp,
                                                fontWeight: FontWeight.w800,
                                                color: textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                            vertical: 6.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0xFF2A2A2A)
                                                : const Color(0xFFF3F4F6),
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                          child: Text(
                                            'insurance.kasko.tariff.step_indicator'.tr(),
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              color: subtitleColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'insurance.kasko.tariff.subtitle'.tr(),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: subtitleColor,
                                      ),
                                    ),
                                    SizedBox(height: 24.h),
                                  ]),
                                ),
                              ),
                              // Tariflar ro'yxatini generatsiya qilish - Optimizatsiya: SliverList
                              if (_tariffs.isEmpty && _allTariffs.isEmpty)
                                // Agar hali yuklanmagan bo'lsa
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(24.w),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const CircularProgressIndicator(
                                            color: Color(0xFF0085FF),
                                            strokeWidth: 2.5,
                                          ),
                                          SizedBox(height: 24.h),
                                          Text(
                                            'insurance.kasko.tariff.loading'.tr(),
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                              color: textColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            'insurance.kasko.tariff.please_wait'.tr(),
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: subtitleColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              else if (_tariffs.isEmpty &&
                                  _allTariffs.isNotEmpty)
                                // Agar kategoriyalashtirishdan keyin bo'sh bo'lsa
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(24.w),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: 64.sp,
                                            color: subtitleColor,
                                          ),
                                          SizedBox(height: 16.h),
                                          Text(
                                            'insurance.kasko.tariff.no_tariffs_in_category'.tr(),
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              color: textColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              else
                                // Optimizatsiya: SliverList ishlatish - faqat ko'rinadigan elementlarni render qilish
                                SliverPadding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate((
                                      context,
                                      index,
                                    ) {
                                      final tariff = _tariffs[index];
                                      if (_enableDebugLogs && index < 3) {
                                        debugPrint(
                                          '🎨 Rendering tariff card: ${tariff.title} (index: $index)',
                                        );
                                      }
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 16.h),
                                        child: _TariffCard(
                                          data: tariff,
                                          isSelected:
                                              _selectedCardIndex == index,
                                          onTap: () {
                                            if (_enableDebugLogs) {
                                              debugPrint(
                                                '👆 Tariff selected: ${tariff.title} (id: ${tariff.id})',
                                              );
                                            }

                                            // Bloc'ga SelectRate event'ini yuborish
                                            final bloc = context
                                                .read<KaskoBloc>();
                                            final currentState = bloc.state;
                                            if (currentState
                                                is KaskoRatesLoaded) {
                                              // Tanlangan rate'ni topish
                                              final selectedRate = currentState
                                                  .rates
                                                  .firstWhere(
                                                    (rate) =>
                                                        rate.id == tariff.id,
                                                    orElse: () => currentState
                                                        .rates
                                                        .first,
                                                  );

                                              // State'ni yangilash va Bloc'ga event yuborish
                                              // Optimizatsiya: faqat o'zgarganda setState
                                              if (_selectedCardIndex != index ||
                                                  _selectedRateEntity?.id !=
                                                      selectedRate.id) {
                                                _debouncedSetState(() {
                                                  _selectedCardIndex = index;
                                                  _selectedRateEntity =
                                                      selectedRate;
                                                });
                                              }

                                              bloc.add(
                                                SelectRate(selectedRate),
                                              );
                                              if (_enableDebugLogs) {
                                                debugPrint(
                                                  '✅✅✅ SelectRate event dispatched: ${selectedRate.name} (id: ${selectedRate.id})',
                                                );
                                              }
                                            } else {
                                              // Agar state KaskoRatesLoaded bo'lmasa, faqat UI'ni yangilash
                                              if (_selectedCardIndex != index) {
                                                _debouncedSetState(
                                                  () => _selectedCardIndex =
                                                      index,
                                                );
                                              }
                                            }
                                          },
                                          isDark: isDark,
                                        ),
                                      );
                                    }, childCount: _tariffs.length),
                                  ),
                                ),
                              SliverToBoxAdapter(child: SizedBox(height: 8.h)),
                            ],
                          ),
                        ),
                        // Xulosa paneli (o'ng tomonda) - faqat desktop'da ko'rsatish
                        if (MediaQuery.of(context).size.width > 600)
                          Container(
                            width: 300.w,
                            margin: EdgeInsets.only(
                              top: 20.h,
                              right: 16.w,
                              bottom: 20.h,
                            ),
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _buildSummaryPanel(
                              bloc,
                              isDark,
                              textColor,
                              subtitleColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildBottomButton(cardBg, bottomPadding),
                ],
              );
            },
          ),
        ),
      ),
    );
  }


  // Xulosa paneli widget
  Widget _buildSummaryPanel(
    KaskoBloc bloc,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    // State'dan ma'lumotlarni olish
    String carName = '--';
    String coverage = '--';
    String premium = '--';
    String period = '1 ${tr('common.year')}';

    final currentState = bloc.state;

    // Mashina ma'lumotlari
    if (currentState is KaskoCarsLoaded && currentState.cars.isNotEmpty) {
      final car = currentState.cars.first;
      carName = car.name;
    }

    // Tanlangan tarif ma'lumotlari
    if (_selectedRateEntity != null) {
      if (_selectedRateEntity!.percent != null) {
        coverage =
            '${(_selectedRateEntity!.percent! * 100).toStringAsFixed(0)}%';
      } else {
        coverage = _selectedRateEntity!.description.isNotEmpty
            ? _selectedRateEntity!.description
            : '--';
      }

      // Premium hisoblash
      if (_carPrice != null && _selectedRateEntity!.percent != null) {
        final calculatedPremium = _carPrice! * _selectedRateEntity!.percent!;
        premium =
            NumberFormat('#,###').format(calculatedPremium.toInt()) + ' so\'m';
      } else if (_selectedRateEntity!.minPremium != null) {
        premium =
            NumberFormat(
              '#,###',
            ).format(_selectedRateEntity!.minPremium!.toInt()) +
            ' so\'m';
      }
    }

    // Policy ma'lumotlari
    if (currentState is KaskoPolicyCalculated) {
      premium =
          NumberFormat(
            '#,###',
          ).format(currentState.calculateResult.premium.toInt()) +
          ' so\'m';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'insurance.kasko.tariff.summary'.tr(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        SizedBox(height: 20.h),
        _buildSummaryRow(
          'insurance.kasko.tariff.insurance_period'.tr(),
          period,
          isDark,
          textColor,
          subtitleColor,
        ),
        SizedBox(height: 14.h),
        _buildSummaryRow(
          'insurance.kasko.tariff.vehicle'.tr(),
          carName,
          isDark,
          textColor,
          subtitleColor,
        ),
        SizedBox(height: 14.h),
        _buildSummaryRow(
          'insurance.kasko.tariff.coverage_amount'.tr(),
          coverage,
          isDark,
          textColor,
          subtitleColor,
        ),
        SizedBox(height: 14.h),
        _buildSummaryRow(
          'insurance.kasko.tariff.amount_to_pay'.tr(),
          premium,
          isDark,
          textColor,
          subtitleColor,
        ),
        SizedBox(height: 20.h),
        InkWell(
          onTap: () async {
            // Sug'urta qoidalarini ochish
            try {
              // PDF URL ni API dan olish kerak, hozircha mock URL
              const pdfUrl = 'https://example.com/kasko-rules.pdf';
              final uri = Uri.parse(pdfUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('insurance.kasko.tariff.pdf_open_error'.tr()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('insurance.kasko.tariff.pdf_open_error'.tr()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: Text(
            'insurance.kasko.tariff.insurance_rules'.tr(),
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF0085FF),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: subtitleColor),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomAppBar(Color cardBg, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: cardBg,
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                size: 20.sp,
                color: textColor,
              ),
              onPressed: () {
                context.router.pop();
              },
            ),
          ),
          Expanded(
            child: Text(
              'insurance.kasko.title'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
          SizedBox(width: 44.w), // Balans uchun
        ],
      ),
    );
  }

  Widget _buildBottomButton(Color cardBg, double bottomPadding) {
    final isEnabled = _selectedCardIndex != -1 && _selectedRateEntity != null;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h + bottomPadding),
      decoration: BoxDecoration(
        color: cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: isEnabled
              ? () {
                  // Ma'lumotlar to'ldirilganligini tekshirish
                  if (_selectedRateEntity == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('insurance.kasko.tariff.select_tariff'.tr()),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // BLoC'dan ma'lumotlarni tekshirish
                  try {
                    final bloc = context.read<KaskoBloc>();

                    // Avtomobil tanlanganligini tekshirish
                    if (bloc.selectedCarPositionId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('insurance.kasko.tariff.select_car'.tr()),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Yil tanlanganligini tekshirish
                    if (bloc.selectedYear == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('insurance.kasko.tariff.select_year'.tr()),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    debugPrint(
                      '✅✅✅ Continue button pressed. Selected rate: ${_selectedRateEntity?.name} (id: ${_selectedRateEntity?.id})',
                    );
                    debugPrint('🚀🚀🚀 Navigating to KaskoDocumentDataPage...');
                    debugPrint('✅ BLoC found: ${bloc.hashCode}');

                    // Avval tarifni to'g'ridan-to'g'ri cache'ga saqlash (navigatsiya paytida ishlatish uchun)
                    // Bu muhim, chunki SelectRate event yuborilganda, u darhol ishlanmaydi
                    if (_selectedRateEntity != null) {
                      bloc.setSelectedRateDirectly(_selectedRateEntity!);
                      debugPrint('💾💾💾 Rate saved directly to cache: ${_selectedRateEntity!.name}');
                      // Keyin SelectRate event'ini ham yuborish (state'ni yangilash uchun)
                      bloc.add(SelectRate(_selectedRateEntity!));
                    }

                    // Polis hisoblash uchun kerakli ma'lumotlar
                    final carId = bloc.selectedCarPositionId;
                    final year = bloc.selectedYear;
                    final price = bloc.calculatedPrice;

                    if (carId != null && year != null && price != null) {
                      // Sana hisoblash (1 yil muddat)
                      final beginDate = DateTime.now();
                      final endDate = DateTime(
                        beginDate.year + 1,
                        beginDate.month,
                        beginDate.day,
                      );

                      // Polis hisoblash
                      bloc.add(
                        CalculatePolicy(
                          carId: carId,
                          year: year,
                          price: price,
                          beginDate: beginDate,
                          endDate: endDate,
                          driverCount: 0, // Default qiymat
                          franchise: 0.0, // Default qiymat
                          selectedRateId: _selectedRateEntity?.id,
                        ),
                      );
                      debugPrint('📊 CalculatePolicy event yuborildi');
                    } else {
                      debugPrint('⚠️ CalculatePolicy uchun ma\'lumotlar yetarli emas: carId=$carId, year=$year, price=$price');
                    }

                    // BLoC'ni o'tkazish bilan navigatsiya
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: bloc,
                              child: const KaskoDocumentDataPage(),
                            ),
                          ),
                        )
                        .then((_) {
                          debugPrint(
                            '✅✅✅ Navigation to KaskoDocumentDataPage completed',
                          );
                        })
                        .catchError((e) {
                          debugPrint('❌❌❌ Navigation error: $e');
                          return null;
                        });
                  } catch (e) {
                    debugPrint('❌❌❌ Error getting BLoC: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${tr('common.error')}: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled
                ? const Color(0xFF0085FF)
                : const Color(0xFFE5E7EB), // Disabled holat uchun kulrang
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            disabledBackgroundColor: const Color(0xFFE5E7EB),
          ),
          child: Text(
            'insurance.kasko.tariff.continue'.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isEnabled ? Colors.white : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ),
    );
  }
}

// --- CARD WIDGET ---
class _TariffCard extends StatelessWidget {
  final TariffModel data;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _TariffCard({
    required this.data,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Asosiy ranglar
    final Color primaryColor = const Color(0xFF0085FF);
    final Color labelBlue = const Color(0xFF0085FF);

    // Dark mode uchun ranglar
    final Color lightBlueBg = const Color(0xFFEFF8FF); // Light mode uchun
    final Color darkBlueBg = const Color(0xFF1E3A5C); // Dark mode uchun

    // Karta fon rangi
    final cardBg = isDark ? darkBlueBg : lightBlueBg;

    // Matn ranglari
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final valueColor = isDark ? Colors.white : const Color(0xFF111827);
    final dividerColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.05);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title - Katta qalin shrift
                Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                SizedBox(height: 20.h),

                // Duration va Coverage - Label'lar ko'k rangda
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Davomiyligi
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'insurance.kasko.tariff.duration'.tr(),
                            style: TextStyle(
                              color: labelBlue,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            data.duration,
                            style: TextStyle(
                              color: valueColor,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    // Qoplash
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'insurance.kasko.tariff.coverage'.tr(),
                            style: TextStyle(
                              color: labelBlue,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            data.description,
                            style: TextStyle(
                              color: valueColor,
                              fontSize: 14.sp,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Divider
                Divider(color: dividerColor, thickness: 1),

                SizedBox(height: 16.h),

                // Price - Pastda katta ko'k rangda
                Text(
                  "${data.price} ${'insurance.kasko.tariff.som'.tr()}",
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            // Checkmark icon - tanlangan holatda
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 20.sp),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
