import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

// Import your actual paths
import '../../../../core/utils/snackbar_helper.dart';
import '../../domain/entities/osago_vehicle.dart';
import '../../logic/bloc/osago_bloc.dart';
import '../../logic/bloc/osago_event.dart';
import '../../logic/bloc/osago_state.dart';
import '../../utils/osago_utils.dart';
import '../../utils/upper_case_text_formatter.dart';
import '../widgets/section_header.dart';
import '../widgets/select_input.dart';
import '../widgets/series_number_widget.dart';
import '../widgets/period_selection_sheet.dart';
import '../widgets/selection_sheet.dart';
import 'osago_company_screen.dart';

// --- CUSTOM LICENSE PLATE WIDGET (1:1 UI) ---

// --- SMART FORMATTER (AVTOMATIK FORMATLASH UCHUN) ---
class UzbekPlateNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Faqat harf va raqamlarni qoldiramiz, bo'sh joylarni olib tashlaymiz
    String text = newValue.text.toUpperCase().replaceAll(' ', '').replaceAll(RegExp(r'[^A-Z0-9]'), '');
    
    if (text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final buffer = StringBuffer();

    // MANTIQ:
    // Agar birinchi belgi RAQAM bo'lsa -> Yuridik (000 AAA)
    // Agar birinchi belgi HARF bo'lsa -> Jismoniy (A 000 AA)

    bool isDigitStart = RegExp(r'^\d').hasMatch(text);

    if (isDigitStart) {
      // YURIDIK: 123 ABC
      for (int i = 0; i < text.length; i++) {
        if (i == 3) buffer.write(' '); // 3-raqamdan keyin probel
        buffer.write(text[i]);
      }
    } else {
      // JISMONIY: A 123 AA
      for (int i = 0; i < text.length; i++) {
        if (i == 1) buffer.write(' '); // 1-harfdan keyin probel
        if (i == 4) buffer.write(' '); // 4-raqamdan keyin probel
        buffer.write(text[i]);
      }
    }

    final formatted = buffer.toString();

    // Kursor pozitsiyasini to'g'ri sozlash
    // Eski va yangi matnlarni solishtirish
    String oldTextWithoutSpaces = oldValue.text.replaceAll(' ', '');
    int oldTextLength = oldTextWithoutSpaces.length;
    int newTextLength = text.length;
    
    // Kursor qaysi pozitsiyada edi (bo'sh joylarsiz)
    int cursorInOldText = 0;
    for (int i = 0; i < newValue.selection.baseOffset && i < newValue.text.length; i++) {
      if (newValue.text[i] != ' ') {
        cursorInOldText++;
      }
    }
    
    // Agar belgi qo'shilgan bo'lsa, kursor pozitsiyasini oxiriga qo'yamiz
    if (newTextLength > oldTextLength) {
      cursorInOldText = newTextLength;
    }
    // Agar belgi o'chirilgan bo'lsa, kursor pozitsiyasini saqlaymiz
    else {
      cursorInOldText = cursorInOldText.clamp(0, newTextLength);
    }
    
    // Yangi matndagi kursor pozitsiyasini hisoblash (bo'sh joylar bilan)
    int newCursorPos = cursorInOldText;
    
    // Bo'sh joylarni qo'shish
    if (isDigitStart) {
      // YURIDIK: 123 ABC -> probel 3-raqamdan keyin
      if (newCursorPos > 3) newCursorPos += 1;
    } else {
      // JISMONIY: A 123 AA -> probellar 1-harfdan keyin va 4-raqamdan keyin
      if (newCursorPos > 1) newCursorPos += 1;
      if (newCursorPos > 5) newCursorPos += 1;
    }
    
    // Kursor pozitsiyasini cheklash
    newCursorPos = newCursorPos.clamp(0, formatted.length);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }
}

