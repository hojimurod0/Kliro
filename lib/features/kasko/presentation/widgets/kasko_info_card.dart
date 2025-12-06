import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Asosiy ranglar
const Color _primaryBlue = Color(0xFF1976D2);
const Color _cardLightBlue = Color(0xFFE3F2FD);

/// Avtomobil va Tarif ma'lumotlari kartasi
class KaskoInfoCard extends StatelessWidget {
  final String carModel;
  final String carYear;
  final String tariffName;
  final String totalPrice;
  final bool isDark;

  const KaskoInfoCard({
    super.key,
    required this.carModel,
    required this.carYear,
    required this.tariffName,
    required this.totalPrice,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E3A5C) : _cardLightBlue;
    final cardTextColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey.shade600;

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
                style: TextStyle(fontSize: 14.sp, color: subtitleColor),
              ),
              Text(
                'Yili',
                style: TextStyle(fontSize: 14.sp, color: subtitleColor),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                carModel,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: cardTextColor,
                ),
              ),
              Text(
                carYear,
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
                style: TextStyle(fontSize: 14.sp, color: subtitleColor),
              ),
              Text(
                'Summa',
                style: TextStyle(fontSize: 14.sp, color: subtitleColor),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tariffName,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: _primaryBlue,
                ),
              ),
              Text(
                totalPrice,
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
}

