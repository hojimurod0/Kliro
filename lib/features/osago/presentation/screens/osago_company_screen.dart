import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/osago_insurance.dart';
import '../../logic/bloc/osago_bloc.dart';
import '../../logic/bloc/osago_event.dart';
import '../../logic/bloc/osago_state.dart';
import '../../utils/osago_utils.dart';
import 'osago_preview_screen.dart';

// -----------------------------------------------------------------------------
// CONSTANTS & THEME
// -----------------------------------------------------------------------------
class AppColors {
  static const Color primary = Color(0xFF0095F6);
  static const Color background = Color(0xFFF5F5F5);
  static const Color textGrey = Color(0xFF757575);
  static const Color borderGrey = Color(0xFFE0E0E0);
}

class OsagoCompanyScreen extends StatefulWidget {
  const OsagoCompanyScreen({super.key});

  @override
  State<OsagoCompanyScreen> createState() => _OsagoCompanyScreenState();
}

class _OsagoCompanyScreenState extends State<OsagoCompanyScreen> {
  // --- CONTROLLERS & KEYS ---
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _dateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _periodController = TextEditingController();

  final Map<String, String> _providers = {
    'gross': 'Gross Insurance',
    'neo': 'NEO Insurance',
    'gusto': 'GUSTO Insurance',
  };

  String _selectedProvider = 'gross';
  DateTime? _startDate;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    log('[OSAGO_COMPANY] initState: Ekran ochildi', name: 'OSAGO');
    
    // State dan periodId ni olish va ko'rsatish
    final currentState = context.read<OsagoBloc>().state;
    log('[OSAGO_COMPANY] Current state: periodId=${currentState.periodId}, osagoType=${currentState.osagoType}', name: 'OSAGO');
    
    if (currentState.periodId != null) {
      final periodDisplay = OsagoUtils.mapIdToPeriod(currentState.periodId);
      if (periodDisplay != null) {
        _periodController.text = periodDisplay;
        log('[OSAGO_COMPANY] Period ID mapping: ${currentState.periodId} -> $periodDisplay', name: 'OSAGO');
      }
    }
    
    // OSAGO type ga qarab kompaniyani avtomatik tanlash
    final osagoType = currentState.osagoType;
    if (osagoType != null) {
      final typeLower = osagoType.toLowerCase();
      log('[OSAGO_COMPANY] OSAGO type aniqlash: $osagoType (lowercase: $typeLower)', name: 'OSAGO');
      
      if (typeLower.contains('cheklangan')) {
        // Cheklangan -> Gross Insurance (gusto not implemented on server)
        _selectedProvider = 'gross';
        _companyController.text = _providers[_selectedProvider]!;
        log('[OSAGO_COMPANY] ✅ Avtomatik tanlandi: Cheklangan -> Gross Insurance', name: 'OSAGO');
      } else if (typeLower.contains('cheklanmagan')) {
        // Cheklanmagan -> NEO Insurance
        _selectedProvider = 'neo';
        _companyController.text = _providers[_selectedProvider]!;
        log('[OSAGO_COMPANY] ✅ Avtomatik tanlandi: Cheklanmagan -> NEO Insurance', name: 'OSAGO');
      } else {
        // Default: Gross Insurance
        _companyController.text = _providers[_selectedProvider]!;
        log('[OSAGO_COMPANY] ⚠️ Default kompaniya: Gross Insurance (osagoType=$osagoType)', name: 'OSAGO');
      }
    } else {
      // Default: Gross Insurance
      _companyController.text = _providers[_selectedProvider]!;
      log('[OSAGO_COMPANY] ⚠️ Default kompaniya: Gross Insurance (osagoType null)', name: 'OSAGO');
    }
    
