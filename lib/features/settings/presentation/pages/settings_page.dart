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
    
    // Эски uz_UZ локалини uz_CYR локалига ўзгартириш
    Locale localeToSet;
    if (currentLocale.languageCode == 'uz' && 
        currentLocale.countryCode != null && 
        currentLocale.countryCode!.toUpperCase() == 'UZ') {
      localeToSet = const Locale('uz', 'CYR');
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
                debugPrint('Changing locale to: ${newLocale.languageCode}_${newLocale.countryCode ?? 'null'}');
                
                try {
                  // Avval locale'ni saqlaymiz
                await LocalePrefs.save(newLocale);
                  debugPrint('Locale saved: ${newLocale.languageCode}_${newLocale.countryCode ?? 'null'}');
                  
                  // Keyin locale'ni o'zgartiramiz
                  try {
                    // Кирилл локали учун қўшимча вақт бериш
                    if (newLocale.languageCode == 'uz' && newLocale.countryCode == 'CYR') {
                      await Future.delayed(const Duration(milliseconds: 100));
                    }
                    await context.setLocale(newLocale);
                    
                    // Локалнинг тўғри ўрнатилганини текшириш
                    final actualLocale = context.locale;
                    debugPrint('Locale set successfully: ${newLocale.languageCode}_${newLocale.countryCode ?? 'null'}');
                    debugPrint('Actual locale after set: ${actualLocale.languageCode}_${actualLocale.countryCode ?? 'null'}');
                    
                    // Локалнинг мос келишини текшириш
                    if (actualLocale.languageCode != newLocale.languageCode ||
                        actualLocale.countryCode != newLocale.countryCode) {
                      debugPrint('WARNING: Locale mismatch! Expected: ${newLocale.languageCode}_${newLocale.countryCode ?? 'null'}, Got: ${actualLocale.languageCode}_${actualLocale.countryCode ?? 'null'}');
                    }
                    
                    // Таржима файлини текшириш
                    try {
                      final testTranslation = tr('app_title');
                      debugPrint('Translation test: app_title = $testTranslation');
                    } catch (e) {
                      debugPrint('Translation error: $e');
                      // Таржима хатоси бўлса ҳам, локал ўрнатилди
                    }
                  } catch (setLocaleError) {
                    debugPrint('Error setting locale: $setLocaleError');
                    // Агар локални ўрнатишда хато бўлса, fallback локални ишлатиш
                    try {
                      if (newLocale.languageCode == 'uz' && newLocale.countryCode == 'CYR') {
                        // Кирилл локали учун қайта уриниш
                        await Future.delayed(const Duration(milliseconds: 200));
                await context.setLocale(newLocale);
                        debugPrint('Cyrillic locale set after retry');
                      } else {
                        // Бошқа локаллар учун fallback
                        await context.setLocale(const Locale('en'));
                        debugPrint('Fallback to English locale');
                      }
                    } catch (fallbackError) {
                      debugPrint('Fallback locale error: $fallbackError');
                      // Хатолик бўлса ҳам, локал сақланди
                    }
                  }
                  
                  // UI ни янгилаш
                  if (mounted) {
                    setState(() => _locale = newLocale);
                  }
                debugPrint('Locale changed successfully: ${newLocale.languageCode}_${newLocale.countryCode ?? 'null'}');
                } catch (e, stackTrace) {
                  debugPrint('Error in locale change: $e');
                  debugPrint('Stack trace: $stackTrace');
                  
                  // Хатолик бўлса ҳам, локал сақланди ва UI ни янгилаш
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
