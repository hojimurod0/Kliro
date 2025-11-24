import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSpacing {
  const AppSpacing._();

  static double get xxs => 4.h;
  static double get xs => 8.h;
  static double get sm => 12.h;
  static double get md => 16.h;
  static double get lg => 20.h;
  static double get xl => 24.h;
  static double get xxl => 32.h;

  static EdgeInsets get screenPadding => EdgeInsets.symmetric(horizontal: 24.w);
}

