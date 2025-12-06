import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/navigation/app_router.dart';
import '../bloc/kasko_bloc.dart';
import '../bloc/kasko_event.dart';
import '../bloc/kasko_state.dart';

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
  // Tanlangan to'lov turi
  PaymentOption _selectedPayment = PaymentOption.payme;
  
  // Ma'lumotlar Bloc state'dan olinadi
  double? _premium;
  String? _orderId;

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

  String _formatAmount(double? amount) {
    if (amount == null) return '0 so\'m';
    final formatter = NumberFormat('#,###', 'uz_UZ');
    return '${formatter.format(amount)} so\'m';
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

    return BlocConsumer<KaskoBloc, KaskoState>(
      listener: (context, state) {
        // CalculatePolicy natijasini saqlash
        if (state is KaskoPolicyCalculated) {
          setState(() {
            _premium = state.calculateResult.premium;
          });
        }
        
        // SaveOrder natijasini saqlash
        if (state is KaskoOrderSaved) {
          setState(() {
            _orderId = state.order.orderId;
            _premium = state.order.premium;
          });
        }
        
        // PaymentLink yaratilgandan keyin to'lov sahifasiga o'tish
        if (state is KaskoPaymentLinkCreated) {
          context.router.push(
            KaskoPaymentRoute(
              orderId: _orderId ?? '',
              amount: _premium ?? 0,
            ),
          );
        }
        
        // Xatolik holati
        if (state is KaskoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        // State'dan premium ni olish
        if (state is KaskoPolicyCalculated && _premium == null) {
          _premium = state.calculateResult.premium;
        }
        if (state is KaskoOrderSaved && _orderId == null) {
          _orderId = state.order.orderId;
          _premium = state.order.premium;
        }

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
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Asosiy kontent (chap tomonda)
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(16.0.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Qadam ko'rsatkichi va sarlavha
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'To\'lov usulini tanlang',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2A2A2A)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'Qadam 5/5',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: subtitleColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0.h),
                      // Ma'lumotlar ro'yxati (web sahifadagi kabi)
                      _buildInfoList(isDark, textColor, subtitleColor),
                      SizedBox(height: 24.0.h),
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
                      SizedBox(height: 100.0.h), // Bottom button uchun joy
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Xulosa paneli (o'ng tomonda) - faqat desktop'da ko'rsatish
          if (MediaQuery.of(context).size.width > 600)
            Container(
              width: 300.w,
              margin: EdgeInsets.only(
                top: 20.h,
                right: 16.w,
                bottom: 20.h,
              ),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildSummaryPanel(
                context.read<KaskoBloc>(),
                isDark,
                textColor,
                subtitleColor,
              ),
            ),
        ],
      ),
      // FIXED BOTTOM PAYMENT BAR
      bottomNavigationBar: Container(
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
            // Ortga tugmasi
            TextButton(
              onPressed: () {
                context.router.pop();
              },
              child: Text(
                'Ortga',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: textColor,
                ),
              ),
            ),
            // Jami Summa va To'lash tugmasi
            Row(
              children: [
                // Jami Summa
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'To\'lanadigan summa',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: subtitleColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatAmount(_premium),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: _primaryBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),
                // To'lash tugmasi
                SizedBox(
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: (state is KaskoLoading || _premium == null)
                        ? null
                        : () {
                            _handlePayment(context);
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
                      'Davom etish',
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
          ],
        ),
      ),
    );
      },
    );
  }

  void _handlePayment(BuildContext context) {
    final bloc = context.read<KaskoBloc>();
    final currentState = bloc.state;
    
    // Agar order allaqachon saqlangan bo'lsa, payment link yaratish
    if (currentState is KaskoOrderSaved) {
      bloc.add(
        CreatePaymentLink(
          orderId: currentState.order.orderId,
          amount: currentState.order.premium,
          returnUrl: 'https://kliro.uz/ru/kasko/success',
          callbackUrl: 'https://api.kliro.uz/payment/callback/kasko',
        ),
      );
    } else if (_orderId != null && _premium != null) {
      // Agar orderId va premium mavjud bo'lsa, payment link yaratish
      bloc.add(
        CreatePaymentLink(
          orderId: _orderId!,
          amount: _premium!,
          returnUrl: 'https://kliro.uz/ru/kasko/success',
          callbackUrl: 'https://api.kliro.uz/payment/callback/kasko',
        ),
      );
    } else {
      // Ma'lumotlar to'liq emas
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ma\'lumotlar to\'liq emas. Iltimos, qayta urinib ko\'ring.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Ma'lumotlar ro'yxati (web sahifadagi kabi)
  Widget _buildInfoList(bool isDark, Color textColor, Color subtitleColor) {
    final bloc = context.read<KaskoBloc>();
    final currentState = bloc.state;
    
    // State'dan ma'lumotlarni olish
    String program = 'Basic';
    
    // Tanlangan tarif
    final selectedRate = bloc.selectedRate ?? bloc.cachedSelectedRate;
    if (selectedRate != null) {
      program = selectedRate.name;
    } else if (currentState is KaskoRatesLoaded && currentState.selectedRate != null) {
      program = currentState.selectedRate!.name;
    }
    
    // Данные документа из BLoC
    String carNumber = bloc.documentCarNumber ?? '--';
    String techPassport = bloc.documentVin ?? '--';
    
    // Личные данные из BLoC
    String ownerName = bloc.ownerName ?? '--';
    String birthDate = bloc.birthDate ?? '--';
    String phone = bloc.ownerPhone ?? '--';
    String passport = bloc.ownerPassport ?? '--';
    
    // Форматирование номера телефона (+998901234567 -> +998 90 123 45 67)
    if (phone != '--' && phone.length >= 13) {
      final phoneWithoutPlus = phone.substring(1); // Убираем +
      if (phoneWithoutPlus.length == 12) {
        phone = '+${phoneWithoutPlus.substring(0, 3)} ${phoneWithoutPlus.substring(3, 5)} ${phoneWithoutPlus.substring(5, 8)} ${phoneWithoutPlus.substring(8, 10)} ${phoneWithoutPlus.substring(10)}';
      }
    }
    
    // Форматирование паспорта (AA1234567 -> AA 1234567)
    if (passport != '--' && passport.length >= 2) {
      final series = passport.substring(0, 2);
      final number = passport.substring(2);
      passport = '$series $number';
    }
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Dastur:', program, isDark, textColor, subtitleColor),
          SizedBox(height: 12.h),
          _buildInfoRow('Ism familiya:', ownerName, isDark, textColor, subtitleColor),
          SizedBox(height: 12.h),
          _buildInfoRow('Avtomobil raqami:', carNumber, isDark, textColor, subtitleColor),
          SizedBox(height: 12.h),
          _buildInfoRow('Texnik pasport:', techPassport, isDark, textColor, subtitleColor),
          SizedBox(height: 12.h),
          _buildInfoRow('Pasport:', passport, isDark, textColor, subtitleColor),
          SizedBox(height: 12.h),
          _buildInfoRow('Tug\'ilgan sana:', birthDate, isDark, textColor, subtitleColor),
          SizedBox(height: 12.h),
          _buildInfoRow('Telefon:', phone, isDark, textColor, subtitleColor),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: subtitleColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  // Xulosa paneli widget
  Widget _buildSummaryPanel(
    KaskoBloc bloc,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    // State'dan ma'lumotlarni olish
    String carName = '--';
    String coverage = '--';
    String premium = '--';
    String period = '1 yil';

    final currentState = bloc.state;
    
    // Mashina ma'lumotlari
    final carFullName = bloc.selectedCarFullName;
    if (carFullName.isNotEmpty) {
      carName = carFullName;
    } else if (currentState is KaskoCarsLoaded && currentState.cars.isNotEmpty) {
      final car = currentState.cars.first;
      carName = car.name;
    }
    
    // Tanlangan tarif ma'lumotlari
    if (currentState is KaskoRatesLoaded && currentState.selectedRate != null) {
      final rate = currentState.selectedRate!;
      if (rate.percent != null) {
        coverage = '${(rate.percent! * 100).toStringAsFixed(0)}%';
      } else {
        coverage = rate.description.isNotEmpty ? rate.description : '--';
      }
    }
    
    // Premium ma'lumotlari
    if (_premium != null) {
      premium = NumberFormat('#,###').format(_premium!.toInt()) + ' so\'m';
    } else if (currentState is KaskoPolicyCalculated) {
      premium = NumberFormat('#,###')
              .format(currentState.calculateResult.premium.toInt()) +
          ' so\'m';
    } else if (currentState is KaskoOrderSaved) {
      premium = NumberFormat('#,###')
              .format(currentState.order.premium.toInt()) +
          ' so\'m';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Xulosa',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        SizedBox(height: 20.h),
        _buildSummaryRow('Sug\'urta davri', period, isDark, textColor, subtitleColor),
        SizedBox(height: 14.h),
        _buildSummaryRow('Avtomobil', carName, isDark, textColor, subtitleColor),
        SizedBox(height: 14.h),
        _buildSummaryRow('Qoplash miqdori', coverage, isDark, textColor, subtitleColor),
        SizedBox(height: 14.h),
        _buildSummaryRow('To\'lanadigan summa', premium, isDark, textColor, subtitleColor),
        SizedBox(height: 20.h),
        InkWell(
          onTap: () {
            // Sug'urta qoidalarini ochish
            // TODO: PDF ochish
          },
          child: Text(
            'Sug\'urta qoidalari',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF0085FF),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: subtitleColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

