import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:klero/features/osago/presentation/screens/osago_vehicle_screen.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/rate_entity.dart';
import '../bloc/kasko_bloc.dart';
import '../bloc/kasko_event.dart';
import '../bloc/kasko_state.dart';
import '../widgets/kasko_info_card.dart';
import '../widgets/kasko_tech_passport_input.dart';
import 'kasko_personal_data_page.dart';

@RoutePage()
class KaskoDocumentDataPage extends StatefulWidget {
  const KaskoDocumentDataPage({super.key});

  @override
  State<KaskoDocumentDataPage> createState() => _KaskoDocumentDataPageState();
}

class _KaskoDocumentDataPageState extends State<KaskoDocumentDataPage> {
  // Text controllers
  final TextEditingController _regionController = TextEditingController(
    text: '01',
  );
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _texPassportSeriesController =
      TextEditingController();
  final TextEditingController _texPassportNumberController =
      TextEditingController();

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  RateEntity? _lastKnownRate; // Oxirgi ma'lum bo'lgan tarif

  @override
  void initState() {
    super.initState();
    // Har bir maydon o'zgarganda tugma holatini yangilash
    _numberController.addListener(_updateButtonState);
    _texPassportSeriesController.addListener(_updateButtonState);
    _texPassportNumberController.addListener(_updateButtonState);

    // Dastlabki tarifni saqlash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final bloc = context.read<KaskoBloc>();
        _lastKnownRate = bloc.selectedRate ?? bloc.cachedSelectedRate;
        debugPrint(
            '🔄🔄🔄 initState: Dastlabki tarif: ${_lastKnownRate?.name ?? "null"}');
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Sahifaga qaytganida (masalan, orqaga qaytib yangi tarif tanlaganda),
    // bloc state'ni tekshirish va UI'ni yangilash
    // PostFrameCallback o'rniga darhol tekshirish - bu sahifaga qaytganida ishlaydi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final bloc = context.read<KaskoBloc>();
        final currentRate = bloc.selectedRate ?? bloc.cachedSelectedRate;

        debugPrint(
            '🔄🔄🔄 didChangeDependencies: Joriy tarif: ${currentRate?.name ?? "null"} (id: ${currentRate?.id ?? "null"})');
        debugPrint(
            '🔄🔄🔄 didChangeDependencies: Oxirgi tarif: ${_lastKnownRate?.name ?? "null"} (id: ${_lastKnownRate?.id ?? "null"})');

        // Agar tarif o'zgarganda, UI'ni yangilash
        if (currentRate != null) {
          if (_lastKnownRate == null || currentRate.id != _lastKnownRate!.id) {
            // Avval _lastKnownRate'ni yangilash, keyin setState chaqirish
            _lastKnownRate = currentRate;
            setState(() {});
            debugPrint(
                '🔄🔄🔄 didChangeDependencies: UI yangilandi, yangi tarif: ${currentRate.name}');
          } else {
            debugPrint(
                '🔄🔄🔄 didChangeDependencies: Tarif o\'zgarmadi, UI yangilanmaydi');
          }
        } else if (_lastKnownRate != null) {
          // Agar currentRate null bo'lsa, lekin _lastKnownRate null emas bo'lsa,
          // bu xatolik bo'lishi mumkin, lekin UI'ni yangilash kerak emas
          debugPrint(
              '🔄🔄🔄 didChangeDependencies: currentRate null, lekin _lastKnownRate mavjud');
        }
      }
    });
  }

  void _updateButtonState() {
    setState(() {});
  }

  // Barcha maydonlar to'ldirilganligini tekshirish
  bool _areAllFieldsValid() {
    final carNumber = _numberController.text.trim();
    final texPassportSeries = _texPassportSeriesController.text.trim();
    final texPassportNumber = _texPassportNumberController.text.trim();

    // Car number tekshiruvi (region + number)
    if (carNumber.isEmpty || carNumber.length < 6) {
      return false;
    }

    // Tex passport seriya tekshiruvi (3 ta harf)
    if (texPassportSeries.isEmpty || texPassportSeries.length != 3) {
      return false;
    }
    if (!RegExp(r'^[A-Za-z]{3}$').hasMatch(texPassportSeries)) {
      return false;
    }

    // Tex passport raqami tekshiruvi (7 ta raqam)
    if (texPassportNumber.isEmpty || texPassportNumber.length != 7) {
      return false;
    }
    if (!RegExp(r'^[0-9]{7}$').hasMatch(texPassportNumber)) {
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _numberController.removeListener(_updateButtonState);
    _texPassportSeriesController.removeListener(_updateButtonState);
    _texPassportNumberController.removeListener(_updateButtonState);
    _regionController.dispose();
    _numberController.dispose();
    _texPassportSeriesController.dispose();
    _texPassportNumberController.dispose();
    super.dispose();
  }

  // ============================================
  // BIRINCHI SAHIFADAN TANLANGAN MA'LUMOTLARNI OLISH
  // ============================================

  /// Birinchi sahifada tanlangan mashina nomini olish (brand + model)
  /// Masalan: "Chevrolet Lacetti"
  String _getCarModel(KaskoBloc bloc) {
    // Avval to'liq nomni olish (birinchi sahifada tanlangan brand + model)
    final carFullName = bloc.selectedCarFullName;
    if (carFullName.isNotEmpty && carFullName.trim().isNotEmpty) {
      return carFullName;
    }

    // Agar to'liq nom bo'sh bo'lsa, carEntity'dan olish
    final carEntity = bloc.selectedCarEntity;
    if (carEntity != null) {
      if (carEntity.brand != null && carEntity.model != null) {
        return '${carEntity.brand} ${carEntity.model}';
      }
      if (carEntity.brand != null) {
        return carEntity.brand!;
      }
      if (carEntity.model != null) {
        return carEntity.model!;
      }
      return carEntity.name;
    }

    // Agar hech narsa topilmasa
    return '--';
  }

  /// Birinchi sahifada tanlangan yilni olish
  String _getCarYear(KaskoBloc bloc) {
    // Birinchi sahifada tanlangan yil
    final year = bloc.selectedYear;
    if (year != null) {
      return year.toString();
    }

    // Agar yil tanlanmagan bo'lsa, carPrice'dan olish
    final carPrice = bloc.cachedCarPrice;
    if (carPrice != null) {
      return carPrice.year.toString();
    }

    return '--';
  }

  // ============================================
  // IKKINCHI SAHIFADAN TANLANGAN MA'LUMOTLARNI OLISH
  // ============================================

  /// Ikkinchi sahifada tanlangan tarif nomini olish
  String _getTariffName(KaskoBloc bloc, KaskoState state) {
    // Ikkinchi sahifada tanlangan tarif nomi
    // Avval state'dan olish (KaskoRatesLoaded state'da selectedRate bor)
    if (state is KaskoRatesLoaded && state.selectedRate != null) {
      return state.selectedRate!.name;
    }

    // Keyin BLoC'dan olish - har doim cached rate'ni tekshirish
    // Bu muhim, chunki state o'zgarganda ham tanlangan tarif saqlanib qolishi kerak
    final selectedRate = bloc.selectedRate;
    final cachedRate = bloc.cachedSelectedRate;
    final rate = selectedRate ?? cachedRate;

    if (rate != null && rate.name.isNotEmpty) {
      return rate.name;
    }

    // Agar hali ham topilmasa, KaskoPolicyCalculated state'dan rates'ni tekshirish
    if (state is KaskoPolicyCalculated && state.rates.isNotEmpty) {
      // Agar cached rate ID'si bo'lsa, rates ro'yxatidan topish
      final cachedRateId = selectedRate?.id ?? cachedRate?.id;
      if (cachedRateId != null) {
        try {
          final foundRate = state.rates.firstWhere(
            (r) => r.id == cachedRateId,
          );
          if (foundRate.name.isNotEmpty) {
            return foundRate.name;
          }
        } catch (e) {
          // Agar topilmasa, birinchi rate'ni olish
          if (state.rates.first.name.isNotEmpty) {
            return state.rates.first.name;
          }
        }
      }
    }

    return '--';
  }

  /// Premium summasini hisoblash va formatlash
  /// Ikkinchi sahifada tanlangan tarif va birinchi sahifada hisoblangan narxdan
  String _getTotalPrice(KaskoBloc bloc, KaskoState state) {
    // Avval Policy yoki Order'dan premium olish (agar hisoblangan bo'lsa)
    if (state is KaskoPolicyCalculated) {
      final formatted = NumberFormat(
        '#,###',
      ).format(state.calculateResult.premium.toInt());
      return '${formatted.replaceAll(',', ' ')} so\'m';
    }

    if (state is KaskoOrderSaved) {
      final formatted = NumberFormat(
        '#,###',
      ).format(state.order.premium.toInt());
      return '${formatted.replaceAll(',', ' ')} so\'m';
    }

    // Ikkinchi sahifada tanlangan tarif va birinchi sahifada hisoblangan narxdan premium hisoblash
    final rate = bloc.selectedRate ?? bloc.cachedSelectedRate;
    final price = bloc.calculatedPrice;

    if (rate != null && price != null) {
      double premium = 0.0;

      // Agar tarifda percent bo'lsa, narxdan foiz hisobla
      if (rate.percent != null && rate.percent! > 0) {
        premium = price * rate.percent! / 100;
      }
      // Agar minPremium bo'lsa, uni ishlat
      else if (rate.minPremium != null && rate.minPremium! > 0) {
        premium = rate.minPremium!;
      }

      if (premium > 0) {
        final formatted = NumberFormat('#,###').format(premium.toInt());
        return '${formatted.replaceAll(',', ' ')} so\'m';
      }
    }

    // Agar faqat minimal premium bo'lsa
    if (rate?.minPremium != null && rate!.minPremium! > 0) {
      final formatted = NumberFormat('#,###').format(rate.minPremium!.toInt());
      return '${formatted.replaceAll(',', ' ')} so\'m';
    }

    return '--';
  }

  // Виджет для отображения личных данных и способа оплаты
  Widget _buildPersonalDataAndPaymentCard(
    KaskoBloc bloc,
    bool isDark,
    Color textColor,
    Color subtitleColor,
    Color cardBg,
  ) {
    final personalCardBg =
        isDark ? const Color(0xFF1E3A5C) : const Color(0xFFE3F2FD);

    // Получаем личные данные из BLoC
    final ownerName = bloc.ownerName ?? '--';
    final birthDate = bloc.birthDate ?? '--';
    final phone = bloc.ownerPhone ?? '--';
    final passport = bloc.ownerPassport ?? '--';
    final paymentMethod = bloc.paymentMethod ?? '--';

    // Форматирование номера телефона
    String formattedPhone = phone;
    if (phone != '--' && phone.length >= 13) {
      final phoneWithoutPlus = phone.substring(1);
      if (phoneWithoutPlus.length == 12) {
        formattedPhone =
            '+${phoneWithoutPlus.substring(0, 3)} ${phoneWithoutPlus.substring(3, 5)} ${phoneWithoutPlus.substring(5, 8)} ${phoneWithoutPlus.substring(8, 10)} ${phoneWithoutPlus.substring(10)}';
      }
    }

    // Форматирование паспорта
    String formattedPassport = passport;
    if (passport != '--' && passport.length >= 2) {
      final series = passport.substring(0, 2);
      final number = passport.substring(2);
      formattedPassport = '$series $number';
    }

    // Форматирование способа оплаты
    String formattedPaymentMethod = paymentMethod;
    if (paymentMethod == 'payme') {
      formattedPaymentMethod = 'Payme';
    } else if (paymentMethod == 'click') {
      formattedPaymentMethod = 'click';
    }

    return Container(
      padding: EdgeInsets.all(16.0.w),
      margin: EdgeInsets.only(bottom: 20.0.h),
      decoration: BoxDecoration(
        color: personalCardBg,
        borderRadius: BorderRadius.circular(15.0.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'insurance.kasko.document_data.personal_data_and_payment'.tr(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 16.h),
          if (ownerName != '--')
            _buildPersonalDataRow(
              'insurance.kasko.document_data.full_name_label'.tr(),
              ownerName,
              isDark,
              textColor,
              subtitleColor,
            ),
          if (birthDate != '--')
            _buildPersonalDataRow(
              'insurance.kasko.document_data.birth_date_label'.tr(),
              birthDate,
              isDark,
              textColor,
              subtitleColor,
            ),
          if (formattedPhone != '--')
            _buildPersonalDataRow(
              'insurance.kasko.document_data.phone_label'.tr(),
              formattedPhone,
              isDark,
              textColor,
              subtitleColor,
            ),
          if (formattedPassport != '--')
            _buildPersonalDataRow(
              'insurance.kasko.document_data.passport_label'.tr(),
              formattedPassport,
              isDark,
              textColor,
              subtitleColor,
            ),
          if (formattedPaymentMethod != '--')
            _buildPersonalDataRow(
              'insurance.kasko.document_data.payment_method_label'.tr(),
              formattedPaymentMethod,
              isDark,
              textColor,
              subtitleColor,
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalDataRow(
    String label,
    String value,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
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
      ),
    );
  }

  // Сохранение данных документа
  void _saveDocumentData(KaskoBloc bloc) {
    // Формируем номер автомобиля (регион + номер без пробелов)
    final region = _regionController.text.trim();
    final number =
        _numberController.text.trim().replaceAll(' ', '').toUpperCase();
    final carNumber = '$region$number';

    // Формируем VIN (техпаспорт серия + номер)
    final techSeries = _texPassportSeriesController.text.trim().toUpperCase();
    final techNumber = _texPassportNumberController.text.trim();
    final vin = '$techSeries$techNumber';

    debugPrint('💾 Сохранение данных документа:');
    debugPrint(
      '  🚗 Car Number: $carNumber (region: $region, number: $number)',
    );
    debugPrint('  🔧 VIN: $vin (series: $techSeries, number: $techNumber)');

    // Сохраняем данные в BLoC через событие
    bloc.add(
      SaveDocumentData(
        carNumber: carNumber,
        vin: vin,
        passportSeria: '',
        passportNumber: '',
      ),
    );

    // Проверяем, что данные сохранились
    Future.delayed(const Duration(milliseconds: 100), () {
      final savedCarNumber = bloc.documentCarNumber;
      final savedVin = bloc.documentVin;
      debugPrint('✅ Проверка сохраненных данных:');
      debugPrint('  🚗 Saved Car Number: $savedCarNumber');
      debugPrint('  🔧 Saved VIN: $savedVin');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final scaffoldBg = AppColors.getScaffoldBg(isDark);
        final cardBg = AppColors.getCardBg(isDark);
        final textColor = AppColors.getTextColor(isDark);
        final subtitleColor = AppColors.getSubtitleColor(isDark);
        final borderColor = AppColors.getBorderColor(isDark);
        final placeholderColor = AppColors.getPlaceholderColor(isDark);
        final bottomPadding = MediaQuery.of(context).padding.bottom;

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            backgroundColor: cardBg,
            elevation: 0.5,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => context.router.pop(),
            ),
            title: Text(
              'insurance.kasko.title'.tr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 18.sp,
              ),
            ),
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
            ),
          ),
          body: BlocConsumer<KaskoBloc, KaskoState>(
            listener: (context, state) {
              // State o'zgarganda, bloc'dan tarifni olish va tekshirish
              final bloc = context.read<KaskoBloc>();
              final selectedRate = bloc.selectedRate;
              final cachedRate = bloc.cachedSelectedRate;
              final currentRate = selectedRate ?? cachedRate;

              if (kDebugMode) {
                debugPrint(
                    '🔔🔔🔔 Listener: State o\'zgardi: ${state.runtimeType}');
                debugPrint(
                    '🔔🔔🔔 Listener: Joriy tarif: ${currentRate?.name ?? "null"} (id: ${currentRate?.id ?? "null"})');
                debugPrint(
                    '🔔🔔🔔 Listener: Oxirgi tarif: ${_lastKnownRate?.name ?? "null"} (id: ${_lastKnownRate?.id ?? "null"})');
              }

              // Agar tarif o'zgarganda, UI'ni yangilash
              if (currentRate != null) {
                if (_lastKnownRate == null ||
                    currentRate.id != _lastKnownRate!.id) {
                  _lastKnownRate = currentRate;
                  if (kDebugMode) {
                    debugPrint(
                        '🔔🔔🔔 Listener: Tarif o\'zgardi, UI yangilanmoqda: ${currentRate.name}');
                  }
                  if (mounted) {
                    setState(() {});
                  }
                } else {
                  if (kDebugMode) {
                    debugPrint('🔔🔔🔔 Listener: Tarif o\'zgarmadi');
                  }
                }
              } else if (state is KaskoRatesLoaded &&
                  state.selectedRate != null) {
                // Agar state'dan tarif olish mumkin bo'lsa
                if (_lastKnownRate == null ||
                    state.selectedRate!.id != _lastKnownRate!.id) {
                  _lastKnownRate = state.selectedRate;
                  if (kDebugMode) {
                    debugPrint(
                        '🔔🔔🔔 Listener: State\'dan tarif yangilandi: ${state.selectedRate!.name}');
                  }
                  if (mounted) {
                    setState(() {});
                  }
                }
              } else if (state is KaskoPolicyCalculated) {
                // Policy hisoblanganida ham UI'ni yangilash
                if (kDebugMode) {
                  debugPrint(
                      '🔔🔔🔔 Listener: Policy hisoblandi, UI yangilanmoqda');
                }
                if (mounted) {
                  setState(() {});
                }
              }
            },
            buildWhen: (previous, current) {
              // State type o'zgarganda rebuild qilish
              // Builder ichida bloc state'ni tekshiramiz, shuning uchun state type o'zgarishi yetarli
              return previous.runtimeType != current.runtimeType;
            },
            builder: (context, state) {
              final bloc = context.read<KaskoBloc>();

              // Sahifaga qaytganida, bloc'dan tarifni tekshirish va yangilash
              // Bu muhim, chunki listener har safar ishlamasligi mumkin
              final currentRate = bloc.selectedRate ?? bloc.cachedSelectedRate;

              // Agar tarif o'zgarganda, UI'ni yangilash
              // Builder ichida setState chaqirolmaymiz, shuning uchun postFrameCallback ishlatamiz
              if (currentRate != null &&
                  (_lastKnownRate == null ||
                      currentRate.id != _lastKnownRate!.id)) {
                // PostFrameCallback orqali setState chaqirish - bu keyingi frame'da ishlaydi
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted &&
                      currentRate.id ==
                          (bloc.selectedRate ?? bloc.cachedSelectedRate)?.id) {
                    _lastKnownRate = currentRate;
                    setState(() {});
                    if (kDebugMode) {
                      debugPrint(
                          '🔄🔄🔄 Builder: UI yangilandi, yangi tarif: ${currentRate.name}');
                    }
                  }
                });
              }

              // Ma'lumotlarni BLoC'dan olish - har safar eng so'nggi qiymatlarni olish
              // _getTariffName har doim bloc'dan eng so'nggi tarifni oladi
              final carModel = _getCarModel(bloc);
              final carYear = _getCarYear(bloc);
              final tariffName = _getTariffName(bloc, state);
              final totalPrice = _getTotalPrice(bloc, state);

              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16.0.w),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'insurance.kasko.document_data.title'.tr(),
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 5.0.h),
                          Text(
                            'insurance.kasko.document_data.subtitle'.tr(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: subtitleColor,
                            ),
                          ),
                          KaskoInfoCard(
                            carModel: carModel,
                            carYear: carYear,
                            tariffName: tariffName,
                            totalPrice: totalPrice,
                            isDark: isDark,
                          ),
                          // Личные данные и способ оплаты
                          _buildPersonalDataAndPaymentCard(
                            bloc,
                            isDark,
                            textColor,
                            subtitleColor,
                            cardBg,
                          ),
                          // KaskoCarPlateInput(
                          //   regionController: _regionController,
                          //   numberController: _numberController,
                          //   isDark: isDark,
                          //   cardBg: cardBg,
                          //   textColor: textColor,
                          //   regionValidator: (value) {
                          //     if (value == null || value.trim().isEmpty) {
                          //       return 'insurance.kasko.document_data.errors.enter_region'
                          //           .tr();
                          //     }
                          //     if (value.length != 2) {
                          //       return 'insurance.kasko.document_data.errors.region_2_digits'
                          //           .tr();
                          //     }
                          //     if (!RegExp(r'^[0-9]{2}$').hasMatch(value)) {
                          //       return 'insurance.kasko.document_data.errors.region_2_digits'
                          //           .tr();
                          //     }
                          //     return null;
                          //   },
                          //   numberValidator: (value) {
                          //     if (value == null || value.trim().isEmpty) {
                          //       return 'insurance.kasko.document_data.errors.enter_car_number'
                          //           .tr();
                          //     }
                          //     final cleanNumber = value
                          //         .trim()
                          //         .replaceAll(' ', '')
                          //         .toUpperCase();
                          //     if (cleanNumber.length < 6) {
                          //       return 'insurance.kasko.document_data.errors.invalid_car_number'
                          //           .tr();
                          //     }
                          //     // Format: A000AA (1 harf + 3 raqam + 2 harf)
                          //     if (!RegExp(
                          //       r'^[A-Z][0-9]{3}[A-Z]{2}$',
                          //     ).hasMatch(cleanNumber)) {
                          //       return 'insurance.kasko.document_data.errors.invalid_car_number_format'
                          //           .tr();
                          //     }
                          //     return null;
                          //   },
                          // ),
                          UzbekLicensePlateInput(
                            regionController: _regionController,
                            numberController: _numberController,
                          ),
                          SizedBox(height: 20.0.h),
                          KaskoTechPassportInput(
                            seriesController: _texPassportSeriesController,
                            numberController: _texPassportNumberController,
                            isDark: isDark,
                            cardBg: cardBg,
                            textColor: textColor,
                            borderColor: borderColor,
                            placeholderColor: placeholderColor,
                            seriesValidator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'insurance.kasko.document_data.errors.enter_tech_passport_series'
                                    .tr();
                              }
                              if (value.length != 3) {
                                return 'insurance.kasko.document_data.errors.series_3_letters'
                                    .tr();
                              }
                              // Faqat harflar bo'lishi kerak
                              if (!RegExp(r'^[A-Za-z]{3}$').hasMatch(value)) {
                                return 'insurance.kasko.document_data.errors.series_3_letters'
                                    .tr();
                              }
                              return null;
                            },
                            numberValidator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'insurance.kasko.document_data.errors.enter_tech_passport_number'
                                    .tr();
                              }
                              if (value.length != 7) {
                                return 'insurance.kasko.document_data.errors.number_7_digits'
                                    .tr();
                              }
                              // Faqat raqamlar bo'lishi kerak
                              if (!RegExp(r'^[0-9]{7}$').hasMatch(value)) {
                                return 'insurance.kasko.document_data.errors.number_7_digits'
                                    .tr();
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 40.0.h),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                        16.0.w,
                        10.0.h,
                        16.0.w,
                        10.0.h + bottomPadding,
                      ),
                      decoration: BoxDecoration(
                        color: cardBg,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _areAllFieldsValid()
                              ? () {
                                  // Form validatsiyasini ishga tushirish
                                  if (_formKey.currentState!.validate()) {
                                    // Validatsiya o'tdi - ma'lumotlarni saqlash va keyingi sahifaga o'tish
                                    _saveDocumentData(bloc);
                                    // BLoC'ni o'tkazish bilan navigatsiya
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BlocProvider.value(
                                          value: bloc,
                                          child: const KaskoPersonalDataPage(),
                                        ),
                                      ),
                                    );
                                  }
                                  // Agar validatsiya o'tmasa, xatolar maydonlar ostida ko'rsatiladi
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _areAllFieldsValid()
                                ? AppColors.kaskoPrimaryBlue
                                : AppColors.kaskoPrimaryBlue.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'insurance.kasko.document_data.calculate'.tr(),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
