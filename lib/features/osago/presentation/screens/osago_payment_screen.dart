import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/bloc/osago_bloc.dart';
import '../../logic/bloc/osago_event.dart';
import '../../logic/bloc/osago_state.dart';
import 'osago_order_confirmation_screen.dart';
import 'osago_success_screen.dart';

const Color _primaryBlue = Color(0xFF0091EA);

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
            appBar: AppBar(title: const Text('To\'lov')),
            body: const Center(child: Text('Ma\'lumotlar topilmadi')),
          );
        }

        final formattedGosNumber = _formatGosNumber(vehicle.gosNumber);
        final formattedPhone = _formatPhone(insurance.phoneNumber);
        final formattedStartDate = _formatDate(insurance.startDate);
        final osagoType = vehicle.isOwner ? 'Individual' : 'Juridik';
        final amountText = '${calc.amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        )} sum';

        return Scaffold(
          appBar: AppBar(title: const Text('OSAGO')),
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
                          const Text(
                            'Order Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildInfoRow('Vehicle Number', formattedGosNumber, showFlag: true),
                          _buildInfoRow('Car Make', '${vehicle.brand} ${vehicle.model}'),
                          _buildInfoRow('Passport Series', '${vehicle.ownerPassportSeria} ${vehicle.ownerPassportNumber}'),
                          _buildInfoRow('Technical Passport Number', '${vehicle.techSeria} ${vehicle.techNumber}'),
                          _buildInfoRow('Type of OSAGO', osagoType),
                          _buildInfoRow('Insurance Term', '${insurance.periodId} months'),
                          _buildInfoRow('Insurance Company', insurance.companyName),
                          _buildInfoRow('Start Date', formattedStartDate),
                          _buildInfoRow('Phone', formattedPhone),
                          const SizedBox(height: 24),
                          // Выбор метода оплаты
                          const Text(
                            'To\'lov turi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          RadioListTile<String>(
                            title: const Text('Payme'),
                            value: 'payme',
                            groupValue: _selectedMethod,
                            onChanged: isLoading ? null : _onMethodChanged,
                            activeColor: _primaryBlue,
                            contentPadding: EdgeInsets.zero,
                          ),
                          RadioListTile<String>(
                            title: const Text('Click'),
                            value: 'click',
                            groupValue: _selectedMethod,
                            onChanged: isLoading ? null : _onMethodChanged,
                            activeColor: _primaryBlue,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Нижняя панель с суммой и кнопкой
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
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
                                const Text(
                                  'Jami summa',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  amountText,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryBlue,
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
                                backgroundColor: _primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'To\'lash',
                                style: TextStyle(
                                  color: Colors.white,
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
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black38,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {bool showFlag = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
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
      ).showSnackBar(const SnackBar(content: Text('To\'lov turini tanlang')));
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
}
