import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/navigation/app_router.dart';

// Asosiy ranglar
const Color _primaryBlue = Color(0xFF1976D2);
const Color _selectedCardColor = Color(0xFF1E88E5);
const Color _selectedCardBorder = Color(0xFF1E88E5);

enum PaymentOption { payme, click }

@RoutePage()
class KaskoPaymentTypePage extends StatefulWidget {
  const KaskoPaymentTypePage({super.key});

  @override
  State<KaskoPaymentTypePage> createState() => _KaskoPaymentTypePageState();
}

class _KaskoPaymentTypePageState extends State<KaskoPaymentTypePage> {
  // Ma'lumotlar (Bular avvalgi sahifalardan kelishi kerak)
  final String _tariffName = 'Basic';
  final String _carNumber = '70D405DB';
  final String _texPassport = 'AAG 0000000';
  final String _passport = 'AA 1234567';
  final String _birthDate = '01.01.1990';
  final String _phone = '+998 90 123 45 67';
  final String _totalAmount = '1,200,000 sum';

  // Tanlangan to'lov turi
  PaymentOption _selectedPayment = PaymentOption.payme;

  // 1. To'lov turi kartasi (Radio button kabi)
  Widget _buildPaymentCard(
    PaymentOption option,
    String title,
    Widget logo,
    bool isDark,
    Color cardBg,
    Color borderColor,
  ) {
    final isSelected = _selectedPayment == option;
    final selectedBg = isDark ? const Color(0xFF1E3A5C) : _selectedCardColor;
    final unselectedBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final selectedBorder = isDark ? Colors.grey[600]! : _selectedCardBorder;
    final textColor = isSelected
        ? Colors.white
        : (isDark ? Colors.white : Colors.black);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPayment = option;
          debugPrint('Tanlangan to\'lov turi: $title');
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.0.h),
        padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 15.0.h),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : unselectedBg,
          borderRadius: BorderRadius.circular(10.0.r),
          border: Border.all(
            color: isSelected ? selectedBorder : borderColor,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo va nomi
            Row(
              children: [
                logo,
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
            // Radio button ko'rinishi
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey[600]! : Colors.grey.shade400),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isSelected
                    ? Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      )
                    : Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Payme logosi
  Widget _paymeLogo(bool isSelected) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'Pay',
          style: TextStyle(
            color: isSelected ? Colors.white : _primaryBlue,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        Text(
          'me',
          style: TextStyle(
            color: isSelected ? Colors.white : _primaryBlue,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ],
    );
  }

  // Click logosi
  Widget _clickLogo(bool isSelected) {
    final iconColor = isSelected ? Colors.white : _primaryBlue;
    final textColor = isSelected ? Colors.white : Colors.black;

    return Row(
      children: [
        Icon(Icons.circle, color: iconColor, size: 10.sp),
        SizedBox(width: 4.w),
        Text(
          'click',
          style: TextStyle(
            color: textColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Ma'lumotlar ro'yxatini ko'rsatish (Web'dagidek)
  Widget _buildInfoList(bool isDark, Color textColor, Color subtitleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dastur
        _buildInfoRow(
          label: 'Dastur:',
          value: _tariffName,
          isDark: isDark,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        SizedBox(height: 12.h),
        // Avtomobil raqami
        _buildInfoRow(
          label: 'Avtomobil raqami:',
          value: _carNumber,
          isDark: isDark,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        SizedBox(height: 12.h),
        // Texnik pasport
        _buildInfoRow(
          label: 'Texnik pasport:',
          value: _texPassport,
          isDark: isDark,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        SizedBox(height: 12.h),
        // Pasport
        _buildInfoRow(
          label: 'Pasport:',
          value: _passport,
          isDark: isDark,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        SizedBox(height: 12.h),
        // Tug'ilgan sana
        _buildInfoRow(
          label: 'Tug\'ilgan sana:',
          value: _birthDate,
          isDark: isDark,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
        SizedBox(height: 12.h),
        // Telefon
        _buildInfoRow(
          label: 'Telefon:',
          value: _phone,
          isDark: isDark,
          textColor: textColor,
          subtitleColor: subtitleColor,
        ),
      ],
    );
  }

  // Ma'lumot qatori
  Widget _buildInfoRow({
    required String label,
    required String value,
    required bool isDark,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontSize: 16.sp, color: subtitleColor),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            textAlign: TextAlign.right,
          ),
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Sarlavha
            Text(
              'To\'lov usulini tanlang',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 5.h),
            // Qadam ko'rsatkich
            Text(
              'Qadam 5/5',
              style: TextStyle(fontSize: 14.sp, color: subtitleColor),
            ),
            SizedBox(height: 24.h),
            // Ma'lumotlar ro'yxati
            _buildInfoList(isDark, textColor, subtitleColor),
            SizedBox(height: 24.h),
            // To'lanadigan summa
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E3A5C)
                    : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'To\'lanadigan summa',
                    style: TextStyle(fontSize: 16.sp, color: subtitleColor),
                  ),
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
            ),
            SizedBox(height: 24.h),
            // 1. Payme kartasi
            _buildPaymentCard(
              PaymentOption.payme,
              'Payme',
              _paymeLogo(_selectedPayment == PaymentOption.payme),
              isDark,
              cardBg,
              borderColor,
            ),
            // 2. Click kartasi
            _buildPaymentCard(
              PaymentOption.click,
              'click',
              _clickLogo(_selectedPayment == PaymentOption.click),
              isDark,
              cardBg,
              borderColor,
            ),
            SizedBox(height: 20.0.h), // Bottom bar uchun minimal joy
          ],
        ),
      ),
      // FIXED BOTTOM PAYMENT BAR
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16.0.w,
          16.0.h,
          16.0.w,
          16.0.h + bottomPadding,
        ),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 3,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Jami Summa
              Flexible(
                child: Column(
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
              ),
              SizedBox(width: 16.w),
              // To'lash tugmasi
              Flexible(
                child: SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      // Keyingi sahifaga o'tish - muvaffaqiyatli yakunlanish sahifasiga
                      context.router.push(const KaskoSuccessRoute());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0.r),
                      ),
                      elevation: 0,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
