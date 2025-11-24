import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/navigation/app_router.dart';

// Asosiy ranglar
const Color _primaryBlue = Color(0xFF1976D2);
const Color _privacyCardColor = Color(0xFFE3F2FD);

@RoutePage()
class KaskoPersonalDataPage extends StatefulWidget {
  const KaskoPersonalDataPage({super.key});

  @override
  State<KaskoPersonalDataPage> createState() => _KaskoPersonalDataPageState();
}

class _KaskoPersonalDataPageState extends State<KaskoPersonalDataPage> {
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

  // Umumiy Text Field Dizayni
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
        borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
      ),
    );
  }

  // Tug'ilgan kun sanasini tanlash funksiyasi
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
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        SizedBox(height: 8.0.h),
        Row(
          children: [
            // 1. Seriya (AA)
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: _passportSeriesController,
                maxLength: 2,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 16.sp,
                ),
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
                style: TextStyle(color: textColor, fontSize: 16.sp),
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
            fontWeight: FontWeight.w500,
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
              style: TextStyle(color: textColor, fontSize: 16.sp),
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
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        SizedBox(height: 8.0.h),
        TextFormField(
          controller: _phoneNumberController,
          keyboardType: TextInputType.phone,
          maxLength: 9,
          style: TextStyle(color: textColor, fontSize: 16.sp),
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
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  Text(
                    '  |  ',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: placeholderColor,
                    ),
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

  // 4. Maxfiylik (Privacy) bloki
  Widget _buildPrivacyCard(bool isDark, Color textColor, Color subtitleColor) {
    final cardBg = isDark ? const Color(0xFF1E3A5C) : _privacyCardColor;
    final cardTextColor = isDark ? Colors.white : Colors.grey.shade700;

    return Container(
      padding: EdgeInsets.all(16.0.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10.0.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Maxfiylik',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: _primaryBlue,
            ),
          ),
          SizedBox(height: 8.0.h),
          Text(
            'Sizning shaxsiy ma\'lumotlaringiz xavfsiz saqlanadi va uchinchi shaxslarga berilmaydi. SMS tasdiqlov kodi ko\'rsatilgan raqamga yuboriladi.',
            style: TextStyle(
              fontSize: 14.sp,
              color: cardTextColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
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
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
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
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0.w),
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
                // 4. Maxfiylik bloki
                _buildPrivacyCard(isDark, textColor, subtitleColor),
                SizedBox(height: 40.0.h),
              ],
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
                  onPressed: () {
                    // Keyingi sahifaga o'tish - buyurtma tafsilotlari
                    context.router.push(const KaskoOrderDetailsRoute());
                  },
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

