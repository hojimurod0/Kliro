import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../bloc/avia_bloc.dart';
import '../bloc/payment_bloc.dart';
import '../widgets/primary_button.dart';
import '../../data/models/refund_amounts_model.dart';
import '../../data/models/price_check_model.dart';
import '../../data/models/payment_permission_model.dart';
import '../../data/models/invoice_request_model.dart';
import '../../data/models/booking_model.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/widgets/base_stateful_widget.dart';
import '../../../../core/services/auth/auth_service.dart';

@RoutePage(name: 'StatusRoute')
class StatusPage extends StatefulWidget {
  final String bookingId;
  final String status;

  const StatusPage({
    super.key,
    required this.bookingId,
    required this.status,
  });

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends BaseStatefulWidget<StatusPage> with WidgetsBindingObserver {
  bool _hasLoaded = false;
  // bool _isRefundLoading = false; // reserved for future UX improvements
  
  // Payment related
  PaymentBloc? _paymentBloc;
  PriceCheckModel? _priceCheck;
  PaymentPermissionModel? _permission;
  bool _isLoadingPayment = false;
  BookingModel? _booking;
  
  // Payment status polling
  String? _currentInvoiceUuid;
  bool _urlLaunched = false;

  PaymentBloc get paymentBloc {
    _paymentBloc ??= ServiceLocator.resolve<PaymentBloc>();
    return _paymentBloc!;
  }

  void _handlePdfDownload() {
    if ((_booking?.status ?? '').toLowerCase().isNotEmpty) {
      context.read<AviaBloc>().add(PdfReceiptRequested(widget.bookingId));
    } else {
      SnackbarHelper.showError(context, 'PDF faqat to\'langan bronlar uchun mavjud');
    }
  }

  Future<void> _launchPdfUrl(String pdfUrl) async {
    // Loading dialog ko'rsatish
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    try {
      Uint8List? pdfBytes;
      
      // 1. Base64 format tekshirish
      if (pdfUrl.startsWith('data:application/pdf;base64,')) {
        final base64String = pdfUrl.split(',').last;
        try {
          pdfBytes = base64Decode(base64String);
        } catch (e) {
          throw Exception('Base64 decode xatolik: $e');
        }
      } 
      // 2. HTTP/HTTPS URL bo'lsa
      else if (pdfUrl.startsWith('http://') || pdfUrl.startsWith('https://')) {
        // Token qo'shish
        final authService = AuthService.instance;
        final token = await authService.getAccessToken();
        
        final dio = Dio();
        if (token != null && token.isNotEmpty) {
          dio.options.headers['Authorization'] = 'Bearer $token';
        }
        
        final response = await dio.get(
          pdfUrl,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            validateStatus: (status) => status! < 500,
          ),
        );
        
        if (response.statusCode == 200 && response.data != null) {
          pdfBytes = response.data;
        } else if (response.statusCode == 401) {
          // Token eskirgan - refresh qilish va qayta urinish
          final authService = AuthService.instance;
          final newToken = await authService.refreshToken();
          if (newToken != null && newToken.isNotEmpty) {
            // Yangi token bilan qayta urinish
            final retryDio = Dio();
            retryDio.options.headers['Authorization'] = 'Bearer $newToken';
            final retryResponse = await retryDio.get(
              pdfUrl,
              options: Options(
                responseType: ResponseType.bytes,
                followRedirects: true,
                validateStatus: (status) => status! < 500,
              ),
            );
            if (retryResponse.statusCode == 200 && retryResponse.data != null) {
              pdfBytes = retryResponse.data;
            } else {
              throw Exception('PDF yuklab olishda xatolik: ${retryResponse.statusCode}');
            }
          } else {
            throw Exception('PDF yuklab olishda autentifikatsiya xatolik');
          }
        } else {
          throw Exception('PDF yuklab olishda xatolik: ${response.statusCode}');
        }
      } 
      // 3. Oddiy base64 string bo'lsa
      else {
        try {
          pdfBytes = base64Decode(pdfUrl);
        } catch (e) {
          // URL deb hisoblash
          final authService = AuthService.instance;
          final token = await authService.getAccessToken();
          
          final dio = Dio();
          if (token != null && token.isNotEmpty) {
            dio.options.headers['Authorization'] = 'Bearer $token';
          }
          
          final response = await dio.get(
            pdfUrl,
            options: Options(responseType: ResponseType.bytes),
          );
          pdfBytes = response.data;
        }
      }

      if (pdfBytes == null || pdfBytes.isEmpty) {
        throw Exception('PDF ma\'lumotlari bo\'sh');
      }

      // Fayl nomini yaratish
      final bookingId = widget.bookingId;
      final fileName = 'booking_${bookingId}_receipt.pdf';
      
      // Platform bo'yicha directory tanlash
      Directory? directory;
      String? filePath;
      
      if (Platform.isAndroid) {
        // Android uchun - app documents directory ishlatish (Scoped Storage)
        try {
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            // Downloads papkasiga saqlash
            final downloadsDir = Directory('${directory.path}/Download');
            if (!await downloadsDir.exists()) {
              await downloadsDir.create(recursive: true);
            }
            filePath = '${downloadsDir.path}/$fileName';
          }
        } catch (e) {
          // Fallback: application documents
          directory = await getApplicationDocumentsDirectory();
          filePath = '${directory.path}/$fileName';
        }
      } else if (Platform.isIOS) {
        // iOS uchun Documents papkasi
        directory = await getApplicationDocumentsDirectory();
        filePath = '${directory.path}/$fileName';
      } else {
        directory = await getExternalStorageDirectory();
        if (directory != null) {
          filePath = '${directory.path}/$fileName';
        }
      }

      if (filePath == null || directory == null) {
        // Fallback: temp file yaratish va ochish
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(pdfBytes);
        
        if (mounted) {
          Navigator.pop(context); // Loading dialog yopish
          await OpenFile.open(tempFile.path);
          SnackbarHelper.showInfo(
            context,
            'PDF ochildi',
          );
        }
        return;
      }

      // PDF faylni saqlash
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        Navigator.pop(context); // Loading dialog yopish
        
        SnackbarHelper.showSuccess(
          context,
          'PDF muvaffaqiyatli saqlandi',
        );
        
        // PDF ni ochish va ulashish dialog'ini ko'rsatish
        try {
          await OpenFile.open(filePath);
        } catch (e) {
          // Agar ochib bo'lmasa, faqat dialog ko'rsatish
        }
        
        _showPdfShareDialog(filePath);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Loading dialog yopish
        
        // Xatolik bo'lsa, browser'da ochishga harakat qilish
        try {
          String urlToOpen = pdfUrl;
          
          // Base64 bo'lsa, temp file yaratish
          if (pdfUrl.startsWith('data:application/pdf;base64,')) {
            final tempDir = await getTemporaryDirectory();
            final tempFile = File('${tempDir.path}/temp_receipt.pdf');
            final base64String = pdfUrl.split(',').last;
            await tempFile.writeAsBytes(base64Decode(base64String));
            urlToOpen = tempFile.path;
          }
          
          // URL bo'lsa, browser'da ochish
          if (urlToOpen.startsWith('http://') || urlToOpen.startsWith('https://')) {
            final uri = Uri.parse(urlToOpen);
            final launched = await launchUrl(
              uri, 
              mode: LaunchMode.externalApplication,
            );
            if (!launched) {
              SnackbarHelper.showError(context, 'PDF faylini ochib bo\'lmadi');
            }
          } else {
            // File path bo'lsa
            await OpenFile.open(urlToOpen);
          }
        } catch (launchError) {
          SnackbarHelper.showError(
            context,
            'PDF yuklab olishda xatolik: ${e.toString()}',
          );
        }
      }
    }
  }

  void _showPdfShareDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('PDF saqlandi'),
        content: Text('PDF fayl muvaffaqiyatli saqlandi. Ulashishni xohlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Yopish'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Share.shareXFiles([XFile(filePath)]);
              } catch (e) {
                SnackbarHelper.showError(context, 'Ulashishda xatolik');
              }
            },
            child: Text('Ulashish'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _paymentBloc = ServiceLocator.resolve<PaymentBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded) {
        _hasLoaded = true;
        _loadBookingInfo();
      }
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // BLoC'lar registerFactory bilan ro'yxatdan o'tkazilgan, 
    // har safar yangi instance yaratiladi, shuning uchun close() qilish xavfsiz
    if (_paymentBloc != null && !_paymentBloc!.isClosed) {
      try {
        _paymentBloc!.close();
      } catch (e) {
        // Error closing PaymentBloc - ignore
      }
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
      _startStatusPolling();
    } else if (state == AppLifecycleState.paused) {
      // App paused bo'lganda polling ni to'xtatish (battery saqlash uchun)
      _stopStatusPolling();
    }
  }
  
  void _checkPaymentStatus() {
    if (_currentInvoiceUuid != null && mounted && !paymentBloc.isClosed) {
      paymentBloc.add(CheckStatusRequested(_currentInvoiceUuid!));
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

  void _loadBookingInfo() {
    context.read<AviaBloc>().add(BookingInfoRequested(widget.bookingId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'avia.status.title'.tr(),
          style: AppTypography.headingL.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AviaBloc, AviaState>(
            listener: (context, state) {
              if (state is AviaBookingInfoFailure) {
                _showError(context, state.message);
              } else if (state is AviaCancelUnpaidSuccess) {
                _showSuccess(context, 'avia.status.cancelled_message'.tr());
                _loadBookingInfo(); // Refresh status
              } else if (state is AviaCancelUnpaidFailure) {
                _showError(context, state.message);
              } else if (state is AviaManualRefundSuccess) {
                _showSuccess(context, 'avia.status.refunded_message'.tr());
                _loadBookingInfo();
              } else if (state is AviaManualRefundFailure) {
                _showError(context, state.message);
              } else if (state is AviaRefundAmountsSuccess) {
                // Show refund confirmation dialog
                _showRefundConfirmation(context, state.amounts);
              } else if (state is AviaRefundAmountsFailure) {
                _showError(context, '${'avia.status.error_message'.tr()}: ${state.message}');
              } else if (state is AviaVoidSuccess) {
                _showSuccess(context, 'avia.status.voided_message'.tr());
                _loadBookingInfo();
              } else if (state is AviaVoidFailure) {
                _showError(context, state.message);
              } else if (state is AviaAutoCancelSuccess) {
                _showSuccess(context, 'avia.status.auto_cancelled_message'.tr());
                _loadBookingInfo();
              } else if (state is AviaAutoCancelFailure) {
                _showError(context, state.message);
              } else if (state is AviaPdfReceiptSuccess) {
                final pdfUrl = state.pdfUrl;
                if (pdfUrl.isNotEmpty) {
                  _launchPdfUrl(pdfUrl);
                } else {
                  SnackbarHelper.showError(context, 'PDF topilmadi');
                }
              } else if (state is AviaPdfReceiptFailure) {
                _showError(context, state.message);
              } else if (state is AviaCheckPriceSuccess && _isLoadingPayment) {
                _priceCheck = state.priceCheck;
                // Ikkalasi ham kelganda invoice yaratish
                if (_priceCheck != null && _permission != null) {
                  // paymentAllowed ni tekshirish, agar null bo'lsa default true
                  final canPay = _permission!.paymentAllowed ?? true; 
                  if (canPay) {
                    _createInvoiceAndLaunch(widget.bookingId);
                  } else {
                    setState(() {
                      _isLoadingPayment = false;
                    });
                    SnackbarHelper.showError(context, 'To\'lov qilish mumkin emas');
                  }
                }
              } else if (state is AviaPaymentPermissionSuccess && _isLoadingPayment) {
                _permission = state.permission;
                // Ikkalasi ham kelganda invoice yaratish
                if (_priceCheck != null && _permission != null) {
                  // paymentAllowed ni tekshirish, agar null bo'lsa default true
                  final canPay = _permission!.paymentAllowed ?? true; 
                  if (canPay) {
                    _createInvoiceAndLaunch(widget.bookingId);
                  } else {
                    setState(() {
                      _isLoadingPayment = false;
                    });
                    SnackbarHelper.showError(context, 'To\'lov qilish mumkin emas');
                  }
                }
              }
            },
          ),
          BlocListener<PaymentBloc, PaymentState>(
            bloc: paymentBloc,
            listener: (context, state) {
              if (state is InvoiceCreatedSuccess) {
                if (state.invoice.checkoutUrl.isNotEmpty) {
                  safeSetState(() {
                    _currentInvoiceUuid = state.invoice.uuid;
                    _urlLaunched = false;
                  });
                  _launchPaymentUrl(state.invoice.checkoutUrl);
                } else {
                  safeSetState(() {
                    _isLoadingPayment = false;
                  });
                  if (mounted) {
                    SnackbarHelper.showError(context, 'To\'lov linki topilmadi');
                  }
                }
              } else if (state is PaymentStatusSuccess) {
                // To'lov holati tekshirildi
                if (state.status == 'paid' || state.status == 'success') {
                  // To'lov muvaffaqiyatli bo'lganda polling ni to'xtatish va payBooking API'sini chaqirish
                  _stopStatusPolling();
                  if (mounted && !context.read<AviaBloc>().isClosed) {
                    context.read<AviaBloc>().add(PaymentRequested(widget.bookingId));
                    safeSetState(() {
                      _currentInvoiceUuid = null;
                      _urlLaunched = false;
                    });
                    // Booking info ni yangilash
                    context.read<AviaBloc>().add(BookingInfoRequested(widget.bookingId));
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
                      _isLoadingPayment = false;
                    });
                  }
                } else {
                  // Pending holatda polling davom etadi
                }
              } else if (state is PaymentFailure) {
                _stopStatusPolling();
                safeSetState(() {
                  _isLoadingPayment = false;
                });
                if (mounted) {
                  SnackbarHelper.showError(context, state.message);
                }
              }
            },
          ),
        ],
        child: BlocConsumer<AviaBloc, AviaState>(
          listener: (context, state) {
            // Empty listener - all handled in MultiBlocListener above
          },
        builder: (context, state) {
          // Keep showing content while processing actions if we have data
          // But if initial load, show loading
          if (state is AviaLoading && !_hasLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AviaBookingInfoSuccess || (state is AviaLoading && _hasLoaded)) {
            // If we are loading (e.g. refunding) but have previous success state, 
            // we need access to the booking data. 
            // However, typical BlocBuilder replaces state. 
            // Ideally we need to store booking locally or use "Success" state as valid data holder.
            // For now, assuming AviaBookingInfoSuccess stays or we handle it via a local variable if we were sophisticated.
            // But simplifying: only show if state IS Success or we cache it.
            // To be safe, if state transfers to something else (like RefundAmountsSuccess), we lose the booking info in builder!
            // So we MUST check if state HAS booking. If not, we might flicker.
            // Let's rely on BlocListener to handle transient states and only rebuild UI on InfoSuccess.
            // But wait, if I trigger refund, state becomes RefundAmountsSuccess, and this builder sees it.
            // It falls through to bottom (CircularProgressIndicator if not handled).
            
            // Fix: Store booking in local state
            // Or better: Re-fetch booking info after actions.
          }
          
          if (state is AviaBookingInfoSuccess) {
            final booking = state.booking;
            safeSetState(() {
              _booking = booking;
            });
            final bookingStatus = booking.status ?? widget.status;
            final isSuccess = ['success', 'paid', 'confirmed', 'ticketed'].contains(bookingStatus.toLowerCase());
            final isBooked = ['booked', 'pending', 'waiting'].contains(bookingStatus.toLowerCase());
            // final isCancelled = ['cancelled', 'canceled', 'voided', 'refunded'].contains(bookingStatus.toLowerCase());
            
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Booking Details Card (rasmdagidek)
                  _buildBookingDetailsCard(context, booking, bookingStatus, isSuccess, isBooked),
                  SizedBox(height: 16.h),
                  
                  // Price Card
                  if (booking.price != null)
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'avia.payment.total_amount'.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              () {
                                if (booking.price == null) return '0 ${booking.currency ?? 'so\'m'}';
                                // Parse price and add 10% commission
                                final rawPrice = booking.price!.replaceAll(RegExp(r'[^\d.]'), '');
                                final priceValue = double.tryParse(rawPrice) ?? 0.0;
                                final priceWithCommission = (priceValue * 1.10).toStringAsFixed(0);
                                return '$priceWithCommission ${booking.currency ?? 'so\'m'}';
                              }(),
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  SizedBox(height: 24.h),
                  
                  // Pending Actions
                  if (isBooked) ...[
                    PrimaryButton(
                      text: 'avia.payment.pay'.tr(),
                      isLoading: _isLoadingPayment,
                      onPressed: _isLoadingPayment ? null : _handlePayNow,
                    ),
                    SizedBox(height: 12.h),
                    OutlinedButton(
                      onPressed: () {
                         context.read<AviaBloc>().add(CancelUnpaidRequested(widget.bookingId));
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: BorderSide(color: theme.colorScheme.error),
                      ),
                      child: Text(
                        'avia.status.cancel_booking'.tr(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],

                  // Paid Actions
                  if (isSuccess) ...[
                    OutlinedButton(
                      onPressed: _handlePdfDownload,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: BorderSide(color: AppColors.getBorderColor(false)),
                      ),
                      child: Text(
                        'PDF',
                        style: TextStyle(
                          fontSize: 16.sp, 
                          color: theme.textTheme.bodyLarge?.color
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    OutlinedButton(
                      onPressed: () {
                         context.read<AviaBloc>().add(RefundAmountsRequested(widget.bookingId));
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: BorderSide(color: AppColors.getBorderColor(false)),
                      ),
                      child: Text(
                        'avia.status.refund_ticket'.tr(),
                        style: TextStyle(
                          fontSize: 16.sp, 
                          color: theme.textTheme.bodyLarge?.color
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('avia.status.void_ticket'.tr()),
                            content: Text('avia.status.void_confirm'.tr()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('avia.status.cancel'.tr()),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.read<AviaBloc>().add(VoidTicketRequested(widget.bookingId));
                                },
                                child: Text(
                                  'avia.status.confirm'.tr(),
                                  style: TextStyle(color: theme.colorScheme.error),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: BorderSide(color: Colors.orange),
                      ),
                      child: Text(
                        'avia.status.void_ticket'.tr(),
                        style: TextStyle(
                          fontSize: 16.sp, 
                          color: Colors.orange
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('avia.status.auto_cancel'.tr()),
                            content: Text('avia.status.auto_cancel_confirm'.tr()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('avia.status.cancel'.tr()),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.read<AviaBloc>().add(AutoCancelRequested(widget.bookingId));
                                },
                                child: Text(
                                  'avia.status.confirm'.tr(),
                                  style: TextStyle(color: theme.colorScheme.error),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: BorderSide(color: theme.colorScheme.error),
                      ),
                      child: Text(
                        'avia.status.auto_cancel'.tr(),
                        style: TextStyle(
                          fontSize: 16.sp, 
                          color: theme.colorScheme.error
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 24.h),

                  // Info Sections (Payer & Passengers)
                  // ... (Keeping logic simple, just showing them if present)
                   if (booking.payer != null) ...[
                    Text(
                      'avia.status.payer_info'.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Ism', booking.payer!.name ?? 'N/A', context),
                            SizedBox(height: 8.h),
                            _buildInfoRow('Email', booking.payer!.email ?? 'N/A', context),
                            SizedBox(height: 8.h),
                            _buildInfoRow('Telefon', booking.payer!.tel ?? 'N/A', context),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],

                ],
              ),
            );
          }

          if (state is AviaBookingInfoFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: theme.colorScheme.error,
                  ),
                  SizedBox(height: 16.h),
                  Text('avia.status.error_message'.tr(), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  Text(state.message, textAlign: TextAlign.center),
                  ElevatedButton(onPressed: _loadBookingInfo, child: Text('avia.status.retry'.tr())),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    SnackbarHelper.showError(context, message);
  }
  
  void _showSuccess(BuildContext context, String message) {
    SnackbarHelper.showSuccess(context, message);
  }

  void _showRefundConfirmation(BuildContext context, RefundAmountsModel amounts) {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Text('avia.status.refund_dialog_title'.tr()),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text('${'avia.status.refund_amount'.tr()}: ${amounts.refundAmount} ${amounts.currency}'),
             Text('${'avia.status.penalty_amount'.tr()}: ${amounts.penaltyAmount} ${amounts.currency}'),
             const SizedBox(height: 16),
             Text('avia.status.refund_confirm'.tr()),
           ],
         ),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(context),
             child: Text('avia.status.no'.tr()),
           ),
           TextButton(
             onPressed: () {
               Navigator.pop(context);
               context.read<AviaBloc>().add(ManualRefundRequested(widget.bookingId));
             },
             child: Text(
               'avia.status.yes_refund'.tr(),
               style: TextStyle(color: Theme.of(context).colorScheme.error),
             ),
           ),
         ],
       ),
     );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildBookingDetailsCard(
    BuildContext context,
    dynamic booking,
    String bookingStatus,
    bool isSuccess,
    bool isBooked,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Format booking date
    String formattedDate = 'N/A';
    if (booking.createdAt != null) {
      try {
        final parsedDate = DateTime.tryParse(booking.createdAt);
        if (parsedDate != null) {
          formattedDate = DateFormat('dd/MM/yyyy, HH:mm:ss').format(parsedDate);
        } else {
          formattedDate = booking.createdAt;
        }
      } catch (e) {
        formattedDate = booking.createdAt ?? 'N/A';
      }
    }

    // Determine payment status badge
    String paymentStatusText;
    Color paymentStatusColor;
    if (isSuccess) {
      paymentStatusText = 'avia.booking_details.paid'.tr();
      paymentStatusColor = AppColors.accentGreen;
    } else if (isBooked) {
      paymentStatusText = 'avia.booking_details.payment_pending'.tr();
      paymentStatusColor = const Color(0xFFD4A574); // Dark yellow/brown from image
    } else {
      paymentStatusText = 'avia.statuses.cancelled'.tr();
      paymentStatusColor = Colors.red;
    }

    // Refund status (assuming non-refundable for now, can be enhanced later)
    // This can be determined from booking rules or API in the future
    final refundText = 'avia.status.not_refundable'.tr();
    final refundColor = AppColors.accentGreen; // Light green from image

    return StatefulBuilder(
      builder: (context, setState) {
        // Use a local state variable that can be toggled
        var isExpanded = true;
        
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Header with title and expand/collapse icon
              InkWell(
                onTap: () => setState(() => isExpanded = !isExpanded),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'avia.booking_details.booking_details'.tr(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: theme.textTheme.titleLarge?.color,
                        size: 24.sp,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Content (shown when expanded)
              if (isExpanded)
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  child: Column(
                    children: [
                      // Брон қилиш ID
                      _buildDetailRow(
                        context,
                        'avia.booking_details.booking_id'.tr(),
                        booking.id ?? 'N/A',
                        isValueBold: false,
                      ),
                      SizedBox(height: 12.h),
                      
                      // Тўлов ҳолати
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${'avia.booking_details.payment_status'.tr()}:',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.white70,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: paymentStatusColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              paymentStatusText,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: paymentStatusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      
                      // Қайтариш
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${'avia.status.refund'.tr()}:',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.white70,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: refundColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              refundText,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: refundColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      
                      // Брон қилиш санаси
                      _buildDetailRow(
                        context,
                        'avia.booking_details.booking_date'.tr(),
                        formattedDate,
                        isValueBold: false,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isValueBold = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14.sp,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.white70,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isValueBold ? FontWeight.w600 : FontWeight.normal,
              color: theme.textTheme.titleLarge?.color ?? Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handlePayNow() async {
    if (_isLoadingPayment) return;
    
    safeSetState(() {
      _isLoadingPayment = true;
      _priceCheck = null;
      _permission = null;
    });
    
    // Price check va payment permission so'rab olish
    final aviaBloc = context.read<AviaBloc>();
    aviaBloc
      ..add(CheckPriceRequested(widget.bookingId))
      ..add(PaymentPermissionRequested(widget.bookingId));
  }

  Future<void> _createInvoiceAndLaunch(String bookingId) async {
    // Narxni booking model'dan olish
    String? priceString = _booking?.price;
    if (priceString == null || priceString.isEmpty || priceString == '0') {
        // Retry fetch or error?
    }
    
    // Agar hali ham price yo'q bo'lsa, xatolik
    if (priceString == null || priceString.isEmpty || priceString == '0') {
      if (mounted) {
        safeSetState(() {
          _isLoadingPayment = false;
        });
        SnackbarHelper.showError(
          context,
          'Narx mavjud emas. Iltimos, keyinroq qayta urinib ko\'ring.',
        );
      }
      return;
    }
    
    // Raqam va nuqtani saqlab qolish (decimal uchun)
    final cleanPrice = priceString.replaceAll(RegExp(r'[^0-9.]'), '');
    // Double ga o'tkazish
    final priceValue = double.tryParse(cleanPrice) ?? 0.0;

    // Debug log
    print('💰 STATUS_PAGE: Original price: $priceString');
    print('💰 STATUS_PAGE: Clean price: $cleanPrice');
    print('💰 STATUS_PAGE: Price value: $priceValue');

    // API eng kichik birlikda amount kutadi (masalan, 500000)
    // UZS uchun: 5000 UZS = 500000 (100 ga ko'paytiriladi)
    // Boshqa valyutalar uchun ham 100 ga ko'paytiriladi (cents uchun)
    // 10% komissiya qo'shish: price * 1.10 * 100
    final amountWithoutCommission = (priceValue * 100).toInt();
    final amount = (priceValue * 1.10 * 100).toInt();
    
    // Debug log
    print('💰 STATUS_PAGE: Amount without commission: $amountWithoutCommission');
    print('💰 STATUS_PAGE: Amount with 10% commission: $amount');

    // Amount musbat bo'lishi kerak (backend talabi)
    if (amount <= 0) {
      if (mounted) {
        safeSetState(() {
          _isLoadingPayment = false;
        });
        final errorMessage = 'avia.payment.price_not_available'.tr();
        SnackbarHelper.showError(
          context,
          errorMessage.contains('avia.payment.price_not_available')
              ? 'Narx mavjud emas. Iltimos, keyinroq qayta urinib ko\'ring.'
              : errorMessage,
        );
      }
      return;
    }

    // Invoice ID formatini Postman collection bo'yicha yaratish
    final random = DateTime.now().millisecondsSinceEpoch % 10000000;
    final invoiceId = 'avia${random.toString().padLeft(7, '0')}';

    if (!mounted || paymentBloc.isClosed) {
      return;
    }

    final request = InvoiceRequestModel(
      amount: amount,
      invoiceId: invoiceId,
      lang: EasyLocalization.of(context)!.locale.languageCode,
      returnUrl: 'https://kliro.uz',
      callbackUrl: 'https://api.kliro.uz/payment/callback/success',
    );

    paymentBloc.add(CreateInvoiceRequested(request));
  }

  Future<void> _launchPaymentUrl(String checkoutUrl) async {
    try {
      if (checkoutUrl.isEmpty) {
        if (mounted) {
          safeSetState(() {
            _isLoadingPayment = false;
          });
          SnackbarHelper.showError(context, 'To\'lov linki topilmadi');
        }
        return;
      }

      final uri = Uri.parse(checkoutUrl);

      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        // Ba'zida launchUrl false qaytaradi, lekin brauzer ochiladi
        if (mounted) {
          safeSetState(() {
            _isLoadingPayment = false;
            _urlLaunched = true;
          });
          // Status polling ni boshlash
          _startStatusPolling();
        }
      } catch (launchError) {
        if (mounted) {
          safeSetState(() {
            _isLoadingPayment = false;
          });
          SnackbarHelper.showError(context, 'To\'lov sahifasini ochib bo\'lmadi');
        }
      }
    } catch (e) {
      if (mounted) {
        safeSetState(() {
          _isLoadingPayment = false;
        });
        SnackbarHelper.showError(context, 'To\'lov sahifasini ochishda xatolik');
      }
    }
  }
}

