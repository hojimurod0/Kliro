import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/navigation/app_router.dart';

// Asosiy ranglar
const Color _primaryBlue = Color(0xFF1976D2);
const Color _cardLightBlue = Color(0xFFE3F2FD);

@RoutePage()
class KaskoDocumentDataPage extends StatefulWidget {
  const KaskoDocumentDataPage({super.key});

  @override
  State<KaskoDocumentDataPage> createState() => _KaskoDocumentDataPageState();
}

class _KaskoDocumentDataPageState extends State<KaskoDocumentDataPage> {
  // Ma'lumotlar (Bular avvalgi sahifalardan kelishi kerak)
  final String _carModel = 'Chevrolet Lacetti';
  final String _carYear = '2022';
  final String _tariffName = 'Premium 1';
  final String _totalPrice = '1 200 000 so\'m';

  // Controllerlar
  final TextEditingController _regionController = TextEditingController(
    text: '01',
  );
  final TextEditingController _numberController = TextEditingController(
    text: 'A 000 AA',
  );
  final TextEditingController _texPassportSeriesController =
      TextEditingController();
  final TextEditingController _texPassportNumberController =
      TextEditingController();

  @override
  void dispose() {
    _regionController.dispose();
    _numberController.dispose();
    _texPassportSeriesController.dispose();
    _texPassportNumberController.dispose();
    super.dispose();
  }

  // 1. Avtomobil va Tarif ma'lumotlari kartasi
  Widget _buildInfoCard(bool isDark, Color textColor, Color subtitleColor) {
    final cardBg = isDark ? const Color(0xFF1E3A5C) : _cardLightBlue;
    final cardTextColor = isDark ? Colors.white : Colors.black;

    return Container(
      padding: EdgeInsets.all(16.0.w),
      margin: EdgeInsets.symmetric(vertical: 20.0.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15.0.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1-qator: Avtomobil va Yili
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Avtomobil',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: subtitleColor,
                ),
              ),
              Text(
                'Yili',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _carModel,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: cardTextColor,
                ),
              ),
              Text(
                _carYear,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: cardTextColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          // 2-qator: Tarif va Summa
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tarif',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: subtitleColor,
                ),
              ),
              Text(
                'Summa',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _tariffName,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: _primaryBlue,
                ),
              ),
              Text(
                _totalPrice,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: _primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Avtomobil raqami kiritish maydoni (Plita ko'rinishi)
  Widget _buildCarPlateInput(bool isDark, Color cardBg, Color textColor) {
    final borderColor = isDark ? Colors.grey[600]! : Colors.black;
    final flagBg = isDark ? const Color(0xFF0D47A1) : Colors.blue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avtomobile raqami',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        SizedBox(height: 8.0.h),
        // Asosiy plita Container
        Container(
          height: 60.h,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10.0.r),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // 1. Viloyat kodi (01)
              Container(
                width: 60.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: borderColor, width: 1.5),
                  ),
                ),
                child: TextFormField(
                  controller: _regionController,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              // 2. Raqam qismi (A 000 AA)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                  child: TextFormField(
                    controller: _numberController,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 8,
                    decoration: InputDecoration(
                      hintText: 'A 000 AA',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[600]! : Colors.grey,
                      ),
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              // 3. Bayroq qismi (UZ)
              Container(
                width: 35.w,
                decoration: BoxDecoration(
                  color: flagBg,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8.5.r),
                    bottomRight: Radius.circular(8.5.r),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Bayroq chiziqlari
                    Container(height: 2.h, color: Colors.white),
                    Container(height: 2.h, color: Colors.green),
                    SizedBox(height: 4.h),
                    Text(
                      'UZ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.0.h),
      ],
    );
  }

  // 3. Tex Passport raqami kiritish maydoni
  Widget _buildTexPassportInput(
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
          'Tex passport',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        SizedBox(height: 8.0.h),
        Row(
          children: [
            // 1. Seriya (AAA)
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: _texPassportSeriesController,
                maxLength: 3,
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(color: textColor, fontSize: 16.sp),
                decoration: InputDecoration(
                  hintText: 'AAA',
                  hintStyle: TextStyle(color: placeholderColor),
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0.w,
                    vertical: 14.0.h,
                  ),
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0.r),
                    borderSide: BorderSide(
                      color: borderColor,
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0.r),
                    borderSide: BorderSide(
                      color: borderColor,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0.r),
                    borderSide: const BorderSide(
                      color: _primaryBlue,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.0.w),
            // 2. Raqam (1234567)
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _texPassportNumberController,
                maxLength: 7,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textColor, fontSize: 16.sp),
                decoration: InputDecoration(
                  hintText: '1234567',
                  hintStyle: TextStyle(color: placeholderColor),
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0.w,
                    vertical: 14.0.h,
                  ),
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0.r),
                    borderSide: BorderSide(
                      color: borderColor,
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0.r),
                    borderSide: BorderSide(
                      color: borderColor,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0.r),
                    borderSide: const BorderSide(
                      color: _primaryBlue,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15.0.h),
        // Eslatma matni
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 4.0.h),
              child: Text(
                '•',
                style: TextStyle(
                  fontSize: 16.sp,
                  height: 1.0,
                  color: textColor,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Ma\'lumotlar texpasportdagi ma\'lumotlarga to\'liq mos kelishi kerak',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.grey[400]! : Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
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
                  'Hujjat ma\'lumotlari',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 5.0.h),
                // Qo'shimcha matn
                Text(
                  'Avtomobil raqami va texpasport ma\'lumotlarini kiriting',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: subtitleColor,
                  ),
                ),
                // 1. Avtomobil va Tarif kartasi
                _buildInfoCard(isDark, textColor, subtitleColor),
                // 2. Avtomobil raqami
                _buildCarPlateInput(isDark, cardBg, textColor),
                // 3. Tex Passport raqami
                _buildTexPassportInput(
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
                    // Keyingi sahifaga o'tish - shaxsiy ma'lumotlar sahifasiga
                    context.router.push(const KaskoPersonalDataRoute());
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

