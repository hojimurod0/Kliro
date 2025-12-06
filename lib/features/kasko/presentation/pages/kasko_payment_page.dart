import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/navigation/app_router.dart';
import '../bloc/kasko_bloc.dart';
import '../bloc/kasko_event.dart';
import '../bloc/kasko_state.dart';

@RoutePage()
class KaskoPaymentPage extends StatelessWidget {
  final String orderId;
  final double amount;

  const KaskoPaymentPage({
    super.key,
    required this.orderId,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KASKO - To\'lov')),
      body: BlocListener<KaskoBloc, KaskoState>(
        listener: (context, state) {
          // To'lov holatini tekshirish
          if (state is KaskoPaymentChecked) {
            if (state.paymentStatus.status == 'paid' ||
                state.paymentStatus.status == 'success') {
              // To'lov muvaffaqiyatli bo'lgandan keyin success sahifasiga o'tish
              context.router.push(const KaskoSuccessRoute());
            }
          }
        },
        child: BlocBuilder<KaskoBloc, KaskoState>(
          builder: (context, state) {
            if (state is KaskoLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is KaskoPaymentLinkCreated) {
              return Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          children: [
                            Text(
                              'To\'lov summasi',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '${state.paymentLink.amount.toStringAsFixed(2)} UZS',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    ElevatedButton(
                      onPressed: () => _openPaymentUrl(
                        context,
                        state.paymentLink.paymentUrl,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: const Text('To\'lovga o\'tish'),
                    ),
                  ],
                ),
              );
            }

            if (state is KaskoError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: TextStyle(fontSize: 16.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<KaskoBloc>().add(
                          CreatePaymentLink(
                            orderId: orderId,
                            amount: amount,
                            returnUrl: 'https://kliro.uz/ru/kasko/success',
                            callbackUrl:
                                'https://api.kliro.uz/payment/callback/kasko',
                          ),
                        );
                      },
                      child: const Text('Qayta urinib ko\'ring'),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.read<KaskoBloc>().add(
                        CreatePaymentLink(
                          orderId: orderId,
                          amount: amount,
                          returnUrl: 'https://kliro.uz/ru/kasko/success',
                          callbackUrl:
                              'https://api.kliro.uz/payment/callback/kasko',
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: const Text('To\'lov havolasini olish'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openPaymentUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // To'lov URL ochilgandan keyin, foydalanuvchi to'lovni amalga oshiradi
      // va returnUrl ga qaytadi. returnUrl da KaskoSuccessRoute ga o'tish kerak
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось открыть ссылку: $url')),
        );
      }
    }
  }
}
