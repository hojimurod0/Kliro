import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/payment_urls_entity.dart';
import '../bloc/accident_bloc.dart';
import '../bloc/accident_state.dart';

class PaymentScreen extends StatefulWidget {
  final int anketaId;
  final PaymentUrlsEntity paymentUrls;
  final int? insurancePremium;
  final Map<String, dynamic>? formData;

  const PaymentScreen({
    super.key,
    required this.anketaId,
    required this.paymentUrls,
    this.insurancePremium,
    this.formData,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Qaysi to'lov turi tanlanganini saqlash uchun o'zgaruvchi
  // 0 - Payme, 1 - Click
  int _selectedPaymentIndex = 0;

  Future<void> _launchUrl(String? url, BuildContext context) async {
    if (url == null || url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'insurance.accident.payment_screen.errors.url_not_found'.tr(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      final uri = Uri.parse(url);

      // Android da canLaunchUrl muammo bo'lishi mumkin, shuning uchun to'g'ridan-to'g'ri launch qilamiz
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        // Agar externalApplication ishlamasa, platformDefault bilan urinib ko'ramiz
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'insurance.accident.payment_screen.errors.url_open_error'
                      .tr(),
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'insurance.accident.payment_screen.errors.error_occurred'.tr(
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

  void _handlePayment() {
    if (_selectedPaymentIndex == 0) {
      // Payme
      final paymeUrl = widget.paymentUrls.payme;
      if (paymeUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'insurance.accident.payment_screen.errors.url_not_found'.tr(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
      _launchUrl(paymeUrl, context);
    } else {
      // Click
      final clickUrl = widget.paymentUrls.click;
      if (clickUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'insurance.accident.payment_screen.errors.url_not_found'.tr(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
      _launchUrl(clickUrl, context);
    }
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Locale o'zgarishini kuzatish uchun context.locale ni ishlatamiz
    // Bu locale o'zgarganda widget'ni qayta build qiladi
    final currentLocale = context.locale;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppColors.primaryBlue;

    return BlocBuilder<AccidentBloc, AccidentState>(
      builder: (context, state) {
        // Insurance premium ni olish
        int insurancePremium = widget.insurancePremium ?? 0;
        if (insurancePremium == 0 && state is AccidentInsuranceCreated) {
          insurancePremium = state.insurance.insurancePremium ?? 0;
        }
        if (insurancePremium == 0 &&
            state is AccidentTariffsLoaded &&
            state.selectedTariff != null) {
          insurancePremium = state.selectedTariff!.insuranceOtv.toInt();
        }

        return Scaffold(
          key: ValueKey('payment_screen_${currentLocale.toString()}'),
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: Padding(
              padding: EdgeInsets.all(8.w),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            title: Text(
              'insurance.accident.payment_screen.title'.tr(),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                // Kiritilgan ma'lumotlar bo'limi
                if (widget.formData != null) ...[
                  _buildInfoSection(isDark: isDark),
                  SizedBox(height: 20.h),
                ],
                Text(
                  'insurance.accident.payment_screen.payment_type'.tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 15.h),
                // Payme Card
                _buildPaymentCard(
                  index: 0,
                  title: 'insurance.accident.payment_screen.payme'.tr(),
                  isSelected: _selectedPaymentIndex == 0,
                  isDark: isDark,
                  activeColor: activeColor,
                  logoWidget: Row(
                    children: [
                      Text(
                        "Pay",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: _selectedPaymentIndex == 0
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      Text(
                        "me",
                        style: TextStyle(
                          color: _selectedPaymentIndex == 0
                              ? Colors.white
                              : Colors.tealAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                // Click Card
                _buildPaymentCard(
                  index: 1,
                  title: 'insurance.accident.payment_screen.click'.tr(),
                  isSelected: _selectedPaymentIndex == 1,
                  isDark: isDark,
                  activeColor: activeColor,
                  logoWidget: Text(
                    "click",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: _selectedPaymentIndex == 1
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomBar(
            insurancePremium: insurancePremium,
            isDark: isDark,
            activeColor: activeColor,
          ),
        );
      },
    );
  }

  // To'lov kartasini chizuvchi metod
  Widget _buildPaymentCard({
    required int index,
    required String title,
    required bool isSelected,
    required bool isDark,
    required Color activeColor,
    required Widget logoWidget,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor
              : (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9F9F9)),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            logoWidget,
            const Spacer(),
            // Radio Button qismi
            Container(
              height: 24.h,
              width: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        height: 12.h,
                        width: 12.w,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
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

  // Ma'lumotlar bo'limi
  Widget _buildInfoSection({required bool isDark}) {
    final data = widget.formData!;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'insurance.accident.payment_screen.info_title'.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            label: 'insurance.accident.payment_screen.full_name'.tr(),
            value: _getFullName(data),
            isDark: isDark,
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            label: 'insurance.accident.payment_screen.phone'.tr(),
            value: _formatPhone(data['phone']?.toString() ?? ''),
            isDark: isDark,
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            label: 'insurance.accident.payment_screen.pinfl'.tr(),
            value: data['pinfl']?.toString() ?? '',
            isDark: isDark,
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            label: 'insurance.accident.payment_screen.passport'.tr(),
            value: _getPassport(data),
            isDark: isDark,
          ),
          if (data['dateBirth'] != null &&
              data['dateBirth'].toString().isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildInfoRow(
              label: 'insurance.accident.payment_screen.birth_date'.tr(),
              value: _formatDate(data['dateBirth']?.toString() ?? ''),
              isDark: isDark,
            ),
          ],
          if (data['address'] != null &&
              data['address'].toString().isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildInfoRow(
              label: 'insurance.accident.payment_screen.address'.tr(),
              value: data['address']?.toString() ?? '',
              isDark: isDark,
            ),
          ],
          if (data['regionName'] != null &&
              data['regionName'].toString().isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildInfoRow(
              label: 'insurance.accident.payment_screen.region'.tr(),
              value: data['regionName']?.toString() ?? '',
              isDark: isDark,
            ),
          ],
          if (data['startDate'] != null &&
              data['startDate'].toString().isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildInfoRow(
              label: 'insurance.accident.payment_screen.start_date'.tr(),
              value: _formatDate(data['startDate']?.toString() ?? ''),
              isDark: isDark,
            ),
          ],
          if (data['tariffName'] != null &&
              data['tariffName'].toString().isNotEmpty) ...[
            SizedBox(height: 8.h),
            _buildInfoRow(
              label: 'insurance.accident.payment_screen.tariff'.tr(),
              value: data['tariffName']?.toString() ?? '',
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            "$label:",
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  String _getFullName(Map<String, dynamic> data) {
    final lastName = data['lastName']?.toString() ?? '';
    final firstName = data['firstName']?.toString() ?? '';
    final patronymName = data['patronymName']?.toString() ?? '';

    final parts = [
      lastName,
      firstName,
      patronymName,
    ].where((part) => part.isNotEmpty).toList();

    return parts.join(' ');
  }

  String _getPassport(Map<String, dynamic> data) {
    final series = data['passSery']?.toString() ?? '';
    final number = data['passNum']?.toString() ?? '';

    if (series.isNotEmpty && number.isNotEmpty) {
      return "$series $number";
    } else if (series.isNotEmpty) {
      return series;
    } else if (number.isNotEmpty) {
      return number;
    }
    return '';
  }

  String _formatPhone(String phone) {
    if (phone.isEmpty) return '';
    // Telefon raqamini formatlash: +998 90 123 45 67
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 12 && cleaned.startsWith('998')) {
      return '+${cleaned.substring(0, 3)} ${cleaned.substring(3, 5)} ${cleaned.substring(5, 8)} ${cleaned.substring(8, 10)} ${cleaned.substring(10)}';
    } else if (cleaned.length == 9) {
      return '+998 ${cleaned.substring(0, 2)} ${cleaned.substring(2, 5)} ${cleaned.substring(5, 7)} ${cleaned.substring(7)}';
    }
    return phone;
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '';
    // yyyy-MM-dd -> dd.MM.yyyy
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        return "${parts[2]}.${parts[1]}.${parts[0]}";
      }
    } catch (e) {
      // Xatolik bo'lsa, asl formatni qaytaramiz
    }
    return date;
  }

  // Pastki qism (Summa va tugma)
  Widget _buildBottomBar({
    required int insurancePremium,
    required bool isDark,
    required Color activeColor,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 40.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'insurance.accident.payment_screen.total_amount'.tr(),
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "${_formatAmount(insurancePremium)} ${'insurance.kasko.tariff.som'.tr()}",
                style: TextStyle(
                  color: activeColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(
            width: 160.w,
            height: 50.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: activeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              onPressed: _handlePayment,
              child: Text(
                'insurance.accident.payment_screen.pay'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
