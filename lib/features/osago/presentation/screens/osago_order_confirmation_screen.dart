import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../logic/bloc/osago_bloc.dart';
import '../../logic/bloc/osago_event.dart';
import '../../logic/bloc/osago_state.dart';
import '../../utils/osago_utils.dart';

// -----------------------------------------------------------------------------
// CONSTANTS & THEME
// -----------------------------------------------------------------------------
class AppColors {
  static const Color background = Color(0xFFF5F6FA);
  static const Color primary = Color(0xFF0095F6);
  static const Color textDark = Colors.black;
  static const Color textGrey = Colors.grey;
  static const Color white = Colors.white;
}

// -----------------------------------------------------------------------------
// MAIN PAGE
// -----------------------------------------------------------------------------
class OsagoOrderConfirmationScreen extends StatefulWidget {
  const OsagoOrderConfirmationScreen({super.key});

  @override
  State<OsagoOrderConfirmationScreen> createState() => _OsagoOrderConfirmationScreenState();
}

class _OsagoOrderConfirmationScreenState extends State<OsagoOrderConfirmationScreen> {
  String? _selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OsagoBloc, OsagoState>(
      builder: (context, state) {
        final vehicle = state.vehicle;
        final insurance = state.insurance;
        final calc = state.calcResponse;
        
        if (vehicle == null || insurance == null || calc == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('OSAGO')),
            body: const Center(child: Text('Ma\'lumotlar topilmadi')),
          );
        }

        // Formatlash funksiyalari
        final formattedGosNumber = _formatGosNumber(vehicle.gosNumber);
        final formattedPhone = _formatPhone(insurance.phoneNumber);
        final formattedStartDate = _formatDate(insurance.startDate);
        final osagoType = vehicle.isOwner ? 'Individual' : 'Juridik';
        final term = OsagoUtils.mapIdToPeriod(insurance.periodId) ?? '${insurance.periodId} months';
        final totalPrice = calc.amount.toInt();