    log('[OSAGO_COMPANY] Tanlangan kompaniya: $_selectedProvider -> ${_companyController.text}', name: 'OSAGO');
  }

  @override
  void dispose() {
    _companyController.dispose();
    _dateController.dispose();
    _phoneController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  // --- ACTIONS (Funksiyalar) ---
  // Sanani tanlash funksiyasi
  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now;
    final DateTime lastDate = now.add(const Duration(days: 30));

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now.add(const Duration(days: 1)),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primary,
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Sanani dd.MM.yyyy formatiga o'tkazish
        _dateController.text = OsagoUtils.formatDateForDisplay(picked);
      });
    }
  }


  // Period tanlash
  void _showPeriodSelection() {
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
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Muddatni tanlang',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              ...['6 oy', '1 yil'].map((period) => ListTile(
                    title: Text(period),
                    onTap: () {
                      setState(() {
                        _periodController.text = period;
                      });
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  // Formani yuborish funksiyasi
  void _submitForm() {
    log('[OSAGO_COMPANY] Submit bosildi', name: 'OSAGO');
    
    if (_formKey.currentState!.validate()) {
      if (_startDate == null) {
        log('[OSAGO_COMPANY] ❌ Boshlanish sanasi tanlanmagan', name: 'OSAGO');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Boshlanish sanasini tanlang")),
        );
        return;
      }

      // Period ID mapping
      final periodId = OsagoUtils.mapPeriodToId(_periodController.text);
      if (periodId == null) {
        log('[OSAGO_COMPANY] ❌ Period ID topilmadi: ${_periodController.text}', name: 'OSAGO');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sug'urta muddatini tanlang")),
        );
        return;
      }

      // Telefon raqamini normalizatsiya qilish va validatsiya
      final phoneText = _phoneController.text.trim();
      final normalizedPhone = OsagoUtils.normalizePhoneNumber(phoneText);
      log('[OSAGO_COMPANY] Telefon raqami: $phoneText -> $normalizedPhone', name: 'OSAGO');
      
      if (!OsagoUtils.isValidPhoneNumber(normalizedPhone)) {
        log('[OSAGO_COMPANY] ❌ Telefon raqami noto\'g\'ri: $normalizedPhone', name: 'OSAGO');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Telefon raqami noto'g'ri formatda")),
        );
        return;
      }

      // State dan numberDriversId ni olish (calc response dan kelgan)
      final currentState = context.read<OsagoBloc>().state;
      log('[OSAGO_COMPANY] State dan olingan: numberDriversId=${currentState.numberDriversId}, osagoType=${currentState.osagoType}', name: 'OSAGO');
      
      // Fallback: agar numberDriversId bo'lmasa, provider va OSAGO type dan map qilamiz
      String numberDriversId = currentState.numberDriversId ?? '5'; // Default: limited
      if (numberDriversId != '0' && numberDriversId != '5') {
        log('[OSAGO_COMPANY] ⚠️ numberDriversId noto\'g\'ri ($numberDriversId), mapping qilinmoqda...', name: 'OSAGO');
        // Noto'g'ri qiymat bo'lsa, provider va OSAGO type dan map qilamiz
        final osagoType = currentState.osagoType;
        final provider = _selectedProvider;
        
        // Provider ga qarab mapping (ustunlik)
        final providerLower = provider.toLowerCase();
        if (providerLower == 'neo') {
          // NEO -> cheklanmagan (0) - nechta bo'lsa, hammasini qo'shadi
          numberDriversId = '0';
          log('[OSAGO_COMPANY] Mapping: NEO -> cheklanmagan (0)', name: 'OSAGO');
        } else if (providerLower == 'gusto') {
          // GUSTO -> cheklangan (5) - 5 tagacha
          numberDriversId = '5';
          log('[OSAGO_COMPANY] Mapping: GUSTO -> cheklangan (5)', name: 'OSAGO');
        } else if (providerLower == 'gross') {
          // GROSS -> default (5)
          numberDriversId = '5';
          log('[OSAGO_COMPANY] Mapping: GROSS -> default (5)', name: 'OSAGO');
        } else {
          // OSAGO type dan map qilish
          if (osagoType != null && osagoType.toLowerCase().contains('cheklanmagan')) {
            numberDriversId = '0';
            log('[OSAGO_COMPANY] Mapping: OSAGO type (cheklanmagan) -> 0', name: 'OSAGO');
          } else {
            numberDriversId = '5';
            log('[OSAGO_COMPANY] Mapping: OSAGO type (default) -> 5', name: 'OSAGO');
          }
        }
      }

      log('[OSAGO_COMPANY] ✅ Final numberDriversId: $numberDriversId', name: 'OSAGO');

      final insurance = OsagoInsurance(
        provider: _selectedProvider,
        companyName: _providers[_selectedProvider]!,
        periodId: periodId, // Mapping qilingan periodId
        numberDriversId: numberDriversId, // State dan yoki calc response dan
        startDate: _startDate!,
        phoneNumber: normalizedPhone,
        ownerInn: '',
        isUnlimited: false,
      );
      
      log('[OSAGO_COMPANY] Insurance yaratildi: provider=$_selectedProvider, periodId=$periodId, numberDriversId=$numberDriversId, startDate=${_startDate}', name: 'OSAGO');
      log('[OSAGO_COMPANY] LoadInsuranceCompany event yuborilmoqda', name: 'OSAGO');
      
      _navigated = false;
      context.read<OsagoBloc>().add(LoadInsuranceCompany(insurance));
    } else {
      log('[OSAGO_COMPANY] ❌ Form validatsiyasi o\'tmadi', name: 'OSAGO');
    }
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
        if (state is OsagoCalcSuccess && !_navigated) {
          _navigated = true;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<OsagoBloc>(),
                child: const OsagoPreviewScreen(),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            "OSAGO",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Sug'urta kompaniyasi",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // 1. Kompaniyani tanlash (avtomatik tanlangan)
                          CustomInputField(
                            controller: _companyController,
                            label: "Kompaniyani tanlang",
                            hintText: "Tanlash",
                            readOnly: true,
                            suffixIcon: Icons.keyboard_arrow_down,
                            onTap: null, // Avtomatik tanlangan, o'zgartirib bo'lmaydi
                            validator: (value) =>
                                value!.isEmpty ? "Kompaniyani kiriting" : null,
                          ),
                          const SizedBox(height: 16),
                          // 2. Period tanlash
                          CustomInputField(
                            controller: _periodController,
                            label: "Sug'urta muddati",
                            hintText: "Tanlang",
                            readOnly: true,
                            suffixIcon: Icons.keyboard_arrow_down,
                            onTap: _showPeriodSelection,
                            validator: (value) =>
                                value!.isEmpty ? "Muddatni tanlang" : null,
                          ),
                          const SizedBox(height: 16),
                          // 3. Boshlanish sanasi (DatePicker bilan)
                          CustomInputField(
                            controller: _dateController,
                            label: "Boshlanish sanasi",
                            hintText: "dd.MM.yyyy",
                            prefixIcon: Icons.calendar_today_outlined,
                            readOnly: true,
                            onTap: _selectDate,
                            validator: (value) =>
                                value!.isEmpty ? "Sanani tanlang" : null,
                          ),
                          const SizedBox(height: 16),
                          // 4. Telefon raqami
                          CustomInputField(
                            controller: _phoneController,
                            label: "Telefon raqami",
                            hintText: "-- --- -- --",
                            prefixIcon: Icons.phone_outlined,
                            isPhoneField: true,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(9),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Telefon raqamini kiriting";
                              }
                              final normalized = OsagoUtils.normalizePhoneNumber(value);
                              if (!OsagoUtils.isValidPhoneNumber(normalized)) {
                                return "9 ta raqam bo'lishi kerak";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Pastki Button qismi
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                child: SafeArea(
                  top: false,
                  child: BlocBuilder<OsagoBloc, OsagoState>(
                    buildWhen: (previous, current) =>
                        previous is OsagoLoading != current is OsagoLoading,
                    builder: (context, state) {
                      final isLoading = state is OsagoLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                "Davom etish",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- OPTIMAL REUSABLE WIDGET ---
class CustomInputField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPhoneField;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const CustomInputField({
    super.key,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPhoneField = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 8),
        // Input Field
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            // Prefix Logic
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(prefixIcon, color: AppColors.primary, size: 22),
                        if (isPhoneField) ...[
                          const SizedBox(width: 8),
                          const Text(
                            "+998",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            height: 20,
                            width: 1,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(width: 8),
                        ]
                      ],
                    ),
                  )
                : null,
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: Colors.grey)
                : null,
            // Borders
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
