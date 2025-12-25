import 'package:flutter_screenutil/flutter_screenutil.dart';

/// App'da ishlatiladigan barcha text size'lar uchun markazlashtirilgan utility class
/// Ipoteka page'dagi text size'lar asosida yaratilgan
class AppTextSize {
  AppTextSize._(); // Private constructor to prevent instantiation

  // AppBar & Headers
  static double get appBarTitle => 17.sp;
  static double get filterTitle => 18.sp;
  static double get sectionHeader => 15.sp;

  // Heading sizes
  static double get headingXL => 24.sp;
  static double get headingL => 20.sp;
  static double get headingM => 18.sp;
  static double get headingS => 16.sp;

  // Body sizes
  static double get bodyLarge => 16.sp;
  static double get bodyMedium => 14.sp;
  static double get bodySmall => 13.sp;
  static double get bodyPrimary => 13.sp;
  static double get bodySecondary => 12.sp;

  // Label sizes
  static double get labelLarge => 14.sp;
  static double get labelMedium => 12.sp;
  static double get labelSmall => 12.sp;

  // Button sizes
  static double get buttonLarge => 16.sp;
  static double get buttonMedium => 14.sp;
  static double get buttonSmall => 12.sp;
  static double get buttonPrimary => 16.sp;
  static double get buttonLink => 12.sp;
  static double get googleButton => 13.sp;

  // Caption & Small text
  static double get caption => 11.sp;
  static double get small => 10.sp;
  static double get tiny => 9.sp;

  // Chip & Badge
  static double get chip => 14.sp;
  static double get badge => 10.sp;

  // Divider text
  static double get divider => 12.sp;

  // Info items (Ipoteka page'dan)
  static double get infoLabel => 12.sp; // Info item label
  static double get infoValue => 16.sp; // Info item value
  static double get advantagesCount => 14.sp; // Advantages section title
  static double get advantagesItem => 13.sp; // Advantages list item
}
