import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/osago_driver.dart';
import '../../domain/entities/osago_vehicle.dart';
import '../../logic/bloc/osago_bloc.dart';
import '../../logic/bloc/osago_event.dart';
import '../../logic/bloc/osago_state.dart';
import '../../utils/osago_utils.dart';
import 'osago_company_screen.dart';

// -----------------------------------------------------------------------------
// GLOBAL THEME & CONSTANTS (Dizayn tizimi)
// -----------------------------------------------------------------------------
class AppColors {
  static const primary = Color(0xFF2F80ED); // Zamonaviy ko'k
  static const background = Color(0xFFF9FAFB);
  static const textMain = Color(0xFF111827);
  static const textGrey = Color(0xFF9CA3AF);
  static const border = Color(0xFFE5E7EB);
  static const white = Colors.white;
}

class OsagoVehicleScreen extends StatefulWidget {
  const OsagoVehicleScreen({super.key});

  @override
  State<OsagoVehicleScreen> createState() => _OsagoVehicleScreenState();
}

class _OsagoVehicleScreenState extends State<OsagoVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _regionCtrl = TextEditingController(text: "01");
  final _carNumberCtrl = TextEditingController();
  final _passportCtrl = TextEditingController(); // Bitta maydon: AA 1234567
  final _techSeriesCtrl = TextEditingController();
  final _techNumberCtrl = TextEditingController();
  final _periodCtrl = TextEditingController(); // Muddati
  final _typeCtrl = TextEditingController(); // Turi
  final _licenseSeriaCtrl = TextEditingController(); // License seria
  final _licenseNumberCtrl = TextEditingController(); // License number

  @override
  void dispose() {
    // Xotirani tozalash
    for (var c in [
      _regionCtrl,
      _carNumberCtrl,
      _passportCtrl,
      _techSeriesCtrl,
      _techNumberCtrl,
      _periodCtrl,
      _typeCtrl,
      _licenseSeriaCtrl,
      _licenseNumberCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // Modal ochish uchun universal funksiya
  void _showSelectionSheet(
    String title,
    List<String> items,
    TextEditingController controller,
    VoidCallback? onSelected,
  ) {
    log('[OSAGO_VEHICLE] Modal ochildi: $title, variantlar: $items', name: 'OSAGO');
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(items[index]),
                      onTap: () {
                        final selectedValue = items[index];
                        log('[OSAGO_VEHICLE] Tanlandi: $title -> $selectedValue', name: 'OSAGO');
                        controller.text = selectedValue;
                        Navigator.pop(context);
                        if (onSelected != null) {
                          onSelected();
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  void _submit() {
    log('[OSAGO_VEHICLE] Submit bosildi', name: 'OSAGO');
    
    if (!_formKey.currentState!.validate()) {
      log('[OSAGO_VEHICLE] ❌ Validatsiya xatosi: barcha maydonlar to\'ldirilmagan', name: 'OSAGO');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('insurance.osago.vehicle.errors.fill_all_fields'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validatsiya: GosNumber format
    final fullGosNumber = OsagoUtils.normalizeGosNumber(
      _regionCtrl.text,
      _carNumberCtrl.text,
    );
    log('[OSAGO_VEHICLE] GosNumber: $_regionCtrl.text + $_carNumberCtrl.text = $fullGosNumber', name: 'OSAGO');
    
    if (!OsagoUtils.isValidGosNumber(fullGosNumber)) {
      log('[OSAGO_VEHICLE] ❌ GosNumber noto\'g\'ri format: $fullGosNumber', name: 'OSAGO');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('insurance.osago.vehicle.errors.invalid_car_number'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }


    // Period ID mapping
    final periodId = OsagoUtils.mapPeriodToId(_periodCtrl.text);
    if (periodId == null) {
      log('[OSAGO_VEHICLE] ❌ Period ID topilmadi: ${_periodCtrl.text}', name: 'OSAGO');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('insurance.osago.vehicle.errors.select_period'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    log('[OSAGO_VEHICLE] ✅ Barcha validatsiyalar o\'tdi', name: 'OSAGO');
    log('[OSAGO_VEHICLE] Ma\'lumotlar: gosNumber=$fullGosNumber, periodId=$periodId, osagoType=${_typeCtrl.text}', name: 'OSAGO');

    // Passport ma'lumotlarini ajratish (AA 1234567 -> AA va 1234567)
    final passportText = _passportCtrl.text.replaceAll(' ', '').toUpperCase();
    final passportSeria = passportText.length >= 2 ? passportText.substring(0, 2) : '';
    final passportNumber = passportText.length > 2 ? passportText.substring(2) : '';

    // OsagoVehicle yaratish - tez operatsiya
    final vehicle = OsagoVehicle(
      brand: '',
      model: '',
      gosNumber: fullGosNumber,
      techSeria: OsagoUtils.normalizeTechPassportSeria(_techSeriesCtrl.text),
      techNumber: OsagoUtils.normalizePassportNumber(_techNumberCtrl.text),
      ownerPassportSeria: OsagoUtils.normalizePassportSeria(passportSeria),
      ownerPassportNumber: OsagoUtils.normalizePassportNumber(passportNumber),
      ownerBirthDate: DateTime.now(),
      isOwner: true,
    );

    // OsagoDriver yaratish - tez operatsiya
    final driver = OsagoDriver(
      passportSeria: vehicle.ownerPassportSeria,
      passportNumber: vehicle.ownerPassportNumber,
      driverBirthday: vehicle.ownerBirthDate,
      relative: 0,
      name: null,
      licenseSeria: _licenseSeriaCtrl.text.trim().isNotEmpty
          ? _licenseSeriaCtrl.text.trim().toUpperCase()
          : null,
      licenseNumber: _licenseNumberCtrl.text.trim().isNotEmpty
          ? _licenseNumberCtrl.text.trim()
          : null,
    );

    log('[OSAGO_VEHICLE] Vehicle va Driver yaratildi', name: 'OSAGO');
    log('[OSAGO_VEHICLE] LoadVehicleData event yuborilmoqda: osagoType=${_typeCtrl.text}, periodId=$periodId', name: 'OSAGO');

    // BLoC ga event yuborish - tez operatsiya
    context.read<OsagoBloc>().add(
          LoadVehicleData(
            vehicle: vehicle,
            drivers: <OsagoDriver>[driver],
            osagoType: _typeCtrl.text,
            periodId: periodId,
            gosNumber: fullGosNumber,
            birthDate: vehicle.ownerBirthDate,
          ),
        );

    log('[OSAGO_VEHICLE] Navigation: OsagoCompanyScreen ga o\'tish', name: 'OSAGO');

    // Navigation ni keyingi frame da bajarish - UI ni bloklamaydi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<OsagoBloc>(),
              child: const OsagoCompanyScreen(),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OsagoBloc, OsagoState>(
      listener: (context, state) {
        if (state is OsagoFailure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('insurance.osago.vehicle.title'.tr()),
          backgroundColor: AppColors.white,
          elevation: 0.5,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.textMain),
          titleTextStyle: const TextStyle(
            color: AppColors.textMain,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Avto Raqam
                        SectionHeader('insurance.osago.vehicle.car_number'.tr()),
                        LicensePlateWidget(
                          regionCtrl: _regionCtrl,
                          numberCtrl: _carNumberCtrl,
                        ),
                        const SizedBox(height: 20),
                        // 2. Passport va Tex Passport
                        SectionHeader('insurance.osago.vehicle.passport'.tr()),
                        TextFormField(
                          controller: _passportCtrl,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            UpperCaseTextFormatter(),
                            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9\s]')),
                          ],
                          decoration: const InputDecoration(
                            hintText: "AA 1234567",
                            counterText: "",
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'insurance.osago.vehicle.errors.enter_passport'.tr();
                            }
                            final cleaned = v.replaceAll(' ', '').toUpperCase();
                            if (cleaned.length < 9 || cleaned.length > 9) {
                              return 'insurance.osago.vehicle.errors.passport_format'.tr();
                            }
                            // Seriya: 2 harf, raqam: 7 raqam
                            if (!RegExp(r'^[A-Z]{2}\d{7}$').hasMatch(cleaned)) {
                              return 'insurance.osago.vehicle.errors.passport_format'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        SectionHeader('insurance.osago.vehicle.tech_passport'.tr()),
                        SeriesNumberWidget(
                          seriesCtrl: _techSeriesCtrl,
                          numberCtrl: _techNumberCtrl,
                          seriesHint: "AAA",
                          numberHint: "1234567",
                          isTechPassport: true,
                        ),
                        const SizedBox(height: 20),
                        // 7. Dropdownlar (Select)
                        SectionHeader('insurance.osago.vehicle.insurance_period'.tr()),
                        SelectInput(
                          controller: _periodCtrl,
                          hint: 'insurance.osago.vehicle.select'.tr(),
                          onTap: () => _showSelectionSheet(
                            'insurance.osago.vehicle.select_period'.tr(),
                            [
                              'insurance.osago.vehicle.period_6_months'.tr(),
                              'insurance.osago.vehicle.period_1_year'.tr(),
                            ],
                            _periodCtrl,
                            null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // 8. OSAGO turi
                        SectionHeader('insurance.osago.vehicle.osago_type'.tr()),
                        SelectInput(
                          controller: _typeCtrl,
                          hint: 'insurance.osago.vehicle.select'.tr(),
                          onTap: () => _showSelectionSheet(
                            'insurance.osago.vehicle.select_type'.tr(),
                            [
                              'insurance.osago.vehicle.type_limited'.tr(),
                              'insurance.osago.vehicle.type_unlimited'.tr(),
                            ],
                            _typeCtrl,
                            null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Pastki Button
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text('insurance.osago.vehicle.continue'.tr()),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// OPTIMIZED COMPONENTS (Vidjetlar)
// -----------------------------------------------------------------------------
// Sarlavha vidjeti
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    // Locale o'zgarganda rebuild qilish uchun
    final locale = context.locale;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title,
        key: ValueKey('header_${locale.toString()}_$title'),
        style: const TextStyle(
          color: AppColors.textGrey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// --- Avtomobil Raqami Vidjeti (KASKO kabi ko'rinish) ---
class LicensePlateWidget extends StatelessWidget {
  final TextEditingController regionCtrl;
  final TextEditingController numberCtrl;

  const LicensePlateWidget({
    super.key,
    required this.regionCtrl,
    required this.numberCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.grey[600]! : Colors.black;
    final flagBg = isDark ? const Color(0xFF0D47A1) : Colors.blue;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- CHAP TOMON (Region: 01) ---
          Container(
            width: 60,
            alignment: Alignment.center,
            child: TextFormField(
              controller: regionCtrl,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              maxLength: 2,
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              validator: (v) => v!.isEmpty ? 'insurance.osago.vehicle.errors.enter_region'.tr() : null,
            ),
          ),
          // --- O'NG TOMON (Raqam: A 000 AA) ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextFormField(
                controller: numberCtrl,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                maxLength: 8,
                decoration: InputDecoration(
                  hintText: "A 000 AA",
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[600]! : Colors.grey,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9\s]')),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'insurance.osago.vehicle.errors.enter_number'.tr();
                  }
                  final cleanNumber = v.replaceAll(' ', '').toUpperCase();
                  if (cleanNumber.length < 6) {
                    return 'insurance.osago.vehicle.errors.invalid_number'.tr();
                  }
                  return null;
                },
              ),
            ),
          ),
          // --- BAYROQ QISMI (UZ) ---
          Container(
            width: 35,
            decoration: BoxDecoration(
              color: flagBg,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8.5),
                bottomRight: Radius.circular(8.5),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Bayroq chiziqlari
                Container(height: 2, color: Colors.white),
                Container(height: 2, color: Colors.green),
                const SizedBox(height: 4),
                const Text(
                  'UZ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Seriya va Raqam Vidjeti (Passport / Tex Passport) ---
class SeriesNumberWidget extends StatelessWidget {
  final TextEditingController seriesCtrl;
  final TextEditingController numberCtrl;
  final String seriesHint;
  final String numberHint;
  final bool isTechPassport;
  final bool isLicense;

  const SeriesNumberWidget({
    super.key,
    required this.seriesCtrl,
    required this.numberCtrl,
    required this.seriesHint,
    required this.numberHint,
    this.isTechPassport = false,
    this.isLicense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seriya
        SizedBox(
          width: isTechPassport ? 90 : (isLicense ? 80 : 80),
          child: TextFormField(
            controller: seriesCtrl,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            maxLength: isTechPassport ? 3 : (isLicense ? 2 : 2),
            inputFormatters: [
              UpperCaseTextFormatter(),
              FilteringTextInputFormatter.allow(RegExp(r'[A-Z]')),
            ],
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: seriesHint,
              counterText: "",
            ),
            validator: (v) {
              if (isLicense) {
                // License seriyasi optional bo'lishi mumkin
                if (v != null && v.isNotEmpty) {
                  if (!OsagoUtils.isValidPassportSeria(v)) {
                    return 'insurance.osago.vehicle.errors.series_2_letters'.tr();
                  }
                }
                return null;
              }
              if (v == null || v.isEmpty) {
                return 'insurance.osago.vehicle.errors.enter_series'.tr();
              }
              if (isTechPassport) {
                if (!OsagoUtils.isValidTechPassportSeria(v)) {
                  return 'insurance.osago.vehicle.errors.series_3_letters'.tr();
                }
              } else {
                if (!OsagoUtils.isValidPassportSeria(v)) {
                  return 'insurance.osago.vehicle.errors.series_2_letters'.tr();
                }
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 10),
        // Raqam
        Expanded(
          child: TextFormField(
            controller: numberCtrl,
            keyboardType: TextInputType.number,
            maxLength: 7,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: numberHint,
              counterText: "",
            ),
            validator: (v) {
              if (isLicense) {
                // License raqami optional bo'lishi mumkin
                if (v != null && v.isNotEmpty) {
                  if (v.length != 7) {
                    return 'insurance.osago.vehicle.errors.number_7_digits'.tr();
                  }
                  if (!OsagoUtils.isValidPassportNumber(v)) {
                    return 'insurance.osago.vehicle.errors.invalid_number_format'.tr();
                  }
                }
                return null;
              }
              if (v == null || v.isEmpty) {
                return 'insurance.osago.vehicle.errors.enter_number_field'.tr();
              }
              if (v.length != 7) {
                return 'insurance.osago.vehicle.errors.number_7_digits'.tr();
              }
              if (isTechPassport) {
                if (!OsagoUtils.isValidTechPassportNumber(v)) {
                  return 'insurance.osago.vehicle.errors.invalid_number_format'.tr();
                }
              } else {
                if (!OsagoUtils.isValidPassportNumber(v)) {
                  return 'insurance.osago.vehicle.errors.invalid_number_format'.tr();
                }
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}

// --- Tanlash (Dropdown) Vidjeti ---
class SelectInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback? onTap;
  final bool enabled;

  const SelectInput({
    super.key,
    required this.controller,
    required this.hint,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: enabled,
      onTap: enabled ? onTap : null,
      validator: (v) => v!.isEmpty ? 'insurance.osago.vehicle.errors.not_selected'.tr() : null,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: const Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.textGrey,
        ),
      ),
    );
  }
}

// --- FORMATTER: Kichik harf yozsa ham KATTA qiladi ---
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
