import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/kasko_bloc.dart';
import '../bloc/kasko_event.dart';
import '../bloc/kasko_state.dart';
import 'kasko_tariff_page.dart';

@RoutePage()
class KaskoFormSelectionPage extends StatefulWidget {
  const KaskoFormSelectionPage({super.key});

  @override
  State<KaskoFormSelectionPage> createState() => _KaskoFormSelectionPageState();
}

class _KaskoFormSelectionPageState extends State<KaskoFormSelectionPage> {
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedPosition;
  int? _selectedYear;
  int? _selectedCarId;

  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  final List<int> _years = List.generate(
    30,
    (index) => DateTime.now().year - index,
  );

  // Cache qilingan ma'lumotlar
  List<String>? _cachedBrands;
  List<String>? _cachedModels;
  bool _isProcessingData = false;

  @override
  void initState() {
    super.initState();
    // Faqat minimal ma'lumotlarni yuklash (brand, model, position)
    // Bu performance uchun yaxshiroq, chunki birinchi sahifada faqat minimal ma'lumotlar kerak
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final bloc = context.read<KaskoBloc>();
        bloc.add(const FetchCarsMinimal());
        // To'liq ma'lumotlar va rates faqat kerak bo'lganda yuklanadi
      }
    });
  }

  Future<void> _processCarsData(List<dynamic> cars) async {
    if (_cachedBrands != null || _isProcessingData) return;

    _isProcessingData = true;
    try {
      // Background'da ma'lumotlarni qayta ishlash
      _cachedBrands = await _extractBrands(cars);
      if (mounted) {
        setState(() {
          _isProcessingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessingData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _positionController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  bool get _canProceed =>
      _selectedBrand != null &&
      _selectedModel != null &&
      _selectedPosition != null &&
      _selectedYear != null &&
      _selectedCarId != null;

  // Sync funksiyalar - UI'da darhol ishlatiladi
  List<String> _extractBrandsSync(List<dynamic> cars) {
    final brands = <String>{};
    for (final car in cars) {
      if (car.brand != null && car.brand!.isNotEmpty) {
        brands.add(car.brand!);
      }
    }
    final result = brands.toList()..sort();
    return result;
  }

  List<String> _extractModelsSync(List<dynamic> cars, String selectedBrand) {
    final models = <String>{};
    for (final car in cars) {
      if (car.brand == selectedBrand &&
          car.model != null &&
          car.model!.isNotEmpty) {
        models.add(car.model!);
      }
    }
    final result = models.toList()..sort();
    return result;
  }

  List<String> _extractPositionsSync(
    List<dynamic> cars,
    String selectedBrand,
    String selectedModel,
  ) {
    final positions = <String>{};
    for (final car in cars) {
      if (car.brand == selectedBrand &&
          car.model == selectedModel &&
          car.name.isNotEmpty) {
        positions.add(car.name);
      }
    }
    final result = positions.toList()..sort();
    return result;
  }

  // Async funksiyalar - background'da cache'ni yangilaydi
  Future<List<String>> _extractBrands(List<dynamic> cars) async {
    final payload = cars
        .map(
          (car) => {'brand': car.brand, 'model': car.model, 'name': car.name},
        )
        .toList();

    final result = await compute(_extractBrandsIsolate, payload);
    return result;
  }

  Future<List<String>> _extractModels(
    List<dynamic> cars,
    String selectedBrand,
  ) async {
    final payload = {
      'cars': cars
          .map(
            (car) => {'brand': car.brand, 'model': car.model, 'name': car.name},
          )
          .toList(),
      'selectedBrand': selectedBrand,
    };

    final result = await compute(_extractModelsIsolate, payload);
    return result;
  }

  void _showSelectionSheet({
    required String title,
    required List<String> items,
    required Function(String) onSelected,
  }) {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('insurance.kasko.form_selection.error'.tr())),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SelectionBottomSheet(
        title: title,
        items: items,
        onSelected: onSelected,
      ),
    );
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

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: BlocConsumer<KaskoBloc, KaskoState>(
          listener: (context, state) {
            // Ma'lumotlar yuklanganda background'da qayta ishlash
            // Og'ir ishlarni microtask'ga ko'chiramiz, main thread'ni bloklamaslik uchun
            if (state is KaskoCarsLoaded && state.cars.isNotEmpty) {
              Future.microtask(() => _processCarsData(state.cars));
            }

            // Mashina narxi hisoblanganidan keyin tariflar sahifasiga o'tish
            if (state is KaskoCarPriceCalculated) {
              // Kichik kechikish bilan navigatsiya (UI yangilanishi uchun)
              // Bloc'ni saqlab qolish uchun Navigator.push ishlatamiz
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  final bloc = context.read<KaskoBloc>();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: bloc,
                        child: const KaskoTariffPage(),
                      ),
                    ),
                  );
                }
              });
            }

            // Xatolik holatida xabar ko'rsatish
            if (state is KaskoError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is KaskoLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFF0085FF),
                ),
              );
            }

            if (state is KaskoError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                      SizedBox(height: 16.h),
                      Text(
                        state.message,
                        style: TextStyle(fontSize: 16.sp, color: textColor),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: () {
                          context.read<KaskoBloc>().add(const FetchCarsMinimal());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0085FF),
                          padding: EdgeInsets.symmetric(
                            horizontal: 32.w,
                            vertical: 12.h,
                          ),
                        ),
                        child: Text(
                          'insurance.kasko.form_selection.retry'.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is KaskoCarsLoaded && state.cars.isNotEmpty) {
              // Brand'larni ajratib olish - cache'dan yoki sync qilish
              final brands = _cachedBrands ?? _extractBrandsSync(state.cars);

              // Tanlangan brand bo'yicha modellar - async yoki sync
              List<String> models = <String>[];
              if (_selectedBrand != null) {
                if (_cachedModels == null) {
                  // Async qayta ishlash
                  _extractModels(state.cars, _selectedBrand!).then((result) {
                    if (mounted) {
                      setState(() {
                        _cachedModels = result;
                      });
                    }
                  });
                  models = _extractModelsSync(state.cars, _selectedBrand!);
                } else {
                  models = _cachedModels!;
                }
              }

              // Tanlangan model bo'yicha pozitsiyalar - sync
              final positions = _selectedModel != null && _selectedBrand != null
                  ? _extractPositionsSync(
                      state.cars,
                      _selectedBrand!,
                      _selectedModel!,
                    )
                  : <String>[];

              return Column(
                children: [
                  _buildCustomAppBar(cardBg, textColor),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'insurance.kasko.form_selection.title'.tr(),
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Brand selection
                          _buildSelectField(
                            label: 'insurance.kasko.form_selection.brand'.tr(),
                            controller: _brandController,
                            hint: 'insurance.kasko.form_selection.select_brand'
                                .tr(),
                            enabled: true,
                            isDark: isDark,
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                            onTap: () {
                              _showSelectionSheet(
                                title:
                                    'insurance.kasko.form_selection.select_brand'
                                        .tr(),
                                items: brands,
                                onSelected: (value) {
                                  setState(() {
                                    _selectedBrand = value;
                                    _brandController.text = value;
                                    _selectedModel = null;
                                    _selectedPosition = null;
                                    _selectedCarId = null;
                                    _modelController.clear();
                                    _positionController.clear();
                                    // Cache'ni tozalash
                                    _cachedModels = null;
                                  });
                                  // BLoC'ga brendni saqlash
                                  context.read<KaskoBloc>().add(
                                    SelectCarBrand(
                                      carBrandId: value,
                                      carBrandName: value,
                                    ),
                                  );
                                },
                              );
                            },
                          ),

                          SizedBox(height: 20.h),

                          // Model selection
                          _buildSelectField(
                            label: 'insurance.kasko.form_selection.model'.tr(),
                            controller: _modelController,
                            hint: 'insurance.kasko.form_selection.select_model'
                                .tr(),
                            enabled: _selectedBrand != null,
                            isDark: isDark,
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                            onTap: _selectedBrand != null
                                ? () {
                                    _showSelectionSheet(
                                      title:
                                          'insurance.kasko.form_selection.select_model'
                                              .tr(),
                                      items: models,
                                      onSelected: (value) {
                                        setState(() {
                                          _selectedModel = value;
                                          _modelController.text = value;
                                          _selectedPosition = null;
                                          _selectedCarId = null;
                                          _positionController.clear();
                                        });
                                        // BLoC'ga modelni saqlash
                                        context.read<KaskoBloc>().add(
                                          SelectCarModel(
                                            carModelId: value,
                                            carModelName: value,
                                          ),
                                        );
                                      },
                                    );
                                  }
                                : null,
                          ),

                          SizedBox(height: 20.h),

                          // Position selection
                          _buildSelectField(
                            label: 'insurance.kasko.form_selection.position'
                                .tr(),
                            controller: _positionController,
                            hint:
                                'insurance.kasko.form_selection.select_position'
                                    .tr(),
                            enabled: _selectedModel != null,
                            isDark: isDark,
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                            onTap: _selectedModel != null
                                ? () {
                                    _showSelectionSheet(
                                      title:
                                          'insurance.kasko.form_selection.select_position'
                                              .tr(),
                                      items: positions,
                                      onSelected: (value) {
                                        setState(() {
                                          _selectedPosition = value;
                                          _positionController.text = value;
                                          // Car ID ni topish
                                          try {
                                            final car = state.cars.firstWhere(
                                              (car) =>
                                                  car.brand == _selectedBrand &&
                                                  car.model == _selectedModel &&
                                                  car.name == value,
                                            );
                                            _selectedCarId = car.id;

                                            // BLoC'ga pozitsiyani saqlash
                                            context.read<KaskoBloc>().add(
                                              SelectCarPosition(
                                                carPositionId: car.id,
                                                carPositionName: value,
                                                carEntity: car,
                                              ),
                                            );
                                          } catch (e) {
                                            debugPrint('Car not found: $e');
                                            _selectedCarId = null;
                                          }
                                        });
                                      },
                                    );
                                  }
                                : null,
                          ),

                          SizedBox(height: 20.h),

                          // Year selection
                          _buildSelectField(
                            label: 'insurance.kasko.form_selection.year'.tr(),
                            controller: _yearController,
                            hint: 'insurance.kasko.form_selection.select_year'
                                .tr(),
                            enabled: true,
                            isDark: isDark,
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                            onTap: () {
                              _showSelectionSheet(
                                title:
                                    'insurance.kasko.form_selection.select_year'
                                        .tr(),
                                items: _years.map((y) => y.toString()).toList(),
                                onSelected: (value) {
                                  final year = int.tryParse(value);
                                  setState(() {
                                    _selectedYear = year;
                                    _yearController.text = value;
                                  });
                                  // BLoC'ga yilni saqlash
                                  if (year != null) {
                                    context.read<KaskoBloc>().add(
                                      SelectYear(year),
                                    );
                                  }
                                },
                              );
                            },
                          ),

                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomButton(cardBg, bottomPadding, subtitleColor),
                ],
              );
            }

            // Agar ma'lumotlar hali yuklanmagan bo'lsa
            if (state is KaskoInitial) {
              return Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFF0085FF),
                ),
              );
            }

            // Agar ma'lumotlar bo'sh bo'lsa
            if (state is KaskoCarsLoaded && state.cars.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 64.sp,
                        color: subtitleColor,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'insurance.kasko.cars_list.not_found'.tr(),
                        style: TextStyle(fontSize: 16.sp, color: textColor),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: () {
                          context.read<KaskoBloc>().add(const FetchCarsMinimal());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0085FF),
                          padding: EdgeInsets.symmetric(
                            horizontal: 32.w,
                            vertical: 12.h,
                          ),
                        ),
                        child: Text(
                          'insurance.kasko.form_selection.retry'.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
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

  Widget _buildSelectField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool enabled,
    required bool isDark,
    required Color textColor,
    required Color subtitleColor,
    VoidCallback? onTap,
  }) {
    final borderColor = isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB);
    final fillColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final disabledFillColor = isDark
        ? const Color(0xFF1E1E1E).withOpacity(0.5)
        : Colors.grey[100]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: enabled ? fillColor : disabledFillColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: enabled && controller.text.isNotEmpty
                      ? const Color(0xFF0085FF).withOpacity(0.3)
                      : borderColor,
                  width: enabled && controller.text.isNotEmpty ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.text.isEmpty ? hint : controller.text,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: controller.text.isEmpty
                            ? subtitleColor
                            : (enabled ? textColor : subtitleColor),
                        fontWeight: controller.text.isEmpty
                            ? FontWeight.normal
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: enabled
                        ? subtitleColor
                        : subtitleColor.withOpacity(0.5),
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(
    Color cardBg,
    double bottomPadding,
    Color subtitleColor,
  ) {
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
          onPressed: _canProceed
              ? () {
                  // Barcha tanlangan ma'lumotlarni BLoC'ga saqlash (agar hali saqlanmagan bo'lsa)
                  final bloc = context.read<KaskoBloc>();

                  // Brand saqlash
                  if (_selectedBrand != null) {
                    bloc.add(
                      SelectCarBrand(
                        carBrandId: _selectedBrand!,
                        carBrandName: _selectedBrand!,
                      ),
                    );
                  }

                  // Model saqlash
                  if (_selectedModel != null) {
                    bloc.add(
                      SelectCarModel(
                        carModelId: _selectedModel!,
                        carModelName: _selectedModel!,
                      ),
                    );
                  }

                  // Position saqlash
                  if (_selectedCarId != null && _selectedPosition != null) {
                    try {
                      final cachedCars = bloc.cachedCars;
                      if (cachedCars != null) {
                        final car = cachedCars.firstWhere(
                          (car) =>
                              car.brand == _selectedBrand &&
                              car.model == _selectedModel &&
                              car.name == _selectedPosition,
                        );
                        bloc.add(
                          SelectCarPosition(
                            carPositionId: _selectedCarId!,
                            carPositionName: _selectedPosition!,
                            carEntity: car,
                          ),
                        );
                      }
                    } catch (e) {
                      debugPrint('Error saving position: $e');
                    }
                  }

                  // Year saqlash
                  if (_selectedYear != null) {
                    bloc.add(SelectYear(_selectedYear!));
                  }

                  // Tanlangan mashina ID va yil bo'yicha avval mashina narxini hisoblash
                  // (KaskoBloc ichidagi CalculateCarPrice usecase orqali)
                  // Navigatsiya BlocListener orqali KaskoCarPriceCalculated state'da amalga oshiriladi
                  try {
                    if (_selectedCarId != null && _selectedYear != null) {
                      bloc.add(
                        CalculateCarPrice(
                          carId: _selectedCarId!,
                          // Hozircha tarifId = 0, backend bu maydonga e'tibor bermasa ham bo'ladi
                          // Asosiy maqsad – mashinaning bazaviy narxini olish (_carPrice)
                          tarifId: 0,
                          year: _selectedYear!,
                        ),
                      );
                    }
                  } catch (e) {
                    // Agar Bloc topilmasa yoki xatolik bo'lsa, xabar ko'rsatish
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Xatolik yuz berdi: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _canProceed
                ? const Color(0xFF0085FF)
                : const Color(0xFFE5E7EB),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          child: Text(
            'insurance.kasko.form_selection.continue'.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: _canProceed ? Colors.white : subtitleColor,
            ),
          ),
        ),
      ),
    );
  }
}

