import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/locale/locale_prefs.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingLanguagePage extends StatefulWidget {
  const OnboardingLanguagePage({super.key, required this.onSelected});
  final VoidCallback onSelected;

  @override
  State<OnboardingLanguagePage> createState() => _OnboardingLanguagePageState();
}

class _OnboardingLanguagePageState extends State<OnboardingLanguagePage> {
  Locale? _selected;

  final _locales = const [
    Locale('uz'),
    Locale('uz', 'CYR'),
    Locale('ru'),
    Locale('en'),
  ];

  String _labelFor(Locale l) {
    final country = l.countryCode?.toUpperCase();
    if (l.languageCode == 'uz' && country == 'CYR') {
      return 'Ўзбек';
    }
    if (l.languageCode == 'uz') return "O'zbek";
    if (l.languageCode == 'ru') return 'Русский';
    if (l.languageCode == 'en') return 'English';
    return l.toLanguageTag();
  }

  // Локалларни солиштириш учун ёрдамчи функция
  bool _isLocaleEqual(Locale? locale1, Locale locale2) {
    if (locale1 == null) return false;
    return locale1.languageCode == locale2.languageCode &&
        locale1.countryCode == locale2.countryCode;
  }

  String _getCtaText(Locale locale) {
    final country = locale.countryCode?.toUpperCase();
    if (locale.languageCode == 'uz' && country == 'CYR') {
      return 'Танлаш';
    }
    if (locale.languageCode == 'uz') {
      return 'Tanlash';
    }
    if (locale.languageCode == 'ru') {
      return 'Продолжить';
    }
    if (locale.languageCode == 'en') {
      return 'Continue';
    }
    return 'auth.common.cta'.tr();
  }

  @override
  void initState() {
    super.initState();
    // Dastlab foydalanuvchining joriy locale'ini olishga harakat qilamiz.
    _selected = const Locale('en');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Kontekstdagi locale'ni boshlang'ich qiymat sifatida tanlab qo'yamiz
    // Locale o'zgarganda yangilash
    // User request: Default to English always on this screen, do not sync with current locale
    /*
    final currentLocale = context.locale;
    if (_selected == null || !_isLocaleEqual(_selected, currentLocale)) {
      _selected = currentLocale;
      debugPrint('OnboardingLanguagePage: Locale updated: ${currentLocale.languageCode}_${currentLocale.countryCode ?? 'null'}');
    }
    */
  }

