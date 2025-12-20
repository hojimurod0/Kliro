import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../bloc/payment_bloc.dart';

@RoutePage(name: 'PaymentProcessingRoute')
class PaymentProcessingPage extends StatefulWidget {
  final String uuid;
  final String checkoutUrl;
  final String returnUrl;

  const PaymentProcessingPage({
    super.key,
    required this.uuid,
    required this.checkoutUrl,
    required this.returnUrl,
  });

  @override
  State<PaymentProcessingPage> createState() => _PaymentProcessingPageState();
}

class _PaymentProcessingPageState extends State<PaymentProcessingPage> with WidgetsBindingObserver {
  late PaymentBloc _bloc;
  bool _urlLaunched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bloc = ServiceLocator.resolve<PaymentBloc>();
    _launchPaymentUrl();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _urlLaunched) {
      // App resumed, check status
      _checkStatus();
    }
  }

  Future<void> _launchPaymentUrl() async {
    final uri = Uri.parse(widget.checkoutUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      setState(() {
        _urlLaunched = true;
      });
    } else {
      SnackbarHelper.showError(
        context,
        'To\'lov sahifasini ochib bo\'lmadi',
      );
    }
  }

  void _checkStatus() {
    _bloc.add(CheckStatusRequested(widget.uuid));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('To\'lov holati'),
          automaticallyImplyLeading: false,
        ),
        body: BlocConsumer<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (state is PaymentStatusSuccess) {
              if (state.status == 'paid' || state.status == 'success') {
                context.router.pop(true); // Return success
              } else if (state.status == 'failed' || state.status == 'canceled') {
                SnackbarHelper.showError(
                  context,
                  'To\'lov bekor qilindi yoki xatolik: ${state.status}',
                );
                context.router.pop(false);
              } else {
                // Pending, waiting...
              }
            }
          },
          builder: (context, state) {
            String statusText = 'To\'lov kutilmoqda...';
            if (state is PaymentStatusSuccess) {
              statusText = 'Status: ${state.status}';
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 24),
                    Text(
                      statusText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Iltimos, to\'lovni amalga oshirgandan so\'ng ilovaga qayting.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _checkStatus,
                      child: const Text('Statusni tekshirish'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.router.pop(false),
                      child: const Text('Bekor qilish'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
