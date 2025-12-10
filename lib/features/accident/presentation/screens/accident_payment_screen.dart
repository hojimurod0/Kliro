import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AccidentPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> formData;
  final String selectedTariff;
  final String insuranceAmount;

  const AccidentPaymentScreen({
    super.key,
    required this.formData,
    required this.selectedTariff,
    required this.insuranceAmount,
  });

  @override
  State<AccidentPaymentScreen> createState() => _AccidentPaymentScreenState();
}

class _AccidentPaymentScreenState extends State<AccidentPaymentScreen> {
  String? _selectedPaymentMethod;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Locale o'zgarishini kuzatish uchun context.locale ni ishlatamiz
    // Bu locale o'zgarganda widget'ni qayta build qiladi
    final currentLocale = context.locale;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF222222);
    final subtitleColor = isDark ? Colors.grey[400] : const Color(0xFF666666);

    return Scaffold(
      key: ValueKey('accident_payment_${currentLocale.toString()}'),
      backgroundColor: backgroundColor,
      appBar: AppBar(
        toolbarHeight: 60.h,
        backgroundColor: cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 60.w,
        leading: Container(
          margin: EdgeInsets.only(left: 16.w, top: 8.h, bottom: 8.h),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? Colors.white24 : const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 20.sp,
              color: isDark ? Colors.white : const Color(0xFF333333),
            ),
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'insurance.accident.payment.title'.tr(),
          style: TextStyle(
            color: textColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
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
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Information Section
                      Text(
                        'insurance.accident.payment.order_info'.tr(),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Personal Information Card
                      _buildInfoCard(
                        title: 'insurance.accident.payment.personal_info'.tr(),
                        isDark: isDark,
                        cardColor: cardColor,
                        children: [
                          _buildInfoRow(
                            'insurance.accident.last_name'.tr(),
                            widget.formData['lastName'] ?? '',
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                          ),
                          _buildInfoRow(
                            'insurance.accident.first_name'.tr(),
                            widget.formData['firstName'] ?? '',
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                          ),
                          if (widget.formData['middleName'] != null &&
                              widget.formData['middleName'].toString().isNotEmpty)
                            _buildInfoRow(
                              'insurance.accident.middle_name'.tr(),
                              widget.formData['middleName'] ?? '',
                              isDark: isDark,
                              subtitleColor: subtitleColor,
                            ),
                          _buildInfoRow(
                            'insurance.accident.birth_date'.tr(),
                            widget.formData['birthDate'] ?? '',
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                          ),
                          _buildInfoRow(
                            'insurance.accident.passport_series'.tr() +
                                ' / ' +
                                'insurance.accident.passport_number'.tr(),
                            '${widget.formData['passportSeries'] ?? ''} ${widget.formData['passportNumber'] ?? ''}',
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                          ),
                          _buildInfoRow(
                            'insurance.accident.pinfl'.tr(),
                            widget.formData['pinfl'] ?? '',
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Contact Information Card
                      _buildInfoCard(
                        title: 'insurance.accident.payment.contact_info'.tr(),
                        isDark: isDark,
                        cardColor: cardColor,
                        children: [
                          _buildInfoRow(
                            'insurance.accident.region'.tr(),
                            widget.formData['region'] ?? '',
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                          ),
                          _buildInfoRow(
                            'insurance.accident.phone'.tr(),
                            widget.formData['phone'] ?? '',
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                          ),
                          _buildInfoRow(
                            'insurance.accident.address'.tr(),
                            widget.formData['address'] ?? '',
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Insurance Information Card
                      _buildInfoCard(
                        title: 'insurance.accident.payment.insurance_info'.tr(),
                        isDark: isDark,
                        cardColor: cardColor,
                        children: [
                          _buildInfoRow(
                            'insurance.accident.payment.tariff'.tr(),
                            widget.selectedTariff,
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                          ),
                          _buildInfoRow(
                            'insurance.accident.start_date'.tr(),
                            widget.formData['startDate'] ?? '',
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                          ),
                          _buildInfoRow(
                            'insurance.accident.end_date'.tr(),
                            widget.formData['endDate'] ?? '',
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Payment Method Selection
                      Text(
                        'insurance.accident.payment.select_payment_method'.tr(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Payme Card
                      _buildPaymentMethodCard(
                        value: 'payme',
                        title: 'insurance.accident.payment.payme'.tr(),
                        logo: _buildPaymeLogo(isDark),
                        isDark: isDark,
                        cardColor: cardColor,
                      ),
                      SizedBox(height: 12.h),

                      // Click Card
                      _buildPaymentMethodCard(
                        value: 'click',
                        title: 'insurance.accident.payment.click'.tr(),
                        logo: _buildClickLogo(isDark),
                        isDark: isDark,
                        cardColor: cardColor,
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Payment Panel
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'insurance.accident.payment.total_amount'.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: subtitleColor,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${widget.insuranceAmount} so\'m',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFF9800),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      SizedBox(
                        width: 160.w,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: (_isLoading || _selectedPaymentMethod == null)
                              ? null
                              : _onPayPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'insurance.accident.payment.pay'.tr(),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
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
          if (_isLoading)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withOpacity(isDark ? 0.7 : 0.38),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF9800),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required bool isDark,
    required Color cardColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF222222),
            ),
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    required bool isDark,
    required Color? subtitleColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: subtitleColor ?? (isDark ? Colors.grey[400] : const Color(0xFF666666)),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required String value,
    required String title,
    required Widget logo,
    required bool isDark,
    required Color cardColor,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF9800)
                : (isDark ? Colors.grey[700]! : const Color(0xFFE0E0E0)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Logo
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? cardColor : Colors.white,
              ),
              child: logo,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            // Radio button
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF9800)
                      : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFFFF9800) : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16.sp,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymeLogo(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'pay',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'me',
            style: TextStyle(
              color: const Color(0xFF00D4AA),
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickLogo(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0066FF),
      ),
      child: Center(
        child: Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          ),
          child: Center(
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0066FF),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onPayPressed() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('insurance.accident.payment.select_payment_method'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: API call to create payment link
    await Future.delayed(const Duration(seconds: 1));

    // Mock payment URL
    final paymentUrl = _selectedPaymentMethod == 'payme'
        ? 'https://payme.uz/checkout/test'
        : 'https://click.uz/checkout/test';

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Open payment URL
    try {
      final uri = Uri.parse(paymentUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to app deep link
        final appUrl = _getPaymentAppUrl(_selectedPaymentMethod!);
        if (appUrl != null) {
          await launchUrlString(appUrl, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('insurance.accident.payment.payment_link_error'.tr()),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('insurance.accident.payment.payment_link_error'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _getPaymentAppUrl(String paymentMethod) {
    if (paymentMethod == 'payme') {
      return Platform.isAndroid || Platform.isIOS ? 'payme://' : null;
    } else if (paymentMethod == 'click') {
      return Platform.isAndroid || Platform.isIOS ? 'clickuz://' : null;
    }
    return null;
  }
}

