import 'package:auto_route/auto_route.dart';
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
  // Ma'lumotlar
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
          print('Tanlangan to\'lov turi: $title');
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
                  'To\'lov turi',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 20.0.h),
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
                        // Keyingi sahifaga o'tish - muvaffaqiyatli yakunlanish sahifasiga
                        context.router.push(const KaskoSuccessRoute());
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

