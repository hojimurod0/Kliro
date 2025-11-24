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
      return 'O\'zbek (Кирилл)';
    }
    if (l.languageCode == 'uz') return "O'zbek tili";
    if (l.languageCode == 'ru') return 'Русский';
    if (l.languageCode == 'en') return 'English';
    return l.toLanguageTag();
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
    _selected = const Locale('en'); // Birinchi marta English tilida ochiladi
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Birinchi marta English tilida ochiladi, shuning uchun didChangeDependencies da hech narsa qilmaymiz
  }

  Future<void> _apply() async {
    final chosen = _selected ?? context.locale;
    await context.setLocale(chosen);
    await LocalePrefs.save(chosen);
    widget.onSelected();
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
    final bottomSpacing = isSmallScreen ? 10.0 : 12.0;
    final middleSpacing = isSmallScreen ? 24.0 : (isLargeScreen ? 40.0 : 32.0);
    final buttonSpacing = isSmallScreen ? 12.0 : 16.0;

    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                  final isSelected = _selected == l;
                  return Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cardBorderRadius),
                      side: BorderSide(
                        color: isSelected ? primary : Colors.black.withOpacity(0.1),
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
                      fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
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
    if (l.languageCode == 'en') return '🇺🇸';
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
      return 'assets/images/american.svg';
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
