import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/osago_driver.dart';
import '../../logic/bloc/osago_bloc.dart';
import '../../logic/bloc/osago_event.dart';
import '../../logic/bloc/osago_state.dart';
import '../../utils/osago_utils.dart';
import 'osago_order_confirmation_screen.dart';

// -----------------------------------------------------------------------------
// CHECK INFORMATION SCREEN (Ma'lumotlarni tekshirish sahifasi)
// -----------------------------------------------------------------------------
// Theme.of(context) orqali dark va light theme qo'llab-quvvatlanadi

class OsagoCheckInformationScreen extends StatefulWidget {
  const OsagoCheckInformationScreen({super.key});

  @override
  State<OsagoCheckInformationScreen> createState() =>
      _OsagoCheckInformationScreenState();
}

class _OsagoCheckInformationScreenState
    extends State<OsagoCheckInformationScreen> {
  String? _selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return BlocListener<OsagoBloc, OsagoState>(
      listener: (context, state) {
        if (state is OsagoFailure && state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
        // Agar policy yaratilgan bo'lsa va hali to'lov sahifasiga o'tilmagan bo'lsa
        if (state is OsagoCreateSuccess &&
            state.createResponse != null &&
            _selectedPaymentMethod == null) {
          // To'lov sahifasiga o'tish (OsagoOrderConfirmationScreen)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _navigateToPaymentScreen(context);
              setState(() {
                _selectedPaymentMethod =
                    'pending'; // Flag to prevent multiple navigations
              });
            }
          });
        }
      },
      child: BlocBuilder<OsagoBloc, OsagoState>(
        builder: (context, state) {
          final vehicle = state.vehicle;
          final insurance = state.insurance;
          final calc = state.calcResponse;

          if (vehicle == null || insurance == null || calc == null) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: _buildAppBar(context),
              body: Center(
                child: Text(
                  'insurance.osago.check.no_data'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            );
          }

          // Formatlash funksiyalari
          final formattedGosNumber = _formatGosNumber(vehicle.gosNumber);
          final formattedPhone = _formatPhone(insurance.phoneNumber);
          final formattedStartDate = _formatDate(insurance.startDate);
          final osagoType = vehicle.isOwner
              ? 'insurance.osago.check.individual'.tr()
              : 'insurance.osago.check.juridical'.tr();
          final term =
              OsagoUtils.mapIdToPeriod(insurance.periodId) ??
              '${insurance.periodId} ${'insurance.osago.preview.months'.tr()}';
          final totalPrice = calc.amount.toInt();

          // Debug: API dan kelgan ma'lumotlarni tekshirish
          log(
            '[OSAGO_CHECK] Calc amount: ${calc.amount} (${calc.amount.toInt()}), issueYear: ${calc.issueYear}',
            name: 'OSAGO',
          );
          log('[OSAGO_CHECK] Total price (toInt): $totalPrice', name: 'OSAGO');

          // API dan kelgan qo'shimcha ma'lumotlar
          final ownerName = state.ownerName ?? calc.ownerName;
          final numberDriversId = state.numberDriversId ?? calc.numberDriversId;
          final sessionId = calc.sessionId;

          // Debug: Drivers ma'lumotlarini log qilish
          log(
            '[OSAGO_CHECK] Drivers ma\'lumotlari: count=${state.drivers.length}',
            name: 'OSAGO',
          );
          for (var i = 0; i < state.drivers.length; i++) {
            final d = state.drivers[i];
            log(
              '[OSAGO_CHECK] Driver[$i]: passport=${d.passportSeria} ${d.passportNumber}, relative=${d.relative}, birthday=${OsagoUtils.formatDateForDisplay(d.driverBirthday)}',
              name: 'OSAGO',
            );
          }

          // Number drivers ni formatlash
          String driversText = '';
          if (numberDriversId != null) {
            if (numberDriversId == '0') {
              driversText = 'insurance.osago.check.unlimited_drivers'.tr();
            } else if (numberDriversId == '5') {
              driversText = 'insurance.osago.check.limited_drivers'.tr();
            } else {
              driversText =
                  '$numberDriversId ${'insurance.osago.check.drivers'.tr()}';
            }
          }

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: _buildAppBar(context),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Order Information Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'insurance.osago.check.order_info'.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Ma'lumot qatorlari
                        InfoRow(
                          label: 'insurance.osago.check.vehicle_number'.tr(),
                          value: '$formattedGosNumber 🇺🇿',
                        ),
                        if (vehicle.brand.isNotEmpty)
                          InfoRow(
                            label: 'insurance.osago.check.car_brand'.tr(),
                            value: vehicle.brand,
                          ),
                        if (vehicle.model.isNotEmpty)
                          InfoRow(
                            label: 'insurance.osago.check.car_model'.tr(),
                            value: vehicle.model,
                          ),
                        if (vehicle.brand.isEmpty && vehicle.model.isNotEmpty)
                          InfoRow(
                            label: 'insurance.osago.check.car_make'.tr(),
                            value: vehicle.model,
                          ),
                        // Yil ma'lumotini ko'rsatish (har doim ko'rsatish)
                        InfoRow(
                          label: 'insurance.osago.check.car_year'.tr(),
                          value: calc.issueYear != null && calc.issueYear! > 0
                              ? calc.issueYear.toString()
                              : '-',
                        ),
                        InfoRow(
                          label: 'insurance.osago.check.passport_series'.tr(),
                          value:
                              '${vehicle.ownerPassportSeria} ${vehicle.ownerPassportNumber}',
                        ),
                        InfoRow(
                          label: 'insurance.osago.check.owner_birth_date'.tr(),
                          value: OsagoUtils.formatDateForDisplay(
                            vehicle.ownerBirthDate,
                          ),
                        ),
                        InfoRow(
                          label: 'insurance.osago.check.tech_passport'.tr(),
                          value: '${vehicle.techSeria} ${vehicle.techNumber}',
                        ),
                        InfoRow(
                          label: 'insurance.osago.check.osago_type'.tr(),
                          value: osagoType,
                        ),
                        InfoRow(
                          label: 'insurance.osago.check.insurance_term'.tr(),
                          value: term,
                        ),
                        InfoRow(
                          label: 'insurance.osago.check.insurance_company'.tr(),
                          value: insurance.companyName,
                        ),
                        InfoRow(
                          label: 'insurance.osago.check.start_date'.tr(),
                          value: formattedStartDate,
                        ),
                        InfoRow(
                          label: 'insurance.osago.check.phone'.tr(),
                          value: formattedPhone,
                        ),
                        // Qo'shimcha ma'lumotlar
                        if (ownerName != null && ownerName.isNotEmpty)
                          InfoRow(
                            label: 'insurance.osago.check.owner_name'.tr(),
                            value: ownerName,
                          ),
                        if (numberDriversId != null && driversText.isNotEmpty)
                          InfoRow(
                            label: 'insurance.osago.check.number_drivers'.tr(),
                            value: driversText,
                          ),
                        InfoRow(
                          label: 'insurance.osago.check.session_id'.tr(),
                          value: sessionId,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Haydovchilar kartalari (agar mavjud bo'lsa)
                  // Faqat qo'shimcha haydovchilar uchun kartalar (birinchi haydovchi - egasi)
                  // Haydovchilar kartalari (agar mavjud bo'lsa)
                  // MUHIM: Agar cheklangan OSAGO bo'lsa va haydovchilar qo'shilgan bo'lsa, ularni ko'rsatish
                  Builder(
                    builder: (context) {
                      // OSAGO type ni tekshirish - cheklangan yoki cheklanmagan
                      final osagoType = state.osagoType;
                      final limitedText = 'insurance.osago.vehicle.type_limited'
                          .tr();
                      final isLimited = osagoType == limitedText;

                      log(
                        '[OSAGO_CHECK] UI render: drivers.length=${state.drivers.length}, numberDriversId=$numberDriversId, osagoType=$osagoType, isLimited=$isLimited',
                        name: 'OSAGO',
                      );

                      // Agar cheklangan OSAGO bo'lsa va haydovchilar mavjud bo'lsa, ularni ko'rsatish
                      // Yoki agar cheklanmagan OSAGO bo'lsa va haydovchilar 1 tadan ko'p bo'lsa
                      final shouldShowDrivers =
                          (isLimited && state.drivers.isNotEmpty) ||
                          (!isLimited && state.drivers.length > 1) ||
                          (numberDriversId == '5' && state.drivers.isNotEmpty);

                      log(
                        '[OSAGO_CHECK] shouldShowDrivers=$shouldShowDrivers',
                        name: 'OSAGO',
                      );

                      if (shouldShowDrivers && state.drivers.isNotEmpty) {
                        // numberDriversId ni to'g'ri o'tkazish - agar cheklangan bo'lsa '5', aks holda numberDriversId
                        final effectiveNumberDriversId = isLimited
                            ? '5'
                            : numberDriversId;
                        return Column(
                          children: _buildDriverCards(
                            context,
                            state.drivers,
                            effectiveNumberDriversId,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BottomPriceBar(
              totalPrice: totalPrice,
              onConfirm: () => _showPaymentMethodDialog(context, state),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Colors.transparent,
      leading: CustomBackButton(onPressed: () => Navigator.of(context).pop()),
      title: Text(
        'insurance.osago.check.title'.tr(),
        style: TextStyle(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  String _formatGosNumber(String gosNumber) {
    final cleaned = gosNumber.replaceAll(' ', '').toUpperCase();
    if (cleaned.length >= 2) {
      final region = cleaned.substring(0, 2);
      final rest = cleaned.substring(2);
      if (rest.isNotEmpty) {
        return '$region ${rest.split('').join(' ')}';
      }
      return region;
    }
    return gosNumber;
  }

  String _formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 12 && cleaned.startsWith('998')) {
      // Format: +998 33 110 88 10
      return '+${cleaned.substring(0, 3)} ${cleaned.substring(3, 5)} ${cleaned.substring(5, 8)} ${cleaned.substring(8, 10)} ${cleaned.substring(10)}';
    } else if (cleaned.length == 9) {
      // Format: +998 33 110 88 10
      return '+998 ${cleaned.substring(0, 2)} ${cleaned.substring(2, 5)} ${cleaned.substring(5, 7)} ${cleaned.substring(7)}';
    }
    return phone;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _showPaymentMethodDialog(BuildContext context, OsagoState state) {
    // Avval create policy qilish kerak, agar hali qilinmagan bo'lsa
    if (state.createResponse == null) {
      // Policy yaratishni boshlash
      context.read<OsagoBloc>().add(const CreatePolicyRequested());
      // BlocListener orqali kuzatib, policy yaratilgandan keyin to'lov sahifasiga o'tish
      return;
    }

    // Agar policy allaqachon yaratilgan bo'lsa, to'lov sahifasiga o'tish
    _navigateToPaymentScreen(context);
  }

  void _navigateToPaymentScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<OsagoBloc>(),
          child: const OsagoOrderConfirmationScreen(),
        ),
      ),
    );
  }

  // Haydovchilar kartalarini yaratish
  List<Widget> _buildDriverCards(
    BuildContext context,
    List<OsagoDriver> drivers,
    String? numberDriversId,
  ) {
    log(
      '[OSAGO_CHECK] _buildDriverCards chaqirildi: drivers count=${drivers.length}, numberDriversId=$numberDriversId',
      name: 'OSAGO',
    );

    // MUHIM: Agar cheklangan OSAGO bo'lsa (numberDriversId == '5'), barcha haydovchilarni ko'rsatish
    // Cheklangan OSAGO da qo'shilgan barcha haydovchilar ko'rsatilishi kerak
    List<OsagoDriver> driversToShow;
    int startIndex;

    if (numberDriversId == '5') {
      // Cheklangan OSAGO: barcha haydovchilarni ko'rsatish (qo'shilgan haydovchilar)
      driversToShow = drivers.take(5).toList(); // Maksimum 5 ta haydovchi
      startIndex = 1; // 1-haydovchi, 2-haydovchi, va hokazo
      log(
        '[OSAGO_CHECK] Cheklangan OSAGO: ${driversToShow.length} ta haydovchi ko\'rsatilmoqda',
        name: 'OSAGO',
      );
    } else if (drivers.length > 1) {
      // Cheklanmagan OSAGO: birinchi haydovchini o'tkazib yuboramiz (egasi)
      driversToShow = drivers
          .sublist(1)
          .take(5)
          .toList(); // Maksimum 5 ta haydovchi
      startIndex = 2; // 2-haydovchi, 3-haydovchi, va hokazo
      log(
        '[OSAGO_CHECK] Cheklanmagan OSAGO: ${driversToShow.length} ta qo\'shimcha haydovchi ko\'rsatilmoqda',
        name: 'OSAGO',
      );
    } else {
      driversToShow = [];
      startIndex = 1;
      log(
        '[OSAGO_CHECK] Haydovchilar ko\'rsatilmaydi: drivers.length=${drivers.length}, numberDriversId=$numberDriversId',
        name: 'OSAGO',
      );
    }

    log(
      '[OSAGO_CHECK] Drivers to show count: ${driversToShow.length}, startIndex=$startIndex',
      name: 'OSAGO',
    );

    if (driversToShow.isEmpty) {
      log(
        '[OSAGO_CHECK] Drivers to show bo\'sh, kartalar yaratilmaydi',
        name: 'OSAGO',
      );
      return [];
    }

    return driversToShow.asMap().entries.map((entry) {
      final index = entry.key;
      final driver = entry.value;
      log(
        '[OSAGO_CHECK] Haydovchi kartasi yaratilmoqda: ${index + startIndex}-haydovchi, passport=${driver.passportSeria} ${driver.passportNumber}, relative=${driver.relative}',
        name: 'OSAGO',
      );
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _DriverCard(driver: driver, driverNumber: index + startIndex),
      );
    }).toList();
  }
}

// -----------------------------------------------------------------------------
// REUSABLE WIDGETS (Qayta ishlatiluvchi komponentlar)
// -----------------------------------------------------------------------------

// Ma'lumot qatori
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                color:
                    theme.textTheme.bodySmall?.color ??
                    theme.textTheme.labelLarge?.color,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color:
                    theme.textTheme.bodyLarge?.color ??
                    theme.textTheme.titleMedium?.color,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// Orqaga qaytish tugmasi (Custom dizayn)
class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CustomBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed ?? () => Navigator.of(context).pop(),
          child: Center(
            child: Icon(
              Icons.arrow_back,
              color: theme.textTheme.titleLarge?.color,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

// Pastki to'lov paneli
class BottomPriceBar extends StatelessWidget {
  final int totalPrice;
  final VoidCallback onConfirm;

  const BottomPriceBar({
    super.key,
    required this.totalPrice,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.02),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'insurance.osago.check.total_amount'.tr(),
                style: TextStyle(
                  color:
                      theme.textTheme.bodySmall?.color ??
                      theme.textTheme.labelLarge?.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatCurrency(totalPrice),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'insurance.osago.check.confirm'.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    // Formatlash: "39200 sum" yoki "392 000 sum" yoki "1 200 000 sum"
    // 5 xonali raqamlar uchun probel qo'shilmaydi (masalan: 39200)
    // 6 va undan ko'p xonali raqamlar uchun har 3 ta raqamdan keyin probel qo'shiladi
    final amountStr = amount.toString();
    if (amountStr.length <= 3) {
      return "$amountStr sum";
    }

    // Agar 5 xonali bo'lsa (masalan: 39200), probel qo'shilmaydi
    if (amountStr.length == 5) {
      return "$amountStr sum";
    }

    // 6 va undan ko'p xonali raqamlar uchun har 3 ta raqamdan keyin probel qo'shamiz
    final result = StringBuffer();
    final chars = amountStr.split('').reversed.toList();

    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) {
        result.write(' ');
      }
      result.write(chars[i]);
    }

    // Teskari qilib, to'g'ri tartibda qaytaramiz
    final formatted = result.toString().split('').reversed.join();
    return "$formatted sum";
  }
}

// Haydovchi kartasi (Expandable)
class _DriverCard extends StatefulWidget {
  final OsagoDriver driver;
  final int driverNumber;

  const _DriverCard({required this.driver, required this.driverNumber});

  @override
  State<_DriverCard> createState() => _DriverCardState();
}

class _DriverCardState extends State<_DriverCard> {
  bool _isExpanded = false;

  String _getRelationshipText(int relativeId) {
    final relationshipOptions = {
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
    return relationshipOptions[relativeId] ?? relationshipOptions[0]!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        children: [
          // Header (bosiladigan qism)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${widget.driverNumber}-haydovchi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ],
              ),
            ),
          ),
          // Ma'lumotlar (expandable qism)
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Divider(color: theme.dividerColor),
                  const SizedBox(height: 12),
                  InfoRow(
                    label: 'insurance.osago.check.passport_series'.tr(),
                    value:
                        '${widget.driver.passportSeria} ${widget.driver.passportNumber}',
                  ),
                  InfoRow(
                    label: 'insurance.osago.check.owner_birth_date'.tr(),
                    value: OsagoUtils.formatDateForDisplay(
                      widget.driver.driverBirthday,
                    ),
                  ),
                  InfoRow(
                    label: 'insurance.osago.company.relationship_degree'.tr(),
                    value: _getRelationshipText(widget.driver.relative),
                    isLast: true,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
