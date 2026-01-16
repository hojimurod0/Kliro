import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/navigation/app_router.dart';
import '../bloc/avia_bloc.dart';
import '../widgets/primary_button.dart';
import '../bloc/payment_bloc.dart';
import '../../data/models/invoice_request_model.dart';
import '../../data/models/price_check_model.dart';
import '../../data/models/payment_permission_model.dart';
import '../../data/models/booking_model.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/base_stateful_widget.dart';

@RoutePage(name: 'PaymentRoute')
class PaymentPage extends StatefulWidget {
  final String bookingId;

  const PaymentPage({super.key, required this.bookingId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends BaseStatefulWidget<PaymentPage>
    with WidgetsBindingObserver {
  bool _hasLoaded = false;
  late PaymentBloc _paymentBloc;
  late AviaBloc _aviaBloc;

  // Local state to store responses from separate API calls
  PriceCheckModel? _priceCheck;
  PaymentPermissionModel? _permission;
  BookingModel? _booking;
  bool _isLoadingAvia = false;

  // Payment tracking
  String? _currentInvoiceUuid;
  bool _urlLaunched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // PaymentBloc va AviaBloc ni ServiceLocator dan olish
    _paymentBloc = ServiceLocator.resolve<PaymentBloc>();
    _aviaBloc = ServiceLocator.resolve<AviaBloc>();

    // Bir marta yuklash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded) {
        _hasLoaded = true;
        _loadData();
      }
    });
  }

  void _loadData() {
    if (mounted && !_aviaBloc.isClosed) {
      _aviaBloc
        ..add(PaymentPermissionRequested(widget.bookingId))
        ..add(CheckPriceRequested(widget.bookingId))
        ..add(BookingInfoRequested(widget.bookingId));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // BLoC'lar registerFactory bilan ro'yxatdan o'tkazilgan,
    // har safar yangi instance yaratiladi, shuning uchun close() qilish xavfsiz
    try {
      if (!_paymentBloc.isClosed) {
        _paymentBloc.close();
      }
    } catch (e) {
      // Error closing PaymentBloc - ignore
    }
    try {
      if (!_aviaBloc.isClosed) {
        _aviaBloc.close();
      }
    } catch (e) {
      // Error closing AviaBloc - ignore
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _urlLaunched &&
        _currentInvoiceUuid != null) {
      _checkPaymentStatus();
      // Polling ni qayta boshlash (agar to'xtatilgan bo'lsa)
      if (!hasActiveTimers()) {
        _startStatusPolling();
      }
    } else if (state == AppLifecycleState.paused) {
      // App paused bo'lganda polling ni to'xtatish (battery saqlash uchun)
      _stopStatusPolling();
    }
  }

  Future<void> _launchPaymentUrl(String checkoutUrl) async {
    try {
      if (checkoutUrl.isEmpty) {
        if (mounted) {
          SnackbarHelper.showError(
            context,
            'To\'lov linki topilmadi',
          );
        }
        return;
      }

      final uri = Uri.parse(checkoutUrl);

      // Android'da canLaunchUrl ba'zida false qaytaradi, lekin launchUrl ishlaydi
      // Shuning uchun to'g'ridan-to'g'ri launchUrl'ni chaqiramiz
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (launched || true) {
          // Ba'zida launchUrl false qaytaradi, lekin brauzer ochiladi
          if (mounted) {
            safeSetState(() {
              _urlLaunched = true;
            });
            // Status polling ni boshlash
            _startStatusPolling();
          }
        }
      } catch (launchError) {
        // Fallback: canLaunchUrl tekshirish
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (mounted) {
            safeSetState(() {
              _urlLaunched = true;
            });
            _startStatusPolling();
          }
        } else {
          if (mounted) {
            SnackbarHelper.showError(
              context,
              'To\'lov sahifasini ochib bo\'lmadi. Iltimos, qo\'lda oching: $checkoutUrl',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          'To\'lov sahifasini ochishda xatolik: $e',
        );
      }
    }
  }

  void _checkPaymentStatus() {
    if (_currentInvoiceUuid != null && mounted && !_paymentBloc.isClosed) {
      _paymentBloc.add(CheckStatusRequested(_currentInvoiceUuid!));
    }
  }

  void _startStatusPolling() {
    // Avval barcha timer'larni to'xtatish
    cancelAllTimers();
    if (_currentInvoiceUuid != null && mounted) {
      final timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (!mounted || _currentInvoiceUuid == null) {
          timer.cancel();
          return;
        }
        _checkPaymentStatus();
      });
      registerTimer(timer);
    }
  }

  void _stopStatusPolling() {
    cancelAllTimers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('avia.payment.title'.tr())),
      body: BlocListener<PaymentBloc, PaymentState>(
        bloc: _paymentBloc,
        listener: (context, state) {
          if (state is InvoiceCreatedSuccess) {
            // To'lov linkini to'g'ridan-to'g'ri ochish
            if (state.invoice.checkoutUrl.isEmpty) {
              if (mounted) {
                SnackbarHelper.showError(
                  context,
                  'To\'lov linki topilmadi',
                );
              }
              return;
            }
            if (mounted) {
              safeSetState(() {
                _currentInvoiceUuid = state.invoice.uuid;
                _urlLaunched = false;
              });
              _launchPaymentUrl(state.invoice.checkoutUrl);
            }
          } else if (state is PaymentStatusSuccess) {
            // To'lov holati tekshirildi
            if (state.status == 'paid' || state.status == 'success') {
              // To'lov muvaffaqiyatli bo'lganda polling ni to'xtatish va payBooking API'sini chaqirish
              _stopStatusPolling();
              if (mounted && !_aviaBloc.isClosed) {
                _aviaBloc.add(PaymentRequested(widget.bookingId));
                safeSetState(() {
                  _currentInvoiceUuid = null;
                  _urlLaunched = false;
                });
              }
            } else if (state.status == 'failed' || state.status == 'canceled') {
              _stopStatusPolling();
              if (mounted) {
                SnackbarHelper.showError(
                  context,
                  'To\'lov bekor qilindi yoki xatolik: ${state.status}',
                );
                safeSetState(() {
                  _currentInvoiceUuid = null;
                  _urlLaunched = false;
                });
              }
            } else {
              // Pending holatda polling davom etadi
            }
          } else if (state is PaymentFailure) {
            _stopStatusPolling();
            if (mounted) {
              SnackbarHelper.showError(
                context,
                '${'avia.status.error_message'.tr()}: ${state.message}',
              );
            }
          }
        },
        child: BlocProvider.value(
          value: _aviaBloc,
          child: BlocConsumer<AviaBloc, AviaState>(
            bloc: _aviaBloc,
            listener: (context, state) {
              if (state is AviaCheckPriceLoading || 
                  state is AviaPaymentPermissionLoading || 
                  state is AviaPaymentLoading) {
                safeSetState(() => _isLoadingAvia = true);
              } else if (state is AviaCheckPriceSuccess) {
                safeSetState(() {
                  _priceCheck = state.priceCheck;
                  _isLoadingAvia = false;
                });
              } else if (state is AviaPaymentPermissionSuccess) {
                safeSetState(() {
                  _permission = state.permission;
                });
              } else if (state is AviaBookingInfoSuccess) {
                 safeSetState(() {
                   _booking = state.booking;
                 });
              } else if (state is AviaPaymentSuccess) {
                safeSetState(() => _isLoadingAvia = false);
                if (mounted) {
                  // payBooking muvaffaqiyatli bo'lganda StatusRoute'ga o'tish
                  context.router.replace(
                    StatusRoute(
                      bookingId: widget.bookingId,
                      status: state.response.status ?? 'success',
                    ),
                  );
                }
              } else if (state is AviaPaymentFailure) {
                safeSetState(() => _isLoadingAvia = false);
                if (mounted) {
                  SnackbarHelper.showError(
                    context,
                    '${'avia.status.error_message'.tr()}: ${state.message}',
                  );
                }
              } else if (state is AviaPaymentPermissionFailure) {
                safeSetState(() => _isLoadingAvia = false);
                if (mounted) {
                  SnackbarHelper.showError(
                    context,
                    state.message,
                    action: SnackBarAction(
                      label: 'avia.common.retry'.tr(),
                      textColor: Colors.white,
                      onPressed: _loadData,
                    ),
                  );
                }
              } else if (state is AviaCheckPriceFailure) {
                safeSetState(() => _isLoadingAvia = false);
                if (mounted) {
                  SnackbarHelper.showError(
                    context,
                    state.message,
                    action: SnackBarAction(
                      label: 'avia.common.retry'.tr(),
                      textColor: Colors.white,
                      onPressed: _loadData,
                    ),
                  );
                }
              }
            },
            builder: (context, state) {
              // Check if we have data (include Booking)
              final hasData = _priceCheck != null && _permission != null && _booking != null;

              if (_isLoadingAvia && !hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!hasData) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('avia.common.loading'
                          .tr()), // Assuming avia.common.loading or use existing common.loading
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: Text('avia.common.retry'.tr()),
                      ),
                    ],
                  ),
                );
              }

              final price =
                  '${_booking!.price ?? 'N/A'} ${_booking!.currency ?? ''}';

              // canPay logic based on paymentAllowed
              final canPay = _permission!.paymentAllowed ?? true; 

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'avia.payment.total_amount'.tr(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(price,
                                style: const TextStyle(
                                    fontSize: 24,
                                    color: AppColors.primaryBlue)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!canPay)
                      Card(
                        color: AppColors.dangerRed.withValues(alpha: 0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'avia.payment.no_payment'.tr(),
                                style: TextStyle(
                                    color: AppColors.dangerRed,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      BlocBuilder<PaymentBloc, PaymentState>(
                        bloc: _paymentBloc,
                        builder: (context, paymentState) {
                          return PrimaryButton(
                            text: 'avia.payment.pay'.tr(),
                            isLoading: _isLoadingAvia ||
                                paymentState is PaymentLoading,
                            onPressed: (_isLoadingAvia ||
                                    paymentState is PaymentLoading)
                                ? null
                                : () {
                                    // Narxni parse qilish va eng kichik birlikka o'tkazish
                                    // Use Booking price instead of PriceCheck price
                                    final priceString =
                                        _booking!.price ?? '0';
                                    // Raqam va nuqtani saqlab qolish (decimal uchun)
                                    final cleanPrice = priceString.replaceAll(
                                      RegExp(r'[^0-9.]'),
                                      '',
                                    );
                                    // Double ga o'tkazish
                                    final priceValue =
                                        double.tryParse(cleanPrice) ?? 0.0;

                                    // Debug log
                                    debugPrint('💰 PAYMENT_PAGE: Original price: $priceString');
                                    debugPrint('💰 PAYMENT_PAGE: Clean price: $cleanPrice');
                                    debugPrint('💰 PAYMENT_PAGE: Price value: $priceValue');

                                    // API eng kichik birlikda amount kutadi (masalan, 500000)
                                    // UZS uchun: 5000 UZS = 500000 (100 ga ko'paytiriladi)
                                    // Boshqa valyutalar uchun ham 100 ga ko'paytiriladi (cents uchun)
                                    // 10% komissiya qo'shish: price * 1.10 * 100
                                    final amountWithoutCommission = (priceValue * 100).toInt();
                                    final amount = (priceValue * 1.10 * 100).toInt();
                                    
                                    // Debug log
                                    debugPrint('💰 PAYMENT_PAGE: Amount without commission: $amountWithoutCommission');
                                    debugPrint('💰 PAYMENT_PAGE: Amount with 10% commission: $amount');

                                    // Amount musbat bo'lishi kerak (backend talabi)
                                    if (amount <= 0) {
                                      if (mounted) {
                                        final errorMessage =
                                            'avia.payment.price_not_available'
                                                .tr();
                                        SnackbarHelper.showError(
                                          context,
                                          errorMessage.contains(
                                                  'avia.payment.price_not_available')
                                              ? 'Narx mavjud emas. Iltimos, keyinroq qayta urinib ko\'ring.'
                                              : errorMessage,
                                        );
                                      }
                                      return;
                                    }

                                    // Invoice ID formatini Postman collection bo'yicha yaratish
                                    // Format: "aviaXXXXXXX" (7 ta raqam) - Postman'da ko'rsatilganidek
                                    // Random 7 ta raqam yaratish
                                    final random =
                                        DateTime.now().millisecondsSinceEpoch %
                                            10000000;
                                    final invoiceId =
                                        'avia${random.toString().padLeft(7, '0')}';

                                    if (!mounted || _paymentBloc.isClosed) {
                                      return;
                                    }

                                    final request = InvoiceRequestModel(
                                      amount: amount,
                                      invoiceId: invoiceId,
                                      lang: EasyLocalization.of(context)!
                                          .locale
                                          .languageCode,
                                      returnUrl: ApiPaths.paymentReturnUrl,
                                      callbackUrl:
                                          ApiPaths.paymentCallbackSuccessUrl,
                                    );

                                    _paymentBloc.add(
                                      CreateInvoiceRequested(request),
                                    );
                                  },
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
