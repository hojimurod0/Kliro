import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/navigation/app_router.dart';
import '../../data/models/create_booking_request_model.dart';
import '../bloc/avia_bloc.dart';
import '../../../../core/utils/validation_utils.dart';
import '../widgets/primary_button.dart';
import '../bloc/payment_bloc.dart';
import '../../data/models/invoice_request_model.dart';
import '../../data/models/price_check_model.dart';
import '../../data/models/payment_permission_model.dart';
import '../../data/models/booking_model.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/base_stateful_widget.dart';

@RoutePage(name: 'AviaBookingRoute')
class BookingPage extends StatefulWidget {
  final String offerId;

  const BookingPage({super.key, required this.offerId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends BaseStatefulWidget<BookingPage>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _payerNameController = TextEditingController();
  final _payerEmailController = TextEditingController();
  final _payerTelController = TextEditingController();
  final _passengerLastNameController = TextEditingController();
  final _passengerFirstNameController = TextEditingController();
  final _passengerBirthdateController = TextEditingController();
  final _passengerTelController = TextEditingController();
  final _passengerDocNumberController = TextEditingController();
  final _passengerDocExpireController = TextEditingController();

  String _passengerGender = 'M';
  String _passengerCitizenship = 'UZ';
  String _passengerDocType = 'A';
  String _passengerAge = 'adt';

  late PaymentBloc _paymentBloc;
  String? _currentBookingId;
  String? _currentInvoiceUuid;
  bool _urlLaunched = false;
  PriceCheckModel? _priceCheck;
  PaymentPermissionModel? _permission;
  BookingModel? _booking;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _paymentBloc = ServiceLocator.resolve<PaymentBloc>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _payerNameController.dispose();
    _payerEmailController.dispose();
    _payerTelController.dispose();
    _passengerLastNameController.dispose();
    _passengerFirstNameController.dispose();
    _passengerBirthdateController.dispose();
    _passengerTelController.dispose();
    _passengerDocNumberController.dispose();
    _passengerDocExpireController.dispose();
    // BLoC'lar registerFactory bilan ro'yxatdan o'tkazilgan,
    // har safar yangi instance yaratiladi, shuning uchun close() qilish xavfsiz
    try {
      if (!_paymentBloc.isClosed) {
        _paymentBloc.close();
      }
    } catch (e) {
      // Error closing PaymentBloc - ignore
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

        // Ba'zida launchUrl false qaytaradi, lekin brauzer ochiladi
        if (mounted) {
          safeSetState(() {
            _urlLaunched = true;
          });
          // Status polling ni boshlash
          _startStatusPolling();
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

  Future<void> _createInvoiceAndLaunch(
      String bookingId, PriceCheckModel priceCheck) async {
    // Narxni parse qilish va eng kichik birlikka o'tkazish
    // Avval priceCheck dan, keyin booking model'dan olish
    String? priceString = priceCheck.price;

    // Agar priceCheck da price yo'q bo'lsa, booking model'dan olish
    if (priceString == null || priceString.isEmpty || priceString == '0') {
      if (_booking?.price != null && _booking!.price!.isNotEmpty) {
        priceString = _booking!.price;
      }
    }

    // Agar hali ham price yo'q bo'lsa, xatolik
    if (priceString == null || priceString.isEmpty || priceString == '0') {
      if (mounted) {
        final errorMessage = 'avia.payment.price_not_available'.tr();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage.contains('avia.payment.price_not_available')
                  ? 'Narx mavjud emas. Iltimos, keyinroq qayta urinib ko\'ring.'
                  : errorMessage,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Raqam va nuqtani saqlab qolish (decimal uchun)
    final cleanPrice = priceString.replaceAll(
      RegExp(r'[^0-9.]'),
      '',
    );
    // Double ga o'tkazish
    final priceValue = double.tryParse(cleanPrice) ?? 0.0;

    // API eng kichik birlikda amount kutadi (masalan, 500000)
    // UZS uchun: 5000 UZS = 500000 (100 ga ko'paytiriladi)
    // Boshqa valyutalar uchun ham 100 ga ko'paytiriladi (cents uchun)
    final amount = (priceValue * 100).toInt();

    // Amount musbat bo'lishi kerak (backend talabi)
    if (amount <= 0) {
      if (mounted) {
        final errorMessage = 'avia.payment.price_not_available'.tr();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage.contains('avia.payment.price_not_available')
                  ? 'Narx mavjud emas. Iltimos, keyinroq qayta urinib ko\'ring.'
                  : errorMessage,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Invoice ID formatini Postman collection bo'yicha yaratish
    // Format: "aviaXXXXXXX" (7 ta raqam) - Postman'da ko'rsatilganidek
    // Random 7 ta raqam yaratish
    final random = DateTime.now().millisecondsSinceEpoch % 10000000;
    final invoiceId = 'avia${random.toString().padLeft(7, '0')}';

    if (!mounted || _paymentBloc.isClosed) {
      return;
    }

    final request = InvoiceRequestModel(
      amount: amount,
      invoiceId: invoiceId,
      lang: EasyLocalization.of(context)!.locale.languageCode,
      returnUrl: 'https://kliro.uz',
      callbackUrl: 'https://api.kliro.uz/payment/callback/success',
    );

    _paymentBloc.add(
      CreateInvoiceRequested(request),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AviaBloc, AviaState>(
          bloc: context.read<AviaBloc>(),
          listener: (context, state) {
            if (state is AviaCreateBookingSuccess) {
              final bookingId = state.booking.id ?? '';
              _currentBookingId = bookingId;
              _booking = state.booking;
              _priceCheck = null;
              _permission = null;
              // Price check va payment permission olish
              context.read<AviaBloc>()
                ..add(PaymentPermissionRequested(bookingId))
                ..add(CheckPriceRequested(bookingId));
            } else if (state is AviaCheckPriceSuccess &&
                _currentBookingId != null) {
              _priceCheck = state.priceCheck;
              // Ikkalasi ham kelganda invoice yaratish
              if (_priceCheck != null && _permission != null) {
                // canPay null bo'lsa ham, booking mavjud bo'lsa to'lovni davom ettirish
                // allowed ni ham tekshirish, agar ikkalasi ham null bo'lsa default true
                final canPay = _permission!.canPay ??
                    _permission!.allowed ??
                    _permission!.paymentAllowed ??
                    true; // Default: invoice yaratishga ruxsat berish
                if (canPay == true) {
                  _createInvoiceAndLaunch(_currentBookingId!, _priceCheck!);
                } else {
                  if (mounted) {
                    SnackbarHelper.showError(
                      context,
                      'To\'lov qilish mumkin emas',
                    );
                  }
                }
              }
            } else if (state is AviaPaymentPermissionSuccess &&
                _currentBookingId != null) {
              _permission = state.permission;
              // Ikkalasi ham kelganda invoice yaratish
              if (_priceCheck != null && _permission != null) {
                // canPay null bo'lsa ham, booking mavjud bo'lsa to'lovni davom ettirish
                // allowed ni ham tekshirish, agar ikkalasi ham null bo'lsa default true
                final canPay = _permission!.canPay ??
                    _permission!.allowed ??
                    _permission!.paymentAllowed ??
                    true; // Default: invoice yaratishga ruxsat berish
                if (canPay == true) {
                  _createInvoiceAndLaunch(_currentBookingId!, _priceCheck!);
                } else {
                  if (mounted) {
                    SnackbarHelper.showError(
                      context,
                      'To\'lov qilish mumkin emas',
                    );
                  }
                }
              }
            } else if (state is AviaCreateBookingFailure) {
              // Check if there's an existing booking ID (duplicate booking)
              if (state.existingBookingId != null) {
                // Navigate to the existing booking status page
                context.router.replace(
                  StatusRoute(
                    bookingId: state.existingBookingId!,
                    status: 'pending',
                  ),
                );
                // Show info message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Bu buyurtma allaqachon mavjud. Mavjud buyurtmaga o\'tildi.'),
                    backgroundColor: Colors.blue,
                  ),
                );
              } else {
                // Regular error - show error message
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  SnackBar(
                    content:
                        Text('${'avia.common.error'.tr()}: ${state.message}'),
                  ),
                );
              }
            } else if (state is AviaPaymentSuccess) {
              // To'lov muvaffaqiyatli bo'lganda StatusRoute'ga o'tish
              if (_currentBookingId != null) {
                context.router.replace(
                  StatusRoute(
                    bookingId: _currentBookingId!,
                    status: state.response.status ?? 'success',
                  ),
                );
              }
            }
          },
        ),
        BlocListener<PaymentBloc, PaymentState>(
          bloc: _paymentBloc,
          listener: (context, state) {
            if (state is InvoiceCreatedSuccess) {
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
              if (state.status == 'paid' || state.status == 'success') {
                // To'lov muvaffaqiyatli bo'lganda polling ni to'xtatish va payBooking API'sini chaqirish
                _stopStatusPolling();
                if (_currentBookingId != null &&
                    mounted &&
                    !context.read<AviaBloc>().isClosed) {
                  context
                      .read<AviaBloc>()
                      .add(PaymentRequested(_currentBookingId!));
                }
                if (mounted) {
                  safeSetState(() {
                    _currentInvoiceUuid = null;
                    _urlLaunched = false;
                  });
                }
              } else if (state.status == 'failed' ||
                  state.status == 'canceled') {
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
        ),
      ],
      child: BlocBuilder<AviaBloc, AviaState>(
        builder: (context, state) {
          if (state is AviaLoading) {
            return Scaffold(
              appBar: AppBar(title: Text('avia.formalization.title'.tr())),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            appBar: AppBar(title: Text('avia.formalization.title'.tr())),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'avia.formalization.customer_info'.tr(),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _payerNameController,
                      decoration: InputDecoration(
                        labelText: 'avia.formalization.name'.tr(),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => ValidationUtils.validateName(
                        value,
                        fieldName: 'avia.formalization.name'.tr(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _payerTelController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'avia.formalization.phone'.tr(),
                        border: OutlineInputBorder(),
                        hintText: '+998901234567',
                      ),
                      validator: ValidationUtils.validatePhone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _payerEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'avia.formalization.email'.tr(),
                        border: OutlineInputBorder(),
                      ),
                      validator: ValidationUtils.validateEmail,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'avia.formalization.passenger_info'.tr(),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passengerLastNameController,
                      decoration: InputDecoration(
                        labelText: 'avia.formalization.last_name'.tr(),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => ValidationUtils.validateName(
                        value,
                        fieldName: 'avia.formalization.last_name'.tr(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passengerFirstNameController,
                      decoration: InputDecoration(
                        labelText: 'avia.formalization.first_name'.tr(),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => ValidationUtils.validateName(
                        value,
                        fieldName: 'avia.formalization.first_name'.tr(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passengerBirthdateController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        labelText: 'avia.formalization.birth_date'.tr(),
                        hintText: 'avia.common.date_format_yyyy_mm_dd'.tr(),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => ValidationUtils.validateDate(value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passengerTelController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'avia.formalization.phone'.tr(),
                        hintText: '+998901234567',
                        border: OutlineInputBorder(),
                      ),
                      validator: ValidationUtils.validatePhone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passengerDocNumberController,
                      decoration: InputDecoration(
                        labelText: 'avia.formalization.passport_series'.tr(),
                        border: OutlineInputBorder(),
                      ),
                      validator: ValidationUtils.validateDocumentNumber,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passengerDocExpireController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        labelText: 'avia.formalization.passport_expiry'.tr(),
                        hintText: 'avia.common.date_format_yyyy_mm_dd'.tr(),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          ValidationUtils.validateDate(value, isRequired: true),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<AviaBloc, AviaState>(
                      builder: (context, state) {
                        final isLoading = state is AviaLoading;
                        return PrimaryButton(
                          text: 'avia.details.book'.tr(),
                          isLoading: isLoading,
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    final request = CreateBookingRequestModel(
                                      payerName: _payerNameController.text,
                                      payerEmail: _payerEmailController.text,
                                      payerTel: _payerTelController.text,
                                      passengers: [
                                        PassengerModel(
                                          lastName:
                                              _passengerLastNameController.text,
                                          firstName:
                                              _passengerFirstNameController
                                                  .text,
                                          age: _passengerAge,
                                          birthdate:
                                              _passengerBirthdateController
                                                  .text,
                                          gender: _passengerGender,
                                          citizenship: _passengerCitizenship,
                                          tel: _passengerTelController.text,
                                          docType: _passengerDocType,
                                          docNumber:
                                              _passengerDocNumberController
                                                  .text,
                                          docExpire:
                                              _passengerDocExpireController
                                                  .text,
                                        ),
                                      ],
                                    );

                                    context.read<AviaBloc>().add(
                                          CreateBookingRequested(
                                            offerId: widget.offerId,
                                            request: request,
                                          ),
                                        );
                                  }
                                },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
