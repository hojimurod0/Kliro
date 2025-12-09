import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../bloc/kasko_bloc.dart';
import '../bloc/kasko_event.dart';
import '../bloc/kasko_state.dart';
import '../../utils/upper_case_text_formatter.dart';
import 'kasko_payment_type_page.dart';

@RoutePage()
class KaskoPersonalDataPage extends StatefulWidget {
  const KaskoPersonalDataPage({super.key});

  @override
  State<KaskoPersonalDataPage> createState() => _KaskoPersonalDataPageState();
}

class _KaskoPersonalDataPageState extends State<KaskoPersonalDataPage> {
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passportSeriesController =
      TextEditingController();
  final TextEditingController _passportNumberController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _birthDateController.dispose();
    _ownerNameController.dispose();
    _phoneNumberController.dispose();
    _passportSeriesController.dispose();
    _passportNumberController.dispose();
    super.dispose();
  }

  InputDecoration _commonInputDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color placeholderColor,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: placeholderColor),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.0.w,
        vertical: 14.0.h,
      ),
      filled: true,
      fillColor: cardBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0.r),
        borderSide: BorderSide(color: borderColor, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0.r),
        borderSide: BorderSide(color: borderColor, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0.r),
        borderSide: const BorderSide(
          color: AppColors.kaskoPrimaryBlue,
          width: 1.5,
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.kaskoPrimaryBlue,
              onPrimary: AppColors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _birthDateController.text =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      setState(() {}); // button state uchun
      // Сохраняем данные после выбора даты
      final bloc = context.read<KaskoBloc>();
      _savePersonalData(bloc);
    }
  }

  Widget _buildBirthDateInput(
    BuildContext context,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color borderColor,
    Color placeholderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tug\'ilgan kun sanasi',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        SizedBox(height: 8.0.h),
        TextFormField(
          controller: _birthDateController,
          readOnly: true,
          onTap: () => _selectDate(context),
          onChanged: (value) {
            setState(() {}); // Button state uchun
            // Сохраняем данные при изменении
            final bloc = context.read<KaskoBloc>();
            if (value.trim().isNotEmpty &&
                RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value.trim())) {
              _savePersonalData(bloc);
            }
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: TextStyle(
            color: textColor,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'insurance.kasko.personal_data.errors.select_birth_date'
                  .tr();
            }
            final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
            if (!dateRegex.hasMatch(value.trim())) {
              return 'insurance.kasko.personal_data.errors.select_birth_date'
                  .tr();
            }
            return null;
          },
          decoration: _commonInputDecoration(
            hintText: 'dd/mm/yyyy',
            prefixIcon: Icon(
              Icons.calendar_today_outlined,
              color: placeholderColor,
              size: 24.sp,
            ),
            isDark: isDark,
            cardBg: cardBg,
            borderColor: borderColor,
            placeholderColor: placeholderColor,
          ),
        ),
        SizedBox(height: 20.0.h),
      ],
    );
  }

  Widget _buildPassportInput(
    bool isDark,
    Color cardBg,
    Color textColor,
    Color borderColor,
    Color placeholderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'insurance.kasko.personal_data.passport_series_number'.tr(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: 8.0.h),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _passportSeriesController,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                maxLength: 2,
                textAlign: TextAlign.center,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) {
                  setState(() {}); // Button state uchun
                  // Сохраняем данные при изменении
                  final bloc = context.read<KaskoBloc>();
                  if (value.trim().isNotEmpty &&
                      RegExp(r'^[A-Za-z]{2}$').hasMatch(value)) {
                    _savePersonalData(bloc);
                  }
                },
                style: TextStyle(
                  color: textColor,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'insurance.kasko.personal_data.errors.enter_passport_series'
                        .tr();
                  }
                  if (!RegExp(r'^[A-Za-z]{2}$').hasMatch(value)) {
                    return 'insurance.kasko.personal_data.errors.series_2_letters'
                        .tr();
                  }
                  return null;
                },
                decoration: _commonInputDecoration(
                  hintText: 'AA',
                  isDark: isDark,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  placeholderColor: placeholderColor,
                ).copyWith(counterText: ''),
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                ],
              ),
            ),
            SizedBox(width: 12.0.w),
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _passportNumberController,
                keyboardType: TextInputType.number,
                maxLength: 7,
                textAlign: TextAlign.center,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) {
                  setState(() {}); // Button state uchun
                  // Сохраняем данные при изменении
                  final bloc = context.read<KaskoBloc>();
                  if (value.trim().isNotEmpty &&
                      RegExp(r'^[0-9]{7}$').hasMatch(value)) {
                    _savePersonalData(bloc);
                  }
                },
                style: TextStyle(
                  color: textColor,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'insurance.kasko.personal_data.errors.enter_passport_number'
                        .tr();
                  }
                  if (!RegExp(r'^[0-9]{7}$').hasMatch(value)) {
                    return 'insurance.kasko.personal_data.errors.number_7_digits'
                        .tr();
                  }
                  return null;
                },
                decoration: _commonInputDecoration(
                  hintText: '1234567',
                  isDark: isDark,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  placeholderColor: placeholderColor,
                ).copyWith(counterText: ''),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
        SizedBox(height: 20.0.h),
      ],
    );
  }

  Widget _buildPhoneNumberInput(
    bool isDark,
    Color cardBg,
    Color textColor,
    Color borderColor,
    Color placeholderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'insurance.kasko.personal_data.phone_number'.tr(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: 8.0.h),
        TextFormField(
          controller: _phoneNumberController,
          keyboardType: TextInputType.phone,
          maxLength: 9,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (value) {
            setState(() {}); // Button state uchun
            // Сохраняем данные при изменении
            final bloc = context.read<KaskoBloc>();
            final phoneValue = value.trim();
            if (phoneValue.isNotEmpty &&
                RegExp(r'^[0-9]{9}$').hasMatch(phoneValue) &&
                (phoneValue.startsWith('9') || phoneValue.startsWith('33'))) {
              _savePersonalData(bloc);
            }
          },
          style: TextStyle(
            color: textColor,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'insurance.kasko.personal_data.errors.enter_phone'.tr();
            }
            final phoneValue = value.trim();
            if (!RegExp(r'^[0-9]{9}$').hasMatch(phoneValue) ||
                (!phoneValue.startsWith('9') && !phoneValue.startsWith('33'))) {
              return 'insurance.kasko.personal_data.errors.phone_9_digits'.tr();
            }
            return null;
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9),
          ],
          decoration: _commonInputDecoration(
            hintText: '--- -- -- --',
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 16.0.w, right: 8.0.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.call, color: placeholderColor, size: 24.sp),
                  SizedBox(width: 8.w),
                  Text(
                    '+998',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    '  |  ',
                    style: TextStyle(fontSize: 16.sp, color: placeholderColor),
                  ),
                ],
              ),
            ),
            isDark: isDark,
            cardBg: cardBg,
            borderColor: borderColor,
            placeholderColor: placeholderColor,
          ).copyWith(counterText: ''),
        ),
        SizedBox(height: 20.0.h),
      ],
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(fontSize: 14.sp)),
          backgroundColor: AppColors.dangerRed,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // Виджет для отображения данных документа
  Widget _buildDocumentDataCard(
    KaskoBloc bloc,
    bool isDark,
    Color textColor,
    Color subtitleColor,
    Color cardBg,
  ) {
    final documentCardBg = isDark
        ? const Color(0xFF1E3A5C)
        : const Color(0xFFE3F2FD);

    // Получаем данные документа из BLoC
    final carNumber = bloc.documentCarNumber ?? '--';
    final vin = bloc.documentVin ?? '--';

    // Форматирование номера автомобиля (01A111AA -> 01 A 111 AA)
    String formattedCarNumber = carNumber;
    if (carNumber != '--' && carNumber.length >= 8) {
      final region = carNumber.substring(0, 2);
      final letter1 = carNumber.substring(2, 3);
      final numbers = carNumber.substring(3, 6);
      final letters2 = carNumber.substring(6, 8);
      formattedCarNumber = '$region $letter1 $numbers $letters2';
    }

    return Container(
      padding: EdgeInsets.all(16.0.w),
      margin: EdgeInsets.only(bottom: 20.0.h),
      decoration: BoxDecoration(
        color: documentCardBg,
        borderRadius: BorderRadius.circular(15.0.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avtomobil hujjatlari',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 16.h),
          if (carNumber != '--')
            _buildDocumentDataRow(
              'Avtomobil raqami:',
              formattedCarNumber,
              isDark,
              textColor,
              subtitleColor,
            ),
          if (vin != '--')
            _buildDocumentDataRow(
              'VIN / Tex passport:',
              vin,
              isDark,
              textColor,
              subtitleColor,
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentDataRow(
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

  void _savePersonalData(KaskoBloc bloc) {
    // BLoC'dan mavjud ma'lumotlarni olish (bo'sh maydonlar uchun)
    final currentBirthDate = bloc.birthDate ?? '';
    final currentOwnerName = bloc.ownerName ?? '';
    final currentOwnerPhone = bloc.ownerPhone ?? '';
    final currentOwnerPassport = bloc.ownerPassport ?? '';

    // Tug'ilgan sana - faqat to'g'ri formatda bo'lsa saqlash
    final birthDateInput = _birthDateController.text.trim();
    final birthDate =
        (birthDateInput.isNotEmpty &&
            RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(birthDateInput))
        ? birthDateInput
        : currentBirthDate;

    // Ism familiya - ixtiyoriy, bo'sh bo'lishi mumkin
    final ownerNameInput = _ownerNameController.text.trim();
    final ownerName = ownerNameInput.isNotEmpty
        ? ownerNameInput
        : currentOwnerName;

    // Telefon - faqat to'g'ri formatda bo'lsa saqlash (9 yoki 33 bilan boshlanishi kerak)
    final phoneNumberInput = _phoneNumberController.text.trim();
    String ownerPhone = currentOwnerPhone;
    if (phoneNumberInput.isNotEmpty &&
        phoneNumberInput.length == 9 &&
        RegExp(r'^[0-9]{9}$').hasMatch(phoneNumberInput) &&
        (phoneNumberInput.startsWith('9') || phoneNumberInput.startsWith('33'))) {
      ownerPhone = '+998$phoneNumberInput';
    }

    // Passport - faqat ikkala qism ham to'g'ri bo'lsa saqlash
    final passportSeriesInput = _passportSeriesController.text.trim();
    final passportNumberInput = _passportNumberController.text.trim();
    String ownerPassport = currentOwnerPassport;
    if (passportSeriesInput.isNotEmpty &&
        passportSeriesInput.length == 2 &&
        RegExp(r'^[A-Za-z]{2}$').hasMatch(passportSeriesInput) &&
        passportNumberInput.isNotEmpty &&
        passportNumberInput.length == 7 &&
        RegExp(r'^[0-9]{7}$').hasMatch(passportNumberInput)) {
      ownerPassport = '$passportSeriesInput$passportNumberInput';
    }

    // Debug: saqlanayotgan ma'lumotlarni ko'rsatish
    debugPrint('💾 _savePersonalData chaqirildi:');
    debugPrint(
      '  📅 Birth Date: input="$birthDateInput", current="$currentBirthDate", final="$birthDate"',
    );
    debugPrint(
      '  👤 Owner Name: input="$ownerNameInput", current="$currentOwnerName", final="$ownerName"',
    );
    debugPrint(
      '  📱 Owner Phone: input="$phoneNumberInput", current="$currentOwnerPhone", final="$ownerPhone"',
    );
    debugPrint(
      '  🆔 Owner Passport: series="$passportSeriesInput", number="$passportNumberInput", current="$currentOwnerPassport", final="$ownerPassport"',
    );

    // Сохраняем личные данные в BLoC (faqat to'g'ri to'ldirilgan maydonlar)
    bloc.add(
      SavePersonalData(
        birthDate: birthDate,
        ownerName: ownerName,
        ownerPhone: ownerPhone,
        ownerPassport: ownerPassport,
      ),
    );
    debugPrint('✅ SavePersonalData event yuborildi');
  }

  void _saveOrder(KaskoBloc bloc) {
    final phoneNumber = _phoneNumberController.text.trim();
    final passportSeries = _passportSeriesController.text.trim();
    final passportNumber = _passportNumberController.text.trim();
    final ownerPassport = '$passportSeries$passportNumber';
    final ownerPhone = '+998$phoneNumber';
    // Ism familiya - ixtiyoriy, bo'sh bo'lishi mumkin
    final ownerName = _ownerNameController.text.trim().isNotEmpty
        ? _ownerNameController.text.trim()
        : (bloc.ownerName ?? '');

    final carId = bloc.selectedCarPositionId;
    final year = bloc.selectedYear;
    final price = bloc.calculatedPrice;
    final carNumber = bloc.documentCarNumber ?? '';
    final vin = bloc.documentVin ?? '';
    final calculateResult = bloc.cachedCalculateResult;

    // Отладочные логи для проверки данных
    debugPrint('🔍 Проверка данных перед сохранением заказа:');
    debugPrint('  🚗 carId: $carId');
    debugPrint('  📅 year: $year');
    debugPrint('  💰 price: $price');
    debugPrint('  📄 carNumber: $carNumber');
    debugPrint('  🔧 vin: $vin');
    debugPrint(
      '  📊 calculateResult: ${calculateResult != null ? "есть" : "null"}',
    );

    if (carId == null ||
        year == null ||
        price == null ||
        calculateResult == null ||
        carNumber.isEmpty ||
        vin.isEmpty) {
      String missingFields = '';
      if (carId == null) missingFields += 'carId, ';
      if (year == null) missingFields += 'year, ';
      if (price == null) missingFields += 'price, ';
      if (calculateResult == null) missingFields += 'calculateResult, ';
      if (carNumber.isEmpty) missingFields += 'carNumber, ';
      if (vin.isEmpty) missingFields += 'vin, ';

      debugPrint('❌ Отсутствуют данные: $missingFields');
      _showError(
        'Ma\'lumotlar to\'liq emas. Iltimos, oldingi sahifalarga qayting.',
      );
      return;
    }

    // Сначала сохраняем личные данные
    _savePersonalData(bloc);

    // Получаем дату рождения и преобразуем формат из DD/MM/YYYY в DD-MM-YYYY
    final birthDateInput = _birthDateController.text.trim();
    String birthDate = '';
    if (birthDateInput.isNotEmpty &&
        RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(birthDateInput)) {
      birthDate = birthDateInput.replaceAll('/', '-');
    } else if (bloc.birthDate != null && bloc.birthDate!.isNotEmpty) {
      birthDate = bloc.birthDate!.contains('/')
          ? bloc.birthDate!.replaceAll('/', '-')
          : bloc.birthDate!;
    }

    // Получаем тариф ID и тип
    final selectedRate = bloc.cachedSelectedRate;
    final tarifId = selectedRate?.id ?? 1; // По умолчанию 1
    final tarifType = 0; // По умолчанию 0, как в примере

    // Затем сохраняем заказ
    bloc.add(
      SaveOrder(
        carId: carId,
        year: year,
        price: price,
        beginDate: calculateResult.beginDate,
        endDate: calculateResult.endDate,
        driverCount: calculateResult.driverCount,
        franchise: calculateResult.franchise,
        premium: calculateResult.premium,
        ownerName: ownerName,
        ownerPhone: ownerPhone,
        ownerPassport: ownerPassport,
        carNumber: carNumber,
        vin: vin,
        birthDate: birthDate,
        tarifId: tarifId,
        tarifType: tarifType,
      ),
    );
  }

  bool get _isButtonEnabled {
    // Tug'ilgan kun sanasi tekshiruvi
    final birthDate = _birthDateController.text.trim();
    if (birthDate.isEmpty ||
        !RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(birthDate)) {
      return false;
    }

    // Pasport seriyasi tekshiruvi
    final passportSeries = _passportSeriesController.text.trim();
    if (passportSeries.isEmpty ||
        !RegExp(r'^[A-Za-z]{2}$').hasMatch(passportSeries)) {
      return false;
    }

    // Pasport raqami tekshiruvi
    final passportNumber = _passportNumberController.text.trim();
    if (passportNumber.isEmpty ||
        !RegExp(r'^[0-9]{7}$').hasMatch(passportNumber)) {
      return false;
    }

    // Telefon raqami tekshiruvi (9 yoki 33 bilan boshlanishi kerak)
    final phoneNumber = _phoneNumberController.text.trim();
    if (phoneNumber.isEmpty ||
        !RegExp(r'^[0-9]{9}$').hasMatch(phoneNumber) ||
        (!phoneNumber.startsWith('9') && !phoneNumber.startsWith('33'))) {
      return false;
    }

    return true;
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
              statusBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
            ),
          ),
          body: BlocConsumer<KaskoBloc, KaskoState>(
            listener: (context, state) {
              if (state is KaskoOrderSaved) {
                // BLoC'ni o'tkazish bilan navigatsiya
                final bloc = context.read<KaskoBloc>();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: bloc,
                      child: const KaskoPaymentTypePage(),
                    ),
                  ),
                );
              } else if (state is KaskoError) {
                _showError(state.message);
              }
            },
            builder: (context, state) {
              final bloc = context.read<KaskoBloc>();
              final isLoading = state is KaskoSavingOrder;

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
                            'insurance.kasko.personal_data.title'.tr(),
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 5.0.h),
                          Text(
                            'insurance.kasko.personal_data.subtitle'.tr(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: subtitleColor,
                            ),
                          ),
                          SizedBox(height: 30.0.h),
                          // Карточка с данными документа
                          _buildDocumentDataCard(
                            bloc,
                            isDark,
                            textColor,
                            subtitleColor,
                            cardBg,
                          ),
                          _buildBirthDateInput(
                            context,
                            isDark,
                            cardBg,
                            textColor,
                            borderColor,
                            placeholderColor,
                          ),
                          _buildPassportInput(
                            isDark,
                            cardBg,
                            textColor,
                            borderColor,
                            placeholderColor,
                          ),
                          _buildPhoneNumberInput(
                            isDark,
                            cardBg,
                            textColor,
                            borderColor,
                            placeholderColor,
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
                          onPressed: isLoading || !_isButtonEnabled
                              ? null
                              : () => _saveOrder(bloc),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLoading
                                ? AppColors.kaskoPrimaryBlue.withOpacity(0.5)
                                : AppColors.kaskoPrimaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0.r),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'insurance.kasko.personal_data.continue'.tr(),
                                  style: TextStyle(
                                    fontSize: 16.sp,
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
