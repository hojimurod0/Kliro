import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import '../../../../../core/utils/snackbar_helper.dart';
import 'personal_data_screen.dart';
import '../logic/bloc/travel_bloc.dart';
import '../logic/bloc/travel_state.dart';
import '../logic/bloc/travel_event.dart';
import '../../domain/entities/travel_insurance.dart';

class SelectInsuranceScreen extends StatefulWidget {
  final String countryCode;
  final bool annualPolicy;
  final bool covidProtection;

  const SelectInsuranceScreen({
    super.key,
    required this.countryCode,
    this.annualPolicy = false,
    this.covidProtection = false,
  });

  @override
  State<SelectInsuranceScreen> createState() => _SelectInsuranceScreenState();

  // --- DESIGN CONSTANTS ---
  static const Color kPrimaryBlue = Color(0xFF0085FF); // Yorqin ko'k
  static const Color kTextBlack = Color(0xFF0F172A); // To'q qora (Slate 900)
  static const Color kTextGrey = Color(0xFF64748B); // Kulrang (Slate 500)
  static const Color kBorderColor = Color(0xFFF1F5F9); // Juda och kulrang
  static const Color kTagBg = Color(0xFFE0F2FE); // Tag foni (Sky 100)
  static const Color kTagText = Color(0xFF0284C7); // Tag matni (Sky 600)
}

class _SelectInsuranceScreenState extends State<SelectInsuranceScreen> {
  int? selectedInsuranceIndex; // Индекс выбранной страховки

