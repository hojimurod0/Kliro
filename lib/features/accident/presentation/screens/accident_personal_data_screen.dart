import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/snackbar_helper.dart';
import '../pages/insurance_form_page.dart';
import '../bloc/accident_bloc.dart';
import '../bloc/accident_event.dart';
import '../bloc/accident_state.dart';
import '../../domain/entities/tariff_entity.dart';
import '../../domain/entities/region_entity.dart';

class AccidentPersonalDataScreen extends StatefulWidget {
  const AccidentPersonalDataScreen({super.key});

  @override
  State<AccidentPersonalDataScreen> createState() =>
      _AccidentPersonalDataScreenState();
}

class _AccidentPersonalDataScreenState
    extends State<AccidentPersonalDataScreen> {
  final _formKey = GlobalKey<FormState>();

  final _lastNameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _middleNameCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  final _passportSeriesCtrl = TextEditingController();
  final _passportNumberCtrl = TextEditingController();
  final _pinflCtrl = TextEditingController();

  final _regionCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _insuranceAmountCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();

  DateTime? _selectedBirthDate;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _isSubmitting = false;
  bool _showAdditionalFields = false;
  bool _agreedToTerms = false;
  bool _agreedToPrivacy = false;

  List<TariffEntity> _tariffs = [];
  List<RegionEntity> _regions = [];
  TariffEntity? _selectedTariff;
  int? _selectedTariffIndex;

  @override
  void initState() {
    super.initState();
    _lastNameCtrl.addListener(_checkBasicFields);
    _firstNameCtrl.addListener(_checkBasicFields);
    _birthDateCtrl.addListener(_checkBasicFields);
    _passportSeriesCtrl.addListener(_checkBasicFields);
    _passportNumberCtrl.addListener(_checkBasicFields);
    _pinflCtrl.addListener(_checkBasicFields);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ),
        );
        final bloc = context.read<AccidentBloc>();
        bloc.add(const FetchTariffs());
        bloc.add(const FetchRegions());
      }
    });
  }

  void _checkBasicFields() {
    final lastNameFilled = _lastNameCtrl.text.trim().isNotEmpty;
    final firstNameFilled = _firstNameCtrl.text.trim().isNotEmpty;
    final birthDateFilled = _birthDateCtrl.text.trim().isNotEmpty;
    final passportSeriesFilled = _passportSeriesCtrl.text.trim().length == 2;
    final passportNumberFilled = _passportNumberCtrl.text.trim().length == 7;
    final pinflFilled = _pinflCtrl.text.trim().length == 14;

    final allBasicFieldsFilled = lastNameFilled &&
        firstNameFilled &&
        birthDateFilled &&
        passportSeriesFilled &&
        passportNumberFilled &&
        pinflFilled;

    if (allBasicFieldsFilled && !_showAdditionalFields) {
      setState(() {
        _showAdditionalFields = true;
      });
    } else if (!allBasicFieldsFilled && _showAdditionalFields) {
      setState(() {
        _showAdditionalFields = false;
      });
    }
  }

  @override
  void dispose() {
    _lastNameCtrl.removeListener(_checkBasicFields);
    _firstNameCtrl.removeListener(_checkBasicFields);
    _birthDateCtrl.removeListener(_checkBasicFields);
    _passportSeriesCtrl.removeListener(_checkBasicFields);
    _passportNumberCtrl.removeListener(_checkBasicFields);
    _pinflCtrl.removeListener(_checkBasicFields);

    _lastNameCtrl.dispose();
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _birthDateCtrl.dispose();
    _passportSeriesCtrl.dispose();
    _passportNumberCtrl.dispose();
    _pinflCtrl.dispose();
    _regionCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _insuranceAmountCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    TextEditingController controller,
    DateTime? initialDate,
    Function(DateTime) onSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: context.locale,
    );
    if (picked != null) {
      setState(() {
        onSelected(picked);
        controller.text =
            '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
      });
    }
  }

  void _selectRegion() {
    if (_regions.isEmpty) {
      // Agar regionlar yuklanmagan bo'lsa, yuklash
      final bloc = context.read<AccidentBloc>();
      bloc.add(const FetchRegions(forceRefresh: true));
      SnackbarHelper.showWarning(
        context,
        'insurance.accident.loading_regions'.tr(),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => BlocBuilder<AccidentBloc, AccidentState>(
        builder: (context, state) {
          final List<RegionEntity> regions =
              state is AccidentRegionsLoaded ? state.regions : _regions;

          return Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'insurance.accident.select_region'.tr(),
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 16.h),
                if (regions.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(20.h),
                    child: Text('insurance.accident.no_regions'.tr()),
                  )
                else
                  ...regions
                      .map(
                        (region) => ListTile(
                          title: Text(region.name),
                          onTap: () {
                            setState(() {
                              _regionCtrl.text = region.name;
                            });
                            final bloc = context.read<AccidentBloc>();
                            bloc.add(SelectRegion(region));
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      SnackbarHelper.showError(
        context,
        'insurance.accident.errors.fill_all_fields'.tr(),
      );
      return;
    }

    if (!_agreedToTerms || !_agreedToPrivacy) {
      SnackbarHelper.showError(
        context,
        'insurance.accident.errors.agree_to_terms'.tr(),
      );
      return;
    }

    if (_selectedTariffIndex == null) {
      SnackbarHelper.showError(
        context,
        'insurance.accident.errors.select_tariff'.tr(),
      );
      return;
    }

    // Подготовка данных для передачи на страницу оформления
    final formData = {
      'lastName': _lastNameCtrl.text.trim(),
      'firstName': _firstNameCtrl.text.trim(),
      'middleName': _middleNameCtrl.text.trim(),
      'birthDate': _birthDateCtrl.text.trim(),
      'passportSeries': _passportSeriesCtrl.text.trim(),
      'passportNumber': _passportNumberCtrl.text.trim(),
      'pinfl': _pinflCtrl.text.trim(),
      'region': _regionCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'startDate': _startDateCtrl.text.trim(),
      'endDate': _endDateCtrl.text.trim(),
      'selectedTariffId':
          _selectedTariff?.id ?? _tariffs[_selectedTariffIndex!].id,
      'insuranceAmount': _insuranceAmountCtrl.text.trim(),
    };

    // Навигация на страницу оформления страхования
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InsuranceFormPage(initialData: formData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Locale o'zgarishini kuzatish uchun context.locale ni ishlatamiz
    // Bu locale o'zgarganda widget'ni qayta build qiladi
    final currentLocale = context.locale;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return BlocListener<AccidentBloc, AccidentState>(
      listener: (context, state) {
        if (state is AccidentRegionsLoaded) {
          setState(() {
            _regions = state.regions;
            if (state.selectedRegion != null) {
              _regionCtrl.text = state.selectedRegion!.name;
            }
          });
        }
        if (state is AccidentError) {
          SnackbarHelper.showError(
            context,
            state.message,
          );
        }
      },
      child: Scaffold(
        key: ValueKey('accident_personal_data_${currentLocale.toString()}'),
        backgroundColor: backgroundColor,
        appBar: AppBar(
          toolbarHeight: 60.h,
          backgroundColor: cardColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leadingWidth: 60.w,
          leading: Container(
            margin: EdgeInsets.only(left: 16.w, top: 8.h, bottom: 8.h),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white24 : const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 20.sp,
                color: isDark ? Colors.white : const Color(0xFF333333),
              ),
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Text(
            'insurance.accident.title'.tr(),
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF333333),
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
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
                        _buildSectionHeader(
                          'insurance.accident.personal_info'.tr(),
                        ),
                        SizedBox(height: 12.h),
                        _buildTextField(
                          controller: _lastNameCtrl,
                          label: 'insurance.accident.last_name'.tr(),
                          hint: 'insurance.accident.last_name_hint'.tr(),
                          isDark: isDark,
                          cardColor: cardColor,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'insurance.accident.errors.enter_last_name'
                                  .tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _firstNameCtrl,
                          label: 'insurance.accident.first_name'.tr(),
                          hint: 'insurance.accident.first_name_hint'.tr(),
                          isDark: isDark,
                          cardColor: cardColor,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'insurance.accident.errors.enter_first_name'
                                  .tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _middleNameCtrl,
                          label: 'insurance.accident.middle_name'.tr(),
                          hint: 'insurance.accident.middle_name_hint'.tr(),
                          isDark: isDark,
                          cardColor: cardColor,
                          required: false,
                        ),
                        SizedBox(height: 16.h),
                        _buildDateField(
                          controller: _birthDateCtrl,
                          label: 'insurance.accident.birth_date'.tr(),
                          hint: 'insurance.accident.birth_date_hint'.tr(),
                          isDark: isDark,
                          cardColor: cardColor,
                          onTap: () => _selectDate(
                            _birthDateCtrl,
                            _selectedBirthDate,
                            (date) => _selectedBirthDate = date,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'insurance.accident.errors.enter_birth_date'
                                  .tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                controller: _passportSeriesCtrl,
                                label:
                                    'insurance.accident.passport_series'.tr(),
                                hint: 'AB',
                                isDark: isDark,
                                cardColor: cardColor,
                                textCapitalization:
                                    TextCapitalization.characters,
                                maxLength: 2,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'insurance.accident.errors.enter_passport_series'
                                        .tr();
                                  }
                                  if (value.length != 2) {
                                    return 'insurance.accident.errors.passport_series_format'
                                        .tr();
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              flex: 3,
                              child: _buildTextField(
                                controller: _passportNumberCtrl,
                                label:
                                    'insurance.accident.passport_number'.tr(),
                                hint: '6135606',
                                isDark: isDark,
                                cardColor: cardColor,
                                keyboardType: TextInputType.number,
                                maxLength: 7,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'insurance.accident.errors.enter_passport_number'
                                        .tr();
                                  }
                                  if (value.length != 7) {
                                    return 'insurance.accident.errors.passport_number_format'
                                        .tr();
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _pinflCtrl,
                          label: 'insurance.accident.pinfl'.tr(),
                          hint: '33110790221689',
                          isDark: isDark,
                          cardColor: cardColor,
                          keyboardType: TextInputType.number,
                          maxLength: 14,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'insurance.accident.errors.enter_pinfl'
                                  .tr();
                            }
                            if (value.length != 14) {
                              return 'insurance.accident.errors.pinfl_format'
                                  .tr();
                            }
                            return null;
                          },
                        ),
                        if (_showAdditionalFields) ...[
                          SizedBox(height: 24.h),
                          _buildSectionHeader(
                            'insurance.accident.additional_info'.tr(),
                          ),
                          SizedBox(height: 12.h),
                          GestureDetector(
                            onTap: _selectRegion,
                            child: AbsorbPointer(
                              child: _buildTextField(
                                controller: _regionCtrl,
                                label: 'insurance.accident.region'.tr(),
                                hint: 'insurance.accident.select_region'.tr(),
                                isDark: isDark,
                                cardColor: cardColor,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'insurance.accident.errors.select_region'
                                        .tr();
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _buildTextField(
                            controller: _phoneCtrl,
                            label: 'insurance.accident.phone'.tr(),
                            hint: '+998 (33) 110-88-10',
                            isDark: isDark,
                            cardColor: cardColor,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'insurance.accident.errors.enter_phone'
                                    .tr();
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          _buildTextField(
                            controller: _addressCtrl,
                            label: 'insurance.accident.address'.tr(),
                            hint: 'insurance.accident.address_hint'.tr(),
                            isDark: isDark,
                            cardColor: cardColor,
                            maxLines: 2,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'insurance.accident.errors.enter_address'
                                    .tr();
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          _buildTextField(
                            controller: _insuranceAmountCtrl,
                            label: 'insurance.accident.insurance_amount'.tr(),
                            hint:
                                'insurance.accident.insurance_amount_hint'.tr(),
                            isDark: isDark,
                            cardColor: cardColor,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'insurance.accident.errors.enter_insurance_amount'
                                    .tr();
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          _buildDateField(
                            controller: _startDateCtrl,
                            label: 'insurance.accident.start_date'.tr(),
                            hint: 'insurance.accident.start_date_hint'.tr(),
                            isDark: isDark,
                            cardColor: cardColor,
                            onTap: () => _selectDate(
                              _startDateCtrl,
                              _selectedStartDate,
                              (date) => _selectedStartDate = date,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'insurance.accident.errors.enter_start_date'
                                    .tr();
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),
                          _buildDateField(
                            controller: _endDateCtrl,
                            label: 'insurance.accident.end_date'.tr(),
                            hint: 'insurance.accident.end_date_hint'.tr(),
                            isDark: isDark,
                            cardColor: cardColor,
                            onTap: () => _selectDate(
                              _endDateCtrl,
                              _selectedEndDate,
                              (date) => _selectedEndDate = date,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'insurance.accident.errors.enter_end_date'
                                    .tr();
                              }
                              return null;
                            },
                          ),
                        ],
                        if (_showAdditionalFields) ...[
                          SizedBox(height: 32.h),
                          _buildSectionHeader(
                            'insurance.accident.select_tariff'.tr(),
                          ),
                          SizedBox(height: 16.h),
                          BlocBuilder<AccidentBloc, AccidentState>(
                            builder: (context, state) {
                              if (state is AccidentTariffsLoading) {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20.h),
                                    child: CircularProgressIndicator(
                                      color: const Color(0xFFFF9800),
                                    ),
                                  ),
                                );
                              }

                              if (state is AccidentTariffsLoaded) {
                                _tariffs = state.tariffs;
                                _selectedTariff = state.selectedTariff;
                                if (_selectedTariff != null) {
                                  _selectedTariffIndex = _tariffs.indexWhere(
                                      (t) => t.id == _selectedTariff!.id);
                                  if (_selectedTariffIndex == -1) {
                                    _selectedTariffIndex = null;
                                  }
                                }
                              }

                              if (state is AccidentError) {
                                return Padding(
                                  padding: EdgeInsets.all(20.h),
                                  child: Column(
                                    children: [
                                      Text(
                                        state.message,
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      SizedBox(height: 8.h),
                                      ElevatedButton(
                                        onPressed: () {
                                          context.read<AccidentBloc>().add(
                                                const FetchTariffs(
                                                    forceRefresh: true),
                                              );
                                        },
                                        child: Text('common.retry'.tr()),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (_tariffs.isEmpty) {
                                return Padding(
                                  padding: EdgeInsets.all(20.h),
                                  child: Text(
                                      'insurance.accident.no_tariffs'.tr()),
                                );
                              }

                              return Column(
                                children: _tariffs.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final tariff = entry.value;
                                  final isSelected =
                                      _selectedTariffIndex == index ||
                                          _selectedTariff?.id == tariff.id;
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: _buildTariffCard(
                                      tariff: tariff,
                                      isSelected: isSelected,
                                      isDark: isDark,
                                      cardColor: cardColor,
                                      onTap: () {
                                        setState(() {
                                          _selectedTariffIndex = index;
                                          _selectedTariff = tariff;
                                          _insuranceAmountCtrl.text =
                                              '${tariff.insurancePremium.toStringAsFixed(0)}';
                                        });
                                        final bloc =
                                            context.read<AccidentBloc>();
                                        bloc.add(SelectTariff(tariff));
                                      },
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                        if (_showAdditionalFields) ...[
                          SizedBox(height: 24.h),
                          _buildCheckbox(
                            value: _agreedToTerms,
                            label: 'insurance.accident.agree_to_terms'.tr(),
                            onChanged: (value) {
                              setState(() {
                                _agreedToTerms = value ?? false;
                              });
                            },
                            isDark: isDark,
                          ),
                          SizedBox(height: 12.h),
                          _buildCheckbox(
                            value: _agreedToPrivacy,
                            label: 'insurance.accident.agree_to_privacy'.tr(),
                            onChanged: (value) {
                              setState(() {
                                _agreedToPrivacy = value ?? false;
                              });
                            },
                            isDark: isDark,
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (_showAdditionalFields)
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
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
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'insurance.accident.submit'.tr(),
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

  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : const Color(0xFF222222),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    required Color cardColor,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
    int maxLines = 1,
    bool required = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : const Color(0xFF555555),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLength: maxLength,
          maxLines: maxLines,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            filled: true,
            fillColor: cardColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : const Color(0xFFE0E0E0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : const Color(0xFFE0E0E0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: const Color(0xFFFF9800), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.red, width: 1.5),
            ),
            counterText: '',
          ),
          validator: required
              ? validator ??
                  (value) {
                    if (value == null || value.isEmpty) {
                      return 'insurance.accident.errors.field_required'.tr();
                    }
                    return null;
                  }
              : null,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    required Color cardColor,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : const Color(0xFF555555),
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
                filled: true,
                fillColor: cardColor,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                suffixIcon: Icon(
                  Icons.calendar_today,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  size: 20.sp,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey[700]! : const Color(0xFFE0E0E0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey[700]! : const Color(0xFFE0E0E0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: const Color(0xFFFF9800),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.red, width: 1.5),
                ),
              ),
              validator: validator,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTariffCard({
    required TariffEntity tariff,
    required bool isSelected,
    required bool isDark,
    required Color cardColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF9800)
                : (isDark ? Colors.grey[700]! : const Color(0xFFE0E0E0)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF9800).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF9800)
                      : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
                  width: 2,
                ),
                color:
                    isSelected ? const Color(0xFFFF9800) : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'insurance.accident.tariff'.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'insurance.accident.tariff_description'.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${tariff.insurancePremium.toStringAsFixed(0)} so\'m',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFF9800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFFF9800),
          checkColor: Colors.white,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.grey[300] : const Color(0xFF555555),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
