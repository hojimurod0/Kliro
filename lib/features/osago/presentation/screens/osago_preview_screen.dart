import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/bloc/osago_bloc.dart';
import '../../logic/bloc/osago_event.dart';
import '../../logic/bloc/osago_state.dart';
import '../../utils/osago_utils.dart';
import 'osago_order_confirmation_screen.dart';

// -----------------------------------------------------------------------------
// CONSTANTS & THEME
// -----------------------------------------------------------------------------
class PreviewAppColors {
  static const Color background = Color(0xFFF5F6FA);
  static const Color primary = Color(0xFF0095F6);
  static const Color textDark = Colors.black;
  static const Color textGrey = Colors.grey;
  static const Color white = Colors.white;
}

class OsagoPreviewScreen extends StatefulWidget {
  const OsagoPreviewScreen({super.key});

  @override
  State<OsagoPreviewScreen> createState() => _OsagoPreviewScreenState();
}

class _OsagoPreviewScreenState extends State<OsagoPreviewScreen> {
  bool _navigated = false;
  String? _selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OsagoBloc, OsagoState>(
      listener: (context, state) {
        if (state is OsagoFailure && state.errorMessage != null) {
          // Сбрасываем флаг навигации при ошибке, чтобы можно было попробовать снова
          _navigated = false;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
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
      builder: (context, state) {
        final calc = state.calcResponse;
        final insurance = state.insurance;
        final vehicle = state.vehicle;
        if (calc == null || insurance == null || vehicle == null) {
          return Scaffold(
            backgroundColor: PreviewAppColors.background,
            appBar: _buildAppBar(),
            body: const Center(child: Text('Hisoblash natijalari topilmadi')),
          );
        }
        final isLoading = state is OsagoLoading;
        final currentPaymentMethod = state.paymentMethod ?? _selectedPaymentMethod;
        
        return Scaffold(
          backgroundColor: PreviewAppColors.background,
          appBar: _buildAppBar(),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryTile(
                    title: 'Kompaniya',
                    value: insurance.companyName,
                  ),
                  _buildSummaryTile(
                    title: 'Muddati',
                    value: OsagoUtils.mapIdToPeriod(insurance.periodId) ?? '${insurance.periodId} oy',
                  ),
                  _buildSummaryTile(
                    title: 'Avto',
                    value: '${vehicle.brand} ${vehicle.model}',
                  ),
                  _buildSummaryTile(
                    title: 'Gos raqami',
                    value: vehicle.gosNumber,
                  ),
                  _buildSummaryTile(
                    title: 'Polis summasi',
                    value:
                        '${calc.amount.toStringAsFixed(2)} ${calc.currency.toUpperCase()}',
                  ),
                  const SizedBox(height: 12),
                  // To'lov turi tanlash
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: PreviewAppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "To'lov turi",
                          style: TextStyle(
                            color: PreviewAppColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RadioListTile<String>(
                          title: const Text('Payme'),
                          value: 'payme',
                          groupValue: currentPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value;
                            });
                            context.read<OsagoBloc>().add(PaymentSelected(value!));
                          },
                          activeColor: PreviewAppColors.primary,
                          contentPadding: EdgeInsets.zero,
                        ),
                        RadioListTile<String>(
                          title: const Text('Click'),
                          value: 'click',
                          groupValue: currentPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value;
                            });
                            context.read<OsagoBloc>().add(PaymentSelected(value!));
                          },
                          activeColor: PreviewAppColors.primary,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (isLoading || state.createResponse != null || currentPaymentMethod == null)
                          ? null
                          : () => _createPolicy(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PreviewAppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Rasmiylashtirish',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: PreviewAppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: PreviewAppColors.textDark),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Buyurtma preview',
        style: TextStyle(
          color: PreviewAppColors.textDark,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSummaryTile({required String title, required String value}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PreviewAppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: PreviewAppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: PreviewAppColors.textDark,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _createPolicy(BuildContext context) {
    setState(() => _navigated = false);
    context.read<OsagoBloc>().add(const CreatePolicyRequested());
  }
}
