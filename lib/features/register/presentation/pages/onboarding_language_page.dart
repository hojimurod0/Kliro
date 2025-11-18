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
    if (l.languageCode == 'uz' && l.countryCode == 'CYR')
      return 'O\'zbek (Кирилл)';
    if (l.languageCode == 'uz') return "O'zbek tili";
    if (l.languageCode == 'ru') return 'Русский';
    if (l.languageCode == 'en') return 'English';
    return l.toLanguageTag();
  }

  @override
  void initState() {
    super.initState();
    _selected = null; // will be set from context in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selected ??= context.locale;
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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 80),
          Center(
            child: SizedBox(
              height: 56,
              child: SvgPicture.asset(
                'assets/images/klero_logo.svg',
                fit: BoxFit.contain,
                placeholderBuilder: (context) => RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    children: [
                      TextSpan(text: 'K'),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: SizedBox(
                          width: 8,
                          height: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      TextSpan(text: 'LiRO'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: _locales.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final l = _locales[i];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: RadioListTile<Locale>(
                    value: l,
                    groupValue: _selected,
                    onChanged: (v) => setState(() => _selected = v),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: primary,
                    title: Text(
                      _labelFor(l),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    secondary: ClipOval(
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        child: OverflowBox(
                          maxWidth: 32,
                          maxHeight: 32,
                          child: Text(
                            _flagEmoji(l),
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Tanlash'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _flagEmoji(Locale l) {
    if (l.languageCode == 'ru') return '🇷🇺';
    if (l.languageCode == 'en') return '🇺🇸';
    return '🇺🇿';
  }
}
