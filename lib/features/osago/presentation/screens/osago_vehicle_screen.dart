import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../domain/entities/osago_vehicle.dart';
import '../../logic/bloc/osago_bloc.dart';
import '../../logic/bloc/osago_event.dart';
import '../../logic/bloc/osago_state.dart';
import '../../utils/osago_utils.dart';
import '../../utils/upper_case_text_formatter.dart';
import '../widgets/license_plate_widget.dart';
import '../widgets/section_header.dart';
import '../widgets/select_input.dart';
import '../widgets/series_number_widget.dart';
import '../widgets/period_selection_sheet.dart';
import '../widgets/selection_sheet.dart';
import 'osago_company_screen.dart';

class OsagoVehicleScreen extends StatefulWidget {
  const OsagoVehicleScreen({super.key});

  @override
  State<OsagoVehicleScreen> createState() => _OsagoVehicleScreenState();
}

class _OsagoVehicleScreenState extends State<OsagoVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _navigated = false;
  bool _isSubmitting = false;

  final _regionCtrl = TextEditingController(text: "01");
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
  }

  void _onPassportChanged() {
    _updateVehicleData();
  }

  void _onTechPassportChanged() {
    _updateVehicleData();
  }

  void _updateVehicleData() {
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
    for (var c in [
      _regionCtrl,
      _carNumberCtrl,
      _passportCtrl,
      _techSeriesCtrl,
      _techNumberCtrl,
      _periodCtrl,
      _typeCtrl,
    ]) {
      c.dispose();
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('insurance.osago.vehicle.errors.fill_all_fields'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final fullGosNumber = OsagoUtils.normalizeGosNumber(
      _regionCtrl.text,
      _carNumberCtrl.text,
    );

    if (!OsagoUtils.isValidGosNumber(fullGosNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'insurance.osago.vehicle.errors.invalid_car_number'.tr(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final periodId = OsagoUtils.mapPeriodToId(_periodCtrl.text);
    if (periodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('insurance.osago.vehicle.errors.select_period'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_typeCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('insurance.osago.vehicle.errors.not_selected'.tr()),
          backgroundColor: Colors.red,
        ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
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
          _isSubmitting = false;
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
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          'insurance.osago.vehicle.car_number'.tr(),
                        ),
                        LicensePlateWidget(
                          regionCtrl: _regionCtrl,
                          numberCtrl: _carNumberCtrl,
                        ),
                        SizedBox(height: 20.h),
                        SectionHeader('insurance.osago.vehicle.passport'.tr()),
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
                                color: value.text.isEmpty
                                    ? Theme.of(context).hintColor
                                    : Theme.of(context).textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: "AA1234567",
                                counterText: "",
                                filled: true,
                                fillColor: Theme.of(context).cardColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1.0,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'insurance.osago.vehicle.errors.enter_passport'
                                      .tr();
                                }
                                final cleaned = v.replaceAll(' ', '').toUpperCase();
                                if (cleaned.length < 9 || cleaned.length > 9) {
                                  return 'insurance.osago.vehicle.errors.passport_format'
                                      .tr();
                                }
                                if (!RegExp(r'^[A-Z]{2}\d{7}$').hasMatch(cleaned)) {
                                  return 'insurance.osago.vehicle.errors.passport_format'
                                      .tr();
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        SizedBox(height: 20.h),
                        SectionHeader(
                          'insurance.osago.vehicle.tech_passport'.tr(),
                        ),
                        SeriesNumberWidget(
                          seriesCtrl: _techSeriesCtrl,
                          numberCtrl: _techNumberCtrl,
                          seriesHint: "AAA",
                          numberHint: "1234567",
                          isTechPassport: true,
                        ),
                        SizedBox(height: 20.h),
                        SectionHeader(
                          'insurance.osago.vehicle.insurance_period'.tr(),
                        ),
                        SelectInput(
                          controller: _periodCtrl,
                          hint: 'insurance.osago.vehicle.select'.tr(),
                          onTap: () => _showPeriodSelectionSheet(),
                        ),
                        SizedBox(height: 20.h),
                        SectionHeader(
                          'insurance.osago.vehicle.osago_type'.tr(),
                        ),
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
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 30.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_isSubmitting) return;
                      _submit();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                              color: Colors.white,
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

