import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loading_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../bloc/accident_bloc.dart';
import '../bloc/accident_event.dart';
import '../bloc/accident_state.dart';

class PaymentStatusPage extends StatefulWidget {
  final int anketaId;

  const PaymentStatusPage({super.key, required this.anketaId});

  @override
  State<PaymentStatusPage> createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends State<PaymentStatusPage> {
  Timer? _statusTimer;
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();
    // Загружаем статус при открытии страницы
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.mounted) {
        _checkStatus();
        // Auto-refresh har 5 soniyada
        _startPolling();
      }
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  void _checkStatus() {
    if (!mounted || !context.mounted) return;

    // Localization'dan til kodini olish
    final locale = context.locale;
    String languageCode = locale.languageCode;

    // API 'uz', 'ru', 'en' formatida kutmoqda
    // Agar 'uz-CYR' bo'lsa, 'uz' qaytaramiz
    if (languageCode == 'uz' && locale.countryCode == 'CYR') {
      languageCode = 'uz';
    }

    context.read<AccidentBloc>().add(
      CheckPayment(anketaId: widget.anketaId, lan: languageCode),
    );
  }

  void _startPolling() {
    if (_isPolling) return; // Agar allaqachon polling ishlamoqda bo'lsa, qayta boshlash kerak emas
    
    _isPolling = true;
    _statusTimer?.cancel(); // Eski timer ni bekor qilish
    
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || !context.mounted) {
        timer.cancel();
        _isPolling = false;
        return;
      }
      
      // Faqat payment status bilan bog'liq state larda tekshiramiz
      final state = context.read<AccidentBloc>().state;
      
