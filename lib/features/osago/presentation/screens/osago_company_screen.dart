import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../domain/entities/osago_driver.dart';
import '../../domain/entities/osago_insurance.dart';
import '../../logic/bloc/osago_bloc.dart';
import '../../logic/bloc/osago_event.dart';
import '../../logic/bloc/osago_state.dart';
import '../../utils/osago_utils.dart';
import 'osago_check_information_screen.dart';
import '../../utils/upper_case_text_formatter.dart';

class OsagoCompanyScreen extends StatefulWidget {
  const OsagoCompanyScreen({super.key});

  @override
  State<OsagoCompanyScreen> createState() => _OsagoCompanyScreenState();
}

class _OsagoCompanyScreenState extends State<OsagoCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _dateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _periodController = TextEditingController();

  final Map<String, String> _providers = {
    'neo': 'NEO Insurance',
    'gross': 'GROSS Insurance',
  };

  String _selectedProvider = 'neo';
  DateTime? _startDate;
  bool _navigated = false;
  bool _showDrivers = false;
  bool _isCheklanganType = false;
  final List<Map<String, dynamic>> _drivers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Настройка статус-бара для темного режима
      final isDark = Theme.of(context).brightness == Brightness.dark;
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      );

      final currentState = context.read<OsagoBloc>().state;

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
          _periodController.text = periodDisplay;
        }
      }

      final osagoType = currentState.osagoType;
      if (osagoType != null) {
        final limitedText = 'insurance.osago.vehicle.type_limited'.tr();
        final unlimitedText = 'insurance.osago.vehicle.type_unlimited'.tr();

        if (osagoType == limitedText) {
          _isCheklanganType = true;
          _selectedProvider = 'neo';
          _companyController.text = _providers[_selectedProvider]!;
          _showDrivers = true;
          _drivers.add({
            'passport': TextEditingController(),
            'birthDate': DateTime.now(),
            'relative': 0,
            'relativeController': TextEditingController(
              text: 'insurance.osago.company.relationship_owner'.tr(),
            ),
          });
        } else if (osagoType == unlimitedText) {
          _isCheklanganType = false;
          _selectedProvider = 'neo';
          _companyController.text = _providers[_selectedProvider]!;
          _showDrivers = false;
        } else {
          _companyController.text = _providers[_selectedProvider]!;
        }
      } else {
        _companyController.text = _providers[_selectedProvider]!;
      }
    });
  }

  @override
  void dispose() {
    for (final driver in _drivers) {
      driver['passport']?.dispose();
      driver['relativeController']?.dispose();
    }

    _companyController.dispose();
    _dateController.dispose();
    _phoneController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _addDriver() {
    if (_drivers.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('insurance.osago.check.limited_drivers'.tr())),
      );
      return;
    }
    setState(() {
      _drivers.add({
        'passport': TextEditingController(),
        'birthDate': DateTime.now(),
        'relative': 0,
        'relativeController': TextEditingController(
          text: 'insurance.osago.company.relationship_owner'.tr(),
        ),
      });
    });
  }

  void _removeDriver(int index) {
    setState(() {
      if (index < _drivers.length) {
        _drivers[index]['passport']?.dispose();
        _drivers[index]['relativeController']?.dispose();
        _drivers.removeAt(index);
      }
    });
  }

  static Map<int, String>? _cachedRelationshipOptions;

  Map<int, String> _getRelationshipOptions() {
    _cachedRelationshipOptions ??= {
      0: 'insurance.osago.company.relationship_owner'.tr(),
      1: 'insurance.osago.company.relationship_son'.tr(),
      2: 'insurance.osago.company.relationship_daughter'.tr(),
      3: 'insurance.osago.company.relationship_father'.tr(),
      4: 'insurance.osago.company.relationship_mother'.tr(),
      5: 'insurance.osago.company.relationship_brother'.tr(),
      6: 'insurance.osago.company.relationship_sister'.tr(),
      7: 'insurance.osago.company.relationship_husband'.tr(),
      8: 'insurance.osago.company.relationship_wife'.tr(),
      9: 'insurance.osago.company.relationship_other_relative'.tr(),
      10: 'insurance.osago.company.relationship_not_relative'.tr(),
    };
    return _cachedRelationshipOptions!;
  }

  Widget _buildDriverCard(int index, Map<String, dynamic> driver) {
    final passportCtrl = driver['passport'] as TextEditingController;
    final birthDate = driver['birthDate'] as DateTime;
    final relative = driver['relative'] as int;

    TextStyle _labelStyle(BuildContext context) {
      return TextStyle(
        color: Theme.of(context).textTheme.bodySmall?.color,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      );
    }

    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'insurance.osago.check.drivers'.tr() + ' ${index + 1}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _removeDriver(index),
                  color: Colors.red,
                  iconSize: 20,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'insurance.osago.vehicle.passport'.tr(),
              style: _labelStyle(context),
            ),
            SizedBox(height: 4.h),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: passportCtrl,
              builder: (context, value, child) {
                return TextFormField(
                  controller: passportCtrl,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                  ],
                  style: TextStyle(
                    color: value.text.isEmpty
                        ? Theme.of(context).hintColor
                        : Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: "AA1234567",
                    counterText: "",
                  ),
                  validator: (v) {
                    if (!_showDrivers) return null;
                    if (v == null || v.isEmpty) {
                      return 'insurance.osago.vehicle.errors.enter_passport'
                          .tr();
                    }
                    final cleaned = v.replaceAll(' ', '').toUpperCase();
                    if (cleaned.length != 9 ||
                        !RegExp(r'^[A-Z]{2}\d{7}$').hasMatch(cleaned)) {
                      return 'insurance.osago.vehicle.errors.passport_format'
                          .tr();
                    }
                    return null;
                  },
                );
              },
            ),
            SizedBox(height: 16.h),
            Text(
              'insurance.osago.vehicle.driver_birth_date'.tr(),
              style: _labelStyle(context),
            ),
            SizedBox(height: 4.h),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: OsagoUtils.formatDateForDisplay(birthDate),
              ),
              decoration: InputDecoration(
                hintText: "dd.MM.yyyy",
                prefixIcon: Icon(
                  Icons.calendar_today_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              onTap: () async {
                final DateTime now = DateTime.now();
                final DateTime firstDate = DateTime(1950);
                final DateTime lastDate = now;

                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: birthDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        primaryColor: Theme.of(context).colorScheme.primary,
                        colorScheme: Theme.of(context).colorScheme,
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    driver['birthDate'] = picked;
                  });
                }
              },
            ),
            SizedBox(height: 16.h),
            Text(
              '${'insurance.osago.company.relationship_degree'.tr()} *',
              style: _labelStyle(context),
            ),
            SizedBox(height: 4.h),
            Builder(
              builder: (context) {
                final relationshipOptions = _getRelationshipOptions();

                final currentText =
                    relationshipOptions[relative] ?? relationshipOptions[0]!;
                final relativeCtrl =
                    driver['relativeController'] as TextEditingController? ??
                    TextEditingController(text: currentText);
                driver['relativeController'] = relativeCtrl;

                if (relative >= 0 && relative <= 10) {
                  relativeCtrl.text = relationshipOptions[relative]!;
                }

                return DropdownButtonFormField<String>(
                  value: relativeCtrl.text,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  items: relationshipOptions.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.value,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      relativeCtrl.text = value;
                      final selectedId = relationshipOptions.entries
                          .firstWhere((entry) => entry.value == value)
                          .key;
                      driver['relative'] = selectedId;
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

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
          data: Theme.of(context).copyWith(
            primaryColor: Theme.of(context).colorScheme.primary,
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _dateController.text = OsagoUtils.formatDateForDisplay(picked);
      });
    }
  }

  Widget _buildShimmerField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 14,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'insurance.osago.company.errors.select_start_date'.tr(),
            ),
          ),
        );
        return;
      }

      final periodId = OsagoUtils.mapPeriodToId(_periodController.text);
      if (periodId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('insurance.osago.company.errors.select_period'.tr()),
          ),
        );
        return;
      }

      final phoneText = _phoneController.text.trim();
      final normalizedPhone = OsagoUtils.normalizePhoneNumber(phoneText);

      if (!OsagoUtils.isValidPhoneNumber(normalizedPhone)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('insurance.osago.company.errors.invalid_phone'.tr()),
          ),
        );
        return;
      }

      final currentState = context.read<OsagoBloc>().state;
      final osagoType = currentState.osagoType;
      final provider = _selectedProvider;
      String numberDriversId;

      final limitedText = 'insurance.osago.vehicle.type_limited'.tr();
      final unlimitedText = 'insurance.osago.vehicle.type_unlimited'.tr();

      if (osagoType == limitedText) {
        numberDriversId = '5';
      } else if (osagoType == unlimitedText) {
        numberDriversId = '0';
      } else {
        final providerLower = provider.toLowerCase();
        if (providerLower == 'neo') {
          numberDriversId = '0';
        } else if (providerLower == 'gross') {
          numberDriversId = '5';
        } else {
          final tempNumberDriversId = currentState.numberDriversId;
          if (tempNumberDriversId != null &&
              (tempNumberDriversId == '0' || tempNumberDriversId == '5')) {
            numberDriversId = tempNumberDriversId;
          } else {
            numberDriversId = '5';
          }
        }
      }

      final insurance = OsagoInsurance(
        provider: _selectedProvider,
        companyName: _providers[_selectedProvider]!,
        periodId: periodId,
        numberDriversId: numberDriversId,
        startDate: _startDate!,
        phoneNumber: normalizedPhone,
        ownerInn: '',
        isUnlimited: false,
      );

      if (_showDrivers && _drivers.isNotEmpty) {
        for (var i = 0; i < _drivers.length; i++) {
          final driverData = _drivers[i];
          final passportCtrl = driverData['passport'] as TextEditingController;
          final passportText = passportCtrl.text
              .replaceAll(' ', '')
              .toUpperCase();

          if (passportText.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${'insurance.osago.check.drivers'.tr()} ${i + 1}: ${'insurance.osago.vehicle.errors.enter_passport'.tr()}',
                ),
              ),
            );
            return;
          }

          if (passportText.length != 9) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${'insurance.osago.check.drivers'.tr()} ${i + 1}: ${'insurance.osago.vehicle.errors.passport_format'.tr()}',
                ),
              ),
            );
            return;
          }

          if (!RegExp(r'^[A-Z]{2}\d{7}$').hasMatch(passportText)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${'insurance.osago.check.drivers'.tr()} ${i + 1}: ${'insurance.osago.vehicle.errors.passport_format'.tr()}',
                ),
              ),
            );
            return;
          }
        }
      }

      final currentVehicle = currentState.vehicle;

      if (_showDrivers && _drivers.isNotEmpty && currentVehicle != null) {
        final driversList = <OsagoDriver>[];
        for (final driverData in _drivers) {
          final passportCtrl = driverData['passport'] as TextEditingController;
          final passportText = passportCtrl.text
              .replaceAll(' ', '')
              .toUpperCase();

          if (passportText.length >= 9) {
            final passportSeria = passportText.substring(0, 2);
            final passportNumber = passportText.substring(2);
            final birthDate = driverData['birthDate'] as DateTime;
            final relativeId = driverData['relative'] as int;

            driversList.add(
              OsagoDriver(
                passportSeria: passportSeria,
                passportNumber: passportNumber,
                driverBirthday: birthDate,
                relative: relativeId,
                name: null,
                licenseSeria: null,
                licenseNumber: null,
              ),
            );
          }
        }

        if (driversList.isNotEmpty) {
          context.read<OsagoBloc>().add(
            LoadVehicleData(
              vehicle: currentVehicle,
              drivers: driversList,
              osagoType: currentState.osagoType,
              periodId: currentState.periodId,
              gosNumber: currentState.gosNumber,
              birthDate: currentState.birthDate,
            ),
          );
        }
      }

      _navigated = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<OsagoBloc>().add(LoadInsuranceCompany(insurance));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OsagoBloc, OsagoState>(
      listener: (context, state) {
        if (state is OsagoFailure && state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
        if (state is OsagoCalcSuccess && !_navigated) {
          _navigated = true;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<OsagoBloc>(),
                child: const OsagoCheckInformationScreen(),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
            onPressed: () {
              _navigated = false;
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'insurance.osago.company.title'.tr(),
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 10.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: BlocBuilder<OsagoBloc, OsagoState>(
                    buildWhen: (previous, current) =>
                        previous is OsagoLoading != current is OsagoLoading,
                    builder: (context, state) {
                      final isLoading = state is OsagoLoading;
                      if (isLoading) {
                        return SingleChildScrollView(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildShimmerField(),
                              SizedBox(height: 16.h),
                              _buildShimmerField(),
                              SizedBox(height: 16.h),
                              _buildShimmerField(),
                            ],
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        padding: EdgeInsets.all(20.w),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'insurance.osago.company.title'.tr(),
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.color,
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Text(
                                'insurance.osago.company.provider'.tr(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile<String>(
                                      title: Text(
                                        'insurance.osago.company.insurance_company_neo'
                                            .tr(),
                                      ),
                                      value: 'neo',
                                      groupValue: _selectedProvider,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedProvider = value!;
                                          _companyController.text =
                                              _providers[_selectedProvider]!;
                                        });
                                      },
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile<String>(
                                      title: Text(
                                        'insurance.osago.company.insurance_company_gross'
                                            .tr(),
                                      ),
                                      value: 'gross',
                                      groupValue: _selectedProvider,
                                      onChanged: _isCheklanganType
                                          ? null
                                          : (value) {
                                              setState(() {
                                                _selectedProvider = value!;
                                                _companyController.text =
                                                    _providers[_selectedProvider]!;
                                              });
                                            },
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              CustomInputField(
                                controller: _dateController,
                                label: 'insurance.osago.company.start_date'
                                    .tr(),
                                hintText: "dd.MM.yyyy",
                                prefixIcon: Icons.calendar_today_outlined,
                                readOnly: true,
                                onTap: _selectDate,
                                validator: (value) => value!.isEmpty
                                    ? 'insurance.osago.company.errors.select_start_date'
                                          .tr()
                                    : null,
                              ),
                              SizedBox(height: 16.h),
                              CustomInputField(
                                controller: _phoneController,
                                label: 'insurance.osago.company.phone_number'
                                    .tr(),
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
                                    return 'insurance.osago.company.errors.enter_phone'
                                        .tr();
                                  }
                                  final normalized =
                                      OsagoUtils.normalizePhoneNumber(value);
                                  if (!OsagoUtils.isValidPhoneNumber(
                                    normalized,
                                  )) {
                                    return 'insurance.osago.company.errors.invalid_phone'
                                        .tr();
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20.h),
                              BlocBuilder<OsagoBloc, OsagoState>(
                                buildWhen: (previous, current) =>
                                    previous.calcResponse !=
                                    current.calcResponse,
                                builder: (context, state) {
                                  final calcResponse = state.calcResponse;
                                  if (calcResponse == null) {
                                    return const SizedBox.shrink();
                                  }

                                  final amount = calcResponse.amount.toInt();
                                  final osagoTypeText =
                                      state.osagoType ??
                                      (_selectedProvider == 'neo'
                                          ? 'Cheklanmagan'
                                          : 'Cheklangan');

                                  final formattedAmount = amount
                                      .toString()
                                      .replaceAllMapped(
                                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                        (Match m) => '${m[1]},',
                                      );

                                  return RepaintBoundary(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${'insurance.osago.company.calculation'.tr()} $osagoTypeText',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.color,
                                            ),
                                          ),
                                          Text(
                                            '$formattedAmount so\'m',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 20.h),
                              if (_showDrivers) ...[
                                SizedBox(height: 8.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'insurance.osago.company.add_driver'
                                            .tr(),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          size: 22,
                                        ),
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        onPressed: _addDriver,
                                      ),
                                    ],
                                  ),
                                ),
                                ..._drivers.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final driver = entry.value;
                                  return _buildDriverCard(index, driver);
                                }).toList(),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: Theme.of(context).cardColor,
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 30.h),
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
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? Shimmer.fromColors(
                                baseColor: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.white70,
                                highlightColor: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[600]!
                                    : Colors.white,
                                child: Text(
                                  'insurance.osago.company.loading_data'.tr(),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Text(
                                'insurance.osago.vehicle.continue'.tr(),
                                style: const TextStyle(
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
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 8),
        controller != null
            ? ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller!,
                builder: (context, value, child) {
                  return TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    readOnly: readOnly,
                    onTap: onTap,
                    validator: validator,
                    inputFormatters: inputFormatters,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: value.text.isEmpty
                          ? Theme.of(context).hintColor
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 16.h,
                        horizontal: 16.w,
                      ),
                      hintText: hintText,
                      hintStyle: TextStyle(color: Theme.of(context).hintColor),
                      prefixIcon: prefixIcon != null
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    prefixIcon,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 22,
                                  ),
                                  if (isPhoneField) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      "+998",
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      height: 20,
                                      width: 1,
                                      color: Theme.of(context).dividerColor,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ],
                              ),
                            )
                          : null,
                      suffixIcon: suffixIcon != null
                          ? Icon(
                              suffixIcon,
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                            )
                          : null,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                          width: 1,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                  );
                },
              )
            : TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                readOnly: readOnly,
                onTap: onTap,
                validator: validator,
                inputFormatters: inputFormatters,
                style: const TextStyle(fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16.h,
                    horizontal: 16.w,
                  ),
                  hintText: hintText,
                  hintStyle: TextStyle(color: Theme.of(context).hintColor),
                  prefixIcon: prefixIcon != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                prefixIcon,
                                color: Theme.of(context).colorScheme.primary,
                                size: 22,
                              ),
                              if (isPhoneField) ...[
                                const SizedBox(width: 8),
                                Text(
                                  "+998",
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  height: 20,
                                  width: 1,
                                  color: Theme.of(context).dividerColor,
                                ),
                                const SizedBox(width: 8),
                              ],
                            ],
                          ),
                        )
                      : null,
                  suffixIcon: suffixIcon != null
                      ? Icon(
                          suffixIcon,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        )
                      : null,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
              ),
      ],
    );
  }
}
