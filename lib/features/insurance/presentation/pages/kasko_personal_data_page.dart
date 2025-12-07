import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/navigation/app_router.dart';
import '../../utils/upper_case_text_formatter.dart';

// Asosiy ranglar
const Color _primaryBlue = Color(0xFF1976D2);
const Color _errorRed = Color(0xFFD32F2F); // Xatolik rangi

@RoutePage()
class KaskoPersonalDataPage extends StatefulWidget {
  const KaskoPersonalDataPage({super.key});

  @override
  State<KaskoPersonalDataPage> createState() => _KaskoPersonalDataPageState();
}

class _KaskoPersonalDataPageState extends State<KaskoPersonalDataPage> {
  // Form Key validatsiya uchun
  final _formKey = GlobalKey<FormState>();

  // Controllerlar
  final TextEditingController _passportSeriesController =
      TextEditingController();
  final TextEditingController _passportNumberController =
      TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _passportSeriesController.dispose();
    _passportNumberController.dispose();
    _birthDateController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  // Umumiy Text Field Dizayni (Validatsiya dizayni qo'shildi)
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
      errorStyle: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: _errorRed,
      ),
      // Oddiy holat
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0.r),
        borderSide: BorderSide(color: borderColor, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0.r),
        borderSide: BorderSide(color: borderColor, width: 1.0),
      ),
      // Fokuslanganda
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0.r),
        borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
      ),
      // Xatolik bo'lganda
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0.r),
        borderSide: const BorderSide(color: _errorRed, width: 1.0),
      ),
      // Xatolik bo'lib turib fokuslanganda
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0.r),
        borderSide: const BorderSide(color: _errorRed, width: 1.5),
      ),
    );
  }

  // Tug'ilgan kun sanasini tanlash funksiyasi
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000), // Default 2000 yil
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
      // Sanani tanlagandan keyin validatsiyani qayta tekshirish (qizil yozuvni o'chirish uchun)
      _formKey.currentState?.validate();
    }
  }

  // 1. Passport seriya va raqami
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
          'Passport seriyasi va raqami',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: 8.0.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment
              .start, // Xatolik chiqqanda tekstlar siljimasligi uchun
          children: [
            // 1. Seriya (AA)
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: _passportSeriesController,
                maxLength: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 20.sp,
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kriting';
                  }
                  if (value.length < 2) {
                    return 'To\'liq emas';
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
              ),
            ),
            SizedBox(width: 10.0.w),
            // 2. Raqam (1234567)
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _passportNumberController,
                maxLength: 7,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Passport raqamini kiriting';
                  }
                  if (value.length < 7) {
                    return 'Raqam 7 xonali bo\'lishi kerak';
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
              ),
            ),
          ],
        ),
        SizedBox(height: 20.0.h),
      ],
    );
  }

  // 2. Tug'ilgan kun sanasi
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
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: 8.0.h),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: TextFormField(
              controller: _birthDateController,
              readOnly: true,
              style: TextStyle(
                color: textColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tug\'ilgan sanani tanlang';
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
          ),
        ),
        SizedBox(height: 20.0.h),
      ],
    );
  }

  // 3. Telefon raqami
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
          'Telefon raqami',
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
          style: TextStyle(
            color: textColor,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Telefon raqamni kiriting';
            }
            if (value.length < 9) {
              return 'Raqam noto\'g\'ri';
            }
            return null;
          },
          decoration: _commonInputDecoration(
            hintText: '90 123 45 67',
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

  // Validation va Navigation funksiyasi
  void _validateAndProceed() {
    // Klaviaturani yopish
    FocusScope.of(context).unfocus();

    // Formni tekshirish
    if (_formKey.currentState!.validate()) {
      // Agar hammasi to'g'ri bo'lsa:
      context.router.push(const KaskoPaymentTypeRoute());
    } else {
      // Agar xatolik bo'lsa, foydalanuvchiga bildirishnoma (ixtiyoriy)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Iltimos, barcha maydonlarni to\'g\'ri to\'ldiring',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey.shade600;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey.shade300;
    final placeholderColor = isDark ? Colors.grey[600]! : Colors.grey.shade500;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            context.router.pop();
          },
        ),
        title: Text(
          'KASKO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      body: Stack(
        children: [
          // SingleChildScrollView + Form
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0.w),
            child: Form(
              key: _formKey, // Form key shu yerda ulandi
              autovalidateMode:
                  AutovalidateMode.onUserInteraction, // Yozayotganda tekshirish
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Sarlavha
                  Text(
                    'Shaxsiy ma\'lumotlar',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 5.0.h),
                  // Qo'shimcha matn
                  Text(
                    'Sug\'urta polisi uchun shaxsiy ma\'lumotlaringizni kiriting',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: subtitleColor,
                    ),
                  ),
                  SizedBox(height: 30.0.h),
                  // 1. Passport seriya va raqami
                  _buildPassportInput(
                    isDark,
                    cardBg,
                    textColor,
                    borderColor,
                    placeholderColor,
                  ),
                  // 2. Tug'ilgan kun sanasi
                  _buildBirthDateInput(
                    context,
                    isDark,
                    cardBg,
                    textColor,
                    borderColor,
                    placeholderColor,
                  ),
                  // 3. Telefon raqami
                  _buildPhoneNumberInput(
                    isDark,
                    cardBg,
                    textColor,
                    borderColor,
                    placeholderColor,
                  ),
                  SizedBox(height: 80.0.h), // Pastki knopka uchun joy
                ],
              ),
            ),
          ),
          // FIXED BOTTOM BUTTON
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
                  onPressed: _validateAndProceed, // Yangi funksiya chaqirildi
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Davom etish',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
