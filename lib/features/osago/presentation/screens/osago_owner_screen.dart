import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/osago_vehicle.dart';
import '../../logic/bloc/osago_bloc.dart';
import '../../logic/bloc/osago_event.dart';
import '../../logic/bloc/osago_state.dart';
import '../../utils/osago_utils.dart';
import 'osago_order_confirmation_screen.dart';

class OsagoOwnerScreen extends StatefulWidget {
  const OsagoOwnerScreen({super.key});

  @override
  State<OsagoOwnerScreen> createState() => _OsagoOwnerScreenState();
}

class _OsagoOwnerScreenState extends State<OsagoOwnerScreen> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<OsagoBloc, OsagoState>(
      listener: (context, state) {
        if (state is OsagoFailure && state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          _navigated = false; // Reset navigation flag on error
        }
        // Navigate to order confirmation screen after policy is created
        if (state is OsagoCreateSuccess &&
            state.createResponse != null &&
            !_navigated) {
          _navigated = true;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<OsagoBloc>(),
                child: const OsagoOrderConfirmationScreen(),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('insurance.osago.owner.title'.tr()),
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
        body: BlocBuilder<OsagoBloc, OsagoState>(
          builder: (context, state) {
            final vehicle = state.vehicle;
            final ownerName = state.ownerName;

            if (vehicle == null) {
              return Center(child: Text('insurance.osago.owner.no_data'.tr()));
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sarlavha
                        Text(
                          'insurance.osago.owner.check_info'.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Mashina egasi ma'lumotlari kartochkasi
                        _buildOwnerInfoCard(context, vehicle, ownerName),
                        const SizedBox(height: 20),
                        // Avtomobil ma'lumotlari kartochkasi
                        _buildVehicleInfoCard(context, vehicle),
                      ],
                    ),
                  ),
                ),
                // Pastki Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        log('[OSAGO_OWNER] Continue bosildi', name: 'OSAGO');
                        if (!_navigated && mounted) {
                          // Calc va Create policy ni chaqirish
                          final currentState = context.read<OsagoBloc>().state;
                          if (currentState.insurance != null &&
                              currentState.vehicle != null) {
                            // Agar calcResponse bo'lmasa, calc ni chaqiramiz
                            if (currentState.calcResponse == null) {
                              log(
                                '[OSAGO_OWNER] CalcRequested event yuborilmoqda',
                                name: 'OSAGO',
                              );
                              context.read<OsagoBloc>().add(
                                const CalcRequested(),
                              );
                            } else if (currentState.createResponse == null) {
                              // Agar calcResponse bo'lsa, lekin createResponse bo'lmasa, create ni chaqiramiz
                              log(
                                '[OSAGO_OWNER] CreatePolicyRequested event yuborilmoqda',
                                name: 'OSAGO',
                              );
                              context.read<OsagoBloc>().add(
                                const CreatePolicyRequested(),
                              );
                            } else {
                              // Agar ikkalasi ham bo'lsa, to'g'ridan-to'g'ri navigation
                              log(
                                '[OSAGO_OWNER] To\'g\'ridan-to\'g\'ri navigation',
                                name: 'OSAGO',
                              );
                              _navigated = true;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<OsagoBloc>(),
                                    child: const OsagoOrderConfirmationScreen(),
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('insurance.osago.vehicle.continue'.tr()),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Mashina egasi ma'lumotlari kartochkasi
  Widget _buildOwnerInfoCard(
    BuildContext context,
    OsagoVehicle vehicle,
    String? ownerName,
  ) {
    final theme = Theme.of(context);
    final cardBg = theme.cardColor;
    final textColor = theme.textTheme.titleLarge?.color ?? Colors.white;
    final subtitleColor = theme.textTheme.bodySmall?.color;

    // Parse ownerName to separate name parts (Ism, Familiya, Otchestvo)
    String? firstName;
    String? lastName;
    String? middleName;
    if (ownerName != null && ownerName.isNotEmpty) {
      final nameParts = ownerName.trim().split(RegExp(r'\s+'));
      if (nameParts.length >= 1) {
        lastName = nameParts[0]; // Familiya
      }
      if (nameParts.length >= 2) {
        firstName = nameParts[1]; // Ism
      }
      if (nameParts.length >= 3) {
        middleName = nameParts[2]; // Otchestvo
      }
    }

    // Format passport
    final passportDisplay =
        '${vehicle.ownerPassportSeria} ${vehicle.ownerPassportNumber}';

    // Format birth date
    final birthDateDisplay = OsagoUtils.formatDateForDisplay(
      vehicle.ownerBirthDate,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'insurance.osago.owner.owner_info'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          // Ism, Familiya, Otchestvo
          if (ownerName != null && ownerName.isNotEmpty) ...[
            if (lastName != null)
              _buildInfoRow(
                context,
                'insurance.osago.owner.last_name'.tr(),
                lastName,
                subtitleColor,
              ),
            if (firstName != null)
              _buildInfoRow(
                context,
                'insurance.osago.owner.first_name'.tr(),
                firstName,
                subtitleColor,
              ),
            if (middleName != null)
              _buildInfoRow(
                context,
                'insurance.osago.owner.middle_name'.tr(),
                middleName,
                subtitleColor,
              ),
            // Agar nameParts bo'lsa, lekin 3 tadan kam bo'lsa, to'liq nomni ko'rsatamiz
            if (lastName == null && firstName == null && middleName == null)
              _buildInfoRow(
                context,
                'insurance.osago.owner.full_name'.tr(),
                ownerName,
                subtitleColor,
              ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
          ],
          // Passport seriya va raqam
          _buildInfoRow(
            context,
            'insurance.osago.owner.passport'.tr(),
            passportDisplay,
            subtitleColor,
          ),
          // Tug'ilgan sana
          _buildInfoRow(
            context,
            'insurance.osago.owner.birth_date'.tr(),
            birthDateDisplay,
            subtitleColor,
          ),
        ],
      ),
    );
  }

  // Avtomobil ma'lumotlari kartochkasi
  Widget _buildVehicleInfoCard(BuildContext context, OsagoVehicle vehicle) {
    final theme = Theme.of(context);
    final cardBg = theme.cardColor;
    final textColor = theme.textTheme.titleLarge?.color ?? Colors.white;
    final subtitleColor = theme.textTheme.bodySmall?.color;

    // Format gos number
    String formattedGosNumber = vehicle.gosNumber;
    if (formattedGosNumber.length >= 2) {
      final region = formattedGosNumber.substring(0, 2);
      final rest = formattedGosNumber.substring(2);
      if (rest.isNotEmpty) {
        formattedGosNumber = '$region ${rest.split('').join(' ')}';
      }
    }

    // Format tech passport
    final techPassportDisplay = '${vehicle.techSeria} ${vehicle.techNumber}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'insurance.osago.owner.vehicle_info'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          // Avtomobil raqami
          _buildInfoRow(
            context,
            'insurance.osago.owner.vehicle_number'.tr(),
            formattedGosNumber,
            subtitleColor,
          ),
          // Brend va Model
          if (vehicle.brand.isNotEmpty || vehicle.model.isNotEmpty)
            _buildInfoRow(
              context,
              'insurance.osago.owner.brand_model'.tr(),
              '${vehicle.brand} ${vehicle.model}'.trim(),
              subtitleColor,
            ),
          // Tex passport
          _buildInfoRow(
            context,
            'insurance.osago.owner.tech_passport'.tr(),
            techPassportDisplay,
            subtitleColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    Color? subtitleColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: subtitleColor),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
