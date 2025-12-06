import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const Color _primaryBlue = Color(0xFF1976D2);

/// Passport raqami kiritish maydoni (faqat raqam, seriya kerak emas)
class KaskoPassportInput extends StatelessWidget {
  final TextEditingController numberController;
  final bool isDark;
  final Color cardBg;
  final Color textColor;
  final Color borderColor;
  final Color placeholderColor;
  final String? Function(String?)? numberValidator;

  const KaskoPassportInput({
    super.key,
    required this.numberController,
    required this.isDark,
    required this.cardBg,
    required this.textColor,
    required this.borderColor,
    required this.placeholderColor,
    this.numberValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Паспорт раками',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        SizedBox(height: 8.0.h),
        TextFormField(
          controller: numberController,
          maxLength: 7,
          keyboardType: TextInputType.number,
          style: TextStyle(color: textColor, fontSize: 16.sp),
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
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0.r),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0.r),
              borderSide: const BorderSide(
                color: _primaryBlue,
                width: 1.5,
              ),
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        SizedBox(height: 20.0.h),
      ],
    );
  }
}

