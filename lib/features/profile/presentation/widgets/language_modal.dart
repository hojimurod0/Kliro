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
    // Locale o'zgarganda yangilash
    final currentLocale = context.locale;
    if (_selectedLocale == null ||
        !_isLocaleEqual(_selectedLocale!, currentLocale)) {
      _selectedLocale = currentLocale;
      debugPrint(
        'LanguageModal: Locale updated: ${currentLocale.languageCode}_${currentLocale.countryCode ?? 'null'}',
      );
    }
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
    // Ensure locale is initialized and updated
    final currentLocale = context.locale;
    if (_selectedLocale == null ||
        !_isLocaleEqual(_selectedLocale, currentLocale)) {
      _selectedLocale = currentLocale;
      debugPrint(
        'LanguageModal.build: Locale initialized/updated: ${currentLocale.languageCode}_${currentLocale.countryCode ?? 'null'}',
      );
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

  // Локалларни солиштириш учун ёрдамчи функция
  bool _isLocaleEqual(Locale? locale1, Locale locale2) {
    if (locale1 == null) return false;
    return locale1.languageCode == locale2.languageCode &&
        locale1.countryCode == locale2.countryCode;
  }

  // 3. Har bir variant elementi uchun yordamchi widget
  Widget _buildOptionItem({
    required Locale locale,
    bool isFirst = false,
    bool isMiddle = false,
    bool isLast = false,
  }) {
    final bool isSelected = _isLocaleEqual(_selectedLocale, locale);

    // Tanlangan variant uchun maxsus stil
    Color bgColor = isSelected ? kSelectedBgColor : kUnselectedBgColor;
    Color titleColor = Colors.white; // Barcha matnlar oq

    return InkWell(
      onTap: () async {
        // Tilni o'zgartirish funksiyasi
        if (!mounted) return;

        try {
          // Локални текшириш - агар кирилл локали бўлса, тўғри форматда бўлишини текшириш
          final localeToSet = locale;
          debugPrint(
            'Changing locale to: ${localeToSet.languageCode}_${localeToSet.countryCode ?? 'null'}',
          );

          // Avval locale'ni saqlaymiz
          await LocalePrefs.save(localeToSet);
          debugPrint(
            'Locale saved: ${localeToSet.languageCode}_${localeToSet.countryCode ?? 'null'}',
          );

          // Keyin locale'ni o'zgartiramiz
          // EasyLocalization xatolikni o'zi boshqaradi, lekin biz yana ham xavfsizlikni ta'minlaymiz
          if (mounted) {
            debugPrint(
              'Setting locale: ${localeToSet.languageCode}_${localeToSet.countryCode ?? 'null'}',
            );

            // Локални текшириш ва ўрнатиш
            try {
              // Кирилл локали учун қўшимча вақт бериш
              if (localeToSet.languageCode == 'uz' &&
                  localeToSet.countryCode == 'CYR') {
                debugPrint(
                  'LanguageModal: Cyrillic locale detected, adding delay...',
                );
                await Future.delayed(const Duration(milliseconds: 200));
              }

              // Локални ўрнатиш
              debugPrint('LanguageModal: Calling setLocale...');
              await context.setLocale(localeToSet);

              // Кирилл локали учун қўшимча вақт бериш (setLocale дан кейин)
              if (localeToSet.languageCode == 'uz' &&
                  localeToSet.countryCode == 'CYR') {
                await Future.delayed(const Duration(milliseconds: 150));
              }

              // Локалнинг тўғри ўрнатилганини текшириш
              final actualLocale = context.locale;
              debugPrint(
                'Locale set successfully: ${localeToSet.languageCode}_${localeToSet.countryCode ?? 'null'}',
              );
              debugPrint(
                'Actual locale after set: ${actualLocale.languageCode}_${actualLocale.countryCode ?? 'null'}',
              );

              // Локалнинг мос келишини текшириш
              if (actualLocale.languageCode != localeToSet.languageCode ||
                  actualLocale.countryCode != localeToSet.countryCode) {
                debugPrint(
                  'WARNING: Locale mismatch! Expected: ${localeToSet.languageCode}_${localeToSet.countryCode ?? 'null'}, Got: ${actualLocale.languageCode}_${actualLocale.countryCode ?? 'null'}',
                );

                // Агар локал мос келмаса, қайта уриниш
                if (mounted) {
                  debugPrint('LanguageModal: Retrying setLocale...');
                  try {
                    if (localeToSet.languageCode == 'uz' &&
                        localeToSet.countryCode == 'CYR') {
                      await Future.delayed(const Duration(milliseconds: 200));
                    }
                    await context.setLocale(localeToSet);
                    final retryLocale = context.locale;
                    debugPrint(
                      'LanguageModal: Retry locale: ${retryLocale.languageCode}_${retryLocale.countryCode ?? 'null'}',
                    );
                  } catch (e) {
                    debugPrint('LanguageModal: Retry failed: $e');
                  }
                }
              }

              // Таржима файлини текшириш
              try {
                final testTranslation = tr('app_title');
                debugPrint('Translation test: app_title = $testTranslation');
              } catch (e) {
                debugPrint('Translation error: $e');
                // Таржима хатоси бўлса ҳам, локал ўрнатилди, шунинг учун давом этиш
              }
            } catch (setLocaleError) {
              debugPrint('Error setting locale: $setLocaleError');
              // Агар локални ўрнатишда хато бўлса, fallback локални ишлатиш
              if (mounted) {
                try {
                  // Кирилл локали учун алохида ишлаш
                  if (localeToSet.languageCode == 'uz' &&
                      localeToSet.countryCode == 'CYR') {
                    // Кирилл локали учун қайта уриниш
                    debugPrint('LanguageModal: Retrying Cyrillic locale...');
                    await Future.delayed(const Duration(milliseconds: 200));
                    await context.setLocale(localeToSet);

                    // Яна бир бор текшириш
                    await Future.delayed(const Duration(milliseconds: 100));
                    final retryLocale = context.locale;
                    debugPrint(
                      'LanguageModal: Cyrillic locale after retry: ${retryLocale.languageCode}_${retryLocale.countryCode ?? 'null'}',
                    );

                    if (retryLocale.languageCode != localeToSet.languageCode ||
                        retryLocale.countryCode != localeToSet.countryCode) {
                      debugPrint(
                        'LanguageModal: Cyrillic locale still not matching, trying one more time...',
                      );
                      await Future.delayed(const Duration(milliseconds: 200));
                      await context.setLocale(localeToSet);
                    }
                  } else {
                    // Бошқа локаллар учун fallback
                    await context.setLocale(const Locale('en'));
                    debugPrint('Fallback to English locale');
                  }
                } catch (fallbackError) {
                  debugPrint('Fallback locale error: $fallbackError');
                  // Хатолик бўлса ҳам, локал сақланди, шунинг учун давом этиш
                }
              }
            }

            if (mounted) {
              setState(() {
                _selectedLocale = localeToSet;
              });

              debugPrint('LanguageModal: Locale changed, closing modal');

              // Кирилл локали учун қўшимча вақт бериш (модал ёпилишидан олдин)
              if (localeToSet.languageCode == 'uz' &&
                  localeToSet.countryCode == 'CYR') {
                debugPrint(
                  'LanguageModal: Cyrillic locale - adding extra delay before closing modal',
                );
                await Future.delayed(const Duration(milliseconds: 200));

                // Яна бир бор локални текшириш ва қўллаш
                final checkLocale = context.locale;
                if (checkLocale.languageCode != localeToSet.languageCode ||
                    checkLocale.countryCode != localeToSet.countryCode) {
                  debugPrint(
                    'LanguageModal: Cyrillic locale not applied, retrying...',
                  );
                  await context.setLocale(localeToSet);
                  await Future.delayed(const Duration(milliseconds: 100));
                }
              }

              // Modalni yopish
              Navigator.pop(context);

              // Qo'shimcha rebuild uchun - bu barcha widget'larni yangilash uchun
              // Locale o'zgarganda MaterialApp qayta build bo'lishi uchun
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (mounted) {
                  // Locale o'zgarganini tasdiqlash
                  try {
                    // Кирилл локали учун қўшимча вақт бериш
                    if (localeToSet.languageCode == 'uz' &&
                        localeToSet.countryCode == 'CYR') {
                      await Future.delayed(const Duration(milliseconds: 100));
                    }

                    final finalLocale = context.locale;
                    debugPrint(
                      'LanguageModal: Final locale after modal close: ${finalLocale.languageCode}_${finalLocale.countryCode ?? 'null'}',
                    );

                    // Агар локал мос келмаса, қайта уриниш
                    if (finalLocale.languageCode != localeToSet.languageCode ||
                        finalLocale.countryCode != localeToSet.countryCode) {
                      debugPrint(
                        'LanguageModal: Locale still not matching, retrying setLocale...',
                      );
                      try {
                        await context.setLocale(localeToSet);
                        await Future.delayed(const Duration(milliseconds: 100));
                        final retryLocale = context.locale;
                        debugPrint(
                          'LanguageModal: Retry locale: ${retryLocale.languageCode}_${retryLocale.countryCode ?? 'null'}',
                        );
                      } catch (e) {
                        debugPrint('LanguageModal: Retry setLocale failed: $e');
                      }
                    }
                  } catch (e) {
                    debugPrint(
                      'LanguageModal: Error checking final locale: $e',
                    );
                  }
                }
              });
            }
          }
        } catch (e, stackTrace) {
          debugPrint('Error in locale change: $e');
          debugPrint('Stack trace: $stackTrace');

          // Xatolik bo'lsa, locale'ni saqlash ва qayta urinish
          if (mounted) {
            try {
              // Locale'ni yana saqlashga harakat qilamiz
              await LocalePrefs.save(locale);

              // setLocale'ni yana chaqirishga harakat qilamiz
              if (mounted) {
                // Кирилл локали учун қўшимча вақт бериш
                if (locale.languageCode == 'uz' &&
                    locale.countryCode == 'CYR') {
                  await Future.delayed(const Duration(milliseconds: 200));
                }
                await context.setLocale(locale);
                debugPrint('Locale set after error retry');
              }
            } catch (e2) {
              // Agar yana xatolik bo'lsa, debug uchun log qilamiz
              debugPrint('Locale o\'zgartirishda xatolik: $e2');
              // Хатолик бўлса ҳам, локал сақланди ва UI ни янгилаш керак
            }

            if (mounted) {
              setState(() {
                _selectedLocale = locale;
              });

              // Modalni yopish (xatolik bo'lsa ham)
              Navigator.pop(context);
            }
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
