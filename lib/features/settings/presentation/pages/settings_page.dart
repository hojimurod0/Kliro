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
    _locale = context.locale;
    _themeMode = ThemeController.instance.mode;
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
              value: _locale,
              isExpanded: true,
              items: locales
                  .map((l) => DropdownMenuItem<Locale>(
                        value: l,
                        child: Text(_labelFor(l)),
                      ))
                  .toList(),
              onChanged: (newLocale) async {
                if (newLocale == null) return;
                setState(() => _locale = newLocale);
                await context.setLocale(newLocale);
                await LocalePrefs.save(newLocale);
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
