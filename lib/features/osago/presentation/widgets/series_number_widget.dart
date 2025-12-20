import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/upper_case_text_formatter.dart';
import '../../utils/osago_utils.dart';

class SeriesNumberWidget extends StatelessWidget {
  final TextEditingController seriesCtrl;
  final TextEditingController numberCtrl;
  final String seriesHint;
  final String numberHint;
  final bool isTechPassport;
  final bool isLicense;

  const SeriesNumberWidget({
    super.key,
    required this.seriesCtrl,
    required this.numberCtrl,
    required this.seriesHint,
    required this.numberHint,
    this.isTechPassport = false,
    this.isLicense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isTechPassport ? 90.w : (isLicense ? 80.w : 80.w),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: seriesCtrl,
            builder: (context, value, child) {
              return TextFormField(
                controller: seriesCtrl,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                maxLength: isTechPassport ? 3 : (isLicense ? 2 : 2),
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z]')),
                ],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: value.text.isEmpty
                      ? Theme.of(context).hintColor
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  hintText: seriesHint,
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor,
                  ),
                  counterText: "",
                ),
                validator: (v) {
                  if (isLicense) {
                    if (v != null && v.isNotEmpty) {
                      if (!OsagoUtils.isValidPassportSeria(v)) {
                        return 'insurance.osago.vehicle.errors.series_2_letters'
                            .tr();
                      }
                    }
                    return null;
                  }
                  if (v == null || v.isEmpty) {
                    return 'insurance.osago.vehicle.errors.enter_series'.tr();
                  }
                  if (isTechPassport) {
                    if (!OsagoUtils.isValidTechPassportSeria(v)) {
                      return 'insurance.osago.vehicle.errors.series_3_letters'
                          .tr();
                    }
                  } else {
                    if (!OsagoUtils.isValidPassportSeria(v)) {
                      return 'insurance.osago.vehicle.errors.series_2_letters'
                          .tr();
                    }
                  }
                  return null;
                },
              );
            },
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: numberCtrl,
            builder: (context, value, child) {
              return TextFormField(
                controller: numberCtrl,
                keyboardType: TextInputType.number,
                maxLength: 7,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: value.text.isEmpty
                      ? Theme.of(context).hintColor
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  hintText: numberHint,
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor,
                  ),
                  counterText: "",
                ),
                validator: (v) {
                  if (isLicense) {
                    if (v != null && v.isNotEmpty) {
                      if (v.length != 7) {
                        return 'insurance.osago.vehicle.errors.number_7_digits'
                            .tr();
                      }
                      if (!OsagoUtils.isValidPassportNumber(v)) {
                        return 'insurance.osago.vehicle.errors.invalid_number_format'
                            .tr();
                      }
                    }
                    return null;
                  }
                  if (v == null || v.isEmpty) {
                    return 'insurance.osago.vehicle.errors.enter_number_field'
                        .tr();
                  }
                  if (v.length != 7) {
                    return 'insurance.osago.vehicle.errors.number_7_digits'.tr();
                  }
                  if (isTechPassport) {
                    if (!OsagoUtils.isValidTechPassportNumber(v)) {
                      return 'insurance.osago.vehicle.errors.invalid_number_format'
                          .tr();
                    }
                  } else {
                    if (!OsagoUtils.isValidPassportNumber(v)) {
                      return 'insurance.osago.vehicle.errors.invalid_number_format'
                          .tr();
                    }
                  }
                  return null;
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

