import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

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
  int _selectedTabIndex = 0; // 0 = Standart tariflar, 1 = Boshqa tariflar
  List<TariffModel> _allTariffs = []; // Barcha tariflar
  List<TariffModel> _standardTariffs = []; // Standart tariflar
  List<TariffModel> _otherTariffs = []; // Boshqa tariflar
  List<TariffModel> _tariffs = []; // Ko'rsatiladigan tariflar
  double? _carPrice; // Mashina narxi (percent dan narxni hisoblash uchun)
  int? _carId; // Tanlangan mashina ID si (car_position_id)
  int? _year; // Tanlangan yil
  RateEntity? _selectedRateEntity; // Tanlangan rate entity (Bloc'dan keladi)

  KaskoBloc? _bloc;

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
  void _filterTariffsByTab() {
    if (_selectedTabIndex == 0) {
      // Standart tariflar
      _tariffs = List.from(_standardTariffs);
    } else {
      // Boshqa tariflar
      _tariffs = List.from(_otherTariffs);
    }
  }

  // Tab o'zgarganda tariflarni yuklash
  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
      _filterTariffsByTab();

      // Agar "Boshqa tariflar" tanlangan bo'lsa va hali yuklanmagan bo'lsa, API'dan yuklash
      if (index == 1 && _otherTariffs.isEmpty) {
        _bloc?.add(const FetchRates(forceRefresh: true));
      }
    });
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

    // Barcha tariflarni formatlash
    for (var i = 0; i < rates.length; i++) {
      final rate = rates[i];
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
        description = '$percentString% qoplash';
      } else {
        description = 'Sug\'urta tarifi';
      }

      tariffs.add(
        TariffModel(
          id: rate.id,
          title: rate.name.isNotEmpty ? rate.name : 'Tarif',
          duration: '12 oy', // Default duration
          description: description,
          price: formattedPrice,
        ),
      );

      if (_enableDebugLogs) {
        debugPrint(
          '📋 Tariff: ${rate.name} - ${formattedPrice} so\'m (percent: ${rate.percent})',
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
  void _categorizeTariffs(List<TariffModel> allTariffs) {
    _standardTariffs = [];
    _otherTariffs = [];

    if (allTariffs.isEmpty) {
      debugPrint('⚠️ No tariffs to categorize');
      _filterTariffsByTab();
      return;
    }

    // Standart tariflar (Basic, Comfort, Premium, Standart A, Standart B kabi)
    final standardNames = [
      'basic',
      'comfort',
      'premium',
      'standart a',
      'standart b',
      'standart',
      'standard',
    ];

    for (final tariff in allTariffs) {
      final titleLower = tariff.title.toLowerCase().trim();
      final isStandard = standardNames.any(
        (name) => titleLower.contains(name.toLowerCase()),
      );

      if (isStandard) {
        _standardTariffs.add(tariff);
        debugPrint('✅ Standard tariff: ${tariff.title}');
      } else {
        _otherTariffs.add(tariff);
        debugPrint('📌 Other tariff: ${tariff.title}');
      }
    }

    // Agar standart tariflar bo'sh bo'lsa, birinchi 2 tasini standart qilamiz
    if (_standardTariffs.isEmpty && allTariffs.length >= 2) {
      _standardTariffs = allTariffs.take(2).toList();
      _otherTariffs = allTariffs.skip(2).toList();
      debugPrint('⚠️ No standard tariffs found, using first 2 as standard');
    } else if (_standardTariffs.isEmpty) {
      // Agar hali ham bo'sh bo'lsa, barchasini standart qilamiz
      _standardTariffs = List.from(allTariffs);
      debugPrint('⚠️ No standard tariffs found, using all as standard');
    }

    debugPrint(
      '📊 Categorized: ${_standardTariffs.length} standard, ${_otherTariffs.length} other',
    );
    _filterTariffsByTab();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF4F6F8);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtitleColor = isDark ? Colors.grey[400]! : const Color(0xFF6B7280);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Bloc'ni context'dan olish yoki yaratish
    KaskoBloc bloc;
    try {
      bloc = context.read<KaskoBloc>();
      if (_enableDebugLogs) {
        debugPrint('✅ Bloc found in context: ${bloc.hashCode}');
      }
    } catch (e) {
      if (_enableDebugLogs) {
        debugPrint('⚠️ Bloc not found in context, creating new one');
      }
      bloc = _getOrCreateBloc(context);
      if (_enableDebugLogs) {
        debugPrint('✅ Bloc created: ${bloc.hashCode}');
      }
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
                    const SnackBar(
                      content: Text('Tariflar topilmadi'),
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
                if (_lastConvertedRates != state.rates || _cachedConvertedTariffs == null) {
                  // Og'ir ishlarni microtask'ga ko'chiramiz, main thread'ni bloklamaslik uchun
                  Future.microtask(() {
                    if (!mounted) return;
                    
                    final convertedTariffs = _convertRatesToTariffs(state.rates);

                    if (convertedTariffs.isEmpty) {
                      if (_enableDebugLogs) {
                        debugPrint(
                          '⚠️⚠️⚠️ _allTariffs is EMPTY after conversion!',
                        );
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tariflar konvertatsiya qilinmadi'),
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
                              'Tariflar yuklanmoqda...',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Iltimos, kuting',
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
                                  'Qayta urinib ko\'ring',
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
                                        Text(
                                          "Tariflar",
                                          style: TextStyle(
                                            fontSize: 24.sp,
                                            fontWeight: FontWeight.w800,
                                            color: textColor,
                                          ),
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
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Text(
                                            "Qadam 2/5",
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
                                      "O'zingizga mos bo'lgan sug'urta tarifini tanlang",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: subtitleColor,
                                      ),
                                    ),
                                    SizedBox(height: 24.h),
                                    // Tab selector (Standart tariflar / Boshqa tariflar)
                                    _buildTabSelector(
                                      isDark,
                                      textColor,
                                      subtitleColor,
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
                                            'Tariflar yuklanmoqda...',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                              color: textColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            'Iltimos, kuting',
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
                                            'Bu kategoriyada tariflar topilmadi',
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
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
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
                                            isSelected: _selectedCardIndex == index,
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
                                                      orElse: () =>
                                                          currentState.rates.first,
                                                    );

                                                // State'ni yangilash va Bloc'ga event yuborish
                                                // Optimizatsiya: faqat o'zgarganda setState
                                                if (_selectedCardIndex != index ||
                                                    _selectedRateEntity?.id != selectedRate.id) {
                                                  _debouncedSetState(() {
                                                    _selectedCardIndex = index;
                                                    _selectedRateEntity = selectedRate;
                                                  });
                                                }

                                                bloc.add(SelectRate(selectedRate));
                                                if (_enableDebugLogs) {
                                                  debugPrint(
                                                    '✅✅✅ SelectRate event dispatched: ${selectedRate.name} (id: ${selectedRate.id})',
                                                  );
                                                }
                                              } else {
                                                // Agar state KaskoRatesLoaded bo'lmasa, faqat UI'ni yangilash
                                                if (_selectedCardIndex != index) {
                                                  _debouncedSetState(
                                                    () => _selectedCardIndex = index,
                                                  );
                                                }
                                              }
                                            },
                                            isDark: isDark,
                                          ),
                                        );
                                      },
                                      childCount: _tariffs.length,
                                    ),
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
                                            'Tariflar yuklanmoqda...',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                              color: textColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            'Iltimos, kuting',
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
                                            'Bu kategoriyada tariflar topilmadi',
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
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
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
                                          isSelected: _selectedCardIndex == index,
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
                                                    orElse: () =>
                                                        currentState.rates.first,
                                                  );

                                              // State'ni yangilash va Bloc'ga event yuborish
                                              // Optimizatsiya: faqat o'zgarganda setState
                                              if (_selectedCardIndex != index ||
                                                  _selectedRateEntity?.id != selectedRate.id) {
                                                _debouncedSetState(() {
                                                  _selectedCardIndex = index;
                                                  _selectedRateEntity = selectedRate;
                                                });
                                              }

                                              bloc.add(SelectRate(selectedRate));
                                              if (_enableDebugLogs) {
                                                debugPrint(
                                                  '✅✅✅ SelectRate event dispatched: ${selectedRate.name} (id: ${selectedRate.id})',
                                                );
                                              }
                                            } else {
                                              // Agar state KaskoRatesLoaded bo'lmasa, faqat UI'ni yangilash
                                              if (_selectedCardIndex != index) {
                                                _debouncedSetState(
                                                  () => _selectedCardIndex = index,
                                                );
                                              }
                                            }
                                          },
                                          isDark: isDark,
                                        ),
                                      );
                                    },
                                    childCount: _tariffs.length,
                                  ),
                                ),
                              SliverToBoxAdapter(
                                child: SizedBox(height: 8.h),
                              ),
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

  // Bloc'ni olish yoki yaratish
  KaskoBloc _getOrCreateBloc(BuildContext context) {
    try {
      // Avval mavjud Bloc'ni topishga harakat qilish
      return context.read<KaskoBloc>();
    } catch (e) {
      debugPrint('KaskoBloc not found in context, creating new one');
      // Agar Bloc topilmasa, ServiceLocator orqali olish
      // Bu Bloc to'g'ri konfiguratsiya qilingan bo'ladi
      try {
        final bloc = ServiceLocator.resolve<KaskoBloc>();
        debugPrint('KaskoBloc created from ServiceLocator');
        return bloc;
      } catch (e2) {
        debugPrint('Error creating KaskoBloc from ServiceLocator: $e2');
        // Agar ServiceLocator'da ham topilmasa, yangi yaratish
        final repository = KaskoRepositoryImpl(
          ServiceLocator.resolve<KaskoRemoteDataSource>(),
        );
        final bloc = KaskoBloc(
          getCars: GetCars(repository),
          getCarsMinimal: GetCarsMinimal(repository),
          getRates: GetRates(repository),
          calculateCarPrice: usecases.CalculateCarPrice(repository),
          calculatePolicy: usecases.CalculatePolicy(repository),
          saveOrder: usecases.SaveOrder(repository),
          getPaymentLink: GetPaymentLink(repository),
          checkPaymentStatus: CheckPaymentStatus(repository),
          uploadImage: usecases.UploadImage(repository),
        );
        debugPrint('KaskoBloc created manually');
        return bloc;
      }
    }
  }

  // Tab selector widget
  Widget _buildTabSelector(bool isDark, Color textColor, Color subtitleColor) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _onTabChanged(0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0
                      ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: _selectedTabIndex == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Standart tariflar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: _selectedTabIndex == 0
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: _selectedTabIndex == 0
                        ? const Color(0xFF0085FF)
                        : subtitleColor,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: GestureDetector(
              onTap: () => _onTabChanged(1),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1
                      ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: _selectedTabIndex == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Boshqa tariflar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: _selectedTabIndex == 1
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: _selectedTabIndex == 1
                        ? const Color(0xFF0085FF)
                        : subtitleColor,
                  ),
                ),
              ),
            ),
          ),
        ],
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
    String period = '1 yil';

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
          'Xulosa',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        SizedBox(height: 20.h),
        _buildSummaryRow(
          'Sug\'urta davri',
          period,
          isDark,
          textColor,
          subtitleColor,
        ),
        SizedBox(height: 14.h),
        _buildSummaryRow(
          'Avtomobil',
          carName,
          isDark,
          textColor,
          subtitleColor,
        ),
        SizedBox(height: 14.h),
        _buildSummaryRow(
          'Qoplash miqdori',
          coverage,
          isDark,
          textColor,
          subtitleColor,
        ),
        SizedBox(height: 14.h),
        _buildSummaryRow(
          'To\'lanadigan summa',
          premium,
          isDark,
          textColor,
          subtitleColor,
        ),
        SizedBox(height: 20.h),
        InkWell(
          onTap: () {
            // Sug'urta qoidalarini ochish
            // TODO: PDF ochish
          },
          child: Text(
            'Sug\'urta qoidalari',
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
              "KASKO",
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
                      const SnackBar(
                        content: Text('Iltimos, tarifni tanlang'),
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
                        const SnackBar(
                          content: Text('Iltimos, avtomobilni tanlang'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Yil tanlanganligini tekshirish
                    if (bloc.selectedYear == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Iltimos, yilni tanlang'),
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
                        content: Text('Xatolik yuz berdi: $e'),
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
            "Davom etish",
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
    // Ikkinchi rasmdagi kabi yengil ko'k rangli karta
    final Color primaryColor = const Color(0xFF0085FF);
    final Color lightBlueBg = const Color(
      0xFFEFF8FF,
    ); // Yengil ko'k rang (rasmdagi kabi)
    final Color labelBlue = const Color(
      0xFF0085FF,
    ); // Label'lar uchun ko'k rang

    // HAR DOIM yengil ko'k rangli karta (rasmdagi kabi)
    final cardBg = lightBlueBg;

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
              color: Colors.black.withOpacity(0.05),
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
                // Title - Katta qalin shrift (rasmdagi kabi qora rang)
                Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827), // Qora rang (rasmdagi kabi)
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
                            "Davomiyligi:",
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
                              color: const Color(0xFF111827), // Qora rang
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
                            "Qoplash:",
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
                              color: const Color(
                                0xFF111827,
                              ), // Qora rang (rasmdagi kabi)
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
                Divider(color: Colors.grey[300], thickness: 1),

                SizedBox(height: 16.h),

                // Price - Pastda katta ko'k rangda
                Text(
                  "${data.price} so'm",
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