// --- MUKAMMAL LICENSE PLATE WIDGET ---
class UzbekLicensePlateInput extends StatefulWidget {
  final TextEditingController regionController;
  final TextEditingController numberController;
  // Validatsiya xatosi bo'lsa qizil qilish uchun
  final bool hasError;

  const UzbekLicensePlateInput({
    super.key,
    required this.regionController,
    required this.numberController,
    this.hasError = false,
  });

  @override
  State<UzbekLicensePlateInput> createState() => _UzbekLicensePlateInputState();
}

class _UzbekLicensePlateInputState extends State<UzbekLicensePlateInput> {
  final FocusNode _regionFocus = FocusNode();
  final FocusNode _numberFocus = FocusNode();

  @override
  void dispose() {
    _regionFocus.dispose();
    _numberFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dark mode tekshiruvi
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Ranglar
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final borderColor = widget.hasError
        ? Colors.red
        : (isDark ? Colors.grey[600]! : Colors.black);
    final dividerColor = isDark ? Colors.grey[600]! : Colors.black;
    final hintColor = isDark ? Colors.grey[500]! : Colors.grey.shade300;
    final boltColor = isDark ? Colors.grey[500]! : Colors.grey.shade400;
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.5)
        : Colors.black.withOpacity(0.08);

    // Shrift uslubi (Haqiqiy raqamga o'xshash)
    final TextStyle plateTextStyle = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 26, // Biroz kichraytirdik, sig'ishi uchun
      fontWeight: FontWeight.w900,
      color: textColor,
      height: 1.2,
    );

    return Container(
      height: 58, // Standart balandlik
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        // Tashqi ramka
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. REGION (01)
          SizedBox(
            width: 65,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: widget.regionController,
                  builder: (context, value, child) {
                    return TextField(
                      controller: widget.regionController,
                      focusNode: _regionFocus,
                      textAlign: TextAlign.center,
                      style: plateTextStyle.copyWith(
                        color: value.text.isEmpty ? hintColor : textColor,
                      ),
                      maxLength: 2,
                      keyboardType: TextInputType.number,
                      // Input ichidagi chiziqlarni yo'qotish
                      decoration: InputDecoration(
                        hintText: "01",
                        hintStyle: plateTextStyle.copyWith(color: hintColor),
                        counterText: "",
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        if (value.length == 2) {
                          _numberFocus.requestFocus();
                        }
                      },
                    );
                  },
                ),
                // Chap Bolt (Vizual)
                Positioned(
                  left: 6,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: boltColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.5)
                              : Colors.black12,
                          blurRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. VERTIKAL CHIZIQ
          Container(width: 1.5, height: double.infinity, color: dividerColor),

          // 3. ASOSIY RAQAM (Avtomatik Formatlash bilan)
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 35,
                  ), // O'ngdan joy qoldiramiz (Bayroq uchun emas, bolt uchun)
                  child: TextField(
                    controller: widget.numberController,
                    focusNode: _numberFocus,
                    textAlign: TextAlign.center,
                    style: plateTextStyle.copyWith(letterSpacing: 2.0),
                    textCapitalization: TextCapitalization.characters,
                    // Input ichidagi chiziqlarni yo'qotish
                    decoration: InputDecoration(
                      hintText: "A 123 AA",
                      hintStyle: plateTextStyle.copyWith(color: hintColor),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      counterText: "",
                      isDense: true,
                    ),
                    inputFormatters: [
                      // Faqat harf va raqam (bo'sh joylarsiz)
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                      UpperCaseTextFormatter(),
                      // Biz yozgan Smart Formatter (avtomatik formatlash)
                      UzbekPlateNumberFormatter(),
                      LengthLimitingTextInputFormatter(
                        10,
                      ), // Maksimal uzunlik (probel bilan)
                    ],
                    onChanged: (value) {
                      if (value.isEmpty) {
                        _regionFocus.requestFocus();
                      }
                    },
                  ),
                ),
                // O'ng Bolt (Vizual)
                Positioned(
                  right: 42,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: boltColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.5)
                              : Colors.black12,
                          blurRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. BAYROQ VA "UZ" KODI
          Container(
            width: 38,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Chizilgan Bayroq
                Container(
                  height: 18,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(color: const Color(0xFF0099B5)),
                      ), // Moviy
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          child: Center(
                            child: Container(height: 0.5, color: Colors.red),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(color: const Color(0xFF1EB53A)),
                      ), // Yashil
                    ],
                  ),
                ),
                // UZ yozuvi
                const Text(
                  "UZ",
                  style: TextStyle(
                    color: Color(0xFF0099B5),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- END CUSTOM WIDGET ---

class OsagoVehicleScreen extends StatefulWidget {
  const OsagoVehicleScreen({super.key});

  @override
  State<OsagoVehicleScreen> createState() => _OsagoVehicleScreenState();
}

class _OsagoVehicleScreenState extends State<OsagoVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _navigated = false;
  bool _isSubmitting = false;
  bool _isRestoring = false; // Restore flag

  final _regionCtrl = TextEditingController();
  final _carNumberCtrl = TextEditingController();
  final _passportCtrl = TextEditingController();
  final _techSeriesCtrl = TextEditingController();
  final _techNumberCtrl = TextEditingController();
  final _periodCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passportCtrl.addListener(_onPassportChanged);
    _techSeriesCtrl.addListener(_onTechPassportChanged);
    _techNumberCtrl.addListener(_onTechPassportChanged);
    // Настройка статус-бара для темного режима
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
          ),
        );
        
        // State'dan ma'lumotlarni restore qilish (orqaga qaytganda)
        _restoreStateFromBloc();
      }
    });
  }

  void _restoreStateFromBloc() {
    // Restore flag'ni o'rnatish - listener'larni o'chirish uchun
    _isRestoring = true;
    
    try {
      final currentState = context.read<OsagoBloc>().state;
      
      // Vehicle ma'lumotlarini restore qilish
      if (currentState.vehicle != null) {
        final vehicle = currentState.vehicle!;
        final gosNumber = vehicle.gosNumber;
        
        // GosNumber ni region va number ga ajratish
        if (gosNumber.length >= 2) {
          _regionCtrl.text = gosNumber.substring(0, 2);
          if (gosNumber.length > 2) {
            final numberPart = gosNumber.substring(2);
            // Formatlash: A 123 AA yoki 123 ABC
            if (numberPart.length > 0) {
              _carNumberCtrl.text = numberPart;
            }
          }
        }
        
        // Passport ma'lumotlarini restore qilish
        if (vehicle.ownerPassportSeria.isNotEmpty && vehicle.ownerPassportNumber.isNotEmpty) {
          _passportCtrl.text = '${vehicle.ownerPassportSeria}${vehicle.ownerPassportNumber}';
        }
        
        // Tech passport ma'lumotlarini restore qilish
        if (vehicle.techSeria.isNotEmpty) {
          _techSeriesCtrl.text = vehicle.techSeria;
        }
        if (vehicle.techNumber.isNotEmpty) {
          _techNumberCtrl.text = vehicle.techNumber;
        }
      }
      
      // Period ma'lumotlarini restore qilish
      if (currentState.periodId != null) {
        String periodDisplay;
        if (currentState.periodId == '6') {
          periodDisplay = 'insurance.osago.vehicle.period_6_months'.tr();
        } else if (currentState.periodId == '12') {
          periodDisplay = 'insurance.osago.vehicle.period_12_months'.tr();
        } else {
          periodDisplay = OsagoUtils.mapIdToPeriod(currentState.periodId) ?? '';
        }
        if (periodDisplay.isNotEmpty) {
          _periodCtrl.text = periodDisplay;
        }
      }
      
      // OSAGO type ma'lumotlarini restore qilish
      if (currentState.osagoType != null && currentState.osagoType!.isNotEmpty) {
        _typeCtrl.text = currentState.osagoType!;
      }
      
      // Navigation flag'ni reset qilish
      _navigated = false;
      _isSubmitting = false;
    } finally {
      // Restore tugagach, flag'ni o'chirish
      _isRestoring = false;
    }
  }

  void _onPassportChanged() {
    _updateVehicleData();
  }

  void _onTechPassportChanged() {
    _updateVehicleData();
  }

  void _updateVehicleData() {
    // Restore paytida listener'larni skip qilish
    if (_isRestoring) {
      return;
    }
    
    final passportText = _passportCtrl.text.replaceAll(' ', '').toUpperCase();
    final passportFilled =
        passportText.length == 9 &&
        RegExp(r'^[A-Z]{2}\d{7}$').hasMatch(passportText);
    final techPassportFilled =
        _techSeriesCtrl.text.trim().length == 3 &&
        _techNumberCtrl.text.trim().length == 7;

    if (passportFilled && techPassportFilled) {
      final passportSeria = passportText.substring(0, 2);
      final passportNumber = passportText.substring(2);
      final fullGosNumber = OsagoUtils.normalizeGosNumber(
        _regionCtrl.text,
        _carNumberCtrl.text,
      );

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

      if (mounted) {
        context.read<OsagoBloc>().add(
          LoadVehicleData(
            vehicle: vehicle,
            drivers: const [],
            osagoType: _typeCtrl.text,
            periodId: null,
            gosNumber: fullGosNumber,
            birthDate: vehicle.ownerBirthDate,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _passportCtrl.removeListener(_onPassportChanged);
    _techSeriesCtrl.removeListener(_onTechPassportChanged);
    _techNumberCtrl.removeListener(_onTechPassportChanged);
    _regionCtrl.dispose();
    _carNumberCtrl.dispose();
    _passportCtrl.dispose();
    _techSeriesCtrl.dispose();
    _techNumberCtrl.dispose();
    _periodCtrl.dispose();
    _typeCtrl.dispose();
    super.dispose();
  }

  void _showPeriodSelectionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PeriodSelectionSheet(
        onSelected: (value) {
          setState(() {
            _periodCtrl.text = value;
          });
        },
      ),
    );
  }

  void _showSelectionSheet(
    String title,
    List<String> items,
    TextEditingController controller,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SelectionSheet(
        title: title,
        items: items,
        onSelected: (value) {
          setState(() {
            controller.text = value;
          });
        },
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      SnackbarHelper.showError(
        context,
        'insurance.osago.vehicle.errors.fill_all_fields'.tr(),
      );
      return;
    }

    // Combine Region + Number
    final fullGosNumber =
        "${_regionCtrl.text}${_carNumberCtrl.text.replaceAll(' ', '')}"
            .toUpperCase();

    // Basic length validation (Region 2 + at least 4 chars)
    if (_regionCtrl.text.length != 2 || _carNumberCtrl.text.length < 4) {
      SnackbarHelper.showError(
        context,
        'insurance.osago.vehicle.errors.invalid_car_number'.tr(),
      );
      return;
    }

    final periodId = OsagoUtils.mapPeriodToId(_periodCtrl.text);
    if (periodId == null) {
      SnackbarHelper.showError(
        context,
        'insurance.osago.vehicle.errors.select_period'.tr(),
      );
      return;
    }

    if (_typeCtrl.text.isEmpty) {
      SnackbarHelper.showError(
        context,
        'insurance.osago.vehicle.errors.not_selected'.tr(),
      );
      return;
    }

    final passportText = _passportCtrl.text.replaceAll(' ', '').toUpperCase();
    final passportSeria = passportText.length >= 2
        ? passportText.substring(0, 2)
        : '';
    final passportNumber = passportText.length > 2
        ? passportText.substring(2)
        : '';

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

    setState(() {
      _isSubmitting = true;
    });

    context.read<OsagoBloc>().add(
      FetchVehicleInfo(
        vehicle: vehicle,
        osagoType: _typeCtrl.text,
        periodId: periodId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OsagoBloc, OsagoState>(
      listener: (context, state) {
        if (state is OsagoFailure && state.errorMessage != null) {
          setState(() {
            _isSubmitting = false;
          });
          SnackbarHelper.showError(context, state.errorMessage!);
        }
        if (state is OsagoVehicleFilled &&
            state.vehicle != null &&
            !_navigated &&
            _isSubmitting) {
          _navigated = true;
          _isSubmitting = false;
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

        if (state is OsagoFailure) {
          setState(() {
            _isSubmitting = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('insurance.osago.vehicle.title'.tr()),
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0.5,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
          titleTextStyle: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                Theme.of(context).brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- CAR NUMBER SECTION (UPDATED) ---
                        SectionHeader(
                          'insurance.osago.vehicle.car_number'.tr(),
                        ),
                        SizedBox(height: 8.h),
                        UzbekLicensePlateInput(
                          regionController: _regionCtrl,
                          numberController: _carNumberCtrl,
                        ),
                        SizedBox(height: 24.h),

                        // --- PASSPORT SECTION ---
                        SectionHeader('insurance.osago.vehicle.passport'.tr()),
                        SizedBox(height: 8.h),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _passportCtrl,
                          builder: (context, value, child) {
                            return TextFormField(
                              controller: _passportCtrl,
                              textCapitalization: TextCapitalization.characters,
                              inputFormatters: [
                                UpperCaseTextFormatter(),
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[A-Z0-9]'),
                                ),
                              ],
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                              ),
                              decoration: InputDecoration(
                                hintText: "AA1234567",
                                hintStyle: TextStyle(
                                  color: Theme.of(context).hintColor,
                                ),
                                filled: true,
                                fillColor: Theme.of(context).cardColor,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'insurance.osago.vehicle.errors.enter_passport'
                                      .tr();
                                }
                                final cleaned = v
                                    .replaceAll(' ', '')
                                    .toUpperCase();
                                if (!RegExp(
                                  r'^[A-Z]{2}\d{7}$',
                                ).hasMatch(cleaned)) {
                                  return 'insurance.osago.vehicle.errors.passport_format'
                                      .tr();
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        SizedBox(height: 24.h),

                        // --- TECH PASSPORT SECTION ---
                        SectionHeader(
                          'insurance.osago.vehicle.tech_passport'.tr(),
                        ),
                        SizedBox(height: 8.h),
                        SeriesNumberWidget(
                          seriesCtrl: _techSeriesCtrl,
                          numberCtrl: _techNumberCtrl,
                          seriesHint: "AAG",
                          numberHint: "1234567",
                          isTechPassport: true,
                        ),
                        SizedBox(height: 24.h),

                        // --- PERIOD SECTION ---
                        SectionHeader(
                          'insurance.osago.vehicle.insurance_period'.tr(),
                        ),
                        SizedBox(height: 8.h),
                        SelectInput(
                          controller: _periodCtrl,
                          hint: 'insurance.osago.vehicle.select'.tr(),
                          onTap: () => _showPeriodSelectionSheet(),
                        ),
                        SizedBox(height: 24.h),

                        // --- OSAGO TYPE SECTION ---
                        SectionHeader(
                          'insurance.osago.vehicle.osago_type'.tr(),
                        ),
                        SizedBox(height: 8.h),
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
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),

              // --- SUBMIT BUTTON ---
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 30.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSubmitting
                        ? Shimmer.fromColors(
                            baseColor: Colors.white70,
                            highlightColor: Colors.white,
                            child: Text(
                              'insurance.osago.company.loading_data'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : Text(
                            'insurance.osago.vehicle.continue'.tr(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
