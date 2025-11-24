import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/navigation/app_router.dart';

// Asosiy ranglar
const Color _bluePrimary = Color(0xFF007AFF); // iOS ga xos ko'k rang
const Color _scaffoldBackground = Color(0xFFF8F8F8); // Ochiq kulrang fon
const Color _cardBackground = Colors.white; // AppBar va maydonlar foni
const Color _textDark = Color(0xFF333333); // Asosiy matn rangi
const Color _placeholderColor = Color(0xFFAAAAAA); // Placeholder matn rangi
const Color _borderColor = Color(0xFFDDDDDD); // Input maydonlarining yengil chegarasi

@RoutePage()
class OsagoInputPage extends StatefulWidget {
  const OsagoInputPage({super.key});

  @override
  State<OsagoInputPage> createState() => _OsagoInputPageState();
}

class _OsagoInputPageState extends State<OsagoInputPage> {
  // Avtomobil egasi emasligini nazorat qilish
  bool isOwner = false;

  // Input controllerlari (funksionallik uchun zarur)
  final TextEditingController _markaController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _regionController = TextEditingController(
    text: '01',
  ); // Boshlang'ich qiymat
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _passportSeriesController =
      TextEditingController();
  final TextEditingController _passportNumberController =
      TextEditingController();
  final TextEditingController _texPassportSeriesController =
      TextEditingController();
  final TextEditingController _texPassportNumberController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _markaController.dispose();
    _modelController.dispose();
    _regionController.dispose();
    _numberController.dispose();
    _passportSeriesController.dispose();
    _passportNumberController.dispose();
    _texPassportSeriesController.dispose();
    _texPassportNumberController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : _scaffoldBackground;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : _cardBackground;
    final textColor = isDark ? Colors.white : _textDark;
    final placeholderColor = isDark ? Colors.grey[600]! : _placeholderColor;
    final borderColor = isDark ? Colors.grey[800]! : _borderColor;

    // Media query yordamida pastki chekka (bottom padding)ni olish
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        toolbarHeight: 56.0.h,
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.router.pop(),
        ),
        title: Text(
          "OSAGO",
          style: TextStyle(
            color: textColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0.w,
              vertical: 10.0.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avtomobile markasi
                InputLabel(text: "Avtomobile markasi", textColor: textColor),
                CustomTextFormField(
                  hintText: "Tanlash",
                  controller: _markaController,
                  textCapitalization: TextCapitalization.none,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  placeholderColor: placeholderColor,
                  textColor: textColor,
                ),
                SizedBox(height: 20.0.h),

                // Modeli
                InputLabel(text: "Modeli", textColor: textColor),
                CustomTextFormField(
                  textCapitalization: TextCapitalization.none,
                  hintText: "Tanlash",
                  controller: _modelController,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  placeholderColor: placeholderColor,
                  textColor: textColor,
                ),
                SizedBox(height: 20.0.h),

                // Avtomobile raqami
                InputLabel(text: "Avtomobile raqami", textColor: textColor),
                CarNumberInput(
                  regionController: _regionController,
                  numberController: _numberController,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  placeholderColor: placeholderColor,
                  textColor: textColor,
                ),
                SizedBox(height: 20.0.h),

                // Pasport seriyasi va raqami
                InputLabel(
                  text: "Passport seriyasi va raqami",
                  textColor: textColor,
                ),
                PassportInput(
                  seriesController: _passportSeriesController,
                  numberController: _passportNumberController,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  placeholderColor: placeholderColor,
                  textColor: textColor,
                ),
                SizedBox(height: 20.0.h),

                // Tex passport
                InputLabel(text: "Tex passport", textColor: textColor),
                TexPassportInput(
                  seriesController: _texPassportSeriesController,
                  numberController: _texPassportNumberController,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  placeholderColor: placeholderColor,
                  textColor: textColor,
                ),
                SizedBox(height: 20.0.h),

                // Tug'ilgan kun sanasi
                InputLabel(
                  text: "Tugilgan kun sanasi",
                  textColor: textColor,
                ),
                DateInput(
                  hintText: "dd/mm/yyyy",
                  controller: _dateController,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  placeholderColor: placeholderColor,
                  textColor: textColor,
                ),
                SizedBox(height: 20.0.h),

                // Men mashinaning egasi emasman. Checkbox
                Row(
                  children: [
                    SizedBox(
                      width: 24.0.w,
                      height: 24.0.w,
                      child: Checkbox(
                        value: isOwner,
                        onChanged: (bool? newValue) {
                          setState(() {
                            isOwner = newValue ?? false;
                          });
                        },
                        activeColor: _bluePrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0.r),
                        ),
                        side: BorderSide(
                          color: isOwner ? _bluePrimary : placeholderColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0.w),
                    Text(
                      "Men mashinaning egasi emasman.",
                      style: TextStyle(
                        fontSize: 16.0.sp,
                        color: textColor,
                      ),
                    ),
                  ],
                ),

                // Pastki tugma uchun joy qoldirish
                SizedBox(height: 80.h + bottomPadding),
              ],
            ),
          ),

          // Pastki qismdagi "Davom etish" tugmasi
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
                    color: const Color(0x10000000),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    // Keyingi sahifaga o'tish
                    context.router.push(OsagoSelectRoute());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _bluePrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0.r),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    "Davom etish",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
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

// ----------------------------------------------------
// Maxsus Input Label
// ----------------------------------------------------
class InputLabel extends StatelessWidget {
  final String text;
  final Color textColor;

