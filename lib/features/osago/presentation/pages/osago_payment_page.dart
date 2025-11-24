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
const Color _textLight = Color(0xFF666666); // Jami summa sarlavhasi
const Color _paymeBlue = Color(0xFF00B1FF); // Payme uchun asosiy ko'k
const Color _clickBlue = Color(0xFF007BFF); // Click uchun asosiy ko'k

// To'lov turlari uchun Enum
enum PaymentType { payme, click }

@RoutePage()
class OsagoPaymentPage extends StatefulWidget {
  const OsagoPaymentPage({super.key});

  @override
  State<OsagoPaymentPage> createState() => _OsagoPaymentPageState();
}

class _OsagoPaymentPageState extends State<OsagoPaymentPage> {
  // Tanlangan to'lov turini saqlash
  PaymentType? _selectedPayment = PaymentType.payme;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : _scaffoldBackground;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : _cardBackground;
    final textColor = isDark ? Colors.white : _textDark;
    final textLightColor = isDark ? Colors.grey[400]! : _textLight;
    final summaColor = isDark ? Colors.white : _textDark;

    final bottomPadding = MediaQuery.of(context).padding.bottom;

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
                // To'lov turi Sarlavhasi
                Padding(
                  padding: EdgeInsets.only(top: 8.0.h, bottom: 20.0.h),
                  child: Text(
                    "To'lov turi",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),

                // Payme Option
                PaymentOptionCard(
                  title: "Payme",
                  value: PaymentType.payme,
                  groupValue: _selectedPayment,
                  onChanged: (PaymentType? newValue) {
                    setState(() {
                      _selectedPayment = newValue;
                    });
                  },
                  logo: PaymeLogo(cardBg: cardBg),
                  primaryColor: _paymeBlue,
                  cardBg: cardBg,
                  textColor: textColor,
                  textLightColor: textLightColor,
                ),
                SizedBox(height: 12.0.h),

                // Click Option
                PaymentOptionCard(
                  title: "click",
                  value: PaymentType.click,
                  groupValue: _selectedPayment,
                  onChanged: (PaymentType? newValue) {
                    setState(() {
                      _selectedPayment = newValue;
                    });
                  },
                  logo: ClickLogo(textColor: textColor),
                  primaryColor: _clickBlue,
                  cardBg: cardBg,
                  textColor: textColor,
                  textLightColor: textLightColor,
                ),

                // Pastki tugma uchun joy qoldirish
                SizedBox(height: 80.h + bottomPadding),
              ],
            ),
          ),

          // Pastki qismdagi To'lov paneli va "To'lash" tugmasi
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

                  // To'lash Tugmasi
                  SizedBox(
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _selectedPayment != null
                          ? () {
                              // To'lash logikasi - keyingi sahifaga o'tish
                              context.router.push(OsagoSuccessRoute());
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _bluePrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 40.0.w),
                      ),
                      child: Text(
                        "To'lash",
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
// To'lov Opsiyasi Karta Widgeti
// ----------------------------------------------------
class PaymentOptionCard extends StatelessWidget {
  final String title;
  final Widget logo;
  final PaymentType value;
  final PaymentType? groupValue;
  final ValueChanged<PaymentType?> onChanged;
  final Color primaryColor;
  final Color cardBg;
  final Color textColor;
  final Color textLightColor;

  const PaymentOptionCard({
    super.key,
    required this.title,
    required this.logo,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.primaryColor,
    required this.cardBg,
    required this.textColor,
    required this.textLightColor,
  });

  bool get isSelected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : cardBg,
          borderRadius: BorderRadius.circular(12.0.r),
          border: isSelected
              ? null
              : Border.all(
                  color: textLightColor,
                  width: 1,
                ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.0.w),
        child: Row(
          children: [
            logo,
            SizedBox(width: 8.0.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? cardBg : textColor,
              ),
            ),
            const Spacer(),
            // Maxsus Radio Button dizaynini taqlid qilish
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? cardBg : textLightColor,
                  width: 1.5,
                ),
                color: isSelected ? cardBg : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10.w,
                        height: 10.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// Payme Logotipini Taqlid Qilish
// ----------------------------------------------------
class PaymeLogo extends StatelessWidget {
  final Color cardBg;

  const PaymeLogo({
    super.key,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // "Pay" qismi (Blue bg, White text)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            "Pay",
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: _paymeBlue,
            ),
          ),
        ),
        SizedBox(width: 2.w),
        // "me" qismi (Blue text)
        Text(
          "me",
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------
// Click Logotipini Taqlid Qilish
// ----------------------------------------------------
class ClickLogo extends StatelessWidget {
  final Color textColor;

  const ClickLogo({
    super.key,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, color: _clickBlue, size: 8.sp),
        SizedBox(width: 4.w),
        Text(
          "click",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

