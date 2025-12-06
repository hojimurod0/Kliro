import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/upper_case_text_formatter.dart';

class LicensePlateWidget extends StatelessWidget {
  final TextEditingController regionCtrl;
  final TextEditingController numberCtrl;

  const LicensePlateWidget({
    super.key,
    required this.regionCtrl,
    required this.numberCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = theme.cardColor;
    final textColor =
        theme.textTheme.titleLarge?.color ??
        (isDark ? Colors.white : Colors.black);

    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 60.w,
            alignment: Alignment.center,
            child: TextFormField(
              controller: regionCtrl,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              maxLength: 2,
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              validator: (v) => v!.isEmpty
                  ? 'insurance.osago.vehicle.errors.enter_region'.tr()
                  : null,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: TextFormField(
                controller: numberCtrl,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                maxLength: 8,
                decoration: InputDecoration(
                  hintText: "A 000 AA",
                  hintStyle: TextStyle(
                    color: theme.hintColor,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9\s]')),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'insurance.osago.vehicle.errors.enter_number'.tr();
                  }
                  final cleanNumber = v.replaceAll(' ', '').toUpperCase();
                  if (cleanNumber.length < 6) {
                    return 'insurance.osago.vehicle.errors.invalid_number'.tr();
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

