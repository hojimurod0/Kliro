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
const Color _textLight = Color(0xFF666666); // Yengilroq matn (kiritilgan ma'lumot sarlavhasi)
const Color _summaColor = Color(0xFF333333); // Summa matn rangi

@RoutePage()
class OsagoOrderPage extends StatelessWidget {
  const OsagoOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : _scaffoldBackground;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : _cardBackground;
    final textColor = isDark ? Colors.white : _textDark;
    final textLightColor = isDark ? Colors.grey[400]! : _textLight;
    final summaColor = isDark ? Colors.white : _summaColor;

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Rasmda ko'rsatilgan ma'lumotlar
    final Map<String, dynamic> orderInfo = {
      "Vehicle Number": "21 3 231 23",
      "Car Make": "Daewoo Nexia",
      "Passport Series": "AD 1234567",
      "Technical Passport Number": "AAA 1234567",
      "Type of OSAGO": "Individual",
      "Insurance Term": "6 months",
      "Insurance Company": "Kapital Insurance",
      "Start Date": "29.10.2025",
      "Phone": "+998 99 999 99-99",
    };

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
                // Order Information Sarlavhasi
                Padding(
                  padding: EdgeInsets.only(top: 8.0.h, bottom: 20.0.h),
                  child: Text(
                    "Order Information",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),

                // Ma'lumotlar Ro'yxati
                ...orderInfo.entries.map((entry) {
                  return InfoRow(
                    label: entry.key,
                    value: entry.value.toString(),
                    hasFlag: entry.key == "Vehicle Number",
                    textColor: textColor,
                    textLightColor: textLightColor,
                  );
                }).toList(),

                // Pastki tugma uchun joy qoldirish
                SizedBox(height: 80.h + bottomPadding),
              ],
            ),
          ),

          // Pastki qismdagi To'lov paneli va "Rasmiylashtirish" tugmasi
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Jami summa
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Jami summa",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: textLightColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "1,200,000 sum",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: summaColor,
                        ),
                      ),
                    ],
                  ),

                  // Rasmiylashtirish Tugmasi
                  SizedBox(
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {
                        // To'lov sahifasiga o'tish
                        context.router.push(OsagoPaymentRoute());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _bluePrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                      ),
                      child: Text(
                        "Rasmiylashtirish",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// Ma'lumot qatori (Label va Value)
// ----------------------------------------------------
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool hasFlag;
  final Color textColor;
  final Color textLightColor;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.hasFlag = false,
    required this.textColor,
    required this.textLightColor,
  });

  // O'zbekiston bayrog'i simulyatsiyasi (emoji orqali)
  Widget _getUzbekFlag() {
    return Padding(
      padding: EdgeInsets.only(left: 6.0.w),
      child: Text("🇺🇿", style: TextStyle(fontSize: 18.sp)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sarlavha (Label)
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              color: textLightColor,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Ma'lumotni o'ng tomonga surish uchun Spacer
          const Spacer(),

          // Qiymat (Value)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),

              // Bayroqchani shartli ravishda qo'shish
              if (hasFlag) _getUzbekFlag(),
            ],
          ),
        ],
      ),
    );
  }
}

