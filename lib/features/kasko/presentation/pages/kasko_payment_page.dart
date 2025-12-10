import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../core/constants/app_colors.dart';

@RoutePage()
class KaskoPaymentPage extends StatelessWidget {
  final String orderId;
  final double amount;
  final String? clickUrl;
  final String? paymeUrl;
  final String paymentMethod;

  const KaskoPaymentPage({
    super.key,
    required this.orderId,
    required this.amount,
    this.clickUrl,
    this.paymeUrl,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = AppColors.getScaffoldBg(isDark);
    final cardBg = AppColors.getCardBg(isDark);
    final textColor = AppColors.getTextColor(isDark);
    final subtitleColor = AppColors.getSubtitleColor(isDark);
    final borderColor = AppColors.getBorderColor(isDark);

    // Payment URL ni olish
    String? paymentUrl;
    final effectivePaymentMethod = paymentMethod.isNotEmpty
        ? paymentMethod
        : 'click';
    if (effectivePaymentMethod == 'payme') {
      paymentUrl = paymeUrl;
    } else if (effectivePaymentMethod == 'click') {
      paymentUrl = clickUrl;
    } else {
      paymentUrl = clickUrl ?? paymeUrl;
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        title: Text(
          'insurance.kasko.payment_page.title'.tr(),
          style: TextStyle(
            color: textColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      body: paymentUrl != null
          ? Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: cardBg,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      side: BorderSide(color: borderColor, width: 1),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          Text(
                            'insurance.kasko.payment_page.amount'.tr(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: subtitleColor,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '${amount.toStringAsFixed(2)} UZS',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  ElevatedButton(
                    onPressed: () {
                      _openPaymentUrl(context, paymentUrl!, paymentMethod);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kaskoPrimaryBlue,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'insurance.kasko.payment_page.go_to_payment'.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: AppColors.dangerRed,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'insurance.kasko.payment_page.link_not_found'.tr(),
                      style: TextStyle(fontSize: 16.sp, color: textColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _openPaymentUrl(
    BuildContext context,
    String url,
    String paymentMethod,
  ) async {
    // URL'dan payment method ni aniqlash (agar parametr bo'lmasa)
    String detectedPaymentMethod = paymentMethod;
    if (detectedPaymentMethod.isEmpty) {
      // URL'dan payment method ni aniqlash
      final uri = Uri.parse(url);
      final host = uri.host.toLowerCase();
      if (host.contains('payme')) {
        detectedPaymentMethod = 'payme';
      } else if (host.contains('click')) {
        detectedPaymentMethod = 'click';
      }
    }

    bool urlOpened = false;

    // Avval payment URL ni ochishga harakat qilamiz
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        urlOpened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Agar payment URL ishlamasa, deep link yoki store URL dan foydalanamiz
      urlOpened = false;
    }

    if (!context.mounted) return;

    // Agar payment URL ishlamasa, deep link yoki store URL dan foydalanamiz
    if (!urlOpened && detectedPaymentMethod.isNotEmpty) {
      final appUrl = _getPaymentAppUrl(detectedPaymentMethod);

      if (appUrl != null) {
        try {
          // Deep link ochishga harakat qilamiz
          urlOpened = await launchUrlString(
            appUrl,
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          // Agar deep link ishlamasa, store URL dan foydalanamiz
          urlOpened = false;
        }
      }

      // Agar deep link ham ishlamasa, store URL dan foydalanamiz
      if (!urlOpened) {
        final storeUrl = _getPaymentStoreUrl(detectedPaymentMethod);
        if (storeUrl.isNotEmpty) {
          try {
            final success = await launchUrlString(
              storeUrl,
              mode: LaunchMode.externalApplication,
            );

            if (!context.mounted) return;

            if (!success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('To\'lov havolasini ochib bo\'lmadi'),
                  backgroundColor: AppColors.dangerRed,
                ),
              );
              return;
            }
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('insurance.kasko.payment_page.link_not_found'.tr()),
                backgroundColor: AppColors.dangerRed,
              ),
            );
            return;
          }
        } else {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('To\'lov havolasini ochib bo\'lmadi'),
              backgroundColor: AppColors.dangerRed,
            ),
          );
          return;
        }
      }
    } else if (!urlOpened) {
      // Agar payment method aniqlanmagan bo'lsa va URL ham ochilmagan bo'lsa
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('To\'lov havolasini ochib bo\'lmadi: $url'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  String? _getPaymentAppUrl(String paymentMethod) {
    // Deep links для открытия приложений напрямую
    if (paymentMethod == 'payme') {
      // Payme deep link - Android va iOS uchun
      if (Platform.isAndroid) {
        return 'payme://';
      } else if (Platform.isIOS) {
        return 'payme://';
      }
      return null;
    } else if (paymentMethod == 'click') {
      // Click deep link - Android va iOS uchun
      if (Platform.isAndroid) {
        return 'clickuz://';
      } else if (Platform.isIOS) {
        return 'clickuz://';
      }
      return null;
    }
    return null;
  }

  String _getPaymentStoreUrl(String paymentMethod) {
    // Fallback URL - agar ilova o'rnatilmagan bo'lsa, Play Store/App Store ga yo'naltiramiz
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
}
