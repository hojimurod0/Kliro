import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_router.dart';
import '../bloc/kasko_bloc.dart';
import '../bloc/kasko_event.dart';
import '../bloc/kasko_state.dart';
import '../../utils/upper_case_text_formatter.dart';

@RoutePage()
class KaskoPersonalDataPage extends StatefulWidget {
  const KaskoPersonalDataPage({super.key});

  @override
  State<KaskoPersonalDataPage> createState() => _KaskoPersonalDataPageState();
}

class _KaskoPersonalDataPageState extends State<KaskoPersonalDataPage> {
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _passportSeriesController =
      TextEditingController();
  final TextEditingController _passportNumberController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _birthDateController.dispose();
    _phoneNumberController.dispose();
    _ownerNameController.dispose();
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
          onChanged: (_) => setState(() {}), // Button state uchun
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

  Widget _buildOwnerNameInput(
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
          'insurance.kasko.personal_data.owner_name'.tr(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: 8.0.h),
        TextFormField(
          controller: _ownerNameController,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (_) => setState(() {}), // ✅
          style: TextStyle(
            color: textColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'insurance.kasko.personal_data.errors.enter_name'.tr();
            }
            if (value.trim().length < 3) {
              return 'insurance.kasko.personal_data.errors.name_min_3'.tr();
            }
            return null;
          },
          decoration: _commonInputDecoration(
            hintText: 'Ism familiyangizni kiriting',
            prefixIcon: Icon(
              Icons.person_outline,
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
                onChanged: (_) => setState(() {}), // ✅
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
                onChanged: (_) => setState(() {}), // ✅
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
          onChanged: (_) => setState(() {}), // ✅
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
                !phoneValue.startsWith('9')) {
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

  void _saveOrder(KaskoBloc bloc) {
    final ownerName = _ownerNameController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final passportSeries = _passportSeriesController.text.trim();
    final passportNumber = _passportNumberController.text.trim();
    final ownerPassport = '$passportSeries$passportNumber';
    final ownerPhone = '+998$phoneNumber';

    final carId = bloc.selectedCarPositionId;
    final year = bloc.selectedYear;
    final price = bloc.calculatedPrice;
    final carNumber = bloc.documentCarNumber ?? '';
    final vin = bloc.documentVin ?? '';
    final calculateResult = bloc.cachedCalculateResult;

    if (carId == null ||
        year == null ||
        price == null ||
        calculateResult == null) {
      _showError(
        'Ma\'lumotlar to\'liq emas. Iltimos, oldingi sahifalarga qayting.',
      );
      return;
    }

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

    // Ism familiya tekshiruvi
    final ownerName = _ownerNameController.text.trim();
    if (ownerName.isEmpty || ownerName.length < 3) {
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

    // Telefon raqami tekshiruvi
    final phoneNumber = _phoneNumberController.text.trim();
    if (phoneNumber.isEmpty ||
        !RegExp(r'^[0-9]{9}$').hasMatch(phoneNumber) ||
        !phoneNumber.startsWith('9')) {
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
                context.router.push(const KaskoPaymentTypeRoute());
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
                          _buildBirthDateInput(
                            context,
                            isDark,
                            cardBg,
                            textColor,
                            borderColor,
                            placeholderColor,
                          ),
                          _buildOwnerNameInput(
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
