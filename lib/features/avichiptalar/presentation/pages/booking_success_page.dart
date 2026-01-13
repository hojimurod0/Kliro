import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../data/models/offer_model.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/price_check_model.dart';
import '../../data/models/payment_permission_model.dart';
import '../../data/models/invoice_request_model.dart';
import '../../data/models/fare_rules_model.dart';
import '../bloc/avia_bloc.dart';
import '../bloc/payment_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/auth/auth_service.dart';

@RoutePage(name: 'BookingSuccessRoute')
class BookingSuccessPage extends StatefulWidget implements AutoRouteWrapper {
  final OfferModel outboundOffer;
  final OfferModel? returnOffer;
  final String bookingId;

  const BookingSuccessPage({
    super.key,
    required this.outboundOffer,
    this.returnOffer,
    required this.bookingId,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
    // Reuse existing AviaBloc if available, otherwise create via ServiceLocator
    try {
      final existingBloc = context.read<AviaBloc>();
      return BlocProvider.value(
        value: existingBloc,
        child: this,
      );
    } catch (_) {
      return BlocProvider(
        create: (_) => ServiceLocator.resolve<AviaBloc>(),
        child: this,
      );
    }
  }

  @override
  State<BookingSuccessPage> createState() => _BookingSuccessPageState();
}

class _BookingSuccessPageState extends State<BookingSuccessPage>
    with WidgetsBindingObserver {
  BookingModel? _booking;
  int?
      _expandedCardIndex; // Track which card is expanded (0: payer, 1: flight, 2: ticket, 3: passenger, 4: booking)
  FareRulesModel? _bookingRules;
  bool _isLoadingRules = false;

  // Timer for payment countdown
  Timer? _countdownTimer;
  int _remainingSeconds = 465; // 7:45 in seconds (7 minutes 45 seconds)
  bool _isTimerActive = true;

  // Payment related
  PaymentBloc? _paymentBloc;
  PriceCheckModel? _priceCheck;
  PaymentPermissionModel? _permission;
  bool _isLoadingPayment = false;

  // Payment status polling
  Timer? _statusCheckTimer;
  String? _currentInvoiceUuid;
  bool _urlLaunched = false;

  PaymentBloc get paymentBloc {
    _paymentBloc ??= ServiceLocator.resolve<PaymentBloc>();
    return _paymentBloc!;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _paymentBloc = ServiceLocator.resolve<PaymentBloc>();
    // Fetch booking info so we can show detailed card after formalization
    final id = widget.bookingId.trim();
    if (id.isNotEmpty) {
      context.read<AviaBloc>().add(BookingInfoRequested(id));
    }
    // Initially expand first card (payer info)
    _expandedCardIndex = 0;

    // Start countdown timer only if not paid
    _startCountdownTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _urlLaunched &&
        _currentInvoiceUuid != null) {
      _checkPaymentStatus();
      // Polling ni qayta boshlash (agar to'xtatilgan bo'lsa)
      if (_statusCheckTimer == null || !_statusCheckTimer!.isActive) {
        _startStatusPolling();
      }
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
    _statusCheckTimer?.cancel();
    if (_currentInvoiceUuid != null && mounted) {
      _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (!mounted || _currentInvoiceUuid == null) {
          timer.cancel();
          return;
        }
        _checkPaymentStatus();
      });
    }
  }

  void _stopStatusPolling() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
  }

  void _startCountdownTimer() {
    // Stop timer if already paid
    if (_isPaid) {
      _isTimerActive = false;
      _countdownTimer?.cancel();
      return;
    }

    _isTimerActive = true;
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Check if paid during countdown
      if (_isPaid) {
        _isTimerActive = false;
        timer.cancel();
        setState(() {});
        return;
      }

      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          // Time expired - navigate to search page
          _isTimerActive = false;
          timer.cancel();
          _navigateToSearchPage();
        }
      });
    });
  }

  void _navigateToSearchPage() {
    if (!mounted) return;

    // Navigate to flight search page and clear stack
    context.router.pushAndPopUntil(
      const FlightSearchRoute(),
      predicate: (route) => false, // Clear all previous routes
    );
  }

  String _formatCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  bool get _isPaid {
    final status = (_booking?.status ?? '').toLowerCase();
    return status == 'paid' || status == 'success' || status == 'confirmed';
  }

  Future<void> _handlePayNow() async {
    if (_isPaid || _isLoadingPayment) return;

    setState(() {
      _isLoadingPayment = true;
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
      // Retry or error
    }

    // Agar hali ham price yo'q bo'lsa, xatolik
    if (priceString == null || priceString.isEmpty || priceString == '0') {
      if (mounted) {
        setState(() {
          _isLoadingPayment = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Narx mavjud emas. Iltimos, keyinroq qayta urinib ko\'ring.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    // Raqam va nuqtani saqlab qolish (decimal uchun)
    final cleanPrice = priceString.replaceAll(RegExp(r'[^0-9.]'), '');
    // Double ga o'tkazish
    final priceValue = double.tryParse(cleanPrice) ?? 0.0;

    // Debug log
    debugPrint('💰 BOOKING_SUCCESS_PAGE: Original price: $priceString');
    debugPrint('💰 BOOKING_SUCCESS_PAGE: Clean price: $cleanPrice');
    debugPrint('💰 BOOKING_SUCCESS_PAGE: Price value: $priceValue');

    // API eng kichik birlikda amount kutadi (masalan, 500000)
    // UZS uchun: 5000 UZS = 500000 (100 ga ko'paytiriladi)
    // Boshqa valyutalar uchun ham 100 ga ko'paytiriladi (cents uchun)
    // 10% komissiya qo'shish: price * 1.10 * 100
    final amountWithoutCommission = (priceValue * 100).toInt();
    final amount = (priceValue * 1.10 * 100).toInt();
    
    // Debug log
      debugPrint('💰 BOOKING_SUCCESS_PAGE: Amount without commission: $amountWithoutCommission');
      debugPrint('💰 BOOKING_SUCCESS_PAGE: Amount with 10% commission: $amount');

    // Amount musbat bo'lishi kerak (backend talabi)
    if (amount <= 0) {
      if (mounted) {
        setState(() {
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
          if (urlToOpen.startsWith('http://') ||
              urlToOpen.startsWith('https://')) {
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
        title: Text('avia.booking_success.pdf.saved'.tr()),
        content:
            Text('avia.booking_success.pdf.saved_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('avia.booking_success.pdf.close'.tr()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Share.shareXFiles([XFile(filePath)]);
              } catch (e) {
                if (mounted) {
                  SnackbarHelper.showError(context, 'avia.booking_success.pdf.share_error'.tr());
                }
              }
            },
            child: Text('avia.booking_success.pdf.share'.tr()),
          ),
        ],
      ),
    );
  }

  void _handlePdfDownload() {
    if (_isPaid && widget.bookingId.isNotEmpty) {
      context.read<AviaBloc>().add(PdfReceiptRequested(widget.bookingId));
    } else {
      SnackbarHelper.showError(
        context,
        'PDF faqat to\'langan bronlar uchun mavjud',
      );
    }
  }

  Future<void> _launchPaymentUrl(String checkoutUrl) async {
    try {
      if (checkoutUrl.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoadingPayment = false;
          });
          SnackbarHelper.showError(context, 'To\'lov linki topilmadi');
        }
        return;
      }

      final uri = Uri.parse(checkoutUrl);

      try {
        final launched =
            await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (launched) {
          if (mounted) {
            setState(() {
              _isLoadingPayment = false;
              _urlLaunched = true;
            });
            // Status polling ni boshlash
            _startStatusPolling();
          }
        } else {
          // Ba'zida launchUrl false qaytaradi, lekin brauzer ochiladi
          // Shuning uchun state'ni yangilaymiz va polling ni boshlaymiz
          if (mounted) {
            setState(() {
              _isLoadingPayment = false;
              _urlLaunched = true;
            });
            _startStatusPolling();
          }
        }
      } catch (launchError) {
        if (mounted) {
          setState(() {
            _isLoadingPayment = false;
          });
          SnackbarHelper.showError(
              context, 'To\'lov sahifasini ochib bo\'lmadi');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPayment = false;
        });
        SnackbarHelper.showError(
            context, 'To\'lov sahifasini ochishda xatolik');
      }
    }
  }

  String _translateStatus(String? status) {
    if (status == null) return '';
    final statusLower = status.toLowerCase();
    final key = 'avia.statuses.$statusLower';
    final translated = key.tr();
    return translated == key ? status : translated;
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty)
      return 'avia.booking_details.na'.tr();
    final value = raw.trim();
    // Try ISO first
    final isoParsed = DateTime.tryParse(value);
    if (isoParsed != null) {
      final d = isoParsed;
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    // Try "yyyy-MM-dd HH:mm[:ss]" by converting space to 'T'
    final tParsed = DateTime.tryParse(value.replaceFirst(' ', 'T'));
    if (tParsed != null) {
      final d = tParsed;
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    return value;
  }

  String _formatMoney(String? raw) {
    if (raw == null) return 'avia.booking_details.na'.tr();
    final cleaned =
        raw.replaceAll(RegExp(r'[^0-9.,]'), '').replaceAll(',', '.');
    if (cleaned.isEmpty) return 'avia.booking_details.na'.tr();
    // Parse price and add 10% commission
    final priceValue = double.tryParse(cleaned) ?? 0.0;
    final priceWithCommission = (priceValue * 1.10).toStringAsFixed(0);
    // Format with spaces
    final parts = priceWithCommission.split('.');
    final intPart = parts[0].replaceAll(RegExp(r'^0+'), '');
    final digits = intPart.isEmpty ? '0' : intPart;
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final idxFromEnd = digits.length - i;
      buf.write(digits[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) {
        buf.write(' ');
      }
    }
    return buf.toString().trim();
  }

  String _formatPhoneDisplay(String? raw) {
    if (raw == null) return 'avia.booking_details.na'.tr();
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 12 && digits.startsWith('998')) {
      final cc = digits.substring(0, 3);
      final op = digits.substring(3, 5);
      final p1 = digits.substring(5, 8);
      final p2 = digits.substring(8, 10);
      final p3 = digits.substring(10, 12);
      return '+$cc $op $p1-$p2-$p3';
    }
    if (digits.isNotEmpty && raw.contains('+')) return raw;
    return raw.isEmpty ? 'avia.booking_details.na'.tr() : raw;
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.trim().isEmpty)
      return 'avia.booking_details.na'.tr();
    try {
      DateTime? parsed;
      if (dateTimeStr.contains('T')) {
        parsed = DateTime.tryParse(dateTimeStr);
      } else {
        parsed = DateTime.tryParse(dateTimeStr.replaceFirst(' ', 'T'));
      }
      if (parsed != null) {
        return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year} ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
      }
      return dateTimeStr;
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _getAirportDisplay(String? code, String? name) {
    if (code == null || code.isEmpty) return 'avia.booking_details.na'.tr();
    if (name != null && name.isNotEmpty && name != code) {
      return '$name ($code)';
    }
    return code;
  }

  String _routeFromBookingOrOffers() {
    final offers = _booking?.offers;
    if (offers != null && offers.isNotEmpty) {
      final firstOffer = offers.first;
      final segs = firstOffer.segments;
      if (segs != null && segs.isNotEmpty) {
        final a = segs.first.departureAirport ?? 'avia.booking_details.na'.tr();
        final b = segs.last.arrivalAirport ?? 'avia.booking_details.na'.tr();
        return '$a → $b';
      }
    }

    final outboundSegments = widget.outboundOffer.segments;
    if (outboundSegments != null && outboundSegments.isNotEmpty) {
      final firstSegment = outboundSegments.first;
      final lastSegment = outboundSegments.last;
      final departure =
          firstSegment.departureAirport ?? 'avia.booking_details.na'.tr();
      final arrival =
          lastSegment.arrivalAirport ?? 'avia.booking_details.na'.tr();
      return '$departure → $arrival';
    }
    return 'avia.booking_details.na'.tr();
  }

  int? _extractKgFromBaggage(String? baggageStr) {
    if (baggageStr == null || baggageStr.trim().isEmpty) return null;
    final text = baggageStr.trim();

    // Try patterns like "20 kg" / "20кг"
    final kgMatch =
        RegExp(r'(\d{1,3}(?:[.,]\d+)?)\s*(kg|кг)\b', caseSensitive: false)
            .firstMatch(text);
    if (kgMatch != null) {
      final rawNum = kgMatch.group(1) ?? '';
      final normalized = rawNum.replaceAll(',', '.');
      final n = double.tryParse(normalized);
      if (n != null && n > 0) return n.round();
    }

    // Extract any number from the string
    final matches = RegExp(r'\d+').allMatches(text).toList();
    if (matches.isNotEmpty) {
      final nums = matches
          .map((m) => int.tryParse(m.group(0) ?? ''))
          .whereType<int>()
          .where((n) => n > 0)
          .toList();
      if (nums.isNotEmpty) {
        nums.sort();
        return nums.last;
      }
    }
    return null;
  }

  String _baggageLabel() {
    final offers = _booking?.offers;
    if (offers == null || offers.isEmpty) return 'avia.booking_details.na'.tr();

    // Try to extract kg from all segments
    int? totalKg;
    String? baggageText;

    for (final offer in offers) {
      final segs = offer.segments;
      if (segs == null || segs.isEmpty) continue;
      for (final seg in segs) {
        // Try baggage field first
        if (seg.baggage != null && seg.baggage!.trim().isNotEmpty) {
          baggageText = seg.baggage!.trim();
          final kg = _extractKgFromBaggage(seg.baggage);
          if (kg != null && kg > 0) {
            if (totalKg == null || kg < totalKg) {
              totalKg = kg; // Use minimum (most restrictive)
            }
          }
        }
        // Also check handBaggage as fallback
        if (totalKg == null &&
            seg.handBaggage != null &&
            seg.handBaggage!.trim().isNotEmpty) {
          final kg = _extractKgFromBaggage(seg.handBaggage);
          if (kg != null && kg > 0) {
            totalKg = kg;
          }
        }
      }
    }

    // If we found kg, show it
    if (totalKg != null && totalKg > 0) {
      return '${totalKg} ${'avia.booking_details.kg'.tr()}';
    }

    // If we have baggage text but couldn't extract kg, show the text
    if (baggageText != null && baggageText.isNotEmpty) {
      return baggageText;
    }

    // Fallback to no baggage
    return 'avia.booking_details.no_baggage'.tr();
  }

  String _passengersSummary() {
    final passengers = _booking?.passengers ?? const [];
    if (passengers.isEmpty) return 'avia.booking_details.na'.tr();
    int adt = 0, chd = 0, inf = 0;
    for (final p in passengers) {
      final a = p.age.toLowerCase();
      if (a == 'adt') adt++;
      if (a == 'chd') chd++;
      if (a == 'inf') inf++;
    }
    if (adt == 1 && chd == 0 && inf == 0) {
      return 'avia.confirmation.adult'.tr();
    }
    final parts = <String>[];
    if (adt > 0) parts.add('$adt ${'avia.confirmation.adult'.tr()}');
    if (chd > 0) parts.add('$chd ${'avia.confirmation.child'.tr()}');
    if (inf > 0) parts.add('$inf ${'avia.confirmation.baby'.tr()}');
    return parts.join(', ');
  }

  Widget _infoRow({
    required String label,
    required String value,
    Widget? trailing,
    bool singleLine = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final labelColor = AppColors.getSubtitleColor(isDark);
    final valueColor = AppColors.getTextColor(isDark);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: labelColor,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: valueColor,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: singleLine ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null) ...[
                  SizedBox(width: 10.w),
                  trailing,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBg(isDark),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.getBorderColor(isDark), width: 1),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MultiBlocListener(
      listeners: [
        BlocListener<AviaBloc, AviaState>(
          listener: (context, state) {
            if (state is AviaBookingInfoSuccess) {
              setState(() {
                _booking = state.booking;
                // Restart timer if booking status changed to paid
                if (_isPaid && _isTimerActive) {
                  _startCountdownTimer();
                }
              });
            } else if (state is AviaPaymentSuccess) {
              // To'lov muvaffaqiyatli bo'lganda booking info ni yangilash
              // Bu PDF card'ini ko'rsatish uchun kerak
              context
                  .read<AviaBloc>()
                  .add(BookingInfoRequested(widget.bookingId));
            } else if (state is AviaPdfReceiptSuccess) {
              // PDF URL olinganda, uni ochish
              final pdfUrl = state.pdfUrl;
              if (pdfUrl.isNotEmpty) {
                _launchPdfUrl(pdfUrl);
              } else {
                SnackbarHelper.showError(context, 'PDF topilmadi');
              }
            } else if (state is AviaPdfReceiptFailure) {
              SnackbarHelper.showError(context, state.message);
            } else if (state is AviaBookingRulesSuccess) {
              setState(() {
                _bookingRules = state.rules;
                _isLoadingRules = false;
              });
            } else if (state is AviaBookingRulesFailure) {
              setState(() {
                _isLoadingRules = false;
              });
              SnackbarHelper.showError(context, state.message);
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
                  SnackbarHelper.showError(
                      context, 'To\'lov qilish mumkin emas');
                }
              }
            } else if (state is AviaPaymentPermissionSuccess &&
                _isLoadingPayment) {
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
                  SnackbarHelper.showError(
                      context, 'To\'lov qilish mumkin emas');
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
                setState(() {
                  _currentInvoiceUuid = state.invoice.uuid;
                  _urlLaunched = false;
                });
                _launchPaymentUrl(state.invoice.checkoutUrl);
              } else {
                setState(() {
                  _isLoadingPayment = false;
                });
                SnackbarHelper.showError(context, 'To\'lov linki topilmadi');
              }
            } else if (state is PaymentStatusSuccess) {
              // To'lov holati tekshirildi
              if (state.status == 'paid' || state.status == 'success') {
                // To'lov muvaffaqiyatli bo'lganda polling ni to'xtatish va payBooking API'sini chaqirish
                _stopStatusPolling();
                if (mounted && !context.read<AviaBloc>().isClosed) {
                  context
                      .read<AviaBloc>()
                      .add(PaymentRequested(widget.bookingId));
                  setState(() {
                    _currentInvoiceUuid = null;
                    _urlLaunched = false;
                  });
                  // Booking info ni yangilash
                  context
                      .read<AviaBloc>()
                      .add(BookingInfoRequested(widget.bookingId));
                }
              } else if (state.status == 'failed' ||
                  state.status == 'canceled') {
                _stopStatusPolling();
                if (mounted) {
                  SnackbarHelper.showError(
                    context,
                    'To\'lov bekor qilindi yoki xatolik: ${state.status}',
                  );
                  setState(() {
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
              setState(() {
                _isLoadingPayment = false;
              });
              SnackbarHelper.showError(context, state.message);
            }
          },
        ),
      ],
      child: BlocBuilder<AviaBloc, AviaState>(
        builder: (context, state) {
          final isLoading = (state is AviaBookingInfoLoading || 
                             state is AviaCancelUnpaidLoading || 
                             state is AviaVoidLoading) && _booking == null;
          final isFailure = state is AviaBookingInfoFailure && _booking == null;

          return Scaffold(
            backgroundColor: AppColors.getScaffoldBg(isDark),
            appBar: AppBar(
              backgroundColor: AppColors.getCardBg(isDark),
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.getTextColor(isDark),
                  size: 20.sp,
                ),
                onPressed: () => context.router.maybePop(),
              ),
              title: Text(
                'avia.booking_details.title'.tr(),
                style: TextStyle(
                  color: AppColors.getTextColor(isDark),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: Column(
              children: [
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : isFailure
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(AppSpacing.lg),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 42.sp,
                                      color: AppColors.getSubtitleColor(isDark),
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      state.message,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.getTextColor(isDark),
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 14.h),
                                    ElevatedButton(
                                      onPressed: () {
                                        final id = widget.bookingId.trim();
                                        if (id.isNotEmpty) {
                                          context.read<AviaBloc>().add(
                                                BookingInfoRequested(id),
                                              );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryBlue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12.h,
                                          horizontal: 18.w,
                                        ),
                                      ),
                                      child: Text(
                                        'common.retry'.tr(),
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              padding: EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Payer (User) Information
                                  if (_booking?.payer != null) ...[
                                    _sectionCard(
                                      child: Theme(
                                        data: theme.copyWith(
                                          dividerColor: Colors.transparent,
                                        ),
                                        child: ExpansionTile(
                                          initiallyExpanded:
                                              _expandedCardIndex == 0,
                                          onExpansionChanged: (expanded) {
                                            setState(() {
                                              _expandedCardIndex =
                                                  expanded ? 0 : null;
                                            });
                                          },
                                          title: Text(
                                            'avia.booking_details.payer_info'
                                                .tr(),
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.getTextColor(
                                                  isDark),
                                            ),
                                          ),
                                          childrenPadding: EdgeInsets.fromLTRB(
                                            AppSpacing.md,
                                            0,
                                            AppSpacing.md,
                                            AppSpacing.md,
                                          ),
                                          children: [
                                            _infoRow(
                                              label: 'avia.booking_details.name'
                                                  .tr(),
                                              value: _booking?.payer?.name
                                                          ?.trim()
                                                          .isEmpty ??
                                                      true
                                                  ? 'avia.booking_details.na'
                                                      .tr()
                                                  : _booking!.payer!.name!
                                                      .trim(),
                                            ),
                                            _infoRow(
                                              label:
                                                  'avia.booking_details.email'
                                                      .tr(),
                                              value: _booking?.payer?.email
                                                          ?.trim()
                                                          .isEmpty ??
                                                      true
                                                  ? 'avia.booking_details.na'
                                                      .tr()
                                                  : _booking!.payer!.email!
                                                      .trim(),
                                              singleLine: true,
                                            ),
                                            _infoRow(
                                              label:
                                                  'avia.booking_details.phone'
                                                      .tr(),
                                              value: _formatPhoneDisplay(
                                                  _booking?.payer?.tel),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: AppSpacing.md),
                                  ],

                                  // Flight Information
                                  if (_booking?.offers != null &&
                                      _booking!.offers!.isNotEmpty) ...[
                                    _sectionCard(
                                      child: Theme(
                                        data: theme.copyWith(
                                          dividerColor: Colors.transparent,
                                        ),
                                        child: ExpansionTile(
                                          initiallyExpanded:
                                              _expandedCardIndex == 1,
                                          onExpansionChanged: (expanded) {
                                            setState(() {
                                              _expandedCardIndex =
                                                  expanded ? 1 : null;
                                            });
                                          },
                                          title: Text(
                                            'avia.booking_details.flight_info'
                                                .tr(),
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.getTextColor(
                                                  isDark),
                                            ),
                                          ),
                                          childrenPadding: EdgeInsets.fromLTRB(
                                            AppSpacing.md,
                                            0,
                                            AppSpacing.md,
                                            AppSpacing.md,
                                          ),
                                          children: [
                                            ...(_booking!.offers!
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              final offerIndex = entry.key;
                                              final offer = entry.value;
                                              final segments =
                                                  offer.segments ?? [];
                                              if (segments.isEmpty)
                                                return const SizedBox.shrink();
                                              final isLastOffer = offerIndex ==
                                                  _booking!.offers!.length - 1;

                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (_booking!.offers!.length >
                                                      1) ...[
                                                    Text(
                                                      offerIndex == 0
                                                          ? 'avia.booking_details.outbound_flight'
                                                              .tr()
                                                          : 'avia.booking_details.return_flight'
                                                              .tr(),
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: AppColors
                                                            .getTextColor(
                                                                isDark),
                                                      ),
                                                    ),
                                                    SizedBox(height: 8.h),
                                                  ],
                                                  ...segments
                                                      .asMap()
                                                      .entries
                                                      .map((segEntry) {
                                                    final segIndex =
                                                        segEntry.key;
                                                    final segment =
                                                        segEntry.value;
                                                    final isLastSegment =
                                                        segIndex ==
                                                            segments.length - 1;

                                                    return Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (segments.length >
                                                            1) ...[
                                                          Text(
                                                            '${'avia.booking_details.segment'.tr()} ${segIndex + 1}',
                                                            style: TextStyle(
                                                              fontSize: 12.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColors
                                                                  .getSubtitleColor(
                                                                      isDark),
                                                            ),
                                                          ),
                                                          SizedBox(height: 4.h),
                                                        ],
                                                        _infoRow(
                                                          label:
                                                              'avia.booking_details.flight_number'
                                                                  .tr(),
                                                          value: (segment
                                                                      .flightNumber
                                                                      ?.trim()
                                                                      .isEmpty ??
                                                                  true)
                                                              ? 'avia.booking_details.na'
                                                                  .tr()
                                                              : segment
                                                                  .flightNumber!
                                                                  .trim(),
                                                        ),
                                                        _infoRow(
                                                          label:
                                                              'avia.booking_details.departure'
                                                                  .tr(),
                                                          value:
                                                              _getAirportDisplay(
                                                            segment
                                                                .departureAirport,
                                                            segment
                                                                .departureAirportName,
                                                          ),
                                                        ),
                                                        _infoRow(
                                                          label:
                                                              'avia.booking_details.departure_time'
                                                                  .tr(),
                                                          value: _formatDateTime(
                                                              segment
                                                                  .departureTime),
                                                        ),
                                                        _infoRow(
                                                          label:
                                                              'avia.booking_details.arrival'
                                                                  .tr(),
                                                          value:
                                                              _getAirportDisplay(
                                                            segment
                                                                .arrivalAirport,
                                                            segment
                                                                .arrivalAirportName,
                                                          ),
                                                        ),
                                                        _infoRow(
                                                          label:
                                                              'avia.booking_details.arrival_time'
                                                                  .tr(),
                                                          value: _formatDateTime(
                                                              segment
                                                                  .arrivalTime),
                                                        ),
                                                        if (segment.airline
                                                                ?.trim()
                                                                .isNotEmpty ??
                                                            false)
                                                          _infoRow(
                                                            label:
                                                                'avia.booking_details.airline'
                                                                    .tr(),
                                                            value: segment
                                                                .airline!
                                                                .trim(),
                                                          ),
                                                        if (segment.aircraft
                                                                ?.trim()
                                                                .isNotEmpty ??
                                                            false)
                                                          _infoRow(
                                                            label:
                                                                'avia.booking_details.aircraft'
                                                                    .tr(),
                                                            value: segment
                                                                .aircraft!
                                                                .trim(),
                                                          ),
                                                        if (!isLastSegment) ...[
                                                          Divider(
                                                            height: 16.h,
                                                            color: AppColors
                                                                .getBorderColor(
                                                                    isDark),
                                                          ),
                                                          SizedBox(height: 8.h),
                                                        ],
                                                      ],
                                                    );
                                                  }),
                                                  if (!isLastOffer) ...[
                                                    SizedBox(height: 16.h),
                                                    Divider(
                                                      height: 1,
                                                      color: AppColors
                                                          .getBorderColor(
                                                              isDark),
                                                    ),
                                                    SizedBox(height: 16.h),
                                                  ],
                                                ],
                                              );
                                            }).toList()),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: AppSpacing.md),
                                  ],

                                  // Ticket information
                                  _sectionCard(
                                    child: Theme(
                                      data: theme.copyWith(
                                        dividerColor: Colors.transparent,
                                      ),
                                      child: ExpansionTile(
                                        initiallyExpanded:
                                            _expandedCardIndex == 2,
                                        onExpansionChanged: (expanded) {
                                          setState(() {
                                            _expandedCardIndex =
                                                expanded ? 2 : null;
                                          });
                                        },
                                        title: Text(
                                          'avia.booking_details.ticket_info'
                                              .tr(),
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w800,
                                            color:
                                                AppColors.getTextColor(isDark),
                                          ),
                                        ),
                                        childrenPadding: EdgeInsets.fromLTRB(
                                          AppSpacing.md,
                                          0,
                                          AppSpacing.md,
                                          AppSpacing.md,
                                        ),
                                        children: [
                                          _infoRow(
                                            label:
                                                'avia.booking_details.payment_status'
                                                    .tr(),
                                            value: _translateStatus(
                                                _booking?.status),
                                            trailing: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10.w,
                                                vertical: 6.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _isPaid
                                                    ? AppColors.accentGreen
                                                        .withValues(alpha: 0.12)
                                                    : AppColors.primaryBlue
                                                        .withValues(
                                                            alpha: 0.10),
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                              ),
                                              child: Text(
                                                _isPaid
                                                    ? 'avia.booking_details.paid'
                                                        .tr()
                                                    : 'avia.booking_details.payment_pending'
                                                        .tr(),
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w800,
                                                  color: _isPaid
                                                      ? AppColors.accentGreen
                                                      : AppColors.primaryBlue,
                                                ),
                                              ),
                                            ),
                                          ),
                                          _infoRow(
                                            label:
                                                'avia.booking_details.baggage'
                                                    .tr(),
                                            value: _baggageLabel(),
                                          ),
                                          _infoRow(
                                            label:
                                                'avia.booking_details.passengers'
                                                    .tr(),
                                            value: _passengersSummary(),
                                          ),
                                          _infoRow(
                                            label:
                                                'avia.booking_details.booking_date'
                                                    .tr(),
                                            value: _formatDate(
                                                _booking?.createdAt),
                                          ),
                                          SizedBox(height: 14.h),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${_formatMoney(_booking?.price)} ${(_booking?.currency ?? '').isEmpty ? 'avia.booking_details.currency_sum'.tr() : (_booking?.currency ?? '')}',
                                                  style: TextStyle(
                                                    fontSize: 20.sp,
                                                    fontWeight: FontWeight.w900,
                                                    color:
                                                        AppColors.primaryBlue,
                                                  ),
                                                ),
                                                SizedBox(height: 2.h),
                                                Text(
                                                  'avia.booking_details.total'
                                                      .tr(),
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: AppColors
                                                        .getSubtitleColor(
                                                            isDark),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: AppSpacing.md),

                                  // Passenger details
                                  _sectionCard(
                                    child: Theme(
                                      data: theme.copyWith(
                                        dividerColor: Colors.transparent,
                                      ),
                                      child: ExpansionTile(
                                        initiallyExpanded:
                                            _expandedCardIndex == 3,
                                        onExpansionChanged: (expanded) {
                                          setState(() {
                                            _expandedCardIndex =
                                                expanded ? 3 : null;
                                          });
                                        },
                                        title: Text(
                                          'avia.booking_details.passenger_details'
                                              .tr(),
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w800,
                                            color:
                                                AppColors.getTextColor(isDark),
                                          ),
                                        ),
                                        childrenPadding: EdgeInsets.fromLTRB(
                                          AppSpacing.md,
                                          0,
                                          AppSpacing.md,
                                          AppSpacing.md,
                                        ),
                                        children: [
                                          ...List.generate(
                                              (_booking?.passengers ?? const [])
                                                  .length, (i) {
                                            final p = _booking!.passengers![i];
                                            final title =
                                                '${'avia.booking_details.passenger'.tr()} ${i + 1}';
                                            return Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 10.h),
                                              child: _sectionCard(
                                                child: Theme(
                                                  data: theme.copyWith(
                                                    dividerColor:
                                                        Colors.transparent,
                                                  ),
                                                  child: ExpansionTile(
                                                    initiallyExpanded: false,
                                                    title: Text(
                                                      title,
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: AppColors
                                                            .getTextColor(
                                                                isDark),
                                                      ),
                                                    ),
                                                    childrenPadding:
                                                        EdgeInsets.fromLTRB(
                                                      AppSpacing.md,
                                                      0,
                                                      AppSpacing.md,
                                                      AppSpacing.md,
                                                    ),
                                                    children: [
                                                      _infoRow(
                                                        label:
                                                            'avia.booking_details.name'
                                                                .tr(),
                                                        value: '${p.firstName} ${p.lastName}'
                                                                .trim()
                                                                .isEmpty
                                                            ? 'avia.booking_details.na'
                                                                .tr()
                                                            : '${p.firstName} ${p.lastName}'
                                                                .trim(),
                                                      ),
                                                      _infoRow(
                                                        label:
                                                            'avia.booking_details.birth_date'
                                                                .tr(),
                                                        value: p.birthdate
                                                                .isEmpty
                                                            ? 'avia.booking_details.na'
                                                                .tr()
                                                            : p.birthdate,
                                                      ),
                                                      _infoRow(
                                                        label:
                                                            'avia.booking_details.document'
                                                                .tr(),
                                                        value: p.docNumber
                                                                .isEmpty
                                                            ? 'avia.booking_details.na'
                                                                .tr()
                                                            : p.docNumber,
                                                      ),
                                                      if (p.docExpire
                                                          .trim()
                                                          .isNotEmpty)
                                                        _infoRow(
                                                          label:
                                                              'avia.booking_details.document_expiry'
                                                                  .tr(),
                                                          value: p.docExpire
                                                              .trim(),
                                                        ),
                                                      _infoRow(
                                                        label:
                                                            'avia.booking_details.phone'
                                                                .tr(),
                                                        value:
                                                            _formatPhoneDisplay(
                                                                p.tel),
                                                      ),
                                                      if (_booking?.payer?.email
                                                              ?.trim()
                                                              .isNotEmpty ??
                                                          false)
                                                        _infoRow(
                                                          label:
                                                              'avia.booking_details.email'
                                                                  .tr(),
                                                          value: _booking!
                                                              .payer!.email!
                                                              .trim(),
                                                          singleLine: true,
                                                        ),
                                                      if (p.gender
                                                          .trim()
                                                          .isNotEmpty)
                                                        _infoRow(
                                                          label:
                                                              'avia.booking_details.gender'
                                                                  .tr(),
                                                          value:
                                                              p.gender.trim(),
                                                        ),
                                                      _infoRow(
                                                        label:
                                                            'avia.booking_details.citizenship'
                                                                .tr(),
                                                        value: p.citizenship
                                                                .isEmpty
                                                            ? 'avia.booking_details.na'
                                                                .tr()
                                                            : p.citizenship,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: AppSpacing.md),

                                  // Booking details (route summary)
                                  _sectionCard(
                                    child: Theme(
                                      data: theme.copyWith(
                                          dividerColor: Colors.transparent),
                                      child: ExpansionTile(
                                        initiallyExpanded:
                                            _expandedCardIndex == 4,
                                        onExpansionChanged: (expanded) {
                                          setState(() {
                                            _expandedCardIndex =
                                                expanded ? 4 : null;
                                          });
                                        },
                                        title: Text(
                                          'avia.booking_details.booking_details'
                                              .tr(),
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w800,
                                            color:
                                                AppColors.getTextColor(isDark),
                                          ),
                                        ),
                                        childrenPadding: EdgeInsets.fromLTRB(
                                          AppSpacing.md,
                                          0,
                                          AppSpacing.md,
                                          AppSpacing.md,
                                        ),
                                        children: [
                                          _infoRow(
                                            label:
                                                'avia.booking_details.booking_id'
                                                    .tr(),
                                            value: (_booking?.id
                                                        ?.trim()
                                                        .isNotEmpty ??
                                                    false)
                                                ? _booking!.id!.trim()
                                                : widget.bookingId.trim(),
                                          ),
                                          _infoRow(
                                            label: 'avia.booking_details.route'
                                                .tr(),
                                            value: _routeFromBookingOrOffers(),
                                          ),
                                          SizedBox(height: 12.h),
                                          OutlinedButton.icon(
                                            onPressed: _isLoadingRules
                                                ? null
                                                : () {
                                                    setState(() {
                                                      _isLoadingRules = true;
                                                    });
                                                    context
                                                        .read<AviaBloc>()
                                                        .add(
                                                          BookingRulesRequested(
                                                              widget.bookingId),
                                                        );
                                                  },
                                            icon: _isLoadingRules
                                                ? SizedBox(
                                                    width: 16.w,
                                                    height: 16.h,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : Icon(
                                                    Icons.description_outlined,
                                                    size: 18.sp,
                                                  ),
                                            label: Text(
                                              'avia.booking_details.view_rules'
                                                  .tr(),
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                                vertical: 12.h,
                                              ),
                                              side: BorderSide(
                                                color: AppColors.primaryBlue,
                                              ),
                                            ),
                                          ),
                                          if (_bookingRules != null) ...[
                                            SizedBox(height: 16.h),
                                            if (_bookingRules!.title != null &&
                                                _bookingRules!.title!
                                                    .trim()
                                                    .isNotEmpty)
                                              Text(
                                                _bookingRules!.title!.trim(),
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.getTextColor(
                                                      isDark),
                                                ),
                                              ),
                                            if (_bookingRules!.description !=
                                                    null &&
                                                _bookingRules!.description!
                                                    .trim()
                                                    .isNotEmpty) ...[
                                              SizedBox(height: 8.h),
                                              Text(
                                                _bookingRules!.description!
                                                    .trim(),
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: AppColors
                                                      .getSubtitleColor(isDark),
                                                ),
                                              ),
                                            ],
                                            if (_bookingRules!.rules != null &&
                                                _bookingRules!
                                                    .rules!.isNotEmpty) ...[
                                              SizedBox(height: 16.h),
                                              ..._bookingRules!.rules!
                                                  .map((rule) => Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 12.h),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            if (rule.type !=
                                                                    null &&
                                                                rule.type!
                                                                    .trim()
                                                                    .isNotEmpty)
                                                              Text(
                                                                rule.type!
                                                                    .trim(),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      14.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: AppColors
                                                                      .getTextColor(
                                                                          isDark),
                                                                ),
                                                              ),
                                                            if (rule.description !=
                                                                    null &&
                                                                rule.description!
                                                                    .trim()
                                                                    .isNotEmpty) ...[
                                                              SizedBox(
                                                                  height: 4.h),
                                                              Text(
                                                                rule.description!
                                                                    .trim(),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      13.sp,
                                                                  color: AppColors
                                                                      .getSubtitleColor(
                                                                          isDark),
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ))
                                                  .toList(),
                                            ],
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                ),

                // Bottom buttons with timer
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.getCardBg(isDark),
                    border: Border(
                      top: BorderSide(
                          color: AppColors.getBorderColor(isDark), width: 1),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Timer (only show if not paid)
                      if (!_isPaid && _isTimerActive) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.getCardBg(isDark)
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: AppColors.getBorderColor(isDark),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16.sp,
                                  color: AppColors.getSubtitleColor(isDark),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  _formatCountdown(_remainingSeconds),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.getTextColor(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.router.maybePop(),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                side: BorderSide(
                                    color: AppColors.getBorderColor(isDark)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                'avia.booking_details.back'.tr(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.getTextColor(isDark),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          if (_isPaid) ...[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _handlePdfDownload,
                                icon: Icon(
                                  Icons.picture_as_pdf,
                                  size: 18.sp,
                                  color: AppColors.primaryBlue,
                                ),
                                label: Text(
                                  'PDF',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  side:
                                      BorderSide(color: AppColors.primaryBlue),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: AppSpacing.md),
                          ],
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: (_isPaid || _isLoadingPayment)
                                  ? null
                                  : _handlePayNow,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                backgroundColor: AppColors.primaryBlue,
                                disabledBackgroundColor: AppColors.primaryBlue
                                    .withValues(alpha: 0.35),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: _isLoadingPayment
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          AppColors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      _isPaid
                                          ? 'avia.booking_details.paid'.tr()
                                          : 'avia.booking_details.pay_now'.tr(),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