  @override
  void initState() {
    super.initState();
    // Загружаем тарифы при инициализации
    if (widget.countryCode.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TravelBloc>().add(LoadTarifs(widget.countryCode));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isDark ? Colors.white : SelectInsuranceScreen.kTextBlack;
    final textGreyColor =
        isDark ? Colors.grey[400]! : SelectInsuranceScreen.kTextGrey;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
          splashRadius: 24,
        ),
        title: Text(
          "travel.select_insurance.title".tr(),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<TravelBloc, TravelState>(
        listener: (context, state) {
          // DetailsSaved state dan keyin CalcRequested chaqirish
          if (state is DetailsSaved) {
            context.read<TravelBloc>().add(const CalcRequested());
          }
        },
        child: BlocBuilder<TravelBloc, TravelState>(
          builder: (context, state) {
            if (state is TravelLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: SelectInsuranceScreen.kPrimaryBlue,
                ),
              );
            }

            if (state is TravelFailure) {
              // Определяем более понятное сообщение об ошибке
              String errorMessage = state.errorMessage ?? 'Xatolik yuz berdi';

              // Улучшаем сообщения для конкретных ошибок
              if (errorMessage.toLowerCase().contains('country not found') ||
                  errorMessage.toLowerCase().contains('tariflar topilmadi') ||
                  errorMessage.toLowerCase().contains('not found')) {
                errorMessage =
                    "travel.select_insurance.error_country_not_found".tr();
              } else if (errorMessage.toLowerCase().contains('network') ||
                  errorMessage.toLowerCase().contains('internet')) {
                errorMessage = "travel.select_insurance.error_network".tr();
              }

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 64,
                        color: isDark
                            ? Colors.blue[300]
                            : SelectInsuranceScreen.kPrimaryBlue,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (widget.countryCode.isNotEmpty) {
                            context.read<TravelBloc>().add(
                                  LoadTarifs(widget.countryCode),
                                );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SelectInsuranceScreen.kPrimaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text("travel.select_insurance.retry".tr()),
                      ),
                    ],
                  ),
                ),
              );
            }

            List<Map<String, dynamic>> companies = [];

            if (state is TarifsLoaded) {
              final tarifsData = state.tarifs;

              // Структура: {result: {apex: [...], company2: [...], ...}}
              Map<String, dynamic>? resultData;

              if (tarifsData.containsKey('result')) {
                final result = tarifsData['result'];
                if (result is Map<String, dynamic>) {
                  resultData = result;
                }
              } else if (tarifsData.containsKey('data')) {
                final data = tarifsData['data'];
                if (data is Map<String, dynamic>) {
                  resultData = data;
                }
              } else {
                // tarifsData уже Map<String, dynamic> из состояния
                resultData = tarifsData;
              }

              if (resultData != null) {
                // Проходим по всем ключам (названия компаний)
                resultData.forEach((companyKey, companyTarifs) {
                  if (companyTarifs is List && companyTarifs.isNotEmpty) {
                    // Формируем название компании (с заглавной буквы)
                    final companyName = _formatCompanyName(companyKey);

                    // Проходим по ВСЕМ тарифам компании и создаем карточку для каждого
                    for (var tarifData in companyTarifs) {
                      if (tarifData is! Map<String, dynamic>) continue;

                      // Извлекаем информацию о тарифе
                      final programName =
                          tarifData['program_name'] as String? ?? 'Standard';
                      final mainSum =
                          tarifData['main_sum'] as String? ?? '0,00 EUR';
                      final medUslugi =
                          tarifData['med_uslugi'] as String? ?? '0,00 EUR';
                      final evakuatsiya =
                          tarifData['evakuatsiya'] as String? ?? '0,00 EUR';

                      // Формируем описание с названием программы - tushunarli format
                      final description =
                          programName.isNotEmpty && programName != 'Standard'
                              ? programName
                              : 'Sug\'urta polisi';

                      // Формируем теги из доступных услуг
                      final tags = <String>[];
                      if (tarifData['covid'] != null &&
                          tarifData['covid'].toString().contains(
                                RegExp(r'[1-9]'),
                              )) {
                        tags.add('COVID qoplash');
                      }
                      if (evakuatsiya != '0,00 EUR' && evakuatsiya != '0,00') {
                        tags.add('Evakuatsiya');
                      }
                      if (medUslugi != '0,00 EUR' && medUslugi != '0,00') {
                        tags.add('Tibbiy yordam');
                      }
                      if (tarifData['repatriatsiya'] != null) {
                        final repatriatsiya =
                            tarifData['repatriatsiya'].toString();
                        if (repatriatsiya != '0,00 EUR' &&
                            repatriatsiya != '0,00') {
                          tags.add('Repatriatsiya');
                        }
                      }
                      if (tarifData['stomatologiya'] != null) {
                        final stomatologiya =
                            tarifData['stomatologiya'].toString();
                        if (stomatologiya != '0,00 EUR' &&
                            stomatologiya != '0,00') {
                          tags.add('Stomatologiya');
                        }
                      }
                      if (tags.isEmpty) {
                        tags.addAll(['Tibbiy yordam', 'Bagaj sug\'urtasi']);
                      }

                      // Пытаемся найти цену (может быть в других полях или нужно рассчитать)
                      String price = '0';
                      // Если есть поле с ценой, используем его
                      if (tarifData.containsKey('price')) {
                        price = tarifData['price'].toString();
                      } else if (tarifData.containsKey('cost')) {
                        price = tarifData['cost'].toString();
                      } else {
                        // Используем main_sum как ориентир для цены
                        price = mainSum
                            .replaceAll(RegExp(r'[^\d,.]'), '')
                            .replaceAll(',', '.');
                      }

                      // Добавляем company_key в данные тарифа для сравнения
                      final tarifWithCompany = Map<String, dynamic>.from(
                        tarifData,
                      );
                      tarifWithCompany['company_key'] = companyKey;

                      companies.add({
                        'company_name': companyName,
                        'company_key': companyKey,
                        'program_name': programName,
                        'description': description,
                        'price': price,
                        'main_sum': mainSum,
                        'med_uslugi': medUslugi,
                        'evakuatsiya': evakuatsiya,
                        'tags': tags,
                        'tarif':
                            tarifWithCompany, // Данные конкретного тарифа с company_key
                        'rating': 4.5, // Дефолтный рейтинг
                      });
                    }
                  }
                });
              }
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sarlavha Qismi
                  Text(
                    "travel.select_insurance.select_company".tr(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "travel.select_insurance.select_tariff".tr(),
                    style: TextStyle(
                      fontSize: 15,
                      color: textGreyColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Компании из API
                  if (companies.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          "travel.select_insurance.companies_not_found".tr(),
                          style: TextStyle(color: textGreyColor, fontSize: 16),
                        ),
                      ),
                    )
                  else
                    ...companies.asMap().entries.map((entry) {
                      final index = entry.key;
                      final company = entry.value;
                      final isSelected = selectedInsuranceIndex == index;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < companies.length - 1 ? 16 : 0,
                        ),
                        child: InsuranceCard(
                          companyName: _formatCompanyNameWithProgram(
                            company['company_name'] as String? ??
                                'Noma\'lum kompaniya',
                            company['program_name'] as String?,
                          ),
                          description: company['description'] as String? ??
                              'Sug\'urta xizmati',
                          price: _formatPrice(
                            company['price'] ?? company['main_sum'] ?? 0,
                          ),
                          tags: company['tags'] is List
                              ? List<String>.from(company['tags'] as List)
                              : _extractTags(company),
                          isDark: isDark,
                          tarif: company['tarif'] as Map<String, dynamic>?,
                          companyKey: company['company_key'] as String? ?? '',
                          companyNameRaw:
                              company['company_name'] as String? ?? '',
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              // Если уже выбрана, снимаем выбор, иначе выбираем
                              selectedInsuranceIndex =
                                  isSelected ? null : index;
                            });
                          },
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 100), // Bottom padding for button
                ],
              ),
            );
          },
        ),
      ),
      // --- PASTKI TUGMA ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: scaffoldBg,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey.shade100,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: selectedInsuranceIndex != null
              ? () {
                  final travelBloc = context.read<TravelBloc>();
                  final currentState = travelBloc.state;

                  // Tanlangan sug'urta ma'lumotlarini olish
                  if (currentState is TarifsLoaded) {
                    final companies = _extractCompanies(currentState.tarifs);
                    if (selectedInsuranceIndex != null &&
                        selectedInsuranceIndex! < companies.length) {
                      final selectedCompany =
                          companies[selectedInsuranceIndex!];
                      final tarif =
                          selectedCompany['tarif'] as Map<String, dynamic>?;
                      final companyKey =
                          selectedCompany['company_key'] as String? ?? '';

                      // State dan mavjud ma'lumotlarni olish
                      final existingInsurance = currentState.insurance;
                      final existingPersons = currentState.persons;
                      // ✅ sessionId ni TravelState dan to'g'ridan-to'g'ri olish (type narrowing muammosini hal qilish)
                      // currentState TarifsLoaded type, lekin TravelState dan meros olgan, shuning uchun sessionId mavjud
                      // Analyzer cache muammosini hal qilish uchun dynamic cast ishlatamiz
                      final sessionId =
                          (currentState as dynamic).sessionId as String?;

                      if (existingInsurance != null &&
                          tarif != null &&
                          sessionId != null &&
                          sessionId.isNotEmpty) {
                        // Yangi TravelInsurance yaratish (provider va companyName bilan)
                        final newInsurance = TravelInsurance(
                          provider: companyKey,
                          companyName:
                              selectedCompany['company_name'] as String? ?? '',
                          startDate: existingInsurance.startDate,
                          endDate: existingInsurance.endDate,
                          phoneNumber: existingInsurance.phoneNumber,
                          email: existingInsurance.email,
                          sessionId: sessionId,
                          amount: existingInsurance.amount,
                          programId: existingInsurance.programId,
                          countryName: existingInsurance.countryName,
                          purposeName: existingInsurance.purposeName,
                        );

                        log(
                          '[SELECT_INSURANCE] ✅ Sug\'urta tanlandi va saqlandi:\n'
                          '  - Provider: $companyKey\n'
                          '  - Company: ${selectedCompany['company_name']}\n'
                          '  - Program ID: ${existingInsurance.programId ?? "yo'q"}\n'
                          '  - Amount: ${existingInsurance.amount ?? "yo'q"}\n'
                          '  - Session ID: $sessionId',
                          name: 'TRAVEL',
                        );

                        // Sug'urtani state ga saqlash
                        travelBloc.add(LoadInsuranceData(newInsurance));

                        // DetailsSubmitted event yuborish
                        if (existingPersons.isNotEmpty) {
                          final travelersBirthdates = existingPersons
                              .map(
                                (p) => DateFormat(
                                  'dd.MM.yyyy',
                                ).format(p.birthDate),
                              )
                              .toList();

                          // ✅ sessionId allaqachon olingan
                          travelBloc.add(
                            DetailsSubmitted(
                              sessionId: sessionId,
                              startDate: DateFormat(
                                'dd.MM.yyyy',
                              ).format(existingInsurance.startDate),
                              endDate: DateFormat(
                                'dd.MM.yyyy',
                              ).format(existingInsurance.endDate),
                              travelersBirthdates: travelersBirthdates,
                              annualPolicy: widget.annualPolicy,
                              covidProtection: widget.covidProtection,
                            ),
                          );

                          // DetailsSaved state kutiladi, keyin CalcRequested chaqiriladi
                          // Bu BlocListener da qilinadi
                        } else {
                          // Persons bo'sh bo'lsa, xatolik ko'rsatish
                          SnackbarHelper.showError(
                            context,
                            'Sayohatchi ma\'lumotlari topilmadi. Iltimos, qayta urinib ko\'ring.',
                          );
                        }
                      } else if (sessionId == null || sessionId.isEmpty) {
                        // SessionId yo'q bo'lsa, xatolik ko'rsatish
                        SnackbarHelper.showError(
                          context,
                          'Session ID topilmadi. Iltimos, qayta urinib ko\'ring.',
                        );
                      }
                    }
                  }

                  // PersonalDataScreen ga o'tish
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: travelBloc,
                        child: const PersonalDataScreen(),
                      ),
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedInsuranceIndex != null
                ? SelectInsuranceScreen.kPrimaryBlue
                : Colors.grey[300],
            foregroundColor: selectedInsuranceIndex != null
                ? Colors.white
                : Colors.grey[600],
            elevation: 0,
            fixedSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[600],
          ),
          child: Text(
            "travel.select_insurance.continue".tr(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';

    // Если это строка с форматированием (например, "20 000,00 EUR")
    if (price is String) {
      // Извлекаем только число
      final cleanPrice =
          price.replaceAll(RegExp(r'[^\d,.]'), '').replaceAll(',', '.');
      final numValue = double.tryParse(cleanPrice) ?? 0;
      if (numValue > 0) {
        // Форматируем с пробелами для тысяч
        final formatted = numValue.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]} ',
            );
        return formatted.trim();
      }
      return price; // Возвращаем как есть, если не удалось распарсить
    }

    // Если это число
    final numValue =
        price is num ? price : (double.tryParse(price.toString()) ?? 0);
    // Форматируем число с пробелами для тысяч
    final formatted = numValue.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
    return formatted.trim();
  }

  String _formatCompanyName(String key) {
    // Преобразуем ключ в читаемое название компании
    // apex -> Apex, uzbekinvest -> Uzbekinvest
    if (key.isEmpty) return 'Noma\'lum kompaniya';

    // Список известных компаний
    final companyNames = {
      'apex': 'APEX Insurance',
      'uzbekinvest': 'O\'zbekinvest',
      'kapital': 'Kapital Insurance',
    };

    final lowerKey = key.toLowerCase();
    if (companyNames.containsKey(lowerKey)) {
      return companyNames[lowerKey]!;
    }

    // Если не найдено в списке, делаем первую букву заглавной
    return key[0].toUpperCase() + key.substring(1).toLowerCase();
  }

  String _formatCompanyNameWithProgram(
    String companyName,
    String? programName,
  ) {
    if (programName != null && programName.isNotEmpty) {
      return '$companyName - $programName';
    }
    return companyName;
  }

  List<String> _extractTags(Map<String, dynamic> company) {
    final List<String> tags = [];

    // Пытаемся извлечь теги из разных полей
    if (company['tags'] is List) {
      tags.addAll((company['tags'] as List).map((e) => e.toString()).toList());
    } else if (company['features'] is List) {
      tags.addAll(
        (company['features'] as List).map((e) => e.toString()).toList(),
      );
    } else if (company['benefits'] is List) {
      tags.addAll(
        (company['benefits'] as List).map((e) => e.toString()).toList(),
      );
    }

    // Если тегов нет, добавляем стандартные
    if (tags.isEmpty) {
      tags.addAll(['Tibbiy yordam', 'Bagaj sug\'urtasi', 'COVID qoplash']);
    }

    return tags;
  }

  // Companies list yaratish uchun yordamchi metod
  List<Map<String, dynamic>> _extractCompanies(
    Map<String, dynamic> tarifsData,
  ) {
    List<Map<String, dynamic>> companies = [];

    // Структура: {result: {apex: [...], company2: [...], ...}}
    Map<String, dynamic>? resultData;

    if (tarifsData.containsKey('result')) {
      final result = tarifsData['result'];
      if (result is Map<String, dynamic>) {
        resultData = result;
      }
    } else if (tarifsData.containsKey('data')) {
      final data = tarifsData['data'];
      if (data is Map<String, dynamic>) {
        resultData = data;
      }
    } else {
      resultData = tarifsData;
    }

    if (resultData != null) {
      resultData.forEach((companyKey, companyTarifs) {
        if (companyTarifs is List && companyTarifs.isNotEmpty) {
          final companyName = _formatCompanyName(companyKey);

          for (var tarifData in companyTarifs) {
            if (tarifData is! Map<String, dynamic>) continue;

            final programName =
                tarifData['program_name'] as String? ?? 'Standard';
            final mainSum = tarifData['main_sum'] as String? ?? '0,00 EUR';
            final medUslugi = tarifData['med_uslugi'] as String? ?? '0,00 EUR';
            final evakuatsiya =
                tarifData['evakuatsiya'] as String? ?? '0,00 EUR';

            // Формируем описание с названием программы - tushunarli format
            final description =
                programName.isNotEmpty && programName != 'Standard'
                    ? programName
                    : 'Sug\'urta polisi';

            final tags = <String>[];
            if (tarifData['covid'] != null &&
                tarifData['covid'].toString().contains(RegExp(r'[1-9]'))) {
              tags.add('COVID qoplash');
            }
            if (evakuatsiya != '0,00 EUR' && evakuatsiya != '0,00') {
              tags.add('Evakuatsiya');
            }
            if (medUslugi != '0,00 EUR' && medUslugi != '0,00') {
              tags.add('Tibbiy yordam');
            }
            if (tags.isEmpty) {
              tags.addAll(['Tibbiy yordam', 'Bagaj sug\'urtasi']);
            }

            String price = '0';
            if (tarifData.containsKey('price')) {
              price = tarifData['price'].toString();
            } else if (tarifData.containsKey('cost')) {
              price = tarifData['cost'].toString();
            } else {
              price = mainSum
                  .replaceAll(RegExp(r'[^\d,.]'), '')
                  .replaceAll(',', '.');
            }

            final tarifWithCompany = Map<String, dynamic>.from(tarifData);
            tarifWithCompany['company_key'] = companyKey;

            companies.add({
              'company_name': companyName,
              'company_key': companyKey,
              'program_name': programName,
              'description': description,
              'price': price,
              'main_sum': mainSum,
              'med_uslugi': medUslugi,
              'evakuatsiya': evakuatsiya,
              'tags': tags,
              'tarif': tarifWithCompany,
              'rating': 4.5,
            });
          }
        }
      });
    }

    return companies;
  }
}

