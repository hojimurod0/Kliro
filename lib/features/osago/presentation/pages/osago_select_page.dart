import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../../core/navigation/app_router.dart';

// Asosiy ranglar
const Color _bluePrimary = Color(0xFF007AFF); // iOS ga xos ko'k rang
const Color _scaffoldBackground = Color(0xFFF8F8F8); // Ochiq kulrang fon
const Color _cardBackground = Colors.white; // AppBar va maydonlar foni
const Color _textDark = Color(0xFF333333); // Asosiy matn rangi
const Color _placeholderColor = Color(0xFFAAAAAA); // Placeholder matn rangi
const Color _borderColor = Color(0xFFDDDDDD); // Input maydonlarining yengil chegarasi

@RoutePage()
class OsagoSelectPage extends StatefulWidget {
  const OsagoSelectPage({super.key});

  @override
  State<OsagoSelectPage> createState() => _OsagoSelectPageState();
}

class _OsagoSelectPageState extends State<OsagoSelectPage> {
  // Controllerlar
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _osagoTypeController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(
    text: '998',
  );

  // Telefon raqami formati uchun Mask
  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '+998 ## ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void dispose() {
    _companyController.dispose();
    _durationController.dispose();
    _osagoTypeController.dispose();
    _startDateController.dispose();
    _phoneController.dispose();
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
                // Sug'urta kompaniyasi Guruh sarlavhasi
                Padding(
                  padding: EdgeInsets.only(top: 8.0.h, bottom: 20.0.h),
                  child: Text(
                    "Sug'urta kompaniyasi",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),

                // Kompaniyani tanlang
                InputLabel(text: "Kompaniyani tanlang", textColor: textColor),
                SelectTextFormField(
                  hintText: "Tanlash",
                  controller: _companyController,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  placeholderColor: placeholderColor,
                  textColor: textColor,
                ),
                SizedBox(height: 20.0.h),

                // Sug'urta muddati
                InputLabel(text: "Sug'urta muddati", textColor: textColor),
                SelectTextFormField(
                  hintText: "Tanlash",
                  controller: _durationController,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  placeholderColor: placeholderColor,
                  textColor: textColor,
                ),
                SizedBox(height: 20.0.h),

                // OSAGO turi
                InputLabel(text: "OSAGO turi", textColor: textColor),
                SelectTextFormField(
                  hintText: "Tanlash",
                  controller: _osagoTypeController,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  placeholderColor: placeholderColor,
                  textColor: textColor,
                ),
                SizedBox(height: 20.0.h),

                // Boshlanish sanasi
                InputLabel(text: "Boshlanish sanasi", textColor: textColor),
                DateInput(
                  hintText: "dd/mm/yyyy",
                  controller: _startDateController,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  placeholderColor: placeholderColor,
                  textColor: textColor,
                ),
                SizedBox(height: 20.0.h),

                // Telefon raqami
                InputLabel(text: "Telefon raqami", textColor: textColor),
                PhoneInput(
                  controller: _phoneController,
                  maskFormatter: _phoneMaskFormatter,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  placeholderColor: placeholderColor,
                  textColor: textColor,
                ),
                SizedBox(height: 20.0.h),

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
                    context.router.push(OsagoOrderRoute());
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
// Tanlash Inputi (Dropdown ga o'xshash)
// ----------------------------------------------------
class SelectTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final Color cardBg;
  final Color borderColor;
  final Color placeholderColor;
  final Color textColor;

  const SelectTextFormField({
    super.key,
    required this.hintText,
    this.controller,
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
            readOnly: true,
            onTap: () {
              // Haqiqiy ilovada bu yerda modal yoki dropdown ochiladi.
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
            ),
            style: TextStyle(color: textColor, fontSize: 16.0.sp),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// Boshlanish sanasi inputi
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
            readOnly: true,
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
              prefixIcon: Icon(
                Icons.calendar_month_outlined,
                color: placeholderColor,
                size: 24.sp,
              ),
              prefixIconConstraints: BoxConstraints(
                minWidth: 40.w,
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

// ----------------------------------------------------
// Telefon raqami inputi (Funksional)
// ----------------------------------------------------
class PhoneInput extends StatelessWidget {
  final TextEditingController controller;
  final MaskTextInputFormatter maskFormatter;
  final Color cardBg;
  final Color borderColor;
  final Color placeholderColor;
  final Color textColor;

  const PhoneInput({
    super.key,
    required this.controller,
    required this.maskFormatter,
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
            keyboardType: TextInputType.phone,
            inputFormatters: [maskFormatter], // Maskani qo'llash
            decoration: InputDecoration(
              hintText: '+998 -- --- -- --',
              hintStyle: TextStyle(
                color: placeholderColor,
                fontSize: 16.0.sp,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              prefixIcon: Icon(
                Icons.call_outlined,
                color: placeholderColor,
                size: 24.sp,
              ),
              prefixIconConstraints: BoxConstraints(
                minWidth: 40.w,
                minHeight: 24.h,
              ),
            ),
            style: TextStyle(color: textColor, fontSize: 16.0.sp),
          ),
        ),
      ),
    );
  }
}