// Selection Bottom Sheet Widget
class _SelectionBottomSheet extends StatelessWidget {
  final String title;
  final List<String> items;
  final Function(String) onSelected;

  const _SelectionBottomSheet({
    required this.title,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtitleColor = isDark ? Colors.grey[400]! : const Color(0xFF6B7280);
    final dividerColor = isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.7;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: subtitleColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          // Title
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: subtitleColor,
                    size: 24.sp,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: dividerColor),
          // Items list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: items.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                color: dividerColor,
                indent: 20.w,
                endIndent: 20.w,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      onSelected(item);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: bottomPadding > 0 ? bottomPadding : 8.h),
        ],
      ),
    );
  }
}

// Isolate funksiyalari - background thread'da bajariladi
List<String> _extractBrandsIsolate(List<Map<String, dynamic>> payload) {
  final brands = <String>{};
  for (final car in payload) {
    final brand = car['brand'] as String?;
    if (brand != null && brand.isNotEmpty) {
      brands.add(brand);
    }
  }
  final result = brands.toList()..sort();
  return result;
}

List<String> _extractModelsIsolate(Map<String, dynamic> payload) {
  final cars = payload['cars'] as List;
  final selectedBrand = payload['selectedBrand'] as String;
  final models = <String>{};

  for (final car in cars) {
    final brand = car['brand'] as String?;
    final model = car['model'] as String?;
    if (brand == selectedBrand && model != null && model.isNotEmpty) {
      models.add(model);
    }
  }
  final result = models.toList()..sort();
  return result;
}
