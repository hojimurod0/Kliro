import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/locale/locale_prefs.dart';
import '../../../../core/services/theme/theme_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Locale _locale;
  late ThemeMode _themeMode;

  static const locales = [
    Locale('uz'),
    Locale('uz', 'CYR'),
    Locale('ru'),
    Locale('en'),
  ];

  @override
  void initState() {
    super.initState();
    _locale = const Locale('en');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLocale = context.locale;
    
    // If we ever get uz_UZ from platform, treat it as Uzbek (Latin).
    Locale localeToSet;
    if (currentLocale.languageCode == 'uz' && 
        currentLocale.countryCode != null && 
        currentLocale.countryCode!.toUpperCase() == 'UZ') {
      localeToSet = const Locale('uz');
    } else {
      localeToSet = currentLocale;
    }
    
    // Locale o'zgarganda yangilash
    if (!_isLocaleEqual(_locale, localeToSet)) {
      _locale = localeToSet;
      debugPrint('SettingsPage: Locale updated: ${localeToSet.languageCode}_${localeToSet.countryCode ?? 'null'}');
    }
    
    _themeMode = ThemeController.instance.mode;
  }

  // Локалларни солиштириш учун ёрдамчи функция
  bool _isLocaleEqual(Locale l1, Locale l2) {
    return l1.languageCode == l2.languageCode &&
        l1.countryCode == l2.countryCode;
  }

  String _labelFor(Locale l) {
    if (l.languageCode == 'uz' && l.countryCode == 'CYR') return 'Uzbek (Cyrillic)';
    if (l.languageCode == 'uz') return 'Uzbek (Latin)';
    if (l.languageCode == 'ru') return 'Russian';
    if (l.languageCode == 'en') return 'English';
    return l.toLanguageTag();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('settings'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('language'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButton<Locale>(
              value: locales.firstWhere(
                (l) => _isLocaleEqual(l, _locale),
                orElse: () => const Locale('en'), // Fallback to English if not found
              ),
              isExpanded: true,
              items: locales
                  .map((l) => DropdownMenuItem<Locale>(
                        value: l,
                        child: Text(_labelFor(l)),
                      ))
                  .toList(),
              onChanged: (newLocale) async {
                if (newLocale == null) return;
                debugPrint(
                  'Changing locale to: ${newLocale.languageCode}_${newLocale.countryCode ?? 'null'}',
                );

                try {
                  // Save first
                  await LocalePrefs.save(newLocale);

                  // Then apply
                  if (newLocale.languageCode == 'uz' &&
                      newLocale.countryCode == 'CYR') {
                    await Future.delayed(const Duration(milliseconds: 100));
                  }
                  if (!context.mounted) return;

                  await context.setLocale(newLocale);
                  if (!context.mounted) return;

                  // Update UI
                  setState(() => _locale = context.locale);
                } catch (e, stackTrace) {
                  debugPrint('Error changing locale: $e');
                  debugPrint('Stack trace: $stackTrace');

                  // Even on error, keep dropdown value in sync
                  if (mounted) {
                    setState(() => _locale = newLocale);
                  }
                }
              },
            ),
            const SizedBox(height: 24),
            Text(tr('theme'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButton<ThemeMode>(
              value: _themeMode,
              isExpanded: true,
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(tr('system_mode')),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(tr('light_mode')),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(tr('dark_mode')),
                ),
              ],
              onChanged: (mode) async {
                if (mode == null) return;
                setState(() => _themeMode = mode);
                await ThemeController.instance.setMode(mode);
              },
            ),
          ],
        ),
      ),
    );
  }
}
