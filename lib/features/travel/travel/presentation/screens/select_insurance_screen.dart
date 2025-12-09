import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'personal_data_screen.dart';
import '../logic/bloc/travel_bloc.dart';
import '../logic/bloc/travel_state.dart';
import '../logic/bloc/travel_event.dart';

class SelectInsuranceScreen extends StatefulWidget {
  final String countryCode;

  const SelectInsuranceScreen({super.key, required this.countryCode});

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
    final textGreyColor = isDark
        ? Colors.grey[400]!
        : SelectInsuranceScreen.kTextGrey;

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
          "Sayohat sug'urtasi",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<TravelBloc, TravelState>(
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
                  'Ushbu mamlakat uchun tariflar topilmadi. Iltimos, boshqa mamlakatni tanlang.';
            } else if (errorMessage.toLowerCase().contains('network') ||
                errorMessage.toLowerCase().contains('internet')) {
              errorMessage =
                  'Internetga ulanmadingiz. Iltimos, internetni tekshiring.';
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
                      child: const Text('Qayta urinish'),
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
                  // Берем первый тариф для отображения основной информации
                  final firstTarif = companyTarifs[0] as Map<String, dynamic>;

                  // Формируем название компании (с заглавной буквы)
                  final companyName = _formatCompanyName(companyKey);

                  // Извлекаем информацию о тарифе
                  final programName =
                      firstTarif['program_name'] as String? ?? 'Standard';
                  final mainSum =
                      firstTarif['main_sum'] as String? ?? '0,00 EUR';
                  final medUslugi =
                      firstTarif['med_uslugi'] as String? ?? '0,00 EUR';
                  final evakuatsiya =
                      firstTarif['evakuatsiya'] as String? ?? '0,00 EUR';

                  // Формируем описание
                  final description =
                      'Asosiy summa: $mainSum, Tibbiy xizmatlar: $medUslugi';

                  // Формируем теги из доступных услуг
                  final tags = <String>[];
                  if (firstTarif['covid'] != null &&
                      firstTarif['covid'].toString().contains(
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
                  if (tags.isEmpty) {
                    tags.addAll(['Tibbiy yordam', 'Bagaj sug\'urtasi']);
                  }

                  // Пытаемся найти цену (может быть в других полях или нужно рассчитать)
                  String price = '0';
                  // Если есть поле с ценой, используем его
                  if (firstTarif.containsKey('price')) {
                    price = firstTarif['price'].toString();
                  } else if (firstTarif.containsKey('cost')) {
                    price = firstTarif['cost'].toString();
                  } else {
                    // Используем main_sum как ориентир для цены
                    price = mainSum
                        .replaceAll(RegExp(r'[^\d,.]'), '')
                        .replaceAll(',', '.');
                  }

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
                    'tarifs': companyTarifs, // Все тарифы компании
                    'rating': 4.5, // Дефолтный рейтинг
                  });
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
                  "Sug'urta kompaniyasini tanlang",
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
                  "Eng mos keluvchi tarifni tanlang",
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
                        'Kompaniyalar topilmadi',
                        style: TextStyle(color: textGreyColor, fontSize: 16),
                      ),
                    ),
                  )
                else
                  ...companies.asMap().entries.map((entry) {
                    final index = entry.key;
                    final company = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < companies.length - 1 ? 16 : 0,
                      ),
                      child: InsuranceCard(
                        companyName:
                            company['company_name'] as String? ??
                            'Noma\'lum kompaniya',
                        rating: (company['rating'] as num?)?.toDouble() ?? 4.5,
                        description:
                            company['description'] as String? ??
                            'Sug\'urta xizmati',
                        price: _formatPrice(
                          company['price'] ?? company['main_sum'] ?? 0,
                        ),
                        tags: company['tags'] is List
                            ? List<String>.from(company['tags'] as List)
                            : _extractTags(company),
                        isDark: isDark,
                      ),
                    );
                  }).toList(),

                const SizedBox(height: 100), // Bottom padding for button
              ],
            ),
          );
        },
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
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PersonalDataScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: SelectInsuranceScreen.kPrimaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            fixedSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            "Davom etish",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
      final cleanPrice = price
          .replaceAll(RegExp(r'[^\d,.]'), '')
          .replaceAll(',', '.');
      final numValue = double.tryParse(cleanPrice) ?? 0;
      if (numValue > 0) {
        // Форматируем с пробелами для тысяч
        final formatted = numValue
            .toStringAsFixed(0)
            .replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]} ',
            );
        return formatted.trim();
      }
      return price; // Возвращаем как есть, если не удалось распарсить
    }

    // Если это число
    final numValue = price is num
        ? price
        : (double.tryParse(price.toString()) ?? 0);
    // Форматируем число с пробелами для тысяч
    final formatted = numValue
        .toStringAsFixed(0)
        .replaceAllMapped(
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
}

// --- MUKAMMAL SUG'URTA KARTASI ---
class InsuranceCard extends StatelessWidget {
  final String companyName;
  final double rating;
  final String description;
  final String price;
  final List<String> tags;
  final bool isDark;

  const InsuranceCard({
    super.key,
    required this.companyName,
    required this.rating,
    required this.description,
    required this.price,
    required this.tags,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : SelectInsuranceScreen.kTextBlack;
    final textGreyColor = isDark
        ? Colors.grey[400]!
        : SelectInsuranceScreen.kTextGrey;
    final borderColor = isDark
        ? Colors.grey[700]!
        : SelectInsuranceScreen.kBorderColor;
    final tagBg = isDark
        ? const Color(0xFF1E3A5C)
        : SelectInsuranceScreen.kTagBg;
    final tagTextColor = isDark
        ? const Color(0xFF60A5FA)
        : SelectInsuranceScreen.kTagText;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(isDark ? 0.2 : 0.08),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          companyName,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                        // Reyting
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Color(0xFFF59E0B),
                              ), // Amber 500
                              const SizedBox(width: 4),
                              Text(
                                rating.toString(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: textGreyColor,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
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
            children: tags
                .map((tag) => _buildTag(tag, tagBg, tagTextColor))
                .toList(),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Polis narxi",
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
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "so'm",
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

              // Tanlash Tugmasi
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: SelectInsuranceScreen.kPrimaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  shape: const StadiumBorder(), // Pilyula shakli
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text(
                  "Tanlash",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
