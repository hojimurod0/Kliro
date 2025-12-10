import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../bloc/kasko_bloc.dart';
import '../bloc/kasko_state.dart';

// Asosiy ranglar
const Color _successGreen = Color(0xFF0EC785);
const Color _cardLightBlue = Color(0xFFF0FAFF);
const Color _iconBlue = Color(0xFF0099EE);
const Color _iconLightBlue = Color(0xFFD6F1FF);

@RoutePage()
class KaskoSuccessPage extends StatelessWidget {
  const KaskoSuccessPage({super.key});

  String _formatAmount(double? amount) {
    if (amount == null) return '0 so\'m';
    final formatter = NumberFormat('#,###', 'uz_UZ');
    return '${formatter.format(amount)} so\'m';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final formatter = DateFormat('yyyy-MM-dd', 'uz_UZ');
    return formatter.format(date);
  }

  // Yordamchi widget: Tafsilot qatori
  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isBlueValue = false,
    required bool isDark,
    required Color textColor,
    required Color subtitleColor,
  }) {
    final iconColor = isDark ? Colors.grey[400]! : const Color(0xFF9AA6AC);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20.sp, color: iconColor),
            SizedBox(width: 10.w),
            Text(
              label,
              style: TextStyle(
                color: subtitleColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: isBlueValue ? _iconBlue : textColor,
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
          ),
        ),
      ],
    );
  }

  // Yordamchi widget: Cheti chizilgan tugma
  Widget _buildOutlineButton(
    IconData icon,
    String text,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color borderColor,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: OutlinedButton(
        onPressed: () {
          // TODO: Polisni yuklab olish yoki ulashish logikasi
          print('$text bosildi');
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          backgroundColor: cardBg,
          overlayColor: Colors.grey.shade100,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 22.sp),
            SizedBox(width: 10.w),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KaskoBloc, KaskoState>(
      builder: (context, state) {
        // Ma'lumotlarni state'dan olish
        String orderId = 'N/A';
        String carName = 'N/A';
        String date = _formatDate(DateTime.now());
        String amount = '0 so\'m';
        
        // SaveOrder'dan ma'lumotlar
        if (state is KaskoOrderSaved) {
          orderId = state.order.orderId;
          amount = _formatAmount(state.order.premium);
        }
        
        // CalculatePolicy'dan ma'lumotlar
        if (state is KaskoPolicyCalculated) {
          amount = _formatAmount(state.calculateResult.premium);
          date = _formatDate(state.calculateResult.beginDate);
        }
        
        // Car ma'lumotlarini olish
        if (state is KaskoCarsLoaded) {
          // Birinchi mashinani olish (yoki tanlangan mashinani)
          if (state.cars.isNotEmpty) {
            final car = state.cars.first;
            carName = car.name;
            if (car.brand != null && car.model != null) {
              carName = '${car.brand} ${car.model}';
            }
          }
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final scaffoldBg = isDark
            ? AppColors.darkScaffoldBg.withOpacity(0.95)
            : AppColors.lightScaffoldBg.withOpacity(0.95);
        final cardBg = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
        final textColor = isDark ? AppColors.darkTextColor : AppColors.lightTextColor;
        final subtitleColor = isDark ? AppColors.darkSubtitle : AppColors.lightSubtitle;
        final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
        final detailCardBg = isDark ? const Color(0xFF1E3A5C) : _cardLightBlue;
        final iconContainerBg = isDark ? const Color(0xFF1E3A5C) : _iconLightBlue;
        final dividerColor = isDark ? AppColors.darkBorder : const Color(0xFFE1EBF2);

        return Scaffold(
      backgroundColor: scaffoldBg,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(28.r),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. ICON QISMI
                Container(
                  width: 84.w,
                  height: 84.w,
                  decoration: const BoxDecoration(
                    color: _successGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24.sp,
                          weight: 50,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // 2. SARLAVHA
                Text(
                  'insurance.kasko.success.title'.tr(),
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 24.h),

                // 3. MA'LUMOTLAR KARTASI
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: detailCardBg,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    children: [
                      // Header: Polis raqami
                      Row(
                        children: [
                          // Hujjat iconi
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              color: iconContainerBg,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Icon(
                              Icons.description_outlined,
                              color: _iconBlue,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          // Matnlar
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'insurance.kasko.success.policy_number'.tr(),
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "#$orderId",
                                style: TextStyle(
                                  color: _iconBlue,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17.sp,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 18.h),
                      // Chiziq
                      Divider(
                        color: dividerColor,
                        thickness: 1.2,
                        height: 1,
                      ),
                      SizedBox(height: 18.h),

                      // Tafsilotlar qatorlari
                      _buildDetailRow(
                        Icons.directions_car_outlined,
                        'insurance.kasko.success.vehicle'.tr(),
                        carName,
                        isDark: isDark,
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                      ),
                      SizedBox(height: 14.h),
                      _buildDetailRow(
                        Icons.calendar_today_outlined,
                        'insurance.kasko.success.date'.tr(),
                        date,
                        isDark: isDark,
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                      ),
                      SizedBox(height: 14.h),
                      _buildDetailRow(
                        Icons.attach_money_rounded,
                        'insurance.kasko.success.amount'.tr(),
                        amount,
                        isBlueValue: true,
                        isDark: isDark,
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // 4. TUGMALAR
                // Polisni yuklab olish
                _buildOutlineButton(
                  Icons.download_rounded,
                  'insurance.kasko.success.download_policy'.tr(),
                  isDark,
                  cardBg,
                  textColor,
                  borderColor,
                ),
                SizedBox(height: 12.h),

                // Ulashish
                _buildOutlineButton(
                  Icons.share_outlined,
                  'insurance.kasko.success.share'.tr(),
                  isDark,
                  cardBg,
                  textColor,
                  borderColor,
                ),
                SizedBox(height: 12.h),

                // Yopish (Katta ko'k tugma)
                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: () {
                      // Barcha KASKO sahifalarini tozalash va asosiy sahifaga qaytish
                      // Orqaga qaytish - barcha KASKO sahifalarini yopish
                      Navigator.of(context).popUntil((route) {
                        return route.isFirst ||
                            route.settings.name == '/insurance-services' ||
                            route.settings.name == '/home';
                      });
                      // Agar hali ham KASKO sahifalarida bo'lsa, to'g'ridan-to'g'ri HomeRoute ga o'tish
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _iconBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'insurance.kasko.success.close'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }
}