// --- MUKAMMAL SUG'URTA KARTASI ---
class InsuranceCard extends StatelessWidget {
  final String companyName;
  final String description;
  final String price;
  final List<String> tags;
  final bool isDark;
  final Map<String, dynamic>? tarif;
  final String companyKey;
  final String companyNameRaw;
  final bool isSelected;
  final VoidCallback? onTap;

  const InsuranceCard({
    super.key,
    required this.companyName,
    required this.description,
    required this.price,
    required this.tags,
    this.isDark = false,
    this.tarif,
    this.companyKey = '',
    this.companyNameRaw = '',
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : SelectInsuranceScreen.kTextBlack;
    final textGreyColor =
        isDark ? Colors.grey[400]! : SelectInsuranceScreen.kTextGrey;
    final borderColor =
        isDark ? Colors.grey[700]! : SelectInsuranceScreen.kBorderColor;
    final tagBg =
        isDark ? const Color(0xFF1E3A5C) : SelectInsuranceScreen.kTagBg;
    final tagTextColor =
        isDark ? const Color(0xFF60A5FA) : SelectInsuranceScreen.kTagText;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? SelectInsuranceScreen.kPrimaryBlue : borderColor,
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? SelectInsuranceScreen.kPrimaryBlue.withOpacity(0.2)
                : Colors.blueGrey.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Logo va Ma'lumotlar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo qutisi
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                // Bino ikonkasini markazlashtirish
                child: Center(
                  child: Icon(
                    Icons.apartment_rounded,
                    size: 26,
                    color: isDark ? Colors.grey[400] : Colors.blueGrey.shade400,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Kompaniya nomi va reyting
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: textGreyColor,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          // Chips / Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                tags.map((tag) => _buildTag(tag, tagBg, tagTextColor)).toList(),
          ),

          const SizedBox(height: 20),

          // Yupqa chiziq
          Divider(
            color: isDark ? Colors.grey[700] : Colors.grey.shade100,
            thickness: 1.5,
            height: 1,
          ),

          const SizedBox(height: 16),
          // Footer: Narx va Tugma
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "travel.select_insurance.policy_price".tr(),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            price,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "travel.select_insurance.sum".tr(),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Sug'urtani tanlash Tugmasi
              Flexible(
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? SelectInsuranceScreen.kPrimaryBlue
                        : Colors.grey[300],
                    foregroundColor:
                        isSelected ? Colors.white : Colors.grey[600],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: const StadiumBorder(), // Pilyula shakli
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    isSelected
                        ? "travel.select_insurance.selected".tr()
                        : "travel.select_insurance.select_insurance".tr(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color tagBg, Color tagTextColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tagBg,
        borderRadius: BorderRadius.circular(30), // Juda dumaloq (pill shape)
        border: Border.all(color: tagTextColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 14,
            color: tagTextColor,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: tagTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