        // Используем сохраненный метод оплаты из state или выбранный локально
        final currentPaymentMethod = state.paymentMethod ?? _selectedPaymentMethod;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Order Information Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Order Information",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Order data rows
                            InfoRow(
                              label: "Vehicle Number",
                              value: '$formattedGosNumber 🇺🇿',
                            ),
                            InfoRow(
                              label: "Car Make",
                              value: '${vehicle.brand} ${vehicle.model}',
                            ),
                            InfoRow(
                              label: "Passport Series",
                              value: '${vehicle.ownerPassportSeria} ${vehicle.ownerPassportNumber}',
                            ),
                            InfoRow(
                              label: "Technical Passport Number",
                              value: '${vehicle.techSeria} ${vehicle.techNumber}',
                            ),
                            InfoRow(
                              label: "Type of OSAGO",
                              value: osagoType,
                            ),
                            InfoRow(
                              label: "Insurance Term",
                              value: term,
                            ),
                            InfoRow(
                              label: "Insurance Company",
                              value: insurance.companyName,
                            ),
                            InfoRow(
                              label: "Start Date",
                              value: formattedStartDate,
                            ),
                            InfoRow(
                              label: "Phone",
                              value: formattedPhone,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Payment Method Selection Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "To'lov turi",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _PaymentMethodOption(
                              title: 'Payme',
                              value: 'payme',
                              groupValue: currentPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value;
                                });
                                context.read<OsagoBloc>().add(PaymentSelected(value!));
                              },
                            ),
                            const SizedBox(height: 12),
                            _PaymentMethodOption(
                              title: 'Click',
                              value: 'click',
                              groupValue: currentPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value;
                                });
                                context.read<OsagoBloc>().add(PaymentSelected(value!));
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom Bar
              _BottomBar(
                totalPrice: totalPrice,
                onConfirm: () => _onConfirmPressed(context, state),
                paymentMethod: currentPaymentMethod,
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: const Text(
        "OSAGO",
        style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  String _formatGosNumber(String gosNumber) {
    // Форматируем номер как "21 3 231 23" (регион + пробел + остальные символы через пробел)
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


  Future<void> _onConfirmPressed(BuildContext context, OsagoState state) async {
    final createResponse = state.createResponse;
    final paymentMethod = state.paymentMethod ?? _selectedPaymentMethod;
    
    if (createResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('To\'lov ma\'lumotlari topilmadi')),
      );
      return;
    }
    
    if (paymentMethod == null || paymentMethod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('To\'lov turini tanlang')),
      );
      return;
    }
    
    // Получаем URL для оплаты из createResponse
    final paymentUrl = createResponse.getPaymentUrl(paymentMethod);
    
    // Если есть прямой URL для оплаты, открываем его
    if (paymentUrl != null && paymentUrl.isNotEmpty) {
      final success = await launchUrlString(
        paymentUrl,
        mode: LaunchMode.externalApplication,
      );
      
      if (!context.mounted) return;
      
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('To\'lov havolasini ochib bo\'lmadi')),
        );
        return;
      }
    } else {
      // Если URL нет, открываем приложение Payme или Click
      final appUrl = _getPaymentAppUrl(paymentMethod);
      if (appUrl != null) {
        final success = await launchUrlString(
          appUrl,
          mode: LaunchMode.externalApplication,
        );
        
        if (!context.mounted) return;
        
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ilovani ochib bo\'lmadi')),
          );
          return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('To\'lov havolasi mavjud emas')),
        );
        return;
      }
    }
    
    // После открытия ссылки оплаты, начинаем проверку статуса полиса
    context.read<OsagoBloc>().add(const CheckPolicyRequested());
  }

  String? _getPaymentAppUrl(String paymentMethod) {
    if (paymentMethod == 'payme') {
      if (Platform.isAndroid) {
        return 'https://play.google.com/store/apps/details?id=uz.dida.payme&hl=ru';
      } else if (Platform.isIOS) {
        return 'https://apps.apple.com/us/app/payme-%D0%BF%D0%B5%D1%80%D0%B5%D0%B2%D0%BE%D0%B4%D1%8B-%D0%B8-%D0%BF%D0%BB%D0%B0%D1%82%D0%B5%D0%B6%D0%B8/id1093525667';
      }
    } else if (paymentMethod == 'click') {
      if (Platform.isAndroid) {
        return 'https://play.google.com/store/apps/details?id=air.com.ssdsoftwaresolutions.clickuz';
      } else if (Platform.isIOS) {
        return 'https://apps.apple.com/uz/app/click-superapp/id768132591';
      }
    }
    return null;
  }
}

// -----------------------------------------------------------------------------
// OPTIMIZED WIDGETS
// -----------------------------------------------------------------------------
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Pastki panel alohida Widget sifatida
class _BottomBar extends StatelessWidget {
  final int totalPrice;
  final VoidCallback onConfirm;
  final String? paymentMethod;

  const _BottomBar({
    required this.totalPrice,
    required this.onConfirm,
    this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
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
              const Text(
                "Jami summa",
                style: TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                _formatCurrency(totalPrice),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: paymentMethod != null ? onConfirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child: const Text(
              "To'lash",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    // Форматируем как "1, 200 000 sum" (с запятой после первой цифры)
    final amountStr = amount.toString();
    if (amountStr.length <= 3) {
      return "$amountStr sum";
    }
    
    // Первая цифра/цифры + запятая
    final firstPart = amountStr.substring(0, amountStr.length % 3 == 0 ? 3 : amountStr.length % 3);
    final restPart = amountStr.substring(firstPart.length);
    
    // Форматируем остальную часть с пробелами
    final formattedRest = restPart.replaceAllMapped(
      RegExp(r'(\d{3})'),
      (Match m) => ' ${m[1]}',
    );
    
    return "$firstPart,$formattedRest sum";
  }
}

// Payment Method Option Widget
class _PaymentMethodOption extends StatelessWidget {
  final String title;
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  const _PaymentMethodOption({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;
    
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? Colors.white : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.primary,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


