import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../bloc/accident_bloc.dart';
import '../bloc/accident_event.dart';
import '../bloc/accident_state.dart';
import '../../utils/accident_validators.dart';
import '../../domain/entities/tariff_entity.dart';
import '../../domain/entities/region_entity.dart';
import 'tariff_selection_page.dart';
import 'region_selection_page.dart';
import 'payment_screen.dart';

// KASKO kabi ranglar
const Color _primaryBlue = Color(0xFF1976D2); // Material Blue 700

class InsuranceFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const InsuranceFormPage({super.key, this.initialData});

  @override
  State<InsuranceFormPage> createState() => _InsuranceFormPageState();
}

class _InsuranceFormPageState extends State<InsuranceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _pinflController = TextEditingController();
  final _passSeryController = TextEditingController();
  final _passNumController = TextEditingController();
  final _dateBirthController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _patronymNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _startDateController = TextEditingController();

  TariffEntity? _selectedTariff;
  RegionEntity? _selectedRegion;
  DateTime? _selectedStartDate;
  DateTime? _selectedDateBirth;
  bool _navigated = false; // Navigation flag to prevent multiple navigations
  int? _initialTariffId; // Initial tariff ID from previous screen
  bool _tariffSelected = false; // Flag to prevent multiple tariff selections
  StreamSubscription<AccidentState>?
  _tariffsSubscription; // Subscription for tariffs stream

  @override
  void initState() {
    super.initState();

    // Tariffs va Regions ni yuklash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.mounted) {
        final bloc = context.read<AccidentBloc>();
        bloc.add(const FetchTariffs());
        bloc.add(const FetchRegions());
      }
    });

    // Agar initialData bo'lsa, formani to'ldiramiz
    if (widget.initialData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fillFormFromData(widget.initialData!);
          // Tarifni tanlashni keyinroq qilamiz
          _selectInitialTariff();
        }
      });
    }
  }

  void _selectInitialTariff() {
    if (_initialTariffId == null || _tariffSelected || !mounted) return;

    final bloc = context.read<AccidentBloc>();
    final currentState = bloc.state;

    if (currentState is AccidentTariffsLoaded) {
      _selectTariffFromList(currentState.tariffs);
    } else {
      _tariffsSubscription?.cancel();
      _tariffsSubscription = bloc.stream.listen((state) {
        if (state is AccidentTariffsLoaded && mounted && !_tariffSelected) {
          _selectTariffFromList(state.tariffs);
          _tariffsSubscription?.cancel();
          _tariffsSubscription = null;
        }
      });
    }
  }

  void _selectTariffFromList(List<TariffEntity> tariffs) {
    if (_initialTariffId == null || _tariffSelected || !mounted) return;

    try {
      final tariff = tariffs.firstWhere(
        (t) => t.id == _initialTariffId,
        orElse: () =>
            tariffs.isNotEmpty ? tariffs.first : throw StateError('No tariffs'),
      );
      if (mounted) {
        setState(() {
          _selectedTariff = tariff;
          _tariffSelected = true;
        });
      }
    } catch (e) {
      // Xatolik bo'lsa, e'tiborsiz qoldiramiz
    }
  }

  void _fillFormFromData(Map<String, dynamic> data) {
    // Asosiy ma'lumotlarni to'ldirish
    if (data['lastName'] != null) {
      _lastNameController.text = data['lastName'] as String;
    }
    if (data['firstName'] != null) {
      _firstNameController.text = data['firstName'] as String;
    }
    if (data['middleName'] != null) {
      _patronymNameController.text = data['middleName'] as String;
    }
    if (data['pinfl'] != null) {
      _pinflController.text = data['pinfl'] as String;
    }
    if (data['passportSeries'] != null) {
      _passSeryController.text = data['passportSeries'] as String;
    }
    if (data['passportNumber'] != null) {
      _passNumController.text = data['passportNumber'] as String;
    }
    if (data['phone'] != null) {
      _phoneController.text = data['phone'] as String;
    }
    if (data['address'] != null) {
      _addressController.text = data['address'] as String;
    }

    // Tug'ilgan sana (DD.MM.YYYY -> yyyy-MM-dd)
    if (data['birthDate'] != null) {
      final birthDateStr = data['birthDate'] as String;
      try {
        final parts = birthDateStr.split('.');
        if (parts.length == 3) {
          final day = parts[0].padLeft(2, '0');
          final month = parts[1].padLeft(2, '0');
          final year = parts[2];
          _dateBirthController.text = '$year-$month-$day';
          _selectedDateBirth = DateTime.parse(_dateBirthController.text);
        } else {
          _dateBirthController.text = birthDateStr;
        }
      } catch (e) {
        _dateBirthController.text = birthDateStr;
      }
    }

    // Boshlanish sanasi (DD.MM.YYYY -> yyyy-MM-dd)
    if (data['startDate'] != null) {
      final startDateStr = data['startDate'] as String;
      try {
        final parts = startDateStr.split('.');
        if (parts.length == 3) {
          final day = parts[0].padLeft(2, '0');
          final month = parts[1].padLeft(2, '0');
          final year = parts[2];
          _startDateController.text = '$year-$month-$day';
          _selectedStartDate = DateTime.parse(_startDateController.text);
        } else {
          _startDateController.text = startDateStr;
        }
      } catch (e) {
        _startDateController.text = startDateStr;
      }
    }

    // Tarifni tanlash (ID bo'yicha) - bu keyinroq BlocBuilder orqali qilinadi
    if (data['selectedTariffId'] != null) {
      _initialTariffId = data['selectedTariffId'] as int;
    }
  }

  @override
  void dispose() {
    _tariffsSubscription?.cancel();
    _tariffsSubscription = null;
    _pinflController.dispose();
    _passSeryController.dispose();
    _passNumController.dispose();
    _dateBirthController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _patronymNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    DateTime? initialDate,
    Function(DateTime) onDateSelected,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateSelected(picked);
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _submitForm() {
    final bloc = context.read<AccidentBloc>();
    final currentState = bloc.state;

    if (currentState is AccidentCreatingInsurance || _navigated) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTariff == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'insurance.accident.form_page.errors.select_tariff'.tr(),
          ),
        ),
      );
      return;
    }

    if (_selectedRegion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'insurance.accident.form_page.errors.select_region'.tr(),
          ),
        ),
      );
      return;
    }

    if (_selectedStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'insurance.accident.form_page.errors.select_start_date'.tr(),
          ),
        ),
      );
      return;
    }

    bloc.add(
      CreateInsurance(
        startDate: _startDateController.text,
        tariffId: _selectedTariff!.id,
        pinfl: _pinflController.text,
        passSery: _passSeryController.text.toUpperCase(),
        passNum: _passNumController.text,
        dateBirth: _dateBirthController.text,
        lastName: _lastNameController.text,
        firstName: _firstNameController.text,
        patronymName: _patronymNameController.text.isNotEmpty
            ? _patronymNameController.text
            : null,
        region: _selectedRegion!.id,
        phone: _phoneController.text.replaceAll(RegExp(r'\D'), ''),
        address: _addressController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Locale o'zgarishini kuzatish uchun context.locale ni ishlatamiz
    // Bu locale o'zgarganda widget'ni qayta build qiladi
    final currentLocale = context.locale;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      key: ValueKey('insurance_form_${currentLocale.toString()}'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('insurance.accident.form_page.title'.tr()),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: BlocConsumer<AccidentBloc, AccidentState>(
        listenWhen: (previous, current) {
          // AccidentInsuranceCreated state ni kuzatish
          final shouldListen = current is AccidentInsuranceCreated ||
              (current is AccidentError &&
                  previous is AccidentCreatingInsurance);
          if (kDebugMode) {
            debugPrint('🔍 listenWhen called: previous=${previous.runtimeType}, current=${current.runtimeType}, shouldListen=$shouldListen');
            if (current is AccidentInsuranceCreated) {
              debugPrint('🔍 AccidentInsuranceCreated detected in listenWhen!');
            }
          }
          return shouldListen;
        },
        listener: (context, state) {
          if (kDebugMode) {
            debugPrint('👂 Listener called with state: ${state.runtimeType}');
            debugPrint('👂 Listener context mounted: ${context.mounted}');
          }
          if (state is AccidentInsuranceCreated) {
            if (kDebugMode) {
              debugPrint('📋 AccidentInsuranceCreated state received');
              debugPrint('   _navigated: $_navigated');
              debugPrint('   mounted: $mounted');
            }
            if (!_navigated && mounted) {
              _navigated = true;

              // Listener contextidan AccidentBloc va Navigator ni xavfsiz olamiz
              final insuranceData = state.insurance;
              
              if (kDebugMode) {
                debugPrint('✅ Navigation starting to PaymentScreen');
                debugPrint('   Anketa ID: ${insuranceData.anketaId}');
                debugPrint('   Premium: ${insuranceData.insurancePremium}');
                debugPrint('   Payment URLs: ${insuranceData.paymentUrls}');
              }

              // To'lov sahifasiga o'tish
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (kDebugMode) {
                  debugPrint('⏰ PostFrameCallback called');
                  debugPrint('   mounted: $mounted');
                  debugPrint('   _navigated: $_navigated');
                }
                if (!mounted || !_navigated) {
                  if (kDebugMode) {
                    debugPrint('⚠️ Navigation cancelled: mounted=$mounted, _navigated=$_navigated');
                  }
                  return;
                }

                try {
                  if (kDebugMode) {
                    debugPrint('🚀 Starting navigation to PaymentScreen...');
                  }
                  final accidentBloc = context.read<AccidentBloc>();
                  
                  // Form ma'lumotlarini yig'ish
                  final formData = {
                    'lastName': _lastNameController.text,
                    'firstName': _firstNameController.text,
                    'patronymName': _patronymNameController.text,
                    'pinfl': _pinflController.text,
                    'passSery': _passSeryController.text,
                    'passNum': _passNumController.text,
                    'dateBirth': _dateBirthController.text,
                    'phone': _phoneController.text,
                    'address': _addressController.text,
                    'startDate': _startDateController.text,
                    'tariffName': _selectedTariff != null
                        ? '${_selectedTariff!.insurancePremium.toStringAsFixed(0)} UZS'
                        : null,
                    'regionName': _selectedRegion?.name,
                  };

                  if (!mounted) {
                    if (kDebugMode) {
                      debugPrint('⚠️ Widget not mounted, cancelling navigation');
                    }
                    return;
                  }

                  if (kDebugMode) {
                    debugPrint('📱 Pushing PaymentScreen to Navigator...');
                  }
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (newContext) => BlocProvider.value(
                        value: accidentBloc,
                        child: PaymentScreen(
                          anketaId: insuranceData.anketaId,
                          paymentUrls: insuranceData.paymentUrls,
                          insurancePremium: insuranceData.insurancePremium,
                          formData: formData,
                        ),
                      ),
                    ),
                  );
                  if (kDebugMode) {
                    debugPrint('✅ Navigation completed successfully');
                  }
                } catch (e, stackTrace) {
                  if (kDebugMode) {
                    debugPrint('❌ Navigation error: $e');
                    debugPrint('❌ Stack trace: $stackTrace');
                  }
                } finally {
                  // Qaytganida yoki xatolik bo'lsa ham flag ni reset qilamiz
                  if (mounted) {
                    setState(() {
                      _navigated = false;
                    });
                  }
                }
              });
            }
          } else if (state is AccidentError) {
            // Xatolik bo'lsa flag ni reset qilamiz
            if (mounted) {
              setState(() {
                _navigated = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BlocBuilder<AccidentBloc, AccidentState>(
                    buildWhen: (previous, current) {
                      // Faqat tariffs bilan bog'liq state larni qabul qil
                      return current is AccidentTariffsLoading ||
                          current is AccidentTariffsLoaded ||
                          (current is AccidentError &&
                              previous is AccidentTariffsLoading);
                    },
                    builder: (context, state) {
                      return _buildTariffSelector();
                    },
                  ),
                  SizedBox(height: 20.h),
                  _buildStartDateField(),
                  SizedBox(height: 20.h),
                  _buildTextField(
                    controller: _pinflController,
                    label: 'insurance.accident.form_page.pinfl'.tr(),
                    hint: 'insurance.accident.form_page.pinfl_hint'.tr(),
                    validator: AccidentValidators.validatePinfl,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _passSeryController,
                          label: 'insurance.accident.form_page.passport_series'
                              .tr(),
                          hint: 'AB',
                          validator: AccidentValidators.validatePassportSeries,
                          textCapitalization: TextCapitalization.characters,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildTextField(
                          controller: _passNumController,
                          label: 'insurance.accident.form_page.passport_number'
                              .tr(),
                          hint: '1234567',
                          validator: AccidentValidators.validatePassportNumber,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _buildTextField(
                    controller: _dateBirthController,
                    label: 'insurance.accident.form_page.date_birth'.tr(),
                    hint: 'YYYY-MM-DD',
                    validator: AccidentValidators.validateDateBirth,
                    readOnly: true,
                    onTap: () => _selectDate(
                      context,
                      _dateBirthController,
                      _selectedDateBirth,
                      (date) {
                        setState(() {
                          _selectedDateBirth = date;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildTextField(
                    controller: _lastNameController,
                    label: 'insurance.accident.form_page.last_name'.tr(),
                    hint: 'insurance.accident.last_name_hint'.tr(),
                    validator: (v) => AccidentValidators.validateRequired(
                      v,
                      'insurance.accident.form_page.last_name'.tr(),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildTextField(
                    controller: _firstNameController,
                    label: 'insurance.accident.form_page.first_name'.tr(),
                    hint: 'insurance.accident.first_name_hint'.tr(),
                    validator: (v) => AccidentValidators.validateRequired(
                      v,
                      'insurance.accident.form_page.first_name'.tr(),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildTextField(
                    controller: _patronymNameController,
                    label: 'insurance.accident.form_page.patronym_name'.tr(),
                    hint: 'insurance.accident.middle_name_hint'.tr(),
                  ),
                  SizedBox(height: 20.h),
                  BlocBuilder<AccidentBloc, AccidentState>(
                    buildWhen: (previous, current) {
                      // Faqat regions bilan bog'liq state larni qabul qil
                      return current is AccidentRegionsLoading ||
                          current is AccidentRegionsLoaded ||
                          (current is AccidentError &&
                              previous is AccidentRegionsLoading);
                    },
                    builder: (context, state) {
                      return _buildRegionSelector();
                    },
                  ),
                  SizedBox(height: 20.h),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'insurance.accident.form_page.phone'.tr(),
                    hint: '998901234567',
                    validator: AccidentValidators.validatePhone,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 20.h),
                  _buildTextField(
                    controller: _addressController,
                    label: 'insurance.accident.form_page.address'.tr(),
                    hint: 'insurance.accident.address_hint'.tr(),
                    validator: (v) => AccidentValidators.validateRequired(
                      v,
                      'insurance.accident.form_page.address'.tr(),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed:
                        (state is AccidentCreatingInsurance || _navigated)
                        ? null
                        : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: state is AccidentCreatingInsurance
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'insurance.accident.form_page.continue'.tr(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTariffSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.grey[300] : Colors.grey[700];

    return InkWell(
      onTap: () async {
        final bloc = context.read<AccidentBloc>();
        final tariff = await Navigator.of(context).push<TariffEntity>(
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: bloc,
              child: TariffSelectionPage(onTariffSelected: (t) {}),
            ),
          ),
        );
        if (tariff != null && mounted) {
          setState(() {
            _selectedTariff = tariff;
          });
          bloc.add(SelectTariff(tariff));
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 4.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: _selectedTariff == null
                ? (isDark ? Colors.grey.shade800 : Colors.grey.shade300)
                : _primaryBlue,
            width: _selectedTariff == null ? 1.0 : 2.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'insurance.accident.form_page.tariff'.tr(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _selectedTariff == null
                        ? 'insurance.accident.form_page.select_tariff'.tr()
                        : '${'insurance.accident.form_page.tariff'.tr()} #${_selectedTariff!.id}',
                    style: TextStyle(fontSize: 12.sp, color: labelColor),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: _primaryBlue, size: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.grey[300] : Colors.grey[700];

    return InkWell(
      onTap: () async {
        final bloc = context.read<AccidentBloc>();
        final region = await Navigator.of(context).push<RegionEntity>(
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: bloc,
              child: RegionSelectionPage(onRegionSelected: (r) {}),
            ),
          ),
        );
        if (region != null && mounted) {
          setState(() {
            _selectedRegion = region;
          });
          bloc.add(SelectRegion(region));
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 4.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: _selectedRegion == null
                ? (isDark ? Colors.grey.shade800 : Colors.grey.shade300)
                : _primaryBlue,
            width: _selectedRegion == null ? 1.0 : 2.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'insurance.accident.form_page.region'.tr(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _selectedRegion == null
                        ? 'insurance.accident.form_page.select_region'.tr()
                        : _selectedRegion!.name,
                    style: TextStyle(fontSize: 12.sp, color: labelColor),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: _primaryBlue, size: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildStartDateField() {
    return _buildTextField(
      controller: _startDateController,
      label: 'insurance.accident.form_page.start_date'.tr(),
      hint: 'YYYY-MM-DD',
      validator: AccidentValidators.validateStartDate,
      readOnly: true,
      onTap: () => _selectDate(
        context,
        _startDateController,
        _selectedStartDate,
        (date) {
          setState(() {
            _selectedStartDate = date;
          });
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final hintColor = isDark ? Colors.grey.shade600 : Colors.grey.shade500;
    final fillColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    // Border configurations
    final borderRadius = BorderRadius.circular(12.r);
    final enabledBorderConfig = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: borderColor, width: 1.0),
    );
    final focusedBorderConfig = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: borderColor, width: 1.0),
    );
    final errorBorderConfig = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(color: Colors.red, width: 2.0),
    );

    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TextFormField
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            textCapitalization: textCapitalization,
            maxLines: maxLines,
            style: TextStyle(
              color: textColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              hintText: hint,
              hintStyle: TextStyle(color: hintColor, fontSize: 15.sp),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              filled: true,
              fillColor: fillColor,
              enabledBorder: enabledBorderConfig,
              focusedBorder: focusedBorderConfig,
              errorBorder: errorBorderConfig,
              focusedErrorBorder: errorBorderConfig,
              suffixIcon: readOnly
                  ? Icon(Icons.calendar_today, size: 20.sp, color: borderColor)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
