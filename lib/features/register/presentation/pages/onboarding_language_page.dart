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
  bool _isApplying = false; // IMPORTANT: _apply() faqat bir marta chaqirilishini ta'minlash uchun

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

  String _getCtaText(Locale? selectedLocale) {
    // Default til English bo'lgani uchun, har doim selectedLocale mavjud
    if (selectedLocale == null) {
      return 'Continue'; // Fallback - default English
    }
    
    // Agar til tanlangan bo'lsa, tanlangan til bo'yicha ko'rsatiladi
    final country = selectedLocale.countryCode?.toUpperCase();
    if (selectedLocale.languageCode == 'uz' && country == 'CYR') {
      return 'Танлаш';
    }
    if (selectedLocale.languageCode == 'uz') {
      return 'Tanlash';
    }
    if (selectedLocale.languageCode == 'ru') {
      return 'Продолжить';
    }
    if (selectedLocale.languageCode == 'en') {
      return 'Continue';
    }
    return 'Continue'; // Default English
  }

  @override
  void initState() {
    super.initState();
    // IMPORTANT: Saqlangan tilni yuklab, default qilib o'rnatish
    _loadSavedLocale();
  }

  // Saqlangan tilni yuklash
  Future<void> _loadSavedLocale() async {
    try {
      final savedLocale = await LocalePrefs.load();
      if (savedLocale != null && mounted) {
        setState(() {
          _selected = savedLocale;
        });
        debugPrint('OnboardingLanguagePage: Loaded saved locale: ${savedLocale.languageCode}_${savedLocale.countryCode ?? 'null'}');
      } else {
        // Saqlangan til yo'q - default English
        if (mounted) {
          setState(() {
            _selected = const Locale('en');
          });
          debugPrint('OnboardingLanguagePage: No saved locale, default set to: en (English)');
        }
      }
    } catch (e) {
      debugPrint('OnboardingLanguagePage: Error loading saved locale: $e');
      // Xatolik bo'lsa, default English
      if (mounted) {
        setState(() {
          _selected = const Locale('en');
        });
      }
    }
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
    
    // IMPORTANT: _apply() faqat bir marta chaqirilishini ta'minlash
    if (_isApplying) {
      debugPrint('OnboardingLanguagePage: _apply() already in progress, skipping...');
      return;
    }
    
    // IMPORTANT: Flag'ni setState() da yangilash - UI yangilanishi uchun
    if (mounted) {
      setState(() {
        _isApplying = true;
      });
    }
    
    // IMPORTANT: Default til English, lekin agar null bo'lsa, English'ga o'rnatamiz
    if (_selected == null) {
      _selected = const Locale('en');
      if (mounted) {
        setState(() {});
      }
    }

    try {
      final localeToSet = _selected!;
      debugPrint(
        'Onboarding: Changing locale to: ${localeToSet.languageCode}_${localeToSet.countryCode ?? 'null'}',
      );

      // Avval locale'ni saqlaymiz
      await LocalePrefs.save(localeToSet);
      debugPrint(
        'Onboarding: Locale saved: ${localeToSet.languageCode}_${localeToSet.countryCode ?? 'null'}',
      );

      // Keyin locale'ni o'zgartiramiz
      if (mounted) {
        await context.setLocale(localeToSet);
        debugPrint(
          'Onboarding: Locale set: ${localeToSet.languageCode}_${localeToSet.countryCode ?? 'null'}',
        );

        // Translation delegate'ni yuklash
        final easyLocalization = EasyLocalization.of(context);
        if (easyLocalization != null && mounted) {
          try {
            await easyLocalization.delegate.load(localeToSet);
            debugPrint('Onboarding: Translation delegate loaded');
          } catch (loadError) {
            debugPrint('Onboarding: Error loading translation delegate: $loadError');
          }
        }
        
        // Qisqa kutish - translation yuklanishini ta'minlash uchun
        if (mounted) {
          setState(() {});
          await Future.delayed(const Duration(milliseconds: 200));
        }
        
        // IMPORTANT: Callback chaqirish - onboarding sahifaga o'tish uchun
        if (mounted) {
          debugPrint('OnboardingLanguagePage: Calling onSelected callback');
          widget.onSelected();
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Onboarding: Error in locale apply: $e');
      debugPrint('Onboarding: Stack trace: $stackTrace');
      // Хатолик бўлса ҳам, локал сақланди ва давом этиш
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          widget.onSelected();
        }
      }
    } finally {
      // IMPORTANT: Har doim flag'ni reset qilish
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
        color: theme.scaffoldBackgroundColor,
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
                        color: theme.textTheme.titleLarge?.color ?? 
                            (isDark ? Colors.white : Colors.black87),
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
                                color: primary,
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
                    color: theme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cardBorderRadius),
                      side: BorderSide(
                        color: isSelected
                            ? primary
                            : (isDark 
                                ? Colors.white.withOpacity(0.1) 
                                : Colors.black.withOpacity(0.1)),
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
                        return theme.iconTheme.color ?? 
                            (isDark ? Colors.white : Colors.black);
                      }),
                      title: Text(
                        _labelFor(l),
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.titleMedium?.color ?? 
                              (isDark ? Colors.white : Colors.black),
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
                onPressed: _isApplying ? null : _apply, // Agar _apply() jarayonda bo'lsa, disabled
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonBorderRadius),
                  ),
                ),
                child: Text(_getCtaText(_selected)),
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
