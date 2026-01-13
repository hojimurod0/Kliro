import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/global_error_handler.dart';

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
    final backgroundColor = AppColors.getScaffoldBg(isDark);
    final cardColor = AppColors.getCardBg(isDark);
    final textColor = AppColors.getTextColor(isDark);
    final subtitleColor = AppColors.getSubtitleColor(isDark);

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
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 20.sp,
              color: textColor,
            ),
            padding: EdgeInsets.zero,
            onPressed: () {
              try {
                Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  GlobalErrorHandler.showErrorSnackBar(
                    context,
                    e,
                    duration: const Duration(seconds: 3),
                  );
                }
              }
            },
          ),
        ),
        title: Text(
          'insurance.accident.payment.title'.tr(),
          style: AppTypography.headingM(context).copyWith(color: textColor),
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
                        style: AppTypography.headingL(context)
                            .copyWith(color: textColor),
                      ),
                      SizedBox(height: 20.h),

                      // Personal Information Card
                      _buildInfoCard(
                        title: 'insurance.accident.payment.personal_info'.tr(),
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                        children: [
                          _buildInfoRow(
                            'insurance.accident.last_name'.tr(),
                            widget.formData['lastName'] ?? '',
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                            textColor: textColor,
                          ),
                          _buildInfoRow(
                            'insurance.accident.first_name'.tr(),
                            widget.formData['firstName'] ?? '',
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                            textColor: textColor,
                          ),
                          if (widget.formData['middleName'] != null &&
                              widget.formData['middleName']
                                  .toString()
                                  .isNotEmpty)
                            _buildInfoRow(
                              'insurance.accident.middle_name'.tr(),
                              widget.formData['middleName'] ?? '',
                              isDark: isDark,
                              subtitleColor: subtitleColor,
                              textColor: textColor,
                            ),
                          _buildInfoRow(
                            'insurance.accident.birth_date'.tr(),
                            widget.formData['birthDate'] ?? '',
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                            textColor: textColor,
                          ),
                          _buildInfoRow(
                            'insurance.accident.passport_series'.tr() +
                                ' / ' +
                                'insurance.accident.passport_number'.tr(),
                            '${widget.formData['passportSeries'] ?? ''} ${widget.formData['passportNumber'] ?? ''}',
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                            textColor: textColor,
                          ),
                          _buildInfoRow(
                            'insurance.accident.pinfl'.tr(),
                            widget.formData['pinfl'] ?? '',
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                            textColor: textColor,
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Contact Information Card
                      _buildInfoCard(
                        title: 'insurance.accident.payment.contact_info'.tr(),
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                        children: [
                          _buildInfoRow(
                            'insurance.accident.region'.tr(),
                            widget.formData['region'] ?? '',
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                            textColor: textColor,
                          ),
                          _buildInfoRow(
                            'insurance.accident.phone'.tr(),
                            widget.formData['phone'] ?? '',
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                            textColor: textColor,
                          ),
                          _buildInfoRow(
                            'insurance.accident.address'.tr(),
                            widget.formData['address'] ?? '',
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                            textColor: textColor,
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Insurance Information Card
                      _buildInfoCard(
                        title: 'insurance.accident.payment.insurance_info'.tr(),
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                        children: [
                          _buildInfoRow(
                            'insurance.accident.payment.tariff'.tr(),
                            widget.selectedTariff,
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                            textColor: textColor,
                          ),
                          _buildInfoRow(
                            'insurance.accident.start_date'.tr(),
                            widget.formData['startDate'] ?? '',
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                            textColor: textColor,
                          ),
                          _buildInfoRow(
                            'insurance.accident.end_date'.tr(),
                            widget.formData['endDate'] ?? '',
                            isDark: isDark,
                            subtitleColor: subtitleColor,
                            textColor: textColor,
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Payment Method Selection
                      Text(
                        'insurance.accident.payment.select_payment_method'.tr(),
                        style: AppTypography.titleLarge(context)
                            .copyWith(color: textColor),
                      ),
                      SizedBox(height: 12.h),

                      // Payme Card
                      _buildPaymentMethodCard(
                        value: 'payme',
                        title: 'insurance.accident.payment.payme'.tr(),
                        logo: _buildPaymeLogo(isDark, textColor),
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                      ),
                      SizedBox(height: 12.h),

                      // Click Card
                      _buildPaymentMethodCard(
                        value: 'click',
                        title: 'insurance.accident.payment.click'.tr(),
                        logo: _buildClickLogo(isDark),
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
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
                      color: AppColors.black.withOpacity(isDark ? 0.3 : 0.05),
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
                              style: AppTypography.bodyMedium(context)
                                  .copyWith(color: subtitleColor),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${widget.insuranceAmount} so\'m',
                              style: AppTypography.priceLarge(context),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      SizedBox(
                        width: 160.w,
                        height: 56.h,
                        child: ElevatedButton(
                          // Payment functionality temporarily disabled for Play Market submission
                          // TODO: Implement backend API integration before enabling
                          onPressed:
                              null, // Disabled until payment is fully implemented
                          /*
                          onPressed: (_isLoading || _selectedPaymentMethod == null)
                              ? null
                              : _onPayPressed,
                          */
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orangeWarning,
                            foregroundColor: AppColors.white,
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
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      AppColors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'insurance.accident.payment.pay'.tr(),
                                  style: AppTypography.buttonLarge(context),
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
                color: AppColors.black.withOpacity(isDark ? 0.7 : 0.38),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.orangeWarning,
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
    required Color textColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.getBorderColor(isDark),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.headingS(context).copyWith(color: textColor),
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
    required Color textColor,
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
              style: AppTypography.bodyMedium(context).copyWith(
                color: subtitleColor ?? AppColors.getSubtitleColor(isDark),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTypography.subtitle(context).copyWith(
                color: textColor,
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
    required Color textColor,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () {
        try {
          setState(() {
            _selectedPaymentMethod = value;
          });
        } catch (e) {
          if (mounted) {
            GlobalErrorHandler.showErrorSnackBar(
              context,
              e,
              duration: const Duration(seconds: 3),
            );
          }
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.orangeWarning
                : AppColors.getBorderColor(isDark),
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
                color: cardColor,
              ),
              child: logo,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyLarge(context).copyWith(
                  fontWeight: FontWeight.w500,
                  color: textColor,
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
                      ? AppColors.orangeWarning
                      : AppColors.getPlaceholderColor(isDark),
                  width: 2,
                ),
                color:
                    isSelected ? AppColors.orangeWarning : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16.sp,
                      color: AppColors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymeLogo(bool isDark, Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'pay',
            style: AppTypography.caption(context).copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'me',
            style: AppTypography.caption(context).copyWith(
              color: AppColors.accentCyan,
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
        color: AppColors.primaryBlue,
      ),
      child: Center(
        child: Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.getCardBg(isDark),
          ),
          child: Center(
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Payment functionality temporarily disabled for Play Market submission
  // TODO: Implement backend API integration before enabling
  /*
  Future<void> _onPayPressed() async {
    try {
      if (_selectedPaymentMethod == null) {
        SnackbarHelper.showError(
          context,
          'insurance.accident.payment.select_payment_method'.tr(),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      if (!mounted) return;

      // Payment functionality is not yet implemented
      // This feature requires backend API integration
      
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        SnackbarHelper.showError(
          context,
          'common.errors.server_error'.tr(),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        GlobalErrorHandler.showErrorSnackBar(
          context,
          e,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }
  */
}
