import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/car_plate_formatter.dart';

/// Avtomobil raqami kiritish maydoni (Plita ko'rinishi)
class KaskoCarPlateInput extends StatelessWidget {
  final TextEditingController regionController;
  final TextEditingController numberController;
  final bool isDark;
  final Color cardBg;
  final Color textColor;
  final String? Function(String?)? regionValidator;
  final String? Function(String?)? numberValidator;

  const KaskoCarPlateInput({
    super.key,
    required this.regionController,
    required this.numberController,
    required this.isDark,
    required this.cardBg,
    required this.textColor,
    this.regionValidator,
    this.numberValidator,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? Colors.grey[600]! : Colors.black;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'insurance.kasko.document_data.car_number'.tr(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: 8.0.h),
        // Asosiy plita Container
        Container(
          height: 60.h,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10.0.r),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Viloyat kodi (01)
              Container(
                width: 60.w,
                height: 60.h,
                child: Center(
                  child: TextFormField(
                    controller: regionController,
                    textAlign: TextAlign.center,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    validator: regionValidator,
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                  ),
                ),
              ),
              // 2. Raqam qismi (A 000 AA)
              Expanded(
                child: Container(
                  height: 60.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                  child: Center(
                    child: TextFormField(
                      controller: numberController,
                      textAlign: TextAlign.center,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 8,
                      validator: numberValidator,
                      decoration: InputDecoration(
                        hintText: 'A 000 AA',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[600]! : Colors.grey,
                        ),
                        counterText: '',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                      inputFormatters: [
                        CarPlateFormatter(),
                        LengthLimitingTextInputFormatter(8), // A 000 AA = 8 belgi
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.0.h),
      ],
    );
  }
}

