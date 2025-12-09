import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

import '../logic/bloc/travel_bloc.dart';
import '../logic/bloc/travel_state.dart';
import '../logic/bloc/travel_event.dart';
import 'select_insurance_screen.dart';

class TravelPersonsScreen extends StatefulWidget {
  const TravelPersonsScreen({super.key});

  @override
  State<TravelPersonsScreen> createState() => _TravelPersonsScreenState();
}

class _TravelPersonsScreenState extends State<TravelPersonsScreen> {
  // --- RANGLAR PALITRASI ---
  final Color kPrimaryBlue = const Color(0xFF0085FF); // Asosiy ko'k rang
  final Color kLightBlueBg = const Color(0xFFEFF8FF); // Ochiq ko'k fon
  final Color kTextBlack = const Color(0xFF111111); // Qora matn
  final Color kTextGrey = const Color(0xFF6B7280); // Kulrang matn
  final Color kBorderGrey = const Color(0xFFE5E7EB); // Och kulrang hoshiya
  final Color kInputBg = const Color(0xFFFFFFFF); // Input foni
  final Color kDeleteRedBg = const Color(0xFFFEF2F2); // O'chirish tugmasi foni
  final Color kDeleteRedIcon = const Color(0xFFEF4444); // Qizil ikonka

  // State variables
  List<Map<String, dynamic>> _countries = [];
  List<String> _selectedCountries = [];
  List<Map<String, dynamic>> _purposes = [];
  int? _selectedPurposeId;
  String? _sessionId;
  
  // Даты
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Дополнительные защиты
  bool _isAnnualInsuranceSelected = false;
  bool _isCovidProtectionSelected = false;
  
