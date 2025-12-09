import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/bloc/osago_bloc.dart';
import '../../logic/bloc/osago_event.dart';
import '../../logic/bloc/osago_state.dart';
import 'osago_order_confirmation_screen.dart';
import 'osago_success_screen.dart';

class OsagoPaymentScreen extends StatefulWidget {
  const OsagoPaymentScreen({super.key});

  @override
  State<OsagoPaymentScreen> createState() => _OsagoPaymentScreenState();
}

class _OsagoPaymentScreenState extends State<OsagoPaymentScreen> {
  String? _selectedMethod;
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OsagoBloc, OsagoState>(
      listener: (context, state) {
        if (state is OsagoFailure && state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
        if (state is OsagoCheckSuccess && !_navigated) {
          _navigated = true;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<OsagoBloc>(),
                child: const OsagoSuccessScreen(),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final vehicle = state.vehicle;
        final insurance = state.insurance;
        final calc = state.calcResponse;
        final isLoading = state is OsagoLoading;
        
        if (vehicle == null || insurance == null || calc == null) {
          return Scaffold(
            appBar: AppBar(title: Text('insurance.osago.payment.title'.tr())),
            body: Center(child: Text('insurance.osago.payment.no_data'.tr())),
          );
        }

        final formattedGosNumber = _formatGosNumber(vehicle.gosNumber);
        final formattedPhone = _formatPhone(insurance.phoneNumber);
        final formattedStartDate = _formatDate(insurance.startDate);
        final osagoType = vehicle.isOwner 
            ? 'insurance.osago.check.individual'.tr() 
            : 'insurance.osago.check.juridical'.tr();
        final amountText = '${calc.amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        )} sum';

        return Scaffold(
          appBar: AppBar(
            title: Text('insurance.osago.payment.title'.tr()),
            backgroundColor: Theme.of(context).cardColor,
            iconTheme: IconThemeData(color: Theme.of(context).textTheme.titleLarge?.color),
            titleTextStyle: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
            ),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'insurance.osago.payment.order_info'.tr(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildInfoRow('insurance.osago.payment.vehicle_number'.tr(), formattedGosNumber, showFlag: true),
                          _buildInfoRow('insurance.osago.payment.car_make'.tr(), '${vehicle.brand} ${vehicle.model}'),
                          _buildInfoRow('insurance.osago.payment.passport_series'.tr(), '${vehicle.ownerPassportSeria} ${vehicle.ownerPassportNumber}'),
                          _buildInfoRow('insurance.osago.payment.tech_passport'.tr(), '${vehicle.techSeria} ${vehicle.techNumber}'),
                          _buildInfoRow('insurance.osago.payment.osago_type'.tr(), osagoType),
                          _buildInfoRow('insurance.osago.payment.insurance_term'.tr(), '${insurance.periodId} ${'insurance.osago.preview.months'.tr()}'),
                          _buildInfoRow('insurance.osago.payment.insurance_company'.tr(), insurance.companyName),
                          _buildInfoRow('insurance.osago.payment.start_date'.tr(), formattedStartDate),
                          _buildInfoRow('insurance.osago.payment.phone'.tr(), formattedPhone),
                          const SizedBox(height: 24),
                          // Выбор метода оплаты
                          Text(
                            'insurance.osago.preview.payment_type'.tr(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildPaymentMethodCard(
                            'payme',
                            'insurance.osago.payment.payment_method_payme'.tr(),
                            _buildPaymeLogo(context),
                          ),
                          const SizedBox(height: 12),
                          _buildPaymentMethodCard(
                            'click',
                            'insurance.osago.payment.payment_method_click'.tr(),
                            _buildClickLogo(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Нижняя панель с суммой и кнопкой
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'insurance.osago.payment.total_amount'.tr(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  amountText,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 160,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: (isLoading || _selectedMethod == null)
                                  ? null
                                  : _onPayPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'insurance.osago.payment.pay'.tr(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (isLoading)
                Positioned.fill(
                  child: ColoredBox(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.7)
                        : Colors.black.withOpacity(0.38),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {bool showFlag = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (showFlag)
                  Container(
                    width: 20,
                    height: 15,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Center(
                      child: Text(
                        '🇺🇿',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatGosNumber(String gosNumber) {
    // Форматируем номер как "21 3 231 23" (регион + пробел + остальные символы через пробел)
    // Пример: "01J409QC" -> "01 J 4 0 9 Q C"
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
    // Форматируем телефон как "+998 99 999 99-99"
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 12 && cleaned.startsWith('998')) {
      return '+${cleaned.substring(0, 3)} ${cleaned.substring(3, 5)} ${cleaned.substring(5, 8)} ${cleaned.substring(8, 10)}-${cleaned.substring(10)}';
    } else if (cleaned.length == 9) {
      return '+998 ${cleaned.substring(0, 2)} ${cleaned.substring(2, 5)} ${cleaned.substring(5, 7)}-${cleaned.substring(7)}';
    }
    return phone;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _onMethodChanged(String? value) {
    if (value == null) return;
    setState(() => _selectedMethod = value);
    context.read<OsagoBloc>().add(PaymentSelected(value));
  }

  Future<void> _onPayPressed() async {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('insurance.osago.payment.select_payment_method'.tr())));
      return;
    }
    
    // To'lov turini saqlash
    context.read<OsagoBloc>().add(PaymentSelected(_selectedMethod!));
    
    // Buyurtma ma'lumotlari sahifasiga o'tish
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<OsagoBloc>(),
          child: const OsagoOrderConfirmationScreen(),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(String value, String title, Widget logo) {
    final isSelected = _selectedMethod == value;
    final isLoading = context.read<OsagoBloc>().state is OsagoLoading;
    
    return InkWell(
      onTap: isLoading ? null : () => _onMethodChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Logo (circular)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).cardColor
                    : Colors.white,
              ),
              child: logo,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            // Radio button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor,
                  width: 2,
                ),
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymeLogo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Theme.of(context).cardColor : Colors.white,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'pay',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'me',
              style: TextStyle(
                color: Color(0xFF00D4AA), // Teal color
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickLogo(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF0066FF), // Blue color
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).cardColor
                : Colors.white,
          ),
          child: Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0066FF),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