      // Agar payment status bilan bog'liq state bo'lsa, tekshiramiz
      if (state is AccidentCheckingPayment ||
          state is AccidentPaymentChecked ||
          state is AccidentInitial) {
        // Loading bo'lmagan vaqtda tekshiramiz
        if (state is! AccidentCheckingPayment) {
          // Agar to'lov to'liq bo'lsa va polis tayyor bo'lsa, polling ni to'xtatish
          if (state is AccidentPaymentChecked) {
            final paymentStatus = state.paymentStatus;
            // statusPayment: 0 - to'lanmagan, 1 - jarayonda, 2 - to'langan
            // statusPolicy: 0 - yo'q, 1 - jarayonda, 2 - rad etilgan, 3 - rasmiylashtirilgan
            if (paymentStatus.statusPayment == 2 && 
                paymentStatus.statusPolicy == 3) {
              // To'lov to'liq va polis tayyor - polling ni to'xtatish
              timer.cancel();
              _isPolling = false;
              return;
            }
          }
          _checkStatus();
        }
      } else {
        // Boshqa state lar da polling ni to'xtatish
        timer.cancel();
        _isPolling = false;
      }
    });
  }

  void _stopPolling() {
    _isPolling = false;
    _statusTimer?.cancel();
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'insurance.accident.payment_status.url_open_error'.tr(),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'insurance.accident.payment_status.error_occurred'.tr(
                namedArgs: {'error': e.toString()},
              ),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _getPaymentStatusText(int status) {
    switch (status) {
      case 1:
        return 'insurance.accident.payment_status.payment_status_not_paid'.tr();
      case 2:
        return 'insurance.accident.payment_status.payment_status_paid'.tr();
      default:
        return 'insurance.accident.payment_status.payment_status_unknown'.tr();
    }
  }

  String _getPolicyStatusText(int status) {
    switch (status) {
      case 2:
        return 'insurance.accident.payment_status.policy_status_processing'
            .tr();
      case 3:
        return 'insurance.accident.payment_status.policy_status_issued'.tr();
      case 4:
        return 'insurance.accident.payment_status.policy_status_rejected'.tr();
      case 8:
        return 'insurance.accident.payment_status.policy_status_cancelled'.tr();
      default:
        return 'insurance.accident.payment_status.policy_status_unknown'.tr();
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 2:
      case 3:
        return Colors.green;
      case 4:
      case 8:
        return Colors.red;
      default:
        return AppColors.grayText;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Locale o'zgarishini kuzatish uchun context.locale ni ishlatamiz
    // Bu locale o'zgarganda widget'ni qayta build qiladi
    final currentLocale = context.locale;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      key: ValueKey('payment_status_${currentLocale.toString()}'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('insurance.accident.payment_status.title'.tr()),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        actions: [
          // Polling toggle button
          BlocBuilder<AccidentBloc, AccidentState>(
            buildWhen: (previous, current) {
              // Faqat payment status bilan bog'liq state larni qabul qil
              return current is AccidentCheckingPayment ||
                  current is AccidentPaymentChecked;
            },
            builder: (context, state) {
              return IconButton(
                icon: Icon(_isPolling ? Icons.pause : Icons.play_arrow),
                tooltip: _isPolling
                    ? 'insurance.accident.payment_status.pause'.tr()
                    : 'insurance.accident.payment_status.auto_refresh'.tr(),
                onPressed: () {
                  if (_isPolling) {
                    _stopPolling();
                  } else {
                    _startPolling();
                  }
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'insurance.accident.payment_status.reload'.tr(),
            onPressed: () {
              _checkStatus();
            },
          ),
        ],
      ),
      body: BlocBuilder<AccidentBloc, AccidentState>(
        buildWhen: (previous, current) {
          // Faqat payment status bilan bog'liq state larni qabul qil
          return current is AccidentCheckingPayment ||
              current is AccidentPaymentChecked ||
              (current is AccidentError &&
                  (previous is AccidentCheckingPayment ||
                      previous is AccidentPaymentChecked));
        },
        builder: (context, state) {
          if (state is AccidentCheckingPayment) {
            return LoadingStateWidget(
              message: 'insurance.accident.payment_status.checking'.tr(),
            );
          }

          if (state is AccidentError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () {
                context.read<AccidentBloc>().add(
                  CheckPayment(anketaId: widget.anketaId, lan: 'uz'),
                );
              },
            );
          }

          if (state is AccidentPaymentChecked) {
            final paymentStatus = state.paymentStatus;
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final cardBg = AppColors.getCardBg(isDark);
            final textColor = AppColors.getTextColor(isDark);

            // Agar to'lov to'liq bo'lsa va polis tayyor bo'lsa, polling ni to'xtatamiz
            if (paymentStatus.statusPayment == 2 &&
                paymentStatus.statusPolicy == 3) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _stopPolling();
              });
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: cardBg,
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'insurance.accident.payment_status.title'.tr(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.grayText,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    paymentStatus.statusPayment,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  _getPaymentStatusText(
                                    paymentStatus.statusPayment,
                                  ),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(
                                      paymentStatus.statusPayment,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'insurance.accident.payment_status.policy_status'
                                .tr(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.grayText,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    paymentStatus.statusPolicy,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  _getPolicyStatusText(
                                    paymentStatus.statusPolicy,
                                  ),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(
                                      paymentStatus.statusPolicy,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (paymentStatus.paymentType != null) ...[
                            SizedBox(height: 16.h),
                            Text(
                              'insurance.accident.payment_status.payment_method'
                                  .tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.grayText,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              paymentStatus.paymentType!,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (paymentStatus.policyInfo != null) ...[
                    SizedBox(height: 16.h),
                    Card(
                      color: cardBg,
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'insurance.accident.payment_status.policy_info'
                                  .tr(),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            if (paymentStatus.policyInfo!.policyNumber !=
                                null) ...[
                              _buildInfoRow(
                                'insurance.accident.payment_status.policy_number'
                                    .tr(),
                                paymentStatus.policyInfo!.policyNumber!,
                                textColor,
                              ),
                              SizedBox(height: 12.h),
                            ],
                            if (paymentStatus.policyInfo!.issueDate !=
                                null) ...[
                              _buildInfoRow(
                                'insurance.accident.payment_status.issue_date'
                                    .tr(),
                                paymentStatus.policyInfo!.issueDate!,
                                textColor,
                              ),
                              SizedBox(height: 12.h),
                            ],
                            if (paymentStatus.policyInfo!.expiryDate != null)
                              _buildInfoRow(
                                'insurance.accident.payment_status.expiry_date'
                                    .tr(),
                                paymentStatus.policyInfo!.expiryDate!,
                                textColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (paymentStatus.downloadUrls != null) ...[
                    SizedBox(height: 16.h),
                    if (paymentStatus.downloadUrls!.pdf != null)
                      ElevatedButton.icon(
                        onPressed: () =>
                            _launchUrl(paymentStatus.downloadUrls!.pdf),
                        icon: Icon(Icons.picture_as_pdf, size: 24.sp),
                        label: Text(
                          'insurance.accident.payment_status.download_pdf'.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    if (paymentStatus.downloadUrls!.pdf != null &&
                        paymentStatus.downloadUrls!.qr != null)
                      SizedBox(height: 12.h),
                    if (paymentStatus.downloadUrls!.qr != null)
                      OutlinedButton.icon(
                        onPressed: () =>
                            _launchUrl(paymentStatus.downloadUrls!.qr),
                        icon: Icon(Icons.qr_code, size: 24.sp),
                        label: Text(
                          'insurance.accident.payment_status.download_qr'.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryBlue,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          side: BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120.w,
          child: Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.grayText),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
