import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../core/constants/app_colors.dart';
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

  // 1. To'lov turi kartasi (Radio button kabi)
  Widget _buildPaymentCard(
    BuildContext context,
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
        // Сохраняем способ оплаты в BLoC
        final bloc = context.read<KaskoBloc>();
        bloc.add(
          SavePaymentMethod(
            paymentMethod: option == PaymentOption.payme ? 'payme' : 'click',
          ),
        );
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
    final scaffoldBg = isDark ? AppColors.darkScaffoldBg : AppColors.lightScaffoldBg;
    final cardBg = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
    final textColor = isDark ? AppColors.darkTextColor : AppColors.lightTextColor;
    final subtitleColor = isDark ? AppColors.darkSubtitle : AppColors.lightSubtitle;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return BlocConsumer<KaskoBloc, KaskoState>(
      listener: (context, state) {
        // Xatolik holati
        if (state is KaskoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        // Agar loading holati bo'lsa, loading ko'rsatish
        if (state is KaskoLoading) {
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
                'insurance.kasko.title'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 18.sp,
                ),
              ),
              centerTitle: true,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: isDark
                    ? Brightness.light
                    : Brightness.dark,
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // State'dan orderId ni olish
        final orderId = _getOrderId(state);

        // Agar orderId null bo'lsa va loading emas, xabar ko'rsatish
        if (orderId == null) {
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
                'insurance.kasko.title'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 18.sp,
                ),
              ),
              centerTitle: true,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: isDark
                    ? Brightness.light
                    : Brightness.dark,
              ),
            ),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24.0.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: Colors.orange,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'insurance.kasko.payment_type.incomplete_data'.tr(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'insurance.kasko.payment_type.save_order_first'.tr(),
                      style: TextStyle(fontSize: 16.sp, color: subtitleColor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () {
                        context.router.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 12.h,
                        ),
                      ),
                      child: Text(
                        'insurance.kasko.payment_type.go_back'.tr(),
                        style: TextStyle(fontSize: 16.sp, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

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
              statusBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
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
                                'insurance.kasko.payment_type.title'.tr(),
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
                                  'insurance.kasko.payment_type.step_indicator'
                                      .tr(),
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
                          // BlocBuilder bilan o'rab olish, ma'lumotlar o'zgarganda yangilanishi uchun
                          BlocBuilder<KaskoBloc, KaskoState>(
                            buildWhen: (previous, current) {
                              // Har safar yangilash (ma'lumotlar private field'larda)
                              return true;
                            },
                            builder: (context, state) {
                              final bloc = context.read<KaskoBloc>();
                              return _buildInfoList(
                                bloc,
                                isDark,
                                textColor,
                                subtitleColor,
                              );
                            },
                          ),
                          SizedBox(height: 24.0.h),
                          // 1. Payme kartasi
                          _buildPaymentCard(
                            context,
                            PaymentOption.payme,
                            'Payme',
                            _paymeLogo(_selectedPayment == PaymentOption.payme),
                            isDark,
                            cardBg,
                            borderColor,
                          ),
                          // 2. Click kartasi
                          _buildPaymentCard(
                            context,
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
                  margin: EdgeInsets.only(top: 20.h, right: 16.w, bottom: 20.h),
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
              child: BlocBuilder<KaskoBloc, KaskoState>(
                builder: (context, blocState) {
                  // Premium ni yangilangan state bilan qayta hisoblash
                  final currentBloc = context.read<KaskoBloc>();
                  final currentPremium = _getPremium(blocState, currentBloc);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Jami Summa
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'insurance.kasko.payment_type.total_amount'.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: subtitleColor,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _formatAmount(currentPremium),
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: _primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      // To'lash tugmasi - tanlangan to'lov turi bo'yicha URL ochish
                      Flexible(
                        child: SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed:
                                (blocState is KaskoLoading ||
                                    currentPremium == null ||
                                    blocState is! KaskoOrderSaved)
                                ? null
                                : () {
                                    _handlePaymentDirect(context, blocState);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'insurance.kasko.payment_type.pay'.tr(),
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
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // To'lovni to'g'ridan-to'g'ri ochish (save API'dan kelgan URL'lar bilan)
  void _handlePaymentDirect(BuildContext context, KaskoState state) {
    debugPrint('🔍 _handlePaymentDirect chaqirildi');
    debugPrint('🔍 Current state type: ${state.runtimeType}');

    final bloc = context.read<KaskoBloc>();

    // Tanlangan to'lov turini olish
    String? paymentMethod = bloc.paymentMethod;
    if (paymentMethod == null || paymentMethod.isEmpty) {
      // Agar paymentMethod tanlanmagan bo'lsa, tanlangan option'dan olish
      paymentMethod = _selectedPayment == PaymentOption.payme
          ? 'payme'
          : 'click';
      debugPrint(
        '⚠️ PaymentMethod BLoC\'dan topilmadi, selected option dan olinyapti: $paymentMethod',
      );
    }

    // SaveOrder'dan URL'larni olish
    if (state is KaskoOrderSaved) {
      final order = state.order;
      final clickUrl = order.clickUrl;
      final paymeUrl = order.paymeUrl;

      debugPrint('✅ Order ma\'lumotlari:');
      debugPrint('  📦 orderId: ${order.orderId}');
      debugPrint('  📄 contractId: ${order.contractId}');
      debugPrint('  💳 paymentMethod: $paymentMethod');
      debugPrint('  🔵 clickUrl: $clickUrl');
      debugPrint('  🟢 paymeUrl: $paymeUrl');
      debugPrint('  📄 urlShartnoma: ${order.urlShartnoma}');

      // Tanlangan to'lov turi bo'yicha URL ni olish
      String? paymentUrl;
      if (paymentMethod == 'payme') {
        paymentUrl = paymeUrl;
        debugPrint('💳 Payme tanlandi, URL: $paymentUrl');
      } else if (paymentMethod == 'click') {
        paymentUrl = clickUrl;
        debugPrint('💳 Click tanlandi, URL: $paymentUrl');
      }

      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        debugPrint('✅ Payment URL topildi, ochilmoqda...');
        // URL ni ochish
        _openPaymentUrlDirect(context, paymentUrl, paymentMethod);
      } else {
        debugPrint('❌ Payment URL topilmadi: paymentMethod=$paymentMethod');
        debugPrint('  🔵 clickUrl: $clickUrl');
        debugPrint('  🟢 paymeUrl: $paymeUrl');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'insurance.kasko.payment_type.payment_link_not_found'.tr(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      debugPrint('❌ KaskoOrderSaved state topilmadi');
      debugPrint('  Current state: ${state.runtimeType}');

      // State'dan order ni olishga harakat qilish (BlocBuilder orqali)
      // Agar state KaskoOrderSaved emas bo'lsa, foydalanuvchiga xabar berish
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'insurance.kasko.payment_type.order_data_not_found'.tr(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // To'g'ridan-to'g'ri URL ochish (payment link yaratmasdan)
  Future<void> _openPaymentUrlDirect(
    BuildContext context,
    String url,
    String paymentMethod,
  ) async {
    bool urlOpened = false;

    debugPrint('🔗 Payment URL ochilmoqda: $url');
    debugPrint('💳 Payment method: $paymentMethod');

    // Avval payment URL ni to'g'ridan-to'g'ri ochishga harakat qilamiz
    // Bir nechta LaunchMode bilan sinab ko'ramiz
    try {
      final uri = Uri.parse(url);
      debugPrint('🔗 Parsed URI: $uri');

      // 1. externalApplication mode bilan sinab ko'ramiz (brauzerda ochadi)
      // canLaunchUrl false qaytishi mumkin, lekin launchUrl ishlashi mumkin
      try {
        urlOpened = await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (urlOpened) {
          debugPrint('✅ Payment URL externalApplication mode bilan ochildi');
          return;
        }
      } catch (e) {
        debugPrint('⚠️ externalApplication mode xatosi: $e');
      }

      // 2. platformDefault mode bilan sinab ko'ramiz
      if (!urlOpened) {
        try {
          urlOpened = await launchUrl(uri, mode: LaunchMode.platformDefault);

          if (urlOpened) {
            debugPrint('✅ Payment URL platformDefault mode bilan ochildi');
            return;
          }
        } catch (e) {
          debugPrint('⚠️ platformDefault mode xatosi: $e');
        }
      }

      // 3. launchUrlString bilan sinab ko'ramiz
      if (!urlOpened) {
        try {
          debugPrint('🔄 launchUrlString bilan sinab ko\'ramiz...');
          urlOpened = await launchUrlString(
            url,
            mode: LaunchMode.externalApplication,
          );

          if (urlOpened) {
            debugPrint('✅ Payment URL launchUrlString bilan ochildi');
            return;
          }
        } catch (e) {
          debugPrint('⚠️ launchUrlString xatosi: $e');
        }
      }

      // 4. launchUrlString platformDefault mode bilan sinab ko'ramiz
      if (!urlOpened) {
        try {
          debugPrint('🔄 launchUrlString platformDefault mode bilan sinab ko\'ramiz...');
          urlOpened = await launchUrlString(
            url,
            mode: LaunchMode.platformDefault,
          );

          if (urlOpened) {
            debugPrint('✅ Payment URL launchUrlString platformDefault mode bilan ochildi');
            return;
          }
        } catch (e) {
          debugPrint('⚠️ launchUrlString platformDefault mode xatosi: $e');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Payment URL ochishda umumiy xatolik: $e');
      urlOpened = false;
    }

    if (!context.mounted) return;

    // Agar payment URL ishlamasa, deep link yoki store URL dan foydalanamiz
    if (!urlOpened && paymentMethod.isNotEmpty) {
      debugPrint('🔄 Deep link yoki store URL sinab ko\'ramiz...');
      final appUrl = _getPaymentAppUrl(paymentMethod);

      if (appUrl != null) {
        try {
          // Deep link ochishga harakat qilamiz
          debugPrint('🔗 Deep link ochilmoqda: $appUrl');
          urlOpened = await launchUrlString(
            appUrl,
            mode: LaunchMode.externalApplication,
          );
          
          if (urlOpened) {
            debugPrint('✅ Deep link ochildi');
            return;
          }
        } catch (e) {
          debugPrint('⚠️ Deep link xatosi: $e');
          urlOpened = false;
        }
      }

      // Agar deep link ham ishlamasa, store URL dan foydalanamiz
      if (!urlOpened) {
        final storeUrl = _getPaymentStoreUrl(paymentMethod);
        if (storeUrl.isNotEmpty) {
          try {
            debugPrint('🔗 Store URL ochilmoqda: $storeUrl');
            final success = await launchUrlString(
              storeUrl,
              mode: LaunchMode.externalApplication,
            );

            if (!context.mounted) return;

            if (success) {
              debugPrint('✅ Store URL ochildi');
              return;
            } else {
              debugPrint('❌ Store URL ochilmadi');
            }
          } catch (e) {
            debugPrint('⚠️ Store URL xatosi: $e');
          }
        }
      }
    }

    if (!context.mounted) return;

    // Agar hali ham ochilmagan bo'lsa, foydalanuvchiga xabar beramiz
    if (!urlOpened) {
      debugPrint('❌ Payment URL ochilmadi');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'insurance.kasko.payment_type.failed_to_open_link'.tr(
                namedArgs: {'url': url},
              ),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'insurance.kasko.payment_type.copy'.tr(),
              onPressed: () {
                // URL'ni clipboard'ga nusxalash
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'insurance.kasko.payment_type.url_copied'.tr(),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  // Deep link URL'larini olish
  String? _getPaymentAppUrl(String paymentMethod) {
    if (paymentMethod == 'payme') {
      return 'payme://';
    } else if (paymentMethod == 'click') {
      return 'clickuz://';
    }
    return null;
  }

  // Store URL'larini olish
  String _getPaymentStoreUrl(String paymentMethod) {
    if (paymentMethod == 'payme') {
      if (Platform.isAndroid) {
        return 'https://play.google.com/store/apps/details?id=uz.dida.payme&hl=ru';
      } else if (Platform.isIOS) {
        return 'https://apps.apple.com/us/app/payme-%D0%BF%D0%B5%D1%80%D0%B5%D0%B2%D0%BE%D0%B4%D1%8B-%D0%B8-%D0%BF%D0%BB%D0%B0%D1%82%D0%B5%D0%B6%D0%B8/id1093525667';
      }
    } else if (paymentMethod == 'click') {
      if (Platform.isAndroid) {
        return 'https://play.google.com/store/apps/details?id=air.com.ssdsoftwaresolutions.clickuz';
      } else if (Platform.isIOS) {
        return 'https://apps.apple.com/uz/app/click-superapp/id768132591';
      }
    }
    return '';
  }

  // State'dan orderId ni olish
  String? _getOrderId(KaskoState state) {
    if (state is KaskoOrderSaved) {
      final orderId = state.order.orderId;
      debugPrint('✅ OrderId KaskoOrderSaved dan: $orderId');
      return orderId;
    }
    if (state is KaskoPaymentLinkCreated) {
      final orderId = state.orderId.toString();
      debugPrint('✅ OrderId KaskoPaymentLinkCreated dan: $orderId');
      return orderId;
    }
    // Agar KaskoLoading bo'lsa, BLoC'dan oldingi state'ni tekshirish
    if (state is KaskoLoading) {
      // Bu holatda BLoC'dan orderId ni olish mumkin emas, chunki state o'zgardi
      // Lekin bu faqat loading holati, shuning uchun null qaytaramiz
      // UI'da loading ko'rsatiladi
      debugPrint('⏳ Loading holati, orderId topilmaydi');
      return null;
    }
    debugPrint('⚠️ OrderId topilmadi, state: ${state.runtimeType}');
    return null;
  }

  // State'dan premium ni olish
  double? _getPremium(KaskoState state, KaskoBloc bloc) {
    debugPrint('🔍 Premium qidirilmoqda...');
    debugPrint('🔍 Current state: ${state.runtimeType}');

    // BLoC'dan cached calculate result ni avval tekshirish (eng ishonchli manba)
    final cachedResult = bloc.cachedCalculateResult;
    if (cachedResult != null && cachedResult.premium > 0) {
      debugPrint(
        '✅ Premium cachedCalculateResult dan: ${cachedResult.premium}',
      );
      return cachedResult.premium;
    }

    // Avval state'dan premium ni olish
    if (state is KaskoPolicyCalculated) {
      debugPrint(
        '✅ Premium KaskoPolicyCalculated dan: ${state.calculateResult.premium}',
      );
      if (state.calculateResult.premium > 0) {
        return state.calculateResult.premium;
      }
    }

    if (state is KaskoOrderSaved) {
      debugPrint('✅ Premium KaskoOrderSaved dan: ${state.order.premium}');
      // Agar premium 0.0 bo'lsa, boshqa manbalarni tekshirish
      if (state.order.premium > 0) {
        return state.order.premium;
      }
      // Premium 0.0 bo'lsa, keyingi manbalarni tekshirish
      debugPrint(
        '⚠️ KaskoOrderSaved da premium 0.0, boshqa manbalarni tekshiryapmiz...',
      );
    }

    // Agar state'dan premium topilmasa, tanlangan tarif va mashina narxidan hisoblash
    final selectedRate = bloc.selectedRate ?? bloc.cachedSelectedRate;
    debugPrint(
      '🔍 Selected rate: ${selectedRate?.name} (id: ${selectedRate?.id})',
    );
    debugPrint('🔍 Rate percent: ${selectedRate?.percent}');
    debugPrint('🔍 Rate minPremium: ${selectedRate?.minPremium}');

    // Mashina narxini olish (calculatedPrice yoki cachedCarPrice)
    double? carPriceValue = bloc.calculatedPrice;
    if (carPriceValue == null) {
      final carPrice = bloc.cachedCarPrice;
      carPriceValue = carPrice?.price;
    }
    debugPrint('🔍 Car price: $carPriceValue');

    if (selectedRate != null) {
      // Tariflar sahifasidagi kabi hisoblash
      double calculatedPrice = 0.0;

      debugPrint('🔍 Tarif ma\'lumotlari:');
      debugPrint('  - Name: ${selectedRate.name}');
      debugPrint('  - Percent: ${selectedRate.percent}');
      debugPrint('  - MinPremium: ${selectedRate.minPremium}');
      debugPrint('  - CarPrice: $carPriceValue');

      // Agar tarifda percent bo'lsa va car price bo'lsa, percent dan narxni hisoblash
      if (selectedRate.percent != null &&
          carPriceValue != null &&
          carPriceValue > 0) {
        // Backend'dan percent 1, 1.5, 2.5 kabi FOIZ ko'rinishida keladi,
        // shuning uchun narxni hisoblashda 100 ga bo'lamiz:
        // 1%  => carPrice * 1 / 100
        // 1.5% => carPrice * 1.5 / 100
        // 2.5% => carPrice * 2.5 / 100
        calculatedPrice = carPriceValue * selectedRate.percent! / 100;
        debugPrint(
          '✅ Premium hisoblandi (percent): $carPriceValue * ${selectedRate.percent}% / 100 = $calculatedPrice',
        );
        if (calculatedPrice > 0) {
          return calculatedPrice;
        }
      }

      // Agar minPremium bo'lsa, uni ishlatish
      if (selectedRate.minPremium != null && selectedRate.minPremium! > 0) {
        calculatedPrice = selectedRate.minPremium!;
        debugPrint('✅ Premium minPremium dan: $calculatedPrice');
        return calculatedPrice;
      }

      debugPrint(
        '⚠️ Premium hisoblanmadi: percent=${selectedRate.percent}, minPremium=${selectedRate.minPremium}, carPrice=$carPriceValue',
      );
    }

    // Agar hech narsa topilmasa, null qaytarish
    debugPrint(
      '⚠️ Premium topilmadi: selectedRate=${selectedRate?.name}, carPrice=$carPriceValue',
    );
    return null;
  }

  // Ma'lumotlar ro'yxati (web sahifadagi kabi)
  Widget _buildInfoList(
    KaskoBloc bloc,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    final currentState = bloc.state;

    // State'dan ma'lumotlarni olish
    String program = 'Basic';

    // Tanlangan tarif
    final selectedRate = bloc.selectedRate ?? bloc.cachedSelectedRate;
    if (selectedRate != null) {
      program = selectedRate.name;
    } else if (currentState is KaskoRatesLoaded &&
        currentState.selectedRate != null) {
      program = currentState.selectedRate!.name;
    }

    // Данные документа из BLoC
    String carNumber = bloc.documentCarNumber ?? '--';
    String techPassport = bloc.documentVin ?? '--';

    // Личные данные из BLoC
    String birthDate = bloc.birthDate ?? '--';
    String phone = bloc.ownerPhone ?? '--';
    String passport = bloc.ownerPassport ?? '--';

    // Mashina narxi (Qoplash summasi)
    String coverageAmount = '--';
    final carPrice = bloc.cachedCarPrice;
    if (carPrice != null && carPrice.price > 0) {
      coverageAmount = _formatAmount(carPrice.price);
    } else if (currentState is KaskoCarPriceCalculated) {
      coverageAmount = _formatAmount(currentState.carPrice.price);
    } else if (currentState is KaskoPolicyCalculated) {
      // Agar policy calculated bo'lsa, price ni olish
      if (currentState.calculateResult.price > 0) {
        coverageAmount = _formatAmount(currentState.calculateResult.price);
      }
    }

    // Debug: ma'lumotlarni console'ga chiqarish
    debugPrint('📋 To\'lov sahifasida ma\'lumotlar:');
    debugPrint('  🚗 Avtomobil raqami: $carNumber');
    debugPrint('  📄 Texnik pasport: $techPassport');
    debugPrint('  📅 Tug\'ilgan sana: $birthDate');
    debugPrint('  📱 Telefon: $phone');
    debugPrint('  🆔 Passport: $passport');
    debugPrint('  💳 To\'lov usuli: ${bloc.paymentMethod ?? '--'}');
    debugPrint('  💰 Qoplash summasi: $coverageAmount');

    // Форматирование номера автомобиля (01A000AA -> 70D405DB formatida)
    // Avtomobil raqami allaqachon to'g'ri formatda saqlanadi (masalan: 01A000AA)
    // Faqat bo'shliqlarni olib tashlash va katta harflarga o'tkazish
    if (carNumber != '--' && carNumber.isNotEmpty) {
      carNumber = carNumber.replaceAll(' ', '').toUpperCase();
    }

    // Форматирование техпаспорта (AAG0000000 -> AAG 0000000)
    if (techPassport != '--' && techPassport.length >= 10) {
      final cleanPassport = techPassport.replaceAll(' ', '').toUpperCase();
      if (cleanPassport.length >= 10) {
        try {
          final series = cleanPassport.substring(0, 3); // 3 harf
          final number = cleanPassport.substring(3); // 7 raqam
          techPassport = '$series $number';
        } catch (e) {
          // Xatolik bo'lsa, asl qiymatni qoldirish
        }
      }
    }

    // Форматирование номера телефона (+998901234567 -> +998 90 123 45 67)
    if (phone != '--' && phone.length >= 13) {
      final phoneWithoutPlus = phone.replaceAll(' ', '').replaceAll('+', '');
      if (phoneWithoutPlus.length == 12) {
        // Format: +998 90 123 45 67
        phone =
            '+${phoneWithoutPlus.substring(0, 3)} ${phoneWithoutPlus.substring(3, 5)} ${phoneWithoutPlus.substring(5, 8)} ${phoneWithoutPlus.substring(8, 10)} ${phoneWithoutPlus.substring(10)}';
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
          _buildInfoRow(
            'insurance.kasko.payment_type.program'.tr(),
            program,
            isDark,
            textColor,
            subtitleColor,
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            'insurance.kasko.payment_type.vehicle_number'.tr(),
            carNumber,
            isDark,
            textColor,
            subtitleColor,
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            'insurance.kasko.payment_type.tech_passport'.tr(),
            techPassport,
            isDark,
            textColor,
            subtitleColor,
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            'insurance.kasko.payment_type.passport'.tr(),
            passport,
            isDark,
            textColor,
            subtitleColor,
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            'insurance.kasko.payment_type.birth_date'.tr(),
            birthDate,
            isDark,
            textColor,
            subtitleColor,
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            'insurance.kasko.payment_type.phone'.tr(),
            phone,
            isDark,
            textColor,
            subtitleColor,
          ),
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
          style: TextStyle(fontSize: 14.sp, color: subtitleColor),
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
    String period = '1 ${tr('common.year')}';

    final currentState = bloc.state;

    // Mashina ma'lumotlari
    final carFullName = bloc.selectedCarFullName;
    if (carFullName.isNotEmpty) {
      carName = carFullName;
    } else if (currentState is KaskoCarsLoaded &&
        currentState.cars.isNotEmpty) {
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
    if (currentState is KaskoOrderSaved) {
      premium =
          NumberFormat('#,###').format(currentState.order.premium.toInt()) +
          ' so\'m';
    } else if (currentState is KaskoPolicyCalculated) {
      premium =
          NumberFormat(
            '#,###',
          ).format(currentState.calculateResult.premium.toInt()) +
          ' so\'m';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'insurance.kasko.payment_type.summary'.tr(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        SizedBox(height: 20.h),
        _buildSummaryRow(
          'insurance.kasko.payment_type.insurance_period'.tr(),
          period,
          isDark,
          textColor,
          subtitleColor,
        ),
        SizedBox(height: 14.h),
        _buildSummaryRow(
          'insurance.kasko.payment_type.vehicle'.tr(),
          carName,
          isDark,
          textColor,
          subtitleColor,
        ),
        SizedBox(height: 14.h),
        _buildSummaryRow(
          'insurance.kasko.payment_type.coverage_amount'.tr(),
          coverage,
          isDark,
          textColor,
          subtitleColor,
        ),
        SizedBox(height: 14.h),
        _buildSummaryRow(
          'insurance.kasko.payment_type.amount_to_pay'.tr(),
          premium,
          isDark,
          textColor,
          subtitleColor,
        ),
        SizedBox(height: 20.h),
        InkWell(
          onTap: () {
            // Sug'urta qoidalarini ochish
            // TODO: PDF ochish
          },
          child: Text(
            'insurance.kasko.payment_type.insurance_rules'.tr(),
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
          style: TextStyle(fontSize: 14.sp, color: subtitleColor),
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
