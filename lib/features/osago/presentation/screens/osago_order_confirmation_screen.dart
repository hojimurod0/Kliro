import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../core/utils/snackbar_helper.dart';
import '../../logic/bloc/osago_bloc.dart';
import '../../logic/bloc/osago_event.dart';
import '../../logic/bloc/osago_state.dart';

// -----------------------------------------------------------------------------
// CONSTANTS & THEME
// -----------------------------------------------------------------------------
// AppColors класс o'rniga Theme.of(context) ishlatiladi

// -----------------------------------------------------------------------------
// MAIN PAGE
// -----------------------------------------------------------------------------
class OsagoOrderConfirmationScreen extends StatefulWidget {
  const OsagoOrderConfirmationScreen({super.key});

  @override
  State<OsagoOrderConfirmationScreen> createState() =>
      _OsagoOrderConfirmationScreenState();
}

class _OsagoOrderConfirmationScreenState
    extends State<OsagoOrderConfirmationScreen> {
  String? _selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OsagoBloc, OsagoState>(
      builder: (context, state) {
        final vehicle = state.vehicle;
        final insurance = state.insurance;
        final calc = state.calcResponse;

        if (vehicle == null || insurance == null || calc == null) {
          return Scaffold(
            appBar: AppBar(title: Text('insurance.osago.payment.title'.tr())),
            body: Center(child: Text('insurance.osago.payment.no_data'.tr())),
          );
        }

        // Jami summa - create response dan kelgan amount ni ustunlik bilan ishlatamiz
        final createResponse = state.createResponse;
        final totalPrice = (createResponse?.amount ?? calc.amount).toInt();

        // Используем сохраненный метод оплаты из state или выбранный локально
        final currentPaymentMethod =
            state.paymentMethod ?? _selectedPaymentMethod;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      // Payment Method Selection Card (faqat to'lov)
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'insurance.osago.preview.payment_type'.tr(),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.color,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            _PaymentMethodOption(
                              title: 'insurance.osago.payment.payment_method_payme'.tr(),
                              value: 'payme',
                              groupValue: currentPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value;
                                });
                                context.read<OsagoBloc>().add(
                                  PaymentSelected(value!),
                                );
                              },
                            ),
                            SizedBox(height: 12.h),
                            _PaymentMethodOption(
                              title: 'insurance.osago.payment.payment_method_click'.tr(),
                              value: 'click',
                              groupValue: currentPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value;
                                });
                                context.read<OsagoBloc>().add(
                                  PaymentSelected(value!),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom Bar
              _BottomBar(
                totalPrice: totalPrice,
                onConfirm: () => _onConfirmPressed(context, state),
                paymentMethod: currentPaymentMethod,
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      leading: Container(
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).textTheme.titleLarge?.color,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        'insurance.osago.payment.title'.tr(),
        style: TextStyle(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  Future<void> _onConfirmPressed(BuildContext context, OsagoState state) async {
    final createResponse = state.createResponse;
    final paymentMethod = state.paymentMethod ?? _selectedPaymentMethod;

    if (createResponse == null) {
      SnackbarHelper.showError(
        context,
        'insurance.osago.payment.no_data'.tr(),
      );
      return;
    }

    if (paymentMethod == null || paymentMethod.isEmpty) {
      SnackbarHelper.showError(
        context,
        'insurance.osago.payment.select_payment_method'.tr(),
      );
      return;
    }

    // Avval payment URL ni olamiz (bu asosiy)
    final paymentUrl = createResponse.getPaymentUrl(paymentMethod);
    if (paymentUrl == null || paymentUrl.isEmpty) {
      SnackbarHelper.showError(
        context,
        'insurance.osago.order.no_payment_url'.tr(),
      );
      return;
    }

    // Avval payment URL dan foydalanishga harakat qilamiz (bu asosiy)
    bool urlOpened = false;

    try {
      // Payment URL ochishga harakat qilamiz
      urlOpened = await launchUrlString(
        paymentUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      // Agar payment URL ishlamasa, deep link yoki store URL dan foydalanamiz
      urlOpened = false;
    }

    if (!context.mounted) return;

    // Agar payment URL ishlamasa, deep link yoki store URL dan foydalanamiz
    if (!urlOpened) {
      final appUrl = _getPaymentAppUrl(paymentMethod);

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
        final storeUrl = _getPaymentStoreUrl(paymentMethod);
        if (storeUrl.isNotEmpty) {
          try {
            final success = await launchUrlString(
              storeUrl,
              mode: LaunchMode.externalApplication,
            );

            if (!context.mounted) return;

            if (!success) {
              SnackbarHelper.showError(
                context,
                'insurance.osago.order.payment_url_error'.tr(),
              );
              return;
            }
          } catch (e) {
            if (!context.mounted) return;
            SnackbarHelper.showError(
              context,
              'insurance.osago.order.payment_url_error'.tr(),
            );
            return;
          }
        } else {
          if (!context.mounted) return;
          SnackbarHelper.showError(
            context,
            'insurance.osago.order.payment_url_error'.tr(),
          );
          return;
        }
      }
    }

    // После открытия ссылки оплаты, начинаем проверку статуса полиса
    context.read<OsagoBloc>().add(const CheckPolicyRequested());
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

// -----------------------------------------------------------------------------
// OPTIMIZED WIDGETS
// -----------------------------------------------------------------------------
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 14.sp,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Pastki panel alohida Widget sifatida
class _BottomBar extends StatelessWidget {
  final int totalPrice;
  final VoidCallback onConfirm;
  final String? paymentMethod;

  const _BottomBar({
    required this.totalPrice,
    required this.onConfirm,
    this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 30.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'insurance.osago.payment.total_amount'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 12.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatCurrency(totalPrice),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: ElevatedButton(
              onPressed: paymentMethod != null ? onConfirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 14.h,
                ),
              ),
              child: Text(
                'insurance.osago.payment.pay'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    // Форматируем как "1, 200 000 sum" (с запятой после первой цифры)
    final amountStr = amount.toString();
    if (amountStr.length <= 3) {
      return "$amountStr sum";
    }

    // Первая цифра/цифры + запятая
    final firstPart = amountStr.substring(
      0,
      amountStr.length % 3 == 0 ? 3 : amountStr.length % 3,
    );
    final restPart = amountStr.substring(firstPart.length);

    // Форматируем остальную часть с пробелами
    final formattedRest = restPart.replaceAllMapped(
      RegExp(r'(\d{3})'),
      (Match m) => ' ${m[1]}',
    );

    return "$firstPart,$formattedRest sum";
  }
}

// Payment Method Option Widget
class _PaymentMethodOption extends StatelessWidget {
  final String title;
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  const _PaymentMethodOption({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.cardColor,
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.dividerColor,
                  width: 2,
                ),
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: theme.colorScheme.primary,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
