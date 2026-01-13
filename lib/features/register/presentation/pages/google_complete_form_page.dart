import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_input_decoration.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../domain/params/auth_params.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/common_back_button.dart';

@RoutePage()
class GoogleCompleteFormPage extends StatefulWidget implements AutoRouteWrapper {
  final String sessionId;

  const GoogleCompleteFormPage({
    super.key,
    required this.sessionId,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceLocator.resolve<RegisterBloc>(),
      child: this,
    );
  }

  @override
  State<GoogleCompleteFormPage> createState() => _GoogleCompleteFormPageState();
}

class _GoogleCompleteFormPageState extends State<GoogleCompleteFormPage> {
  // TextField controllerlari
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  // Manzillar ro'yxati va ularning ID lari
  final List<MapEntry<String, int>> _regions = [
    const MapEntry("Toshkent shahri", 1),
    const MapEntry("Toshkent viloyati", 2),
    const MapEntry("Andijon viloyati", 3),
    const MapEntry("Buxoro viloyati", 4),
    const MapEntry("Farg'ona viloyati", 5),
    const MapEntry("Jizzax viloyati", 6),
    const MapEntry("Xorazm viloyati", 7),
    const MapEntry("Namangan viloyati", 8),
    const MapEntry("Navoiy viloyati", 9),
    const MapEntry("Qashqadaryo viloyati", 10),
    const MapEntry("Qoraqalpog'iston", 11),
    const MapEntry("Samarqand viloyati", 12),
    const MapEntry("Sirdaryo viloyati", 13),
    const MapEntry("Surxondaryo viloyati", 14),
  ];

  int? _selectedRegionId;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _submit() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      SnackbarHelper.showError(
        context,
        'auth.user_details.snack_name'.tr(),
      );
      return;
    }

    if (_selectedRegionId == null) {
      SnackbarHelper.showError(
        context,
        'auth.user_details.snack_region'.tr(),
      );
      return;
    }

    // Google OAuth complete registration
    context.read<RegisterBloc>().add(
          CompleteGoogleRegistrationRequested(
            GoogleCompleteParams(
              sessionId: widget.sessionId,
              regionId: _selectedRegionId!,
              firstName: firstName,
              lastName: lastName,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.flow != RegisterFlow.googleComplete) return;

        if (state.status == RegisterStatus.failure) {
          SnackbarHelper.showError(
            context,
            state.error ?? tr('common.error_occurred_simple'),
          );
        } else if (state.status == RegisterStatus.success) {
          SnackbarHelper.showSuccess(
            context,
            state.message ?? 'Google ro\'yxatdan o\'tish muvaffaqiyatli yakunlandi',
          );
          context.router.replace(HomeRoute());
        }
      },
      builder: (context, state) {
        final isLoading =
            state.isLoading && state.flow == RegisterFlow.googleComplete;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.sm),
                  // 1. Orqaga tugmasi
                  const CommonBackButton(),

                  SizedBox(height: AppSpacing.lg),

                  // 2. Sarlavha
                  Text(
                    'Ma\'lumotlarni to\'ldiring',
                    style: AppTypography.headingXL(context).copyWith(
                      color: isDark ? AppColors.white : AppColors.black,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Google orqali ro\'yxatdan o\'tishni yakunlash uchun quyidagi ma\'lumotlarni kiriting',
                    style: AppTypography.bodyPrimary(context),
                  ),

                  SizedBox(height: AppSpacing.lg),
                  // 3. Inputlar

                  // --- ISM ---
                  _buildLabel('auth.field.first_name'.tr()),
                  SizedBox(height: AppSpacing.xs),
                  _buildTextField(
                    controller: _firstNameController,
                    hint: 'auth.field.first_name_hint'.tr(),
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: AppSpacing.md),

                  // --- FAMILIYA ---
                  _buildLabel('auth.field.last_name'.tr()),
                  SizedBox(height: AppSpacing.xs),
                  _buildTextField(
                    controller: _lastNameController,
                    hint: 'auth.field.last_name_hint'.tr(),
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: AppSpacing.md),

                  // --- MANZIL (DROPDOWN) ---
                  _buildLabel('auth.field.address'.tr()),
                  SizedBox(height: AppSpacing.xs),
                  _buildDropdownField(),
                  SizedBox(height: AppSpacing.xxl),

                  // 4. Kirish (Submit) Tugmasi
                  AuthPrimaryButton(
                    label: 'Ro\'yxatdan o\'tishni yakunlash',
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                  SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Label (Input tepasidagi kichik yozuv)
  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: Text(text, style: AppTypography.labelSmall(context)),
    );
  }

  // Oddiy Input Field
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      style: TextStyle(
        color: isDark ? AppColors.white : AppColors.black,
      ),
      decoration: AppInputDecoration.outline(
        hint: hint,
        prefixIcon: icon,
        fillColor: isDark ? AppColors.darkCardBg : AppColors.white,
        borderColor: isDark ? AppColors.darkBorder : null,
        hintColor: isDark ? AppColors.grayText : null,
        prefixIconColor: isDark ? AppColors.grayText : null,
      ),
    );
  }

  // Dropdown Field (Manzil tanlash uchun)
  Widget _buildDropdownField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedRegionName = _regions
        .firstWhere(
          (entry) => entry.value == _selectedRegionId,
          orElse: () => const MapEntry('', 0),
        )
        .key;

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
      child: DropdownButtonFormField<String>(
        value: _selectedRegionId != null ? selectedRegionName : null,
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: isDark ? AppColors.white : AppColors.black,
          size: 20.sp,
        ),
        decoration: AppInputDecoration.outline(
          hint: 'auth.user_details.address_hint'.tr(),
          prefixIcon: Icons.location_on_outlined,
          fillColor: isDark ? AppColors.darkCardBg : AppColors.white,
          borderColor: isDark ? AppColors.darkBorder : null,
          hintColor: isDark ? AppColors.grayText : null,
          prefixIconColor: isDark ? AppColors.grayText : null,
        ),
        dropdownColor: isDark ? AppColors.darkCardBg : AppColors.white,
        items: _regions.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(
              entry.key,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? AppColors.white : AppColors.black,
              ),
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            final entry = _regions.firstWhere((e) => e.key == newValue);
            setState(() {
              _selectedRegionId = entry.value;
            });
          }
        },
      ),
    );
  }
}