  Future<void> _apply() async {
    if (!mounted) return;

    try {
      // Локални текшириш - агар кирилл локали бўлса, тўғри форматда бўлишини текшириш
      final localeToSet = _selected ?? context.locale;
      debugPrint(
        'Onboarding: Changing locale to: ${localeToSet.languageCode}_${localeToSet.countryCode ?? 'null'}',
      );

      // Avval locale'ni saqlaymiz
      await LocalePrefs.save(localeToSet);
      debugPrint(
        'Onboarding: Locale saved: ${localeToSet.languageCode}_${localeToSet.countryCode ?? 'null'}',
      );

      // Keyin locale'ni o'zgartiramiz
      // EasyLocalization xatolikni o'zi boshqaradi, lekin biz yana ham xavfsizlikni ta'minlaymiz
      if (mounted) {
        debugPrint(
          'Onboarding: Setting locale: ${localeToSet.languageCode}_${localeToSet.countryCode ?? 'null'}',
        );

        // Локални текшириш ва ўрнатиш
        try {
          // Кирилл локали учун қўшимча вақт бериш
          if (localeToSet.languageCode == 'uz' && localeToSet.countryCode == 'CYR') {
            await Future.delayed(const Duration(milliseconds: 100));
          }
          await context.setLocale(localeToSet);
          
          // Локалнинг тўғри ўрнатилганини текшириш
          final actualLocale = context.locale;
          debugPrint(
            'Onboarding: Locale set successfully: ${localeToSet.languageCode}_${localeToSet.countryCode ?? 'null'}',
          );
          debugPrint(
            'Onboarding: Actual locale after set: ${actualLocale.languageCode}_${actualLocale.countryCode ?? 'null'}',
          );
          
          // Локалнинг мос келишини текшириш
          if (actualLocale.languageCode != localeToSet.languageCode ||
              actualLocale.countryCode != localeToSet.countryCode) {
            debugPrint('Onboarding: WARNING: Locale mismatch! Expected: ${localeToSet.languageCode}_${localeToSet.countryCode ?? 'null'}, Got: ${actualLocale.languageCode}_${actualLocale.countryCode ?? 'null'}');
          }

          // Таржима файлини текшириш
          try {
            final testTranslation = tr('app_title');
            debugPrint('Onboarding: Translation test: app_title = $testTranslation');
          } catch (e) {
            debugPrint('Onboarding: Translation error: $e');
            // Таржима хатоси бўлса ҳам, локал ўрнатилди, шунинг учун давом этиш
          }
        } catch (setLocaleError) {
          debugPrint('Onboarding: Error setting locale: $setLocaleError');
          // Агар локални ўрнатишда хато бўлса, fallback локални ишлатиш
          if (mounted) {
            try {
              // Кирилл локали учун алохида ишлаш
              if (localeToSet.languageCode == 'uz' &&
                  localeToSet.countryCode == 'CYR') {
                // Кирилл локали учун қайта уриниш
                await Future.delayed(const Duration(milliseconds: 200));
                await context.setLocale(localeToSet);
                debugPrint('Onboarding: Cyrillic locale set after retry');
              } else {
                // Бошқа локаллар учун fallback
                await context.setLocale(const Locale('en'));
                debugPrint('Onboarding: Fallback to English locale');
              }
            } catch (fallbackError) {
              debugPrint('Onboarding: Fallback locale error: $fallbackError');
              // Хатолик бўлса ҳам, локал сақланди, шунинг учун давом этиш
            }
          }
        }

        // Locale yuklanishini kutish uchun kichik kechikish
        // Bu vaqt ichida barcha widget'lar qayta build bo'lishi uchun
        // Кирилл локали учун қўшимча вақт бериш
        if (localeToSet.languageCode == 'uz' && localeToSet.countryCode == 'CYR') {
          await Future.delayed(const Duration(milliseconds: 300));
        } else {
          await Future.delayed(const Duration(milliseconds: 200));
        }
        
        // Locale'ning тўғри ўрнатилганини текшириш
        if (mounted) {
          final finalLocale = context.locale;
          debugPrint('Onboarding: Final locale before navigation: ${finalLocale.languageCode}_${finalLocale.countryCode ?? 'null'}');
          
          // Локалнинг мос келишини яна бир бор текшириш
          if (finalLocale.languageCode != localeToSet.languageCode ||
              finalLocale.countryCode != localeToSet.countryCode) {
            debugPrint('Onboarding: WARNING: Final locale mismatch! Expected: ${localeToSet.languageCode}_${localeToSet.countryCode ?? 'null'}, Got: ${finalLocale.languageCode}_${finalLocale.countryCode ?? 'null'}');
            // Агар локал мос келмаса, қайта уриниш
            if (mounted) {
              try {
                await context.setLocale(localeToSet);
                debugPrint('Onboarding: Retry setLocale successful');
              } catch (e) {
                debugPrint('Onboarding: Retry setLocale failed: $e');
              }
            }
          }
          
          // Qo'shimcha rebuild uchun bir marta setState chaqirish
          // Bu parent widget'ga locale o'zgarganini bildiradi
          if (mounted) {
            widget.onSelected();
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Onboarding: Error in locale apply: $e');
      debugPrint('Onboarding: Stack trace: $stackTrace');
      // Хатолик бўлса ҳам, локал сақланди ва давом этиш
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 200));
        widget.onSelected();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF0A93F6); // ko'k rang (designga yaqin)
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenWidth < 360;
    final isLargeScreen = screenWidth > 600;

    // Responsive values
    final horizontalPadding = isSmallScreen
        ? 16.0
        : (isLargeScreen ? 32.0 : 24.0);
    final topSpacing = isSmallScreen ? 60.0 : (isLargeScreen ? 100.0 : 80.0);
    final logoHeight = isSmallScreen ? 48.0 : (isLargeScreen ? 64.0 : 56.0);
    final logoFontSize = isSmallScreen ? 32.0 : (isLargeScreen ? 40.0 : 36.0);
    final logoDotSize = isSmallScreen ? 7.0 : (isLargeScreen ? 9.0 : 8.0);
    final cardSpacing = isSmallScreen ? 10.0 : 12.0;
    final cardBorderRadius = isSmallScreen ? 14.0 : 16.0;
    final titleFontSize = isSmallScreen ? 15.0 : (isLargeScreen ? 18.0 : 16.0);
    final buttonHeight = isSmallScreen ? 44.0 : (isLargeScreen ? 52.0 : 48.0);
    final buttonBorderRadius = isSmallScreen ? 12.0 : 14.0;
    final bottomSpacing = 20.0;
    final middleSpacing = isSmallScreen ? 24.0 : (isLargeScreen ? 40.0 : 32.0);
    final buttonSpacing = isSmallScreen ? 12.0 : 16.0;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final totalBottomPadding = bottomPadding > 0 ? bottomPadding + 20.0 : 20.0;

    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          bottom: totalBottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: topSpacing),
            Center(
              child: SizedBox(
                height: logoHeight,
                child: SvgPicture.asset(
                  'assets/images/klero_logo.svg',
                  fit: BoxFit.contain,
                  placeholderBuilder: (context) => RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: logoFontSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      children: [
                        const TextSpan(text: 'K'),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: SizedBox(
                            width: logoDotSize,
                            height: logoDotSize,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: 'LiRO'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: middleSpacing),
            Expanded(
              child: ListView.separated(
                itemCount: _locales.length,
                separatorBuilder: (_, __) => SizedBox(height: cardSpacing),
                itemBuilder: (context, i) {
                  final l = _locales[i];
                  final isSelected = _isLocaleEqual(_selected, l);
                  return Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cardBorderRadius),
                      side: BorderSide(
                        color: isSelected
                            ? primary
                            : Colors.black.withOpacity(0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: RadioListTile<Locale>(
                      value: l,
                      groupValue: _selected,
                      onChanged: (v) {
                        setState(() {
                          _selected = v;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: primary,
                      fillColor: MaterialStateProperty.resolveWith<Color>((
                        Set<MaterialState> states,
                      ) {
                        if (states.contains(MaterialState.selected)) {
                          return primary;
                        }
                        return Colors.black;
                      }),
                      title: Text(
                        _labelFor(l),
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      secondary: _FlagBadge(
                        assetPath: _flagAsset(l),
                        emoji: _flagEmoji(l),
                        isSmallScreen: isSmallScreen,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: buttonSpacing),
            SizedBox(
              height: buttonHeight,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonBorderRadius),
                  ),
                ),
                child: Text(_getCtaText(_selected ?? context.locale)),
              ),
            ),
            SizedBox(height: bottomSpacing),
          ],
        ),
      ),
    );
  }

  String _flagEmoji(Locale l) {
    if (l.languageCode == 'ru') return '🇷🇺';
    if (l.languageCode == 'en') return '🇬🇧';
    return '🇺🇿';
  }

  String? _flagAsset(Locale l) {
    if (l.languageCode == 'uz') {
      return 'assets/images/uzb.svg';
    }
    if (l.languageCode == 'ru') {
      return 'assets/images/rus.svg';
    }
    if (l.languageCode == 'en') {
      return 'assets/images/brinatya.svg';
    }
    return null;
  }
}

class _FlagBadge extends StatelessWidget {
  const _FlagBadge({
    required this.emoji,
    this.assetPath,
    this.isSmallScreen = false,
  });

  final String? assetPath;
  final String emoji;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final badgeSize = isSmallScreen ? 28.0 : 32.0;
    final emojiSize = isSmallScreen ? 20.0 : 24.0;

    return ClipOval(
      child: Container(
        width: badgeSize,
        height: badgeSize,
        alignment: Alignment.center,
        child: assetPath != null
            ? SvgPicture.asset(assetPath!, fit: BoxFit.cover)
            : Text(emoji, style: TextStyle(fontSize: emojiSize)),
      ),
    );
  }
}
