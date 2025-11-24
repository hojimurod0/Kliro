import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/navigation/app_router.dart';

// Asosiy ranglar
const Color _primaryBlue = Color(0xFF1976D2);
const Color _cardLightBlue = Color(0xFFE3F2FD);
const Color _iconBlue = Color(0xFF42A5F5);

@RoutePage()
class KaskoOrderDetailsPage extends StatelessWidget {
  const KaskoOrderDetailsPage({super.key});

  // Ma'lumotlar (Bular avvalgi sahifalardan keladi)
  final String _carModel = 'Chevrolet Lacetti';
  final String _carYear = '2022-yil';
  final String _tariffName = 'Premium 1';
  final String _duration = '12 oy';
  final String _coverage = 'To\'liq zarar qoplash 100%';
  final String _totalAmount = '1,200,000 sum';

  // Sug'urta qamrovi ro'yxati
  final List<String> _insuranceCoverages = const [
    'Avtomobilga yetkazilgan zarar',
    'O\'g\'irlik va talonda',
    'Tabiiy ofatlar',
    'Uchinchi shaxslar zarari',
    '24/7 yordam xizmati',
  ];

  // Qayta ishlatiladigan ma'lumot qatori (karta ichida)
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isBold = false,
    required bool isDark,
    required Color textColor,
    required Color subtitleColor,
  }) {
    final iconBg = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.0.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8.0.r),
            ),
            child: Icon(icon, color: _iconBlue, size: 22.sp),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: subtitleColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    color: isBold ? _primaryBlue : textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Buyurtma tafsilotlari kartasi
  Widget _buildOrderCard(bool isDark, Color textColor, Color subtitleColor) {
    final cardBg = isDark ? const Color(0xFF1E3A5C) : _cardLightBlue;

    return Container(
      padding: EdgeInsets.all(16.0.w),
      margin: EdgeInsets.symmetric(vertical: 20.0.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15.0.r),
      ),
      child: Column(
        children: [
          // 1. Avtomobil
          _buildInfoRow(
            icon: Icons.directions_car_outlined,
            label: 'Avtomobil',
            value: _carModel,
            isBold: true,
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          // Yil uchun alohida text
          Padding(
            padding: EdgeInsets.only(left: 55.w, bottom: 20.h),
            child: Text(
              _carYear,
              style: TextStyle(
                fontSize: 16.sp,
                color: textColor,
              ),
            ),
          ),
          // 2. Tarif
          _buildInfoRow(
            icon: Icons.security_outlined,
            label: 'Tarif',
            value: _tariffName,
            isBold: true,
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          // 3. Muddat
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Muddat',
            value: _duration,
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          // 4. Qoplash
          _buildInfoRow(
            icon: Icons.description_outlined,
            label: 'Qoplash',
            value: _coverage,
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
        ],
      ),
    );
  }

  // 2. Sug'urta qamrovi ro'yxati
  Widget _buildCoverageList(bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sug\'urta qamrovi',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: 15.h),
        // Ro'yxat elementlari
        ..._insuranceCoverages.map((coverage) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10.0.h),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: _iconBlue,
                  size: 22.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    coverage,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
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
                  'Buyurtma tafsilotlari',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 5.0.h),
                // Qo'shimcha matn
                Text(
                  'Barcha ma\'lumotlarni tekshiring va to\'lovni amalga oshiring',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: subtitleColor,
                  ),
                ),
                // 1. Buyurtma kartasi
                _buildOrderCard(isDark, textColor, subtitleColor),
                // 2. Sug'urta qamrovi ro'yxati
                _buildCoverageList(isDark, textColor),
                SizedBox(height: 40.0.h),
              ],
            ),
          ),
          // FIXED BOTTOM PAYMENT BAR
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Jami Summa
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jami summa',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: subtitleColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _totalAmount,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: _primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  // To'lash tugmasi
                  SizedBox(
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {
                        // Keyingi sahifaga o'tish - to'lov turi
                        context.router.push(const KaskoPaymentTypeRoute());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0.r),
                        ),
                        elevation: 0,
                        minimumSize: Size(120.w, 50.h),
                      ),
                      child: Text(
                        'To\'lash',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
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

