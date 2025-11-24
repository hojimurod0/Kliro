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
import '../../../../core/services/auth/auth_service.dart';
import '../../domain/params/auth_params.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/common_back_button.dart';

@RoutePage()
class UserDetailsScreen extends StatefulWidget implements AutoRouteWrapper {
  final String contactInfo;

  const UserDetailsScreen({super.key, required this.contactInfo});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceLocator.resolve<RegisterBloc>(),
      child: this,
    );
  }

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  // Parol ko'rinishi holatlari
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // TextField controllerlari
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth.user_details.snack_name'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedRegionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth.user_details.snack_region'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth.user_details.snack_password'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth.user_details.snack_password_match'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final normalizedContact = AuthService.normalizeContact(widget.contactInfo);
    if (normalizedContact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kontakt ma'lumotida xatolik bor."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final isEmail = normalizedContact.contains('@');
    context.read<RegisterBloc>().add(
      CompleteRegistrationRequested(
        RegistrationFinalizeParams(
          email: isEmail ? normalizedContact : null,
          phone: isEmail ? null : normalizedContact,
          regionId: _selectedRegionId!,
          password: password,
          confirmPassword: confirmPassword,
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
        if (state.flow != RegisterFlow.registrationFinalize) return;

        if (state.status == RegisterStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'Xatolik yuz berdi'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state.status == RegisterStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message ?? 'auth.user_details.snack_saved'.tr(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.router.replace(HomeRoute());
        }
      },
      builder: (context, state) {
        final isLoading =
            state.isLoading && state.flow == RegisterFlow.registrationFinalize;
        return Scaffold(
          backgroundColor: AppColors.white,
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
                    'auth.user_details.title'.tr(),
                    style: AppTypography.headingXL,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'auth.user_details.subtitle'.tr(),
                    style: AppTypography.bodyPrimary,
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
                  SizedBox(height: AppSpacing.md),

                  // --- PAROL ---
                  _buildLabel('auth.field.password_label'.tr()),
                  SizedBox(height: AppSpacing.xs),
                  _buildTextField(
                    controller: _passwordController,
                    hint: 'auth.field.password_hint'.tr(),
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isVisible: _isPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  SizedBox(height: AppSpacing.md),

                  // --- PAROLNI TASDIQLASH ---
                  _buildLabel('auth.field.confirm_password_label'.tr()),
                  SizedBox(height: AppSpacing.xs),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hint: 'auth.field.confirm_password_label'.tr(),
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isVisible: _isConfirmPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  SizedBox(height: AppSpacing.xxl),

                  // 4. Kirish (Submit) Tugmasi
                  AuthPrimaryButton(
                    label: 'auth.user_details.submit'.tr(),
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
      child: Text(text, style: AppTypography.labelSmall),
    );
  }

  // Oddiy Input Field
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      decoration: AppInputDecoration.outline(
        hint: hint,
        prefixIcon: icon,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey,
                  size: 20.sp,
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
      ),
    );
  }

  // Dropdown Field (Manzil tanlash uchun)
  Widget _buildDropdownField() {
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
          color: AppColors.black,
          size: 20.sp,
        ),
        decoration: AppInputDecoration.outline(
          hint: 'auth.user_details.address_hint'.tr(),
          prefixIcon: Icons.location_on_outlined,
        ),
        dropdownColor: AppColors.white,
        items: _regions.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(
              entry.key,
              style: TextStyle(fontSize: 13.sp, color: AppColors.black),
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

  // Orqaga tugmasi
}
