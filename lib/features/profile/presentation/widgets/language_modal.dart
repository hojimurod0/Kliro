import 'dart:ui'; // BackdropFilter uchun
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/services/locale/locale_prefs.dart';

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

const Color kUnselectedTextColor = Color(
  0xFFFFFFFF,
); // Tanlanmagan matn rangi (oq)

const Color kSelectedTextColor = Color(0xFFFFFFFF); // Tanlangan matn rangi

const Color kSecondaryTextColor = Color.fromARGB(
  255,
  217,
  214,
  214,
); // Kichik yordamchi matn rangi

Future<void> showLanguageModal(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true, // To'liq balandlikda bo'lishi uchun
    backgroundColor: Colors.transparent, // Orqa fonni shaffof qilish
    barrierColor:
        Colors.transparent, // Modalni o'rab turgan rangni ham shaffof qilish
    builder: (BuildContext context) {
      // BackdropFilter orqali xiralashgan fonni ta'minlaymiz
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur effekti
        child: const LanguageActionSheet(),
      );
    },
  );
}

// ----------------------------------------------------------------------
// 1. Asosiy Action Sheet Widgeti (Til tanlash)
class LanguageActionSheet extends StatefulWidget {
  const LanguageActionSheet({super.key});

  @override
  State<LanguageActionSheet> createState() => _LanguageActionSheetState();
}

class _LanguageActionSheetState extends State<LanguageActionSheet> {
  Locale? _selectedLocale;

  final List<Locale> _locales = const [
    Locale('uz'), // O'zbekcha (Lotin)
    Locale('uz', 'CYR'), // Кирилл
    Locale('ru'), // Русский
    Locale('en'), // English
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLocale ??= context.locale;
  }

  String _getLanguageTitle(Locale locale) {
    if (locale.languageCode == 'uz' && locale.countryCode == 'CYR') {
      return "O'zbek (Kirill)";
    }
    if (locale.languageCode == 'uz') {
      return "O'zbek";
    }
    if (locale.languageCode == 'ru') {
      return "Русский";
    }
    if (locale.languageCode == 'en') {
      return "English";
    }
    return locale.toLanguageTag();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure locale is initialized
    if (_selectedLocale == null) {
      _selectedLocale = context.locale;
    }

    final double screenHeight = MediaQuery.of(context).size.height;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    // Konteynerning balandligini ekranning pastki qismiga mahkamlash
    return SizedBox(
      height: screenHeight,
      child: Column(
        children: [
          // Yuqori qismdagi bo'sh joy (Blur effekti fonni xiralashtiradi)
          const Spacer(),

          // Asosiy Kontent (Qorong'i-kulrang blok)
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

                // 2. Variantlar guruhi (4ta til)
                _buildOptionGroup(),

                SizedBox(
                  height: bottomPadding + 25.0,
                ), // iOS safe area + дополнительный отступ
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
          locale: _locales[0], // O'zbekcha (Lotin)
          isFirst: true,
        ),
        SizedBox(height: 15.h),
        _buildOptionItem(
          locale: _locales[1], // Ўзбек
          isMiddle: true,
        ),
        SizedBox(height: 15.h),
        _buildOptionItem(
          locale: _locales[2], // Русский
          isMiddle: true,
        ),
        SizedBox(height: 15.h),
        _buildOptionItem(
          locale: _locales[3], // English
          isLast: true,
        ),
      ],
    );
  }

  // 3. Har bir variant elementi uchun yordamchi widget
  Widget _buildOptionItem({
    required Locale locale,
    bool isFirst = false,
    bool isMiddle = false,
    bool isLast = false,
  }) {
    final bool isSelected =
        _selectedLocale != null && _selectedLocale == locale;

    // Tanlangan variant uchun maxsus stil
    Color bgColor = isSelected ? kSelectedBgColor : kUnselectedBgColor;
    Color titleColor = Colors.white; // Barcha matnlar oq

    return InkWell(
      onTap: () async {
        // Tilni o'zgartirish funksiyasi
        try {
          // Avval locale'ni saqlaymiz
          await LocalePrefs.save(locale);
          // Keyin locale'ni o'zgartiramiz
          await context.setLocale(locale);
          if (mounted) {
            setState(() {
              _selectedLocale = locale;
            });
            Navigator.pop(context);
            // Profile page ni yangilash uchun
            if (mounted) {
              setState(() {});
            }
          }
        } catch (e) {
          // Xatolik bo'lsa, faqat locale'ni saqlaymiz va qayta urinamiz
          await LocalePrefs.save(locale);
          try {
            await context.setLocale(locale);
          } catch (_) {}
          if (mounted) {
            setState(() {
              _selectedLocale = locale;
            });
            Navigator.pop(context);
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: bgColor,
          // Tanlangan elementni to'liq yumaloq qilish uchun
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Center(
          child: Text(
            _getLanguageTitle(locale),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
        ),
      ),
    );
  }
}
