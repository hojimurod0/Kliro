import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/navigation/app_router.dart';
import '../bloc/kasko_bloc.dart';
import '../bloc/kasko_state.dart';

// Asosiy ranglar
const Color _primaryBlue = Color(0xFF1976D2);
const Color _cardLightBlue = Color(0xFFE3F2FD);
const Color _iconBlue = Color(0xFF42A5F5);

@RoutePage()
class KaskoOrderDetailsPage extends StatelessWidget {
  const KaskoOrderDetailsPage({super.key});

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
  Widget _buildOrderCard(
    KaskoBloc bloc,
    KaskoState state,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    final cardBg = isDark ? const Color(0xFF1E3A5C) : _cardLightBlue;

    // Ma'lumotlarni BLoC'dan olish
    final carModel = bloc.selectedCarFullName.isNotEmpty
        ? bloc.selectedCarFullName
        : '--';
    final carYear = bloc.selectedYear != null
        ? '${bloc.selectedYear}-yil'
        : '--';
    final tariffName = bloc.selectedRate?.name ?? bloc.cachedSelectedRate?.name ?? '--';
    
    // Muddat va qoplash ma'lumotlarini olish
    String duration = '12 oy';
    String coverage = 'To\'liq zarar qoplash 100%';
    
    if (state is KaskoPolicyCalculated) {
      final beginDate = state.calculateResult.beginDate;
      final endDate = state.calculateResult.endDate;
      final months = ((endDate.difference(beginDate).inDays) / 30).round();
      duration = '$months oy';
      
      if (state.calculateResult.franchise > 0) {
        coverage = 'Franchise: ${state.calculateResult.franchise.toStringAsFixed(0)} so\'m';
      }
    } else if (bloc.cachedCalculateResult != null) {
      final calcResult = bloc.cachedCalculateResult!;
      final beginDate = calcResult.beginDate;
      final endDate = calcResult.endDate;
      final months = ((endDate.difference(beginDate).inDays) / 30).round();
      duration = '$months oy';
      
      if (calcResult.franchise > 0) {
        coverage = 'Franchise: ${calcResult.franchise.toStringAsFixed(0)} so\'m';
      }
    }

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
            value: carModel,
            isBold: true,
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          // Yil uchun alohida text
          Padding(
            padding: EdgeInsets.only(left: 55.w, bottom: 20.h),
            child: Text(
              carYear,
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
            value: tariffName,
            isBold: true,
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          // 3. Muddat
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Muddat',
            value: duration,
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          // 4. Qoplash
          _buildInfoRow(
            icon: Icons.description_outlined,
            label: 'Qoplash',
            value: coverage,
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
        ],
      ),
    );
  }
  
  // 3. Hujjatlar va shaxsiy ma'lumotlar kartasi
  Widget _buildDocumentAndPersonalCard(
    KaskoBloc bloc,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    final cardBg = isDark ? const Color(0xFF1E3A5C) : _cardLightBlue;

    // Ma'lumotlarni BLoC'dan olish
    final carNumber = bloc.documentCarNumber ?? '--';
    final vin = bloc.documentVin ?? '--';
    final ownerName = bloc.ownerName ?? '--';
    final ownerPhone = bloc.ownerPhone ?? '--';
    final birthDate = bloc.birthDate ?? '--';
    final passport = bloc.ownerPassport ?? '--';

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
          Text(
            'Hujjatlar va shaxsiy ma\'lumotlar',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 16.h),
          // Avtomobil raqami
          _buildInfoRow(
            icon: Icons.directions_car_outlined,
            label: 'Avtomobil raqami',
            value: carNumber,
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          // VIN / Tex passport
          _buildInfoRow(
            icon: Icons.description_outlined,
            label: 'VIN / Tex passport',
            value: vin,
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          // Ism familiya
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Ism familiya',
            value: ownerName,
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          // Tug'ilgan sana
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Tug\'ilgan sana',
            value: birthDate,
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          // Telefon raqami
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Telefon raqami',
            value: ownerPhone,
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          // Passport
          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: 'Passport',
            value: passport,
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

  String _getTotalAmount(KaskoBloc bloc, KaskoState state) {
    if (state is KaskoPolicyCalculated) {
      final formatted = NumberFormat('#,###').format(
        state.calculateResult.premium.toInt(),
      );
      return '${formatted.replaceAll(',', ' ')} so\'m';
    }
    
    if (state is KaskoOrderSaved) {
      final formatted = NumberFormat('#,###').format(
        state.order.premium.toInt(),
      );
      return '${formatted.replaceAll(',', ' ')} so\'m';
    }
    
    final calcResult = bloc.cachedCalculateResult;
    if (calcResult != null) {
      final formatted = NumberFormat('#,###').format(
        calcResult.premium.toInt(),
      );
      return '${formatted.replaceAll(',', ' ')} so\'m';
    }
    
    return '--';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400]! : Colors.grey.shade600;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return BlocBuilder<KaskoBloc, KaskoState>(
      builder: (context, state) {
        final bloc = context.read<KaskoBloc>();
        final totalAmount = _getTotalAmount(bloc, state);

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
                    _buildOrderCard(bloc, state, isDark, textColor, subtitleColor),
                    // 2. Hujjatlar va shaxsiy ma'lumotlar kartasi
                    _buildDocumentAndPersonalCard(bloc, isDark, textColor, subtitleColor),
                    // 3. Sug'urta qamrovi ro'yxati
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
                            totalAmount,
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
      },
    );
  }
}

