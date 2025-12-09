import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/bloc/osago_bloc.dart';
import '../../logic/bloc/osago_event.dart';
import '../../logic/bloc/osago_state.dart';
import '../../utils/osago_utils.dart';
import 'osago_order_confirmation_screen.dart';

// -----------------------------------------------------------------------------
// CONSTANTS & THEME
// -----------------------------------------------------------------------------
// PreviewAppColors класс o'rniga Theme.of(context) ishlatiladi

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
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: _buildAppBar(),
            body: Center(child: Text('insurance.osago.preview.no_results'.tr())),
          );
        }
        final isLoading = state is OsagoLoading;
        final currentPaymentMethod = state.paymentMethod ?? _selectedPaymentMethod;
        
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryTile(
                    title: 'insurance.osago.preview.company'.tr(),
                    value: insurance.companyName,
                  ),
                  _buildSummaryTile(
                    title: 'insurance.osago.preview.period'.tr(),
                    value: OsagoUtils.mapIdToPeriod(insurance.periodId) ?? '${insurance.periodId} ${'insurance.osago.preview.months'.tr()}',
                  ),
                  _buildSummaryTile(
                    title: 'insurance.osago.preview.vehicle'.tr(),
                    value: '${vehicle.brand} ${vehicle.model}',
                  ),
                  _buildSummaryTile(
                    title: 'insurance.osago.preview.gos_number'.tr(),
                    value: vehicle.gosNumber,
                  ),
                  _buildSummaryTile(
                    title: 'insurance.osago.preview.policy_amount'.tr(),
                    value:
                        '${calc.amount.toStringAsFixed(2)} ${calc.currency.toUpperCase()}',
                  ),
                  const SizedBox(height: 12),
                  // To'lov turi tanlash
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'insurance.osago.preview.payment_type'.tr(),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.titleLarge?.color,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RadioListTile<String>(
                          title: Text('insurance.osago.payment.payment_method_payme'.tr()),
                          value: 'payme',
                          groupValue: currentPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value;
                            });
                            context.read<OsagoBloc>().add(PaymentSelected(value!));
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                          contentPadding: EdgeInsets.zero,
                        ),
                        RadioListTile<String>(
                          title: Text('insurance.osago.payment.payment_method_click'.tr()),
                          value: 'click',
                          groupValue: currentPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value;
                            });
                            context.read<OsagoBloc>().add(PaymentSelected(value!));
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
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
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'insurance.osago.preview.confirm'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (isLoading)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black38,
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'insurance.osago.preview.title'.tr(),
        style: TextStyle(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  Widget _buildSummaryTile({required String title, required String value}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
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
