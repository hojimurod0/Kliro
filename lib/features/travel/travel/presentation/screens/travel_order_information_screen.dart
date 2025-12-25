import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/snackbar_helper.dart';
import '../logic/bloc/travel_bloc.dart';
import '../logic/bloc/travel_event.dart';
import '../logic/bloc/travel_state.dart';

@RoutePage()
class TravelOrderInformationScreen extends StatefulWidget {
  const TravelOrderInformationScreen({super.key});

  @override
  State<TravelOrderInformationScreen> createState() =>
      _TravelOrderInformationScreenState();
}

class _TravelOrderInformationScreenState
    extends State<TravelOrderInformationScreen> {
  bool _shouldAutoCreatePolicy = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = AppColors.getScaffoldBg(isDark);
    final cardBg = AppColors.getCardBg(isDark);
    final textColor = AppColors.getTextColor(isDark);
    final subtitleColor = AppColors.getSubtitleColor(isDark);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return BlocConsumer<TravelBloc, TravelState>(
      listener: (context, state) {
        final bloc = context.read<TravelBloc>();

        // TravelCalcSuccess listener - agar calcResponse null bo'lsa va hisob-kitob muvaffaqiyatli bo'lsa
        if (state is TravelCalcSuccess &&
            state.calcResponse != null &&
            _shouldAutoCreatePolicy) {
          log(
            '[ORDER_INFO] ✅ TravelCalcSuccess - avtomatik CreatePolicyRequested yuborilmoqda...',
            name: 'TRAVEL',
          );
          // Avtomatik CreatePolicyRequested yuborish
          _shouldAutoCreatePolicy = false; // Flag'ni reset qilish
          Future.delayed(const Duration(milliseconds: 300), () {
            bloc.add(const CreatePolicyRequested());
          });
        }

        if (state is TravelCreateSuccess) {
          log(
            '[ORDER_INFO] ✅ TravelCreateSuccess - to\'lov havolasi ochilmoqda...\n'
            '  - Payment Method: ${state.paymentMethod ?? "yo'q"}\n'
            '  - Click URL: ${state.createResponse?.clickUrl != null ? "mavjud" : "yo'q"}\n'
            '  - Payme URL: ${state.createResponse?.paymeUrl != null ? "mavjud" : "yo'q"}',
            name: 'TRAVEL',
          );
          // Polis yaratildi, to'lov linkini ochish
          final paymentMethod = state.paymentMethod ?? 'click';
          final clickUrl = state.createResponse?.clickUrl;
          final paymeUrl = state.createResponse?.paymeUrl;

          String? paymentUrl;
          if (paymentMethod == 'payme' &&
              paymeUrl != null &&
              paymeUrl.isNotEmpty) {
            paymentUrl = paymeUrl;
          } else if (clickUrl != null && clickUrl.isNotEmpty) {
            paymentUrl = clickUrl;
          }

          if (paymentUrl != null && paymentUrl.isNotEmpty) {
            launchUrlString(paymentUrl, mode: LaunchMode.externalApplication);
          } else {
            SnackbarHelper.showWarning(
              context,
              "travel.order_info.payment_link_not_found".tr(),
            );
          }
        } else if (state is TravelFailure) {
          SnackbarHelper.showError(
            context,
            state.errorMessage ?? "travel.order_info.error".tr(),
            action: SnackBarAction(
              label: "travel.order_info.retry".tr(),
              textColor: Colors.white,
              onPressed: () {
                // Xatolikdan keyin qayta urinish
                if (state.calcResponse == null) {
                  bloc.add(const CalcRequested());
                } else {
                  bloc.add(const CreatePolicyRequested());
                }
              },
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<TravelBloc>();

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            backgroundColor: cardBg,
            elevation: 0.5,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => context.router.pop(),
            ),
            title: Text(
              "travel.order_info.title".tr(),
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
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(16.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sarlavha
                    Text(
                      "travel.order_info.travel_insurance".tr(),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 5.0.h),
                    Text(
                      "travel.order_info.check_all_info".tr(),
                      style: TextStyle(fontSize: 16.sp, color: subtitleColor),
                    ),
                    SizedBox(height: 20.h),

                    // Sug'urta ma'lumotlari
                    _buildInsuranceCard(
                      state,
                      isDark,
                      textColor,
                      subtitleColor,
                    ),
                    SizedBox(height: 16.h),

                    // Shaxsiy ma'lumotlar
                    _buildPersonsCard(state, isDark, textColor, subtitleColor),
                    SizedBox(height: 16.h),

                    // To'lov usuli tanlash
                    _buildPaymentMethodCard(
                      bloc,
                      state,
                      isDark,
                      textColor,
                      subtitleColor,
                    ),
                    SizedBox(height: 100.h), // Bottom bar uchun joy
                  ],
                ),
              ),

              // Fixed bottom bar
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
                        color: isDark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Jami summa
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "travel.order_info.total_amount".tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: subtitleColor,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _getTotalAmount(state),
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      // To'lov tugmasi
                      ElevatedButton(
                        onPressed: state is TravelLoading
                            ? null
                            : () {
                                log(
                                  '[ORDER_INFO] 🔄 "To\'lov" tugmasi bosildi',
                                  name: 'TRAVEL',
                                );

                                // Agar polis allaqachon yaratilgan bo'lsa va linklar mavjud bo'lsa, to'lov linkini ochish
                                if (state is TravelCreateSuccess) {
                                  final paymentMethod =
                                      state.paymentMethod ?? 'click';
                                  final clickUrl =
                                      state.createResponse?.clickUrl;
                                  final paymeUrl =
                                      state.createResponse?.paymeUrl;

                                  String? paymentUrl;
                                  if (paymentMethod == 'payme' &&
                                      paymeUrl != null &&
                                      paymeUrl.isNotEmpty) {
                                    paymentUrl = paymeUrl;
                                  } else if (clickUrl != null &&
                                      clickUrl.isNotEmpty) {
                                    paymentUrl = clickUrl;
                                  }

                                  if (paymentUrl != null &&
                                      paymentUrl.isNotEmpty) {
                                    log(
                                      '[ORDER_INFO] ✅ To\'lov linkini ochish: $paymentUrl',
                                      name: 'TRAVEL',
                                    );
                                    launchUrlString(
                                      paymentUrl,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } else {
                                    SnackbarHelper.showWarning(
                                      context,
                                      "travel.order_info.payment_link_not_found"
                                          .tr(),
                                    );
                                  }
                                  return;
                                }

                                // Agar calcResponse null bo'lsa, avval hisob-kitob qilish
                                if (state.calcResponse == null) {
                                  log(
                                    '[ORDER_INFO] ⏳ CalcResponse yo\'q - CalcRequested yuborilmoqda...',
                                    name: 'TRAVEL',
                                  );
                                  _shouldAutoCreatePolicy =
                                      true; // Flag'ni o'rnatish
                                  bloc.add(const CalcRequested());
                                  // TravelCalcSuccess listener orqali avtomatik CreatePolicyRequested yuboriladi
                                } else {
                                  log(
                                    '[ORDER_INFO] ⏳ CreatePolicyRequested yuborilmoqda...\n'
                                    '  - Payment Method: ${state.paymentMethod ?? "yo'q"}\n'
                                    '  - Amount: ${state.calcResponse?.amount ?? "yo'q"}',
                                    name: 'TRAVEL',
                                  );
                                  // To'g'ridan-to'g'ri polis yaratish
                                  bloc.add(const CreatePolicyRequested());
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state is TravelCreateSuccess
                              ? Colors.green
                              : const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 32.w,
                            vertical: 16.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: state is TravelLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                state is TravelCreateSuccess
                                    ? "travel.order_info.process_payment".tr()
                                    : "travel.order_info.payment".tr(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
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
      },
    );
  }

  Widget _buildInsuranceCard(
    TravelState state,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    final cardBg = isDark ? const Color(0xFF1E3A5C) : const Color(0xFFE3F2FD);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF42A5F5),
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  "travel.order_info.insurance_info".tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          if (state.insurance != null) ...[
            // Sug'urta kompaniyasi - birinchi
            _buildInfoRow(
              icon: Icons.business_outlined,
              label: "travel.order_info.insurance_company".tr(),
              value: state.insurance!.companyName.isNotEmpty
                  ? state.insurance!.companyName
                  : (state.insurance!.provider.isNotEmpty
                        ? state.insurance!.provider
                        : '--'),
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),
            SizedBox(height: 12.h),
            // Mamlakat
            if (state.insurance!.countryName != null &&
                state.insurance!.countryName!.isNotEmpty) ...[
              _buildInfoRow(
                icon: Icons.location_on_outlined,
                label: "travel.order_info.country".tr(),
                value: state.insurance!.countryName!,
                textColor: textColor,
                subtitleColor: subtitleColor,
              ),
              SizedBox(height: 12.h),
            ],
            // Sayohat maqsadi
            if (state.insurance!.purposeName != null &&
                state.insurance!.purposeName!.isNotEmpty) ...[
              _buildInfoRow(
                icon: Icons.flag_outlined,
                label: "travel.order_info.travel_purpose".tr(),
                value: state.insurance!.purposeName!,
                textColor: textColor,
                subtitleColor: subtitleColor,
              ),
              SizedBox(height: 12.h),
            ],
            // Sanalar
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: "travel.order_info.start_date".tr(),
              value: DateFormat('dd.MM.yyyy')
                  .format(state.insurance!.startDate),
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),
            SizedBox(height: 12.h),
            _buildInfoRow(
              icon: Icons.event_outlined,
              label: "travel.order_info.end_date".tr(),
              value: DateFormat('dd.MM.yyyy')
                  .format(state.insurance!.endDate),
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),
            SizedBox(height: 12.h),
            // Aloqa ma'lumotlari
            Divider(
              color: subtitleColor.withOpacity(0.2),
              height: 24.h,
            ),
            Text(
              "travel.order_info.contact_info".tr(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: subtitleColor,
              ),
            ),
            SizedBox(height: 12.h),
            _buildInfoRow(
              icon: Icons.phone_outlined,
              label: "travel.order_info.phone".tr(),
              value: state.insurance!.phoneNumber,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),
            if ((state.insurance!.email ?? '').isNotEmpty) ...[
              SizedBox(height: 8.h),
              _buildInfoRow(
                icon: Icons.email_outlined,
                label: "travel.order_info.email".tr(),
                value: state.insurance!.email ?? '',
                textColor: textColor,
                subtitleColor: subtitleColor,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPersonsCard(
    TravelState state,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    final cardBg = isDark ? const Color(0xFF1E3A5C) : const Color(0xFFE3F2FD);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people_outline,
                color: const Color(0xFF42A5F5),
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  "travel.order_info.travelers".tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ...state.persons.asMap().entries.map((entry) {
            final index = entry.key;
            final person = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < state.persons.length - 1 ? 20.h : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index > 0) ...[
                    Divider(
                      color: subtitleColor.withOpacity(0.2),
                      height: 24.h,
                    ),
                  ],
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[800]!.withOpacity(0.3)
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 18.sp,
                          color: const Color(0xFF42A5F5),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            "${"travel.order_info.traveler".tr()} ${index + 1}",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildInfoRow(
                    icon: Icons.person_outline,
                    label: "travel.order_info.full_name".tr(),
                    value:
                        '${person.lastName} ${person.firstName} ${person.middleName ?? ''}'.trim(),
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                  ),
                  SizedBox(height: 8.h),
                  _buildInfoRow(
                    icon: Icons.badge_outlined,
                    label: "travel.order_info.passport".tr(),
                    value: '${person.passportSeria} ${person.passportNumber}',
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                  ),
                  SizedBox(height: 8.h),
                  _buildInfoRow(
                    icon: Icons.cake_outlined,
                    label: "travel.order_info.birth_date".tr(),
                    value: DateFormat('dd.MM.yyyy').format(person.birthDate),
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    TravelBloc bloc,
    TravelState state,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    final cardBg = isDark ? const Color(0xFF1E3A5C) : const Color(0xFFE3F2FD);
    final paymentMethod = state.paymentMethod ?? 'click';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "travel.order_info.payment_method".tr(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildPaymentOption(
                  'Payme',
                  paymentMethod == 'payme',
                  () => bloc.add(const PaymentSelected('payme')),
                  isDark,
                  textColor,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildPaymentOption(
                  'Click',
                  paymentMethod == 'click',
                  () => bloc.add(const PaymentSelected('click')),
                  isDark,
                  textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    String name,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
    Color textColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1976D2)
              : (isDark ? const Color(0xFF2C2C2C) : Colors.white),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1976D2)
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color(0xFF42A5F5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: const Color(0xFF42A5F5), size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getTotalAmount(TravelState state) {
    if (state.calcResponse != null) {
      final amount = state.calcResponse!.amount;
      final formatted = NumberFormat('#,###').format(amount.toInt());
      return '${formatted.replaceAll(',', ' ')} ${state.calcResponse!.currency}';
    }
    return '--';
  }
}
