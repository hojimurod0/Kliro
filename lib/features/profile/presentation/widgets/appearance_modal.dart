import 'dart:ui'; // BackdropFilter uchun
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/services/theme/theme_controller.dart';

// Asosiy ranglar
const Color kPrimaryBlue = Color(0xFF007AFF); // Moviy (ko'k) rang

const Color kScaffoldBgColor = Color.fromARGB(
  67,
  0,
  5,
  156,
); // Umumiy och kulrang fon

const Color kModalBgColor = Color.fromARGB(
  59,
  6,
  32,
  91,
); // Umumiy modal fon rangi (yengil kulrang)

const Color kUnselectedBgColor = Color.fromARGB(
  68,
  22,
  19,
  72,
); // Tanlanmagan elementning oq foni

const Color kSelectedBgColor = kPrimaryBlue; // Tanlangan elementning moviy foni

const Color kUnselectedTextColor = Color(0xFFFFFFFF); // Tanlanmagan matn rangi (oq)

const Color kSelectedTextColor = Color(0xFFFFFFFF); // Tanlangan matn rangi

const Color kSecondaryTextColor = Color.fromARGB(
  255,
  217,
  214,
  214,
); // Kichik yordamchi matn rangi

void showAppearanceModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // To'liq balandlikda bo'lishi uchun
    backgroundColor: Colors.transparent, // Orqa fonni shaffof qilish
    barrierColor:
        Colors.transparent, // Modalni o'rab turgan rangni ham shaffof qilish
    builder: (BuildContext context) {
      // BackdropFilter orqali xiralashgan fonni ta'minlaymiz
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur effekti
        child: const AppearanceActionSheet(),
      );
    },
  );
}

// ----------------------------------------------------------------------
// 1. Asosiy Action Sheet Widgeti
class AppearanceActionSheet extends StatefulWidget {
  const AppearanceActionSheet({super.key});

  @override
  State<AppearanceActionSheet> createState() => _AppearanceActionSheetState();
}

class _AppearanceActionSheetState extends State<AppearanceActionSheet> {
  late ThemeMode _currentMode;

  @override
  void initState() {
    super.initState();
    _currentMode = ThemeController.instance.mode;
    // ThemeController o'zgarishlarini kuzatish
    ThemeController.instance.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeController.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {
        _currentMode = ThemeController.instance.mode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    // Konteynerning balandligini ekranning pastki qismiga mahkamlash
    return SizedBox(
      height: screenHeight,
      child: Column(
        children: [
          // Yuqori qismdagi bo'sh joy (Blur effekti fonni xiralashtiradi)
          const Spacer(),

          // Asosiy Kontent (Oq-kulrang blok)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: const BoxDecoration(
              color: kModalBgColor, // Yengil kulrang fon
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ), // Katta yumaloq burchak
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tutqich (Handlebar)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Container(
                    width: 40.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: kSecondaryTextColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2.5.r),
                    ),
                  ),
                ),

                // Tashqi ko'rinish sarlavhasi
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: const Text(
                    "Tashqi ko'rinish",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                // 2. Variantlar guruhi (Yorug', Qorong'i, Avtomatik)
                _buildOptionGroup(),

                SizedBox(height: 10.h),

                // 3. Yopish tugmasi
                _buildCloseButton(context, bottomPadding),

                SizedBox(height: bottomPadding), // iOS safe area
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Variantlar guruhi uchun yordamchi widget
  Widget _buildOptionGroup() {
    return Column(
      children: [
        _buildOptionItem(
          icon: Icons.wb_sunny_outlined,
          title: "Yorug'",
          subtitle: "Yorug' rejim",
          mode: ThemeMode.light,
          isFirst: true,
        ),
        SizedBox(height: 15.h),
        _buildOptionItem(
          icon: Icons.mode_night_outlined,
          title: "Qorong'i",
          subtitle: "Qorong'i rejim",
          mode: ThemeMode.dark,
          isMiddle: true,
        ),
        SizedBox(height: 15.h),
        _buildOptionItem(
          icon: Icons.phone_android_outlined,
          title: "Avtomatik",
          subtitle: "Tizim sozlamalari",
          mode: ThemeMode.system,
          isLast: true,
        ),
      ],
    );
  }

  // 3. Har bir variant elementi uchun yordamchi widget
  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeMode mode,
    bool isFirst = false,
    bool isMiddle = false,
    bool isLast = false,
  }) {
    final bool isSelected = _currentMode == mode;

    // Tanlangan variant uchun maxsus stil
    Color bgColor = isSelected ? kSelectedBgColor : kModalBgColor;
    Color titleColor = isSelected ? kSelectedTextColor : Colors.white;
    Color subtitleColor = isSelected ? kSelectedTextColor : Colors.white;

    return InkWell(
      onTap: () {
        // Rejimni o'zgartirish funksiyasi
        ThemeController.instance.setMode(mode);
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: bgColor,
          // Tanlangan elementni to'liq yumaloq qilish uchun
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: isSelected ? kSelectedTextColor : kPrimaryBlue,
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 4. Yopish tugmasi
  Widget _buildCloseButton(BuildContext context, double bottomPadding) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Modalni yopish
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: 10.h,
          top: 10.h,
        ), // Yuqoridan va pastdan masofa
        height: 50.h,
        decoration: BoxDecoration(
          color: kUnselectedBgColor, // Oq fon
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Center(
          child: Text(
            "Yopish",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: kPrimaryBlue, // Moviy rang
            ),
          ),
        ),
      ),
    );
  }
}