  const InputLabel({
    super.key,
    required this.text,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// Umumiylashtirilgan Text Input
// ----------------------------------------------------
class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final TextCapitalization textCapitalization;
  final Color cardBg;
  final Color borderColor;
  final Color placeholderColor;
  final Color textColor;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.suffixIcon,
    this.keyboardType,
    this.controller,
    required this.textCapitalization,
    required this.cardBg,
    required this.borderColor,
    required this.placeholderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.0.r),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0.w),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: placeholderColor,
                fontSize: 16.0.sp,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, color: placeholderColor)
                  : null,
            ),
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            style: TextStyle(color: textColor, fontSize: 16.0.sp),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// Avtomobil raqami inputi (Yangi, funksional versiya)
// ----------------------------------------------------
class CarNumberInput extends StatelessWidget {
  final TextEditingController regionController;
  final TextEditingController numberController;
  final Color cardBg;
  final Color borderColor;
  final Color placeholderColor;
  final Color textColor;

  const CarNumberInput({
    super.key,
    required this.regionController,
    required this.numberController,
    required this.cardBg,
    required this.borderColor,
    required this.placeholderColor,
    required this.textColor,
  });

  // Raqam maydonlari uchun umumiy InputDecoration
  InputDecoration _commonInputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: placeholderColor,
      ),
      border: InputBorder.none,
      isDense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final numberBorderColor = isDark ? Colors.grey[700]! : Colors.black;

    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.0.r),
        border: Border.all(
          color: numberBorderColor,
          width: 1.5,
        ), // Qalin qora chegara
      ),
      child: Row(
        children: [
          // Chap qism (Kod - Editable)
          Container(
            width: 60.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.5.r),
                bottomLeft: Radius.circular(10.5.r),
              ),
              border: Border(
                right: BorderSide(color: numberBorderColor, width: 1.5),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0.w),
              child: TextFormField(
                controller: regionController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 2,
                decoration: _commonInputDecoration(
                  hint: '01',
                ).copyWith(counterText: ''), // counterText ni yashirish
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ),

          // O'ng qism (Raqam - Editable)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0.w),
              child: TextFormField(
                controller: numberController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                maxLength: 8, // Misol uchun 'A 000 AA'
                decoration: _commonInputDecoration(
                  hint: 'A 000 AA',
                ).copyWith(counterText: ''),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// Passport seriyasi va raqami inputi
// ----------------------------------------------------
class PassportInput extends StatelessWidget {
  final TextEditingController seriesController;
  final TextEditingController numberController;
  final Color cardBg;
  final Color borderColor;
  final Color placeholderColor;
  final Color textColor;

  const PassportInput({
    super.key,
    required this.seriesController,
    required this.numberController,
    required this.cardBg,
    required this.borderColor,
    required this.placeholderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Seriya
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 50.h,
            child: CustomTextFormField(
              hintText: "AA",
              controller: seriesController,
              textCapitalization: TextCapitalization.characters,
              cardBg: cardBg,
              borderColor: borderColor,
              placeholderColor: placeholderColor,
              textColor: textColor,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        // Raqam
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 50.h,
            child: CustomTextFormField(
              textCapitalization: TextCapitalization.characters,
              hintText: "1234567",
              keyboardType: TextInputType.number,
              controller: numberController,
              cardBg: cardBg,
              borderColor: borderColor,
              placeholderColor: placeholderColor,
              textColor: textColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------
// Tex passport seriyasi va raqami inputi
// ----------------------------------------------------
class TexPassportInput extends StatelessWidget {
  final TextEditingController seriesController;
  final TextEditingController numberController;
  final Color cardBg;
  final Color borderColor;
  final Color placeholderColor;
  final Color textColor;

  const TexPassportInput({
    super.key,
    required this.seriesController,
    required this.numberController,
    required this.cardBg,
    required this.borderColor,
    required this.placeholderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Seriya
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 50.h,
            child: CustomTextFormField(
              hintText: "AAA",
              controller: seriesController,
              textCapitalization: TextCapitalization.characters,
              cardBg: cardBg,
              borderColor: borderColor,
              placeholderColor: placeholderColor,
              textColor: textColor,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        // Raqam
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 50.h,
            child: CustomTextFormField(
              textCapitalization: TextCapitalization.characters,
              hintText: "1234567",
              keyboardType: TextInputType.number,
              controller: numberController,
              cardBg: cardBg,
              borderColor: borderColor,
              placeholderColor: placeholderColor,
              textColor: textColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------
// Tug'ilgan kun sanasi inputi (Yangi, funksional versiya)
// ----------------------------------------------------
class DateInput extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final Color cardBg;
  final Color borderColor;
  final Color placeholderColor;
  final Color textColor;

  const DateInput({
    super.key,
    required this.hintText,
    required this.controller,
    required this.cardBg,
    required this.borderColor,
    required this.placeholderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.0.r),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0.w),
          child: TextFormField(
            controller: controller,
            // Aslida bu yerda DatePicker dialogi ochilishi kerak,
            // lekin rasmda ko'ringan vizual dizaynni saqlab qolamiz.
            readOnly:
                true, // Haqiqiy ilovada shu joyga bosilganda sanani tanlash oynasi chiqishi kerak
            onTap: () {
              // Misol uchun, showDatePicker() funksiyasini chaqirish
            },
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: placeholderColor,
                fontSize: 16.0.sp,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              // Ikonkani oldi qismga (prefix) joylashtiramiz
              prefixIcon: Icon(
                Icons.calendar_month_outlined,
                color: placeholderColor,
                size: 24.sp,
              ),
              prefixIconConstraints: BoxConstraints(
                minWidth: 40.w, // Ikonka va matn orasidagi masofa uchun
                minHeight: 24.h,
              ),
            ),
            keyboardType: TextInputType.datetime,
            style: TextStyle(color: textColor, fontSize: 16.0.sp),
          ),
        ),
      ),
    );
  }
}