  // Путешественники
  List<Map<String, dynamic>> _travelers = [
    {'id': 1, 'birthDate': null}
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    // Загружаем страны и цели при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TravelBloc>().add(LoadCountries());
      context.read<TravelBloc>().add(LoadPurposes());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isDark ? Colors.white : kTextBlack;
    final textGreyColor = isDark ? Colors.grey[400]! : kTextGrey;
    final borderColor = isDark ? Colors.grey[700]! : kBorderGrey;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final lightBlueBg = isDark ? const Color(0xFF1E3A5C) : kLightBlueBg;

    return BlocListener<TravelBloc, TravelState>(
      listener: (context, state) {
        if (state is CountriesLoaded) {
          // Оптимизация: обработку данных переносим в microtask для разгрузки main thread
          Future.microtask(() {
            if (!mounted) return;
            setState(() {
              _countries = state.countries.map((c) {
                // Если уже Map, возвращаем как есть
                if (c is Map<String, dynamic>) {
                  return c;
                }
                // Если другой тип, пытаемся преобразовать
                return c as Map<String, dynamic>;
              }).toList();
            });
          });
        } else if (state is PurposesLoaded) {
          setState(() {
            _purposes = state.purposes.map((p) {
              // Если уже Map, возвращаем как есть
              if (p is Map<String, dynamic>) {
                return p;
              }
              // Если другой тип, пытаемся преобразовать
              return p as Map<String, dynamic>;
            }).toList();
          });
        } else if (state is PurposeCreated) {
          setState(() {
            _sessionId = state.sessionId;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maqsad yaratildi'),
              backgroundColor: Colors.green,
            ),
          );
          // Переходим на следующую страницу после создания сессии
          final firstCountry = _selectedCountries.isNotEmpty 
              ? _selectedCountries.first 
              : '';
          final travelBloc = context.read<TravelBloc>();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: travelBloc,
                child: SelectInsuranceScreen(
                  countryCode: firstCountry,
                ),
              ),
            ),
          );
        } else if (state is TravelFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Xatolik yuz berdi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<TravelBloc, TravelState>(
        buildWhen: (previous, current) {
          // Обновляем UI при изменении состояния загрузки целей
          return current is PurposesLoaded ||
              current is CountriesLoaded ||
              current is TravelLoading ||
              current is TravelFailure ||
              current is TravelInitial;
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: scaffoldBg,
            // --- APP BAR ---
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
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            // --- ASOSIY QISM ---
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Katta Sarlavha - веб-стиль, адаптированный для мобильного
                  Text(
                    "Sayohat ma'lumotlari",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sayohatingiz haqida asosiy ma'lumotlarni kiriting",
                    style: TextStyle(
                      fontSize: 14,
                      color: textGreyColor,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 1. Qayerga boryapsiz? - веб-стиль
                  _buildSectionLabel(
                    "Qayerga boryapsiz?",
                    Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildCountryDropdown(state),
                  if (_selectedCountries.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedCountries.map((code) {
                        final country = _countries.firstWhere(
                          (c) => c['code'] == code,
                          orElse: () => {'name': code},
                        );
                        return Chip(
                          label: Text(_getCountryName(country)),
                          onDeleted: () {
                            setState(() {
                              _selectedCountries.remove(code);
                            });
                          },
                          deleteIcon: const Icon(Icons.close, size: 18),
                          backgroundColor: lightBlueBg,
                          labelStyle: TextStyle(
                            color: kPrimaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // 2. Sayohat maqsadi
                  _buildLabel("Sayohat maqsadi"),
                  _buildPurposeDropdown(),
                  const SizedBox(height: 16),
                  // 3. Sanalar (Boshlash va Tugash)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Boshlash"),
                            _buildDateInputBox("dd/mm/yyyy", isStart: true),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Tugash"),
                            _buildDateInputBox("dd/mm/yyyy", isStart: false),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // 4. Qo'shimcha himoya Header
                  Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 18,
                        color: textGreyColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Qo'shimcha himoya",
                        style: TextStyle(
                          color: textGreyColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 5. Sug'urta turlari (Cards)
                  // Yillik sug'urta
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAnnualInsuranceSelected = !_isAnnualInsuranceSelected;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isAnnualInsuranceSelected
                            ? lightBlueBg
                            : (isDark
                                ? const Color(0xFF1E1E1E)
                                : const Color(0xFFFAFAFA)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isAnnualInsuranceSelected
                              ? kPrimaryBlue
                              : (isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey.shade200),
                          width: _isAnnualInsuranceSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Yillik sug'urta",
                                  style: TextStyle(
                                    color: _isAnnualInsuranceSelected
                                        ? kPrimaryBlue
                                        : textColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Butun yil uchun himoya",
                                  style: TextStyle(
                                    color: textGreyColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isAnnualInsuranceSelected)
                            Icon(Icons.check_circle,
                                color: kPrimaryBlue, size: 26),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // COVID-19 himoyasi
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isCovidProtectionSelected = !_isCovidProtectionSelected;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isCovidProtectionSelected
                            ? lightBlueBg
                            : (isDark
                                ? const Color(0xFF1E1E1E)
                                : const Color(0xFFFAFAFA)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isCovidProtectionSelected
                              ? kPrimaryBlue
                              : (isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey.shade200),
                          width: _isCovidProtectionSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "COVID-19 himoyasi",
                                  style: TextStyle(
                                    color: _isCovidProtectionSelected
                                        ? kPrimaryBlue
                                        : textColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Koronavirus davolash xarajatlari",
                                  style: TextStyle(
                                      color: textGreyColor, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          if (_isCovidProtectionSelected)
                            Icon(Icons.check_circle,
                                color: kPrimaryBlue, size: 26),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 6. Sayohatchilar Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 24,
                            color: textColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Sayohatchilar",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      // Qo'shish tugmasi
                      InkWell(
                        onTap: () {
                          setState(() {
                            _travelers.add({
                              'id': _travelers.length + 1,
                              'birthDate': null
                            });
                          });
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: lightBlueBg,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.add, size: 18, color: kPrimaryBlue),
                              const SizedBox(width: 4),
                              Text(
                                "Qo'shish",
                                style: TextStyle(
                                  color: kPrimaryBlue,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 7. Sayohatchi Kartalari
                  ..._travelers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final traveler = entry.value;
                    final travelerId = traveler['id'] as int;
                    final birthDate = traveler['birthDate'] as DateTime?;
                    
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < _travelers.length - 1 ? 16 : 0,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.3 : 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Sayohatchi $travelerId",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                                ),
                                // O'chirish knopkasi (только если больше одного)
                                if (_travelers.length > 1)
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _travelers.removeAt(index);
                                        // Перенумеровываем ID
                                        for (int i = 0; i < _travelers.length; i++) {
                                          _travelers[i]['id'] = i + 1;
                                        }
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: kDeleteRedBg,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: 18,
                                        color: kDeleteRedIcon,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Label + Icon
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                  color: textGreyColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Tug'ilgan sana",
                                  style: TextStyle(
                                    color: textGreyColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Ichki Sana Tanlash Inputi (Pill shape)
                            InkWell(
                              onTap: () => _selectTravelerBirthDate(index),
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                height: 52,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey[900]
                                      : const Color(0xFFFAFAFA),
                                  border: Border.all(color: borderColor),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      birthDate != null
                                          ? DateFormat('dd/MM/yyyy').format(birthDate)
                                          : "Sanani tanlang",
                                      style: TextStyle(
                                        color: birthDate != null
                                            ? textColor
                                            : (isDark
                                                ? Colors.grey[500]
                                                : Colors.grey.shade400),
                                        fontSize: 15,
                                        fontWeight: birthDate != null
                                            ? FontWeight.w500
                                            : FontWeight.w400,
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_month_outlined,
                                      color: textGreyColor,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
            // --- PASTKI TUGMA ---
            bottomNavigationBar: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: scaffoldBg,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.grey[800]!
                        : kBorderGrey.withOpacity(0.5),
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
                  // Валидация перед переходом
                  if (_selectedPurposeId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sayohat maqsadini tanlang'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (_selectedCountries.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kamida bitta mamlakatni tanlang'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (_startDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Boshlanish sanasini tanlang'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (_endDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tugash sanasini tanlang'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  // Проверяем, что все путешественники имеют дату рождения
                  for (int i = 0; i < _travelers.length; i++) {
                    if (_travelers[i]['birthDate'] == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sayohatchi ${i + 1} uchun tug\'ilgan sanani tanlang'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                  }

                  // Создаем цель путешествия
                  if (_sessionId == null) {
                    context.read<TravelBloc>().add(
                      PurposeSubmitted(
                        purposeId: _selectedPurposeId!,
                        destinations: _selectedCountries,
                      ),
                    );
                    // Ждем создания сессии перед переходом
                    // Переход будет в BlocListener при PurposeCreated
                  } else {
                    // Если сессия уже создана, переходим дальше
                    final firstCountry = _selectedCountries.isNotEmpty 
                        ? _selectedCountries.first 
                        : '';
                    final travelBloc = context.read<TravelBloc>();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: travelBloc,
                          child: SelectInsuranceScreen(
                            countryCode: firstCountry,
                          ),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryBlue,
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
        },
      ),
    );
  }

  // Dropdown для выбора стран
  Widget _buildCountryDropdown(TravelState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : kTextBlack;
    final borderColor = isDark ? Colors.grey[700]! : kBorderGrey;

    // Показываем индикатор загрузки только если данные еще не загружены
    if ((state is TravelLoading || state is TravelInitial) &&
        _countries.isEmpty) {
      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // Если список стран пустой, показываем сообщение
    if (_countries.isEmpty) {
      final textGreyColor = isDark ? Colors.grey[400]! : kTextGrey;
      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            "Mamlakatlar yuklanmoqda...",
            style: TextStyle(color: textGreyColor, fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: null, // Всегда null для множественного выбора
        isExpanded: true,
        decoration: InputDecoration(
          hintText: _selectedCountries.isEmpty
              ? "Mamlakatni tanlang"
              : "${_selectedCountries.length} ta tanlangan",
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey.shade400,
            fontWeight: FontWeight.w400,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: kPrimaryBlue, width: 1.5),
          ),
          filled: true,
          fillColor: cardBg,
        ),
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: isDark ? Colors.grey[400] : Colors.grey.shade600,
        ),
        items: _countries.isEmpty
            ? []
            : _countries
                  .where((country) {
                    final code = country['code'] as String? ?? '';
                    return code.isNotEmpty;
                  })
                  .map((country) {
                    final code = country['code'] as String? ?? '';
                    final name = _getCountryName(country);
                    final isSelected = _selectedCountries.contains(code);
                    return DropdownMenuItem<String>(
                      value: code,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: kPrimaryBlue,
                              size: 18,
                            )
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              name.isEmpty ? code : name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                  .toList(),
        onChanged: _countries.isEmpty
            ? null
            : (value) {
                if (value != null && value.isNotEmpty) {
                  setState(() {
                    if (_selectedCountries.contains(value)) {
                      _selectedCountries.remove(value);
                    } else {
                      _selectedCountries.add(value);
                    }
                  });
                }
              },
      ),
    );
  }

  // Dropdown для выбора цели путешествия - веб-стиль
  Widget _buildPurposeDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : kTextBlack;
    final borderColor = isDark ? Colors.grey[700]! : kBorderGrey;

    // Показываем индикатор загрузки если данные еще не загружены
    if (_purposes.isEmpty) {
      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<int>(
        value: _selectedPurposeId,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: "Maqsadni tanlang",
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey.shade600,
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: kPrimaryBlue, width: 2),
          ),
          filled: true,
          fillColor: cardBg,
        ),
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: isDark ? Colors.grey[400] : Colors.grey.shade600,
        ),
        items: _purposes
            .where((purpose) {
              final id = purpose['id'] as int?;
              return id != null;
            })
            .map((purpose) {
              final id = purpose['id'] as int;
              final name = _getPurposeName(purpose);
              return DropdownMenuItem<int>(
                value: id,
                child: Text(name.isEmpty ? 'Maqsad $id' : name),
              );
            })
            .toList(),
        onChanged: _purposes.isEmpty
            ? null
            : (value) {
                if (value != null) {
                  setState(() {
                    _selectedPurposeId = value;
                  });
                }
              },
      ),
    );
  }

  // Получает локализованное имя страны
  String _getCountryName(Map<String, dynamic> country) {
    final locale = context.locale.languageCode;
    final countryCode = context.locale.countryCode;

    // Для uz_CYR используем uz
    if (locale == 'uz' && countryCode == 'CYR') {
      return country['uz'] as String? ?? country['name'] as String? ?? '';
    }

    // Для остальных локалей используем соответствующее поле
    switch (locale) {
      case 'uz':
        return country['uz'] as String? ?? country['name'] as String? ?? '';
      case 'ru':
        return country['ru'] as String? ?? country['name'] as String? ?? '';
      case 'en':
        return country['en'] as String? ?? country['name'] as String? ?? '';
      default:
        return country['name'] as String? ?? '';
    }
  }

  // Получает локализованное имя цели путешествия
  String _getPurposeName(Map<String, dynamic> purpose) {
    final locale = context.locale.languageCode;
    final countryCode = context.locale.countryCode;

    // Для uz_CYR используем uz
    if (locale == 'uz' && countryCode == 'CYR') {
      return purpose['uz'] as String? ?? purpose['name'] as String? ?? '';
    }

    // Для остальных локалей используем соответствующее поле
    switch (locale) {
      case 'uz':
        return purpose['uz'] as String? ?? purpose['name'] as String? ?? '';
      case 'ru':
        return purpose['ru'] as String? ?? purpose['name'] as String? ?? '';
      case 'en':
        return purpose['en'] as String? ?? purpose['name'] as String? ?? '';
      default:
        return purpose['name'] as String? ?? '';
    }
  }

  // --- YORDAMCHI WIDGETLAR ---
  Widget _buildLabel(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textGreyColor = isDark ? Colors.grey[400]! : kTextGrey;

    return Text(
      text,
      style: TextStyle(
        color: textGreyColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
    );
  }

  // Веб-стиль секция с иконкой
  Widget _buildSectionLabel(String text, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : kTextBlack;

    return Row(
      children: [
        Icon(icon, size: 20, color: kPrimaryBlue),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildDateInputBox(String hint, {required bool isStart}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.grey[700]! : kBorderGrey;
    final textColor = isDark ? Colors.white : kTextBlack;
    final selectedDate = isStart ? _startDate : _endDate;
    final dateText = selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(selectedDate)
        : hint;

    return InkWell(
      onTap: () => _selectDate(isStart),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_outlined, size: 22, color: kPrimaryBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dateText,
                style: TextStyle(
                  color: selectedDate != null
                      ? textColor
                      : (isDark ? Colors.grey[400] : Colors.grey.shade600),
                  fontSize: 15,
                  fontWeight: selectedDate != null
                      ? FontWeight.w500
                      : FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.grey[600] : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final now = DateTime.now();
    final firstDate = isStart ? now : (_startDate ?? now);
    final lastDate = DateTime(now.year + 1, 12, 31);

    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? now)
          : (_endDate ?? _startDate ?? now.add(const Duration(days: 1))),
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('uz', 'UZ'),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimaryBlue,
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              onSurface: isDark ? Colors.white : kTextBlack,
            ),
            dialogBackgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Если дата окончания раньше новой даты начала, сбрасываем её
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          if (_startDate == null || picked.isAfter(_startDate!) || picked.isAtSameMomentAs(_startDate!)) {
            _endDate = picked;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tugash sanasi boshlanish sanasidan keyin bo\'lishi kerak'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      });
    }
  }

  Future<void> _selectTravelerBirthDate(int index) async {
    final now = DateTime.now();
    final firstDate = DateTime(1900, 1, 1);
    final lastDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: _travelers[index]['birthDate'] as DateTime? ?? 
          DateTime(now.year - 30, 1, 1),
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('uz', 'UZ'),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimaryBlue,
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              onSurface: isDark ? Colors.white : kTextBlack,
            ),
            dialogBackgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _travelers[index]['birthDate'] = picked;
      });
    }
  }
}
