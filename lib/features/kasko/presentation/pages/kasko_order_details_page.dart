import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_router.dart';
import '../bloc/kasko_bloc.dart';
import '../bloc/kasko_state.dart';
import 'kasko_payment_type_page.dart';

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
    
    // Muddat, qoplash va sug'urta davri ma'lumotlarini olish
    String duration = '12 oy';
    String insurancePeriod = '1 йил';
    String coverageAmount = '--';
    String coverage = 'To\'liq zarar qoplash 100%';
    
    if (state is KaskoPolicyCalculated) {
      final beginDate = state.calculateResult.beginDate;
      final endDate = state.calculateResult.endDate;
      final days = endDate.difference(beginDate).inDays;
      final months = (days / 30).round();
      final years = (days / 365).round();
      
      duration = '$months oy';
      insurancePeriod = years > 0 ? '$years йил' : '1 йил';
      
      // Қоплаш миқдори (Сумма покрытия)
      final formattedCoverage = NumberFormat('#,###').format(
        state.calculateResult.price.toInt(),
      );
      coverageAmount = '${formattedCoverage.replaceAll(',', ' ')} UZS';
      
      if (state.calculateResult.franchise > 0) {
        coverage = 'Franchise: ${state.calculateResult.franchise.toStringAsFixed(0)} so\'m';
      }
    } else if (bloc.cachedCalculateResult != null) {
      final calcResult = bloc.cachedCalculateResult!;
      final beginDate = calcResult.beginDate;
      final endDate = calcResult.endDate;
      final days = endDate.difference(beginDate).inDays;
      final months = (days / 30).round();
      final years = (days / 365).round();
      
      duration = '$months oy';
      insurancePeriod = years > 0 ? '$years йил' : '1 йил';
      
      // Қоплаш миқдори (Сумма покрытия)
      final formattedCoverage = NumberFormat('#,###').format(
        calcResult.price.toInt(),
      );
      coverageAmount = '${formattedCoverage.replaceAll(',', ' ')} UZS';
      
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
          // 1. Суғурта даври (Срок страхования)
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Суғурта даври',
            value: insurancePeriod,
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          // 2. Avtomobil
          _buildInfoRow(
            icon: Icons.directions_car_outlined,
            label: 'Автомобил',
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
          // 3. Қоплаш миқдори (Сумма покрытия)
          _buildInfoRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Қоплаш миқдори',
            value: coverageAmount,
            isBold: true,
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          // 4. Tarif
          _buildInfoRow(
            icon: Icons.security_outlined,
            label: 'Tarif',
            value: tariffName,
            isBold: true,
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          // 5. Muddat
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Muddat',
            value: duration,
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          // 6. Qoplash
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
  
  // Avtomobil raqamini formatlash
  // Format: "01A000AA" -> "01 A 000 AA"
  String _formatCarNumber(String? carNumber) {
    if (carNumber == null || carNumber.isEmpty || carNumber == '--') {
      return '--';
    }
    
    // Bo'shliqlarni olib tashlash va katta harflarga o'tkazish
    final cleanNumber = carNumber.replaceAll(' ', '').toUpperCase();
    
    // Format: Region (2 raqam) + Number (1 harf + 3 raqam + 2 harf)
    // Jami: 2 + 6 = 8 belgi
    if (cleanNumber.length < 8) {
      return carNumber; // Agar format noto'g'ri bo'lsa, asl qiymatni qaytarish
    }
    
    try {
      // Region (2 ta raqam)
      final region = cleanNumber.substring(0, 2);
      
      // Number qismi (6 ta belgi: 1 harf + 3 raqam + 2 harf)
      final numberPart = cleanNumber.substring(2);
      
      if (numberPart.length < 6) {
        return carNumber;
      }
      
      // Number qismini formatlash: A 000 AA
      final firstLetter = numberPart[0];
      final digits = numberPart.substring(1, 4);
      final lastLetters = numberPart.substring(4);
      
      // Format: "01 A 000 AA"
      return '$region $firstLetter $digits $lastLetters';
    } catch (e) {
      // Xatolik bo'lsa, asl qiymatni qaytarish
      return carNumber;
    }
  }

  // Telefon raqamini formatlash
  // Format: "+998901234567" -> "+998 90 123 45 67"
  String _formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty || phone == '--') {
      return '--';
    }
    
    // + ni olib tashlash
    final cleanPhone = phone.replaceAll('+', '').replaceAll(' ', '');
    
    if (cleanPhone.length < 12) {
      return phone;
    }
    
    try {
      // Format: +998 90 123 45 67
      final countryCode = cleanPhone.substring(0, 3); // 998
      final operatorCode = cleanPhone.substring(3, 5); // 90
      final part1 = cleanPhone.substring(5, 8); // 123
      final part2 = cleanPhone.substring(8, 10); // 45
      final part3 = cleanPhone.substring(10); // 67
      
      return '+$countryCode $operatorCode $part1 $part2 $part3';
    } catch (e) {
      return phone;
    }
  }

  // Passport raqamini formatlash
  // Format: "AA1234567" -> "AA 1234567"
  String _formatPassport(String? passport) {
    if (passport == null || passport.isEmpty || passport == '--') {
      return '--';
    }
    
    final cleanPassport = passport.replaceAll(' ', '').toUpperCase();
    
    if (cleanPassport.length < 2) {
      return passport;
    }
    
    try {
      final series = cleanPassport.substring(0, 2);
      final number = cleanPassport.substring(2);
      return '$series $number';
    } catch (e) {
      return passport;
    }
  }

  // 3. Hujjatlar va shaxsiy ma'lumotlar kartasi
  Widget _buildDocumentAndPersonalCard(
    KaskoBloc bloc,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    final cardBg = isDark ? const Color(0xFF1E3A5C) : _cardLightBlue;

    // Ma'lumotlarni BLoC'dan olish va formatlash
    final carNumber = _formatCarNumber(bloc.documentCarNumber);
    final vin = bloc.documentVin ?? '--';
    final ownerName = bloc.ownerName ?? '--';
    final ownerPhone = _formatPhoneNumber(bloc.ownerPhone);
    final birthDate = bloc.birthDate ?? '--';
    final passport = _formatPassport(bloc.ownerPassport);

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
          // Способ оплаты
          if (bloc.paymentMethod != null && bloc.paymentMethod!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.payment_outlined,
              label: 'To\'lov usuli',
              value: bloc.paymentMethod == 'payme' ? 'Payme' : (bloc.paymentMethod == 'click' ? 'click' : bloc.paymentMethod!),
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
      return '${formatted.replaceAll(',', ' ')} UZS';
    }
    
    if (state is KaskoOrderSaved) {
      final formatted = NumberFormat('#,###').format(
        state.order.premium.toInt(),
      );
      return '${formatted.replaceAll(',', ' ')} UZS';
    }
    
    final calcResult = bloc.cachedCalculateResult;
    if (calcResult != null) {
      final formatted = NumberFormat('#,###').format(
        calcResult.premium.toInt(),
      );
      return '${formatted.replaceAll(',', ' ')} UZS';
    }
    
    return '--';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = AppColors.getScaffoldBg(isDark);
    final cardBg = AppColors.getCardBg(isDark);
    final textColor = AppColors.getTextColor(isDark);
    final subtitleColor = AppColors.getSubtitleColor(isDark);
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
                        color: isDark 
                            ? Colors.black.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.1),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Тўланадиган сумма (Сумма к оплате)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Тўланадиган сумма',
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
                            // BLoC'ni o'tkazish bilan navigatsiya
                            final bloc = context.read<KaskoBloc>();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: bloc,
                                  child: const KaskoPaymentTypePage(),
                                ),
                              ),
                            );
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

