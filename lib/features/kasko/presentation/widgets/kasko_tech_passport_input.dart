import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/upper_case_text_formatter.dart';

/// Tex Passport raqami kiritish maydoni
class KaskoTechPassportInput extends StatelessWidget {
  final TextEditingController seriesController;
  final TextEditingController numberController;
  final bool isDark;
  final Color cardBg;
  final Color textColor;
  final Color borderColor;
  final Color placeholderColor;
  final String? Function(String?)? seriesValidator;
  final String? Function(String?)? numberValidator;

  const KaskoTechPassportInput({
    super.key,
    required this.seriesController,
    required this.numberController,
    required this.isDark,
    required this.cardBg,
    required this.textColor,
    required this.borderColor,
    required this.placeholderColor,
    this.seriesValidator,
    this.numberValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'insurance.kasko.document_data.tech_passport'.tr(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: 8.0.h),
        Row(
          children: [
            // 1. Seriya (AAA)
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: seriesController,
                maxLength: 3,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
                validator: seriesValidator,
                decoration: InputDecoration(
                  hintText: 'AAA',
                  hintStyle: TextStyle(color: placeholderColor),
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0.w,
                    vertical: 14.0.h,
                  ),
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0.r),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0.r),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0.r),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0.r),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0.r),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z]')),
                ],
              ),
            ),
            SizedBox(width: 10.0.w),
            // 2. Raqam (1234567)
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: numberController,
                maxLength: 7,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
                validator: numberValidator,
                decoration: InputDecoration(
                  hintText: '1234567',
                  hintStyle: TextStyle(color: placeholderColor),
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0.w,
                    vertical: 14.0.h,
                  ),
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0.r),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0.r),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0.r),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0.r),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0.r),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 15.0.h),
        // Eslatma matni
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 4.0.h),
              child: Text(
                '•',
                style: TextStyle(
                  fontSize: 16.sp,
                  height: 1.0,
                  color: textColor,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'insurance.kasko.document_data.match_info'.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.grey[400]! : Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

