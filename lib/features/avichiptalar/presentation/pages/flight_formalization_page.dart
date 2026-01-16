import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../features/register/domain/usecases/get_profile.dart';
import '../../../../features/register/domain/entities/user_profile.dart';
import '../../data/models/create_booking_request_model.dart';
import '../../data/models/offer_model.dart';
import '../bloc/avia_bloc.dart';
import '../widgets/primary_button.dart';
import '../../data/models/human_model.dart';
import '../models/passenger_data.dart';
import '../../../../core/utils/input_formatters.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/services/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/avia_orders_local_data_source.dart';

@RoutePage(name: 'FlightFormalizationRoute')
class FlightFormalizationPage extends StatefulWidget
    implements AutoRouteWrapper {
  final OfferModel outboundOffer;
  final OfferModel? returnOffer;
  final String totalPrice;
  final String currency;
  final int adults;
  final int childrenCount;
  final int babies;

  const FlightFormalizationPage({
    super.key,
    required this.outboundOffer,
    this.returnOffer,
    required this.totalPrice,
    required this.currency,
    this.adults = 1,
    this.childrenCount = 0,
    this.babies = 0,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
    // AviaBloc modul ichida mavjud bo'lishi kerak
    // Agar context da yo'q bo'lsa, ServiceLocator dan olish
    try {
      final existingBloc = context.read<AviaBloc>();
      return BlocProvider.value(
        value: existingBloc,
        child: this,
      );
    } catch (_) {
      // Context da yo'q bo'lsa, ServiceLocator dan olish
      return BlocProvider(
        create: (_) => ServiceLocator.resolve<AviaBloc>(),
        child: this,
      );
    }
  }

  @override
  State<FlightFormalizationPage> createState() =>
      _FlightFormalizationPageState();
}

class _FlightFormalizationPageState extends State<FlightFormalizationPage> {
  final _formKey = GlobalKey<FormState>();

  // Customer information controllers (will be populated from AuthService)
  final _customerNameController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerPhoneController = TextEditingController();

  // List of passengers data
  List<PassengerData> _passengers = [];
  int _expandedPassengerIndex = 0; // Index of currently expanded passenger card
  int?
      _currentPassengerSelectionIndex; // Index of passenger being selected from saved list

  // Controllers for each passenger (list of controllers)
  final List<TextEditingController> _passengerNameControllers = [];
  final List<TextEditingController> _passengerSurnameControllers = [];
  final List<TextEditingController> _passengerPatronymicControllers = [];
  final List<TextEditingController> _passengerReturnDateControllers = [];
  final List<TextEditingController> _passengerPhoneControllers = [];
  final List<TextEditingController> _passportSeriesControllers = [];
  final List<TextEditingController> _passportExpiryControllers = [];
  final List<TextEditingController> _citizenshipControllers = [];
  final List<String> _selectedGenders = [];
  final List<bool> _savePassengerInfo = [];

  bool _isValidUzPhone(String raw) {
    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return digitsOnly.length == 12 && digitsOnly.startsWith('998');
  }

  Future<void> _saveOrderId(String bookingId) async {
    try {
      final id = bookingId.trim();
      if (id.isEmpty) return;
      final prefs = ServiceLocator.resolve<SharedPreferences>();
      final local = AviaOrdersLocalDataSource(prefs);
      await local.addOrder(id);
    } catch (_) {
      // ignore - local caching should not break UX
    }
  }

  String _normalizePhoneForApi(String raw) {
    final normalized = AuthService.normalizeContact(raw);
    // If somehow an email sneaks in, return raw cleaned value to avoid crash.
    if (normalized.contains('@')) {
      return normalized;
    }
    // Extract only digits and + sign
    final cleaned = normalized.replaceAll(RegExp(r'[^0-9+]'), '');
    // Remove + sign for processing
    final digitsOnly = cleaned.replaceAll('+', '');
    // Limit to 12 digits (998 + 9 digits) to prevent extra digits
    final limitedDigits =
        digitsOnly.length > 12 ? digitsOnly.substring(0, 12) : digitsOnly;
    // Return with + prefix if it starts with 998
    if (limitedDigits.startsWith('998')) {
      return '+$limitedDigits';
    }
    // If doesn't start with 998, add it
    if (limitedDigits.isNotEmpty && !limitedDigits.startsWith('998')) {
      // If already has 9 digits, add 998 prefix
      if (limitedDigits.length == 9) {
        return '+998$limitedDigits';
      }
      // Otherwise return as is with + prefix
      return '+$limitedDigits';
    }
    return cleaned;
  }

  @override
  void initState() {
    super.initState();
    _initializePassengers();
    _initializeControllers();
    // Default phone prefix for Uzbekistan
    _customerPhoneController.text = '+998';
    // Context mavjud bo'lgandan keyin tekshirish
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndLoadData();
    });
  }

  /// Check if user is logged in, if not redirect to login
  Future<void> _checkAuthAndLoadData() async {
    if (!mounted) return;

    try {
      final authService = AuthService.instance;
      final user = await authService.fetchActiveUser();

      if (!mounted) return;

      // Agar ro'yxatdan o'tmagan bo'lsa, login sahifasiga yo'naltirish
      if (user == null) {
        // Login sahifasiga yo'naltirish va natijani kutish
        await context.router.push(const LoginRoute());

        if (!mounted) return;

        // Login muvaffaqiyatli bo'lgandan keyin ma'lumotlarni yuklash
        final userAfterLogin = await authService.fetchActiveUser();
        if (userAfterLogin != null && mounted) {
          await _loadUserData();
        } else if (mounted) {
          // Agar login qilmagan bo'lsa, sahifadan chiqish
          Navigator.of(context).pop();
        }
      } else {
        // Agar ro'yxatdan o'tgan bo'lsa, ma'lumotlarni yuklash
        await _loadUserData();
      }
    } catch (e) {
      AppLogger.warning('Failed to check auth status', e);
      // Xatolik bo'lsa ham davom etish
      if (mounted) {
        await _loadUserData();
      }
    }
  }

  /// Load logged-in user data into customer info fields
  Future<void> _loadUserData() async {
    try {
      final authService = AuthService.instance;
      final user = await authService.fetchActiveUser();

      // Faqat mavjud bo'lsa ma'lumotlarni yuklash
      if (user != null && mounted) {
        // Profile'ni yuklab, email va telefon alohida olish
        UserProfile? profile;
        try {
          final getProfile = ServiceLocator.resolve<GetProfile>();
          profile = await getProfile();
        } catch (e) {
          // Profile yuklanmasa, faqat user.contact ishlatish
          AppLogger.warning('Failed to load profile, using contact only', e);
        }

        setState(() {
          // Ismni faqat bo'sh bo'lsa to'ldirish
          if (_customerNameController.text.trim().isEmpty) {
            _customerNameController.text = user.fullName;
          }

          final currentEmail = _customerEmailController.text.trim();
          final currentPhone = _customerPhoneController.text.trim();

          // Email maydonini to'ldirish (user.email, profile'dan yoki user.contact'dan)
          if (currentEmail.isEmpty) {
            if (user.email != null && user.email!.isNotEmpty) {
              _customerEmailController.text = user.email!;
            } else if (profile?.email != null && profile!.email!.isNotEmpty) {
              _customerEmailController.text = profile.email!;
            } else if (user.contact.contains('@')) {
              _customerEmailController.text = user.contact;
            }
          }

          // Telefon maydonini to'ldirish (user.phone, profile'dan yoki user.contact'dan)
          if (currentPhone.isEmpty || currentPhone == '+998') {
            if (user.phone != null && user.phone!.isNotEmpty) {
              final normalizedPhone = AuthService.normalizeContact(user.phone!);
              _customerPhoneController.text = normalizedPhone;
            } else if (profile?.phone != null && profile!.phone!.isNotEmpty) {
              final normalizedPhone =
                  AuthService.normalizeContact(profile.phone!);
              _customerPhoneController.text = normalizedPhone;
            } else if (!user.contact.contains('@')) {
              final normalizedPhone =
                  AuthService.normalizeContact(user.contact);
              _customerPhoneController.text = normalizedPhone;
            } else {
              _customerPhoneController.text = '+998';
            }
          }
        });
      }
    } catch (e) {
      // Xatolik bo'lsa ham davom etish - login talab qilinmaydi
      AppLogger.warning('Failed to load user data', e);
    }
  }

  void _initializePassengers() {
    _passengers = [];

    // Add adults
    for (int i = 0; i < widget.adults; i++) {
      _passengers.add(
        PassengerData(
          passengerType: 'adult',
          name: '',
          surname: '',
          patronymic: '',
          phone: '',
          passportSeries: '',
          gender: 'Erkak',
        ),
      );
    }

    // Add children
    for (int i = 0; i < widget.childrenCount; i++) {
      _passengers.add(PassengerData(passengerType: 'child', gender: 'Erkak'));
    }

    // Add babies
    for (int i = 0; i < widget.babies; i++) {
      _passengers.add(PassengerData(passengerType: 'baby', gender: 'Erkak'));
    }

    // Initialize save preference to false (default) for each passenger
    _savePassengerInfo.clear();
    for (int i = 0; i < _passengers.length; i++) {
      _savePassengerInfo.add(false);
    }
  }

  void _initializeControllers() {
    // Dispose old controllers if any
    for (var controller in _passengerNameControllers) {
      controller.dispose();
    }
    for (var controller in _passengerSurnameControllers) {
      controller.dispose();
    }
    for (var controller in _passengerPatronymicControllers) {
      controller.dispose();
    }
    for (var controller in _passengerReturnDateControllers) {
      controller.dispose();
    }
    for (var controller in _passengerPhoneControllers) {
      controller.dispose();
    }
    for (var controller in _passportSeriesControllers) {
      controller.dispose();
    }
    for (var controller in _passportExpiryControllers) {
      controller.dispose();
    }
    for (var controller in _citizenshipControllers) {
      controller.dispose();
    }

    // Clear lists
    _passengerNameControllers.clear();
    _passengerSurnameControllers.clear();
    _passengerPatronymicControllers.clear();
    _passengerReturnDateControllers.clear();
    _passengerPhoneControllers.clear();
    _passportSeriesControllers.clear();
    _passportExpiryControllers.clear();
    _citizenshipControllers.clear();
    _selectedGenders.clear();

    // Create controllers for each passenger
    for (int i = 0; i < _passengers.length; i++) {
      final passenger = _passengers[i];
      _passengerNameControllers.add(
        TextEditingController(text: passenger.name),
      );
      _passengerSurnameControllers.add(
        TextEditingController(text: passenger.surname),
      );
      _passengerPatronymicControllers.add(
        TextEditingController(text: passenger.patronymic),
      );
      _passengerReturnDateControllers.add(
        TextEditingController(text: passenger.returnDate ?? ''),
      );
      final initialPhone = passenger.phone.trim().isEmpty
          ? '+998'
          : AuthService.normalizeContact(passenger.phone);
      _passengerPhoneControllers.add(
        TextEditingController(text: initialPhone),
      );
      _passportSeriesControllers.add(
        TextEditingController(text: passenger.passportSeries),
      );
      _passportExpiryControllers.add(
        TextEditingController(text: passenger.passportExpiry ?? ''),
      );
      _citizenshipControllers.add(
        TextEditingController(text: passenger.citizenship ?? ''),
      );
      _selectedGenders.add(passenger.gender);
    }
  }

  void _togglePassengerCard(int index) {
    if (_expandedPassengerIndex == index) {
      // If clicking on already expanded card, collapse it
      setState(() {
        _expandedPassengerIndex = -1;
      });
    } else {
      // Save current passenger data before switching
      if (_expandedPassengerIndex >= 0) {
        _savePassengerData(_expandedPassengerIndex);
      }
      // Expand new passenger card
      setState(() {
        _expandedPassengerIndex = index;
      });
    }
  }

  void _savePassengerData(int index) {
    // Safety check
    if (index < 0 ||
        index >= _passengers.length ||
        index >= _passengerNameControllers.length ||
        index >= _passengerSurnameControllers.length) {
      return;
    }

    _passengers[index] = PassengerData(
      name: _passengerNameControllers[index].text,
      surname: _passengerSurnameControllers[index].text,
      patronymic: _passengerPatronymicControllers[index].text,
      returnDate: _passengerReturnDateControllers[index].text.isEmpty
          ? null
          : _passengerReturnDateControllers[index].text,
      gender: _selectedGenders[index],
      passportSeries: _passportSeriesControllers[index].text,
      passportExpiry: _passportExpiryControllers[index].text.isEmpty
          ? null
          : _passportExpiryControllers[index].text,
      citizenship: _citizenshipControllers[index].text.isEmpty
          ? null
          : _citizenshipControllers[index].text,
      phone: _passengerPhoneControllers[index].text.trim(),
      passengerType: _passengers[index].passengerType,
    );
  }

  int get _totalPassengers => _passengers.length;

  String _getPassengerTypeLabel(int index) {
    final passenger = _passengers[index];
    switch (passenger.passengerType) {
      case 'adult':
        return 'avia.confirmation.adult'.tr();
      case 'child':
        return 'avia.confirmation.child'.tr();
      case 'baby':
        return 'avia.confirmation.baby'.tr();
      default:
        return 'avia.confirmation.adult'.tr();
    }
  }

  // Получить общую сумму (уже рассчитанную)
  double _getTotalPriceValue() {
    try {
      final totalPriceStr = widget.totalPrice.replaceAll(RegExp(r'[^\d]'), '');
      return double.tryParse(totalPriceStr) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Рассчитать цену для конкретного пассажира
  // API dan kelgan narx barcha yo'lovchilar uchun hisoblangan
  // Har bir yo'lovchi uchun teng taqsimlaymiz (API narxlarini ishlatamiz)
  double _getPassengerPrice(String passengerType) {
    final totalPrice = _getTotalPriceValue();
    if (totalPrice == 0) return 0;

    // API dan kelgan narx barcha yo'lovchilar uchun hisoblangan
    // Har bir yo'lovchi uchun teng taqsimlaymiz
    // API narxlarini to'g'ridan-to'g'ri ishlatamiz, hardcoded coefficients emas
    final totalPassengers = _passengers.length;
    if (totalPassengers == 0) return 0;

    // Har bir yo'lovchi uchun teng taqsimlash
    // API dan kelgan narx allaqachon barcha yo'lovchilar uchun hisoblangan
    return totalPrice / totalPassengers;
  }

  // Форматировать цену
  String _formatPrice(double price) {
    try {
      final priceInt = price.toInt();
      if (priceInt >= 1000000) {
        final millions = priceInt ~/ 1000000;
        final remainder = priceInt % 1000000;
        if (remainder == 0) {
          return '$millions, 000 000';
        } else {
          final remainderStr = remainder.toString().padLeft(6, '0');
          final thousands = remainderStr.substring(0, 3);
          final hundreds = remainderStr.substring(3);
          if (hundreds == '000') {
            return '$millions, $thousands 000';
          } else {
            return '$millions, $thousands $hundreds';
          }
        }
      } else if (priceInt >= 1000) {
        final thousands = priceInt ~/ 1000;
        final remainder = priceInt % 1000;
        if (remainder == 0) {
          return '$thousands 000';
        } else {
          return '$thousands ${remainder.toString().padLeft(3, '0')}';
        }
      }
      return priceInt.toString();
    } catch (e) {
      return price.toString();
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _customerPhoneController.dispose();
    for (var controller in _passengerNameControllers) {
      controller.dispose();
    }
    for (var controller in _passengerSurnameControllers) {
      controller.dispose();
    }
    for (var controller in _passengerPatronymicControllers) {
      controller.dispose();
    }
    for (var controller in _passengerReturnDateControllers) {
      controller.dispose();
    }
    for (var controller in _passengerPhoneControllers) {
      controller.dispose();
    }
    for (var controller in _passportSeriesControllers) {
      controller.dispose();
    }
    for (var controller in _passportExpiryControllers) {
      controller.dispose();
    }
    for (var controller in _citizenshipControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate(
    TextEditingController controller,
    int passengerIndex,
  ) async {
    // Close keyboard before showing date picker
    FocusScope.of(context).unfocus();

    // Determine if this is for birth date or passport expiry
    final isBirthDate =
        controller == _passengerReturnDateControllers[passengerIndex];

    DateTime initialDate;
    DateTime firstDate;
    DateTime lastDate;

    if (isBirthDate) {
      // For birth date: allow dates from 1900 to today
      final now = DateTime.now();
      initialDate =
          DateTime(now.year - 25, now.month, now.day); // Default: 25 years ago
      firstDate = DateTime(1900); // Oldest date
      lastDate = now; // Today
    } else {
      // For passport expiry: allow dates from today to 10 years in the future
      final now = DateTime.now();
      initialDate = DateTime(
          now.year + 5, now.month, now.day); // Default: 5 years from now
      firstDate = now; // Today
      lastDate =
          DateTime(now.year + 10, now.month, now.day); // 10 years from now
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: context.locale,
      builder: (context, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppColors.primaryBlue,
              onPrimary: theme.colorScheme.onPrimary,
              surface: AppColors.getCardBg(isDark),
              onSurface: AppColors.getTextColor(isDark),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<AviaBloc, AviaState>(
      listener: (context, state) {
        if (state is AviaCreateBookingSuccess) {
          // Booking muvaffaqiyatli bo'lgandan keyin passenger'larni saqlash
          _savePassengersToMyList();

          context.router.push(
            BookingSuccessRoute(
              outboundOffer: widget.outboundOffer,
              returnOffer: widget.returnOffer,
              bookingId: state.booking.id ?? '',
            ),
          );
        } else if (state is AviaCreateBookingFailure) {
          // Check if there's an existing booking ID (duplicate booking)
          if (state.existingBookingId != null) {
            // Navigate to the existing booking instead of showing error
            context.router.push(
              BookingSuccessRoute(
                outboundOffer: widget.outboundOffer,
                returnOffer: widget.returnOffer,
                bookingId: state.existingBookingId!,
              ),
            );
            // Show info message
            SnackbarHelper.showInfo(
              context,
              'Bu buyurtma allaqachon mavjud. Mavjud buyurtmaga o\'tildi.',
            );
          } else {
            // Regular error - show error message
            SnackbarHelper.showError(context, state.message);
          }
        } else if (state is AviaGetHumansSuccess) {
          AppLogger.debug(
              'AviaGetHumansSuccess received with ${state.humans.length} humans');
          _showHumansList(context, state.humans);
        } else if (state is AviaGetHumansFailure) {
          AppLogger.error('AviaGetHumansFailure: ${state.message}');
          SnackbarHelper.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AviaBookingLoading;
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
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'avia.formalization.title'.tr(),
              style: TextStyle(
                color: AppColors.getTextColor(isDark),
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer Information Section
                        _buildSectionTitle(
                            'avia.formalization.customer_info'.tr()),
                        SizedBox(height: AppSpacing.md),
                        _buildInputField(
                          controller: _customerNameController,
                          label: 'avia.formalization.name'.tr(),
                          icon: Icons.person_outline,
                        ),
                        SizedBox(height: AppSpacing.md),
                        _buildInputField(
                          controller: _customerPhoneController,
                          label: 'avia.formalization.phone'.tr(),
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [PhoneFormatter()],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null; // Bo'sh bo'lishi mumkin
                            }
                            final phoneDigits =
                                value.replaceAll(RegExp(r'[^0-9]'), '');
                            // Agar faqat "998" (default prefix) bo'lsa, bo'sh deb hisoblash
                            if (phoneDigits.isEmpty ||
                                phoneDigits == '998' ||
                                value.trim() == '+998') {
                              return null;
                            }
                            // To'liq telefon raqami bo'lsa, formatni tekshirish
                            if (phoneDigits.length != 12 ||
                                !phoneDigits.startsWith('998')) {
                              return "Telefon raqami noto'g'ri. Misol: +998 90 123-45-67";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppSpacing.md),
                        _buildInputField(
                          controller: _customerEmailController,
                          label: 'avia.formalization.email'.tr(),
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Email kiritish majburiy";
                            }
                            final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                            if (!emailRegex.hasMatch(value.trim())) {
                              return "Email noto'g'ri formatda";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppSpacing.xl),
                        // Passenger navigation tabs (if multiple passengers)
                        if (_totalPassengers > 1) ...[
                          _buildPassengerTabs(isDark),
                          SizedBox(height: AppSpacing.md),
                        ],
                        // Passenger Information Cards
                        _buildSectionTitle(
                            'avia.formalization.passenger_info'.tr()),
                        SizedBox(height: AppSpacing.md),
                        // List of passenger cards
                        ...List.generate(_totalPassengers, (index) {
                          return _buildPassengerCard(index, isDark);
                        }),
                      ],
                    ),
                  ),
                ),
                // Footer buttons
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.getCardBg(isDark),
                    border: isDark
                        ? Border(
                            top: BorderSide(
                                color: AppColors.darkBorder, width: 1),
                          )
                        : null,
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price info (read-only)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'avia.formalization.total'.tr(),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.getSubtitleColor(isDark),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '${widget.totalPrice} ${widget.currency}',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                if (_totalPassengers > 1) ...[
                                  SizedBox(height: 2.h),
                                  Text(
                                    '$_totalPassengers ${'avia.formalization.for_passengers'.tr()}',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: AppColors.getSubtitleColor(isDark),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),
                      // Main action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                side: BorderSide(
                                  color: AppColors.getBorderColor(isDark),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                'avia.formalization.cancel'.tr(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.getSubtitleColor(isDark),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            flex: 2,
                            child: PrimaryButton(
                              text: 'avia.formalization.formalize'.tr(),
                              isLoading: isLoading,
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      // Save all passenger data
                                      for (int i = 0;
                                          i < _passengers.length;
                                          i++) {
                                        _savePassengerData(i);
                                      }

                                      // Validate customer info first
                                      final customerName =
                                          _customerNameController.text.trim();
                                      final customerEmail =
                                          _customerEmailController.text.trim();
                                      final customerPhone =
                                          _customerPhoneController.text.trim();

                                      // Ism majburiy
                                      if (customerName.isEmpty) {
                                        SnackbarHelper.showWarning(
                                          context,
                                          'Iltimos, ismni kiriting',
                                        );
                                        return;
                                      }

                                      // Email majburiy + format validatsiyasi
                                      if (customerEmail.isEmpty) {
                                        SnackbarHelper.showWarning(
                                          context,
                                          'Iltimos, email kiriting',
                                        );
                                        return;
                                      }

                                      final emailRegex = RegExp(
                                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                      if (!emailRegex.hasMatch(customerEmail)) {
                                        SnackbarHelper.showWarning(
                                          context,
                                          "Email noto'g'ri formatda. Misol: example@email.com",
                                        );
                                        return;
                                      }

                                      // Telefon ixtiyoriy: faqat to'ldirilgan bo'lsa tekshiramiz
                                      final phoneDigits = customerPhone
                                          .replaceAll(RegExp(r'[^0-9]'), '');
                                      final isPhoneEmpty =
                                          phoneDigits.isEmpty ||
                                              phoneDigits == '998' ||
                                              customerPhone.trim() == '+998';
                                      if (!isPhoneEmpty) {
                                        final hasValidPhone =
                                            phoneDigits.length == 12 &&
                                                phoneDigits.startsWith('998');
                                        if (!hasValidPhone) {
                                          SnackbarHelper.showWarning(
                                            context,
                                            "Telefon raqami noto'g'ri. Misol: +998 90 123-45-67",
                                          );
                                          return;
                                        }
                                      }

                                      // Validate passenger phone numbers to prevent backend 422 (passengers.*.tel invalid)
                                      for (int i = 0;
                                          i < _passengers.length;
                                          i++) {
                                        final pPhone = _passengers[i].phone;
                                        if (!_isValidUzPhone(pPhone)) {
                                          setState(() {
                                            _expandedPassengerIndex = i;
                                          });
                                          SnackbarHelper.showWarning(
                                            context,
                                            "Telefon raqami noto'g'ri. Misol: +998 90 123-45-67",
                                          );
                                          return;
                                        }
                                      }

                                      // Validate all passengers
                                      bool allValid = true;
                                      int? firstInvalidIndex;
                                      for (int i = 0;
                                          i < _passengers.length;
                                          i++) {
                                        if (!_passengers[i].isFilled) {
                                          allValid = false;
                                          firstInvalidIndex = i;
                                          // Expand first unfilled passenger
                                          setState(() {
                                            _expandedPassengerIndex = i;
                                          });
                                          break;
                                        }
                                      }

                                      if (allValid &&
                                          _formKey.currentState!.validate()) {
                                        try {
                                          // Prepare request data
                                          // Debug logs removed to reduce console noise

                                          final passengersList =
                                              _passengers.map((p) {
                                            // Convert date format from dd/MM/yyyy to yyyy-MM-dd if needed
                                            // Or ensure it matches API expectation. Let's assume API expects YYYY-MM-DD
                                            String formatDate(String? date) {
                                              if (date == null || date.isEmpty)
                                                return '';
                                              try {
                                                if (date.isEmpty) return '';

                                                // 1. Handle yyyy-MM-dd (Standard API format)
                                                if (RegExp(
                                                        r'^\d{4}-\d{2}-\d{2}$')
                                                    .hasMatch(date)) {
                                                  return date;
                                                }
                                                // 2. Handle yyyy/MM/dd (Converting to yyyy-MM-dd)
                                                if (RegExp(
                                                        r'^\d{4}/\d{2}/\d{2}$')
                                                    .hasMatch(date)) {
                                                  return date.replaceAll(
                                                      '/', '-');
                                                }

                                                // 3. Handle dd/MM/yyyy (Manual input standard)
                                                // Also support . or - as separators for robust manual handling
                                                // Regex checks for d/M/yyyy, dd/MM/yyyy, d-M-yyyy etc.
                                                // If it starts with 2 digits, assume day.
                                                if (RegExp(
                                                        r'^\d{1,2}[./-]\d{1,2}[./-]\d{4}$')
                                                    .hasMatch(date)) {
                                                  // Normalize separators to / for standard parsing
                                                  String normDate = date
                                                      .replaceAll('.', '/')
                                                      .replaceAll('-', '/');
                                                  final inputFormat =
                                                      DateFormat('dd/MM/yyyy');
                                                  final outputFormat =
                                                      DateFormat('yyyy-MM-dd');
                                                  final dateTime = inputFormat
                                                      .parse(normDate);
                                                  return outputFormat
                                                      .format(dateTime);
                                                }

                                                // Fallback: try parsing with lenient format if above failed
                                                // (E.g. maybe user typed ddMMyyyy without separators? unlikely given input formatter)
                                                return date;
                                              } catch (e) {
                                                // Date format error - using original date
                                                return date;
                                              }
                                            }

                                            String mapAgeType(String type) {
                                              switch (type) {
                                                case 'adult':
                                                  return 'adt';
                                                case 'child':
                                                  return 'chd';
                                                case 'baby':
                                                  return 'inf';
                                                default:
                                                  return 'adt';
                                              }
                                            }

                                            // Get flight departure date for age calculation
                                            // Age should be calculated based on flight date, not current date
                                            DateTime getFlightDepartureDate() {
                                              try {
                                                // Try to get departure date from outbound offer
                                                final segments = widget
                                                    .outboundOffer.segments;
                                                if (segments != null &&
                                                    segments.isNotEmpty) {
                                                  final departureTime = segments
                                                      .first.departureTime;
                                                  if (departureTime != null &&
                                                      departureTime
                                                          .isNotEmpty) {
                                                    // Parse departure time (format: "YYYY-MM-DD HH:mm:ss" or "YYYY-MM-DD")
                                                    final datePart =
                                                        departureTime
                                                            .split(' ')
                                                            .first;
                                                    final dateParts =
                                                        datePart.split('-');
                                                    if (dateParts.length == 3) {
                                                      final year = int.parse(
                                                          dateParts[0]);
                                                      final month = int.parse(
                                                          dateParts[1]);
                                                      final day = int.parse(
                                                          dateParts[2]);
                                                      return DateTime(
                                                          year, month, day);
                                                    }
                                                  }
                                                }
                                              } catch (e) {
                                                // Failed to parse flight departure date - using current date
                                              }
                                              // Fall back to current date if flight date can't be determined
                                              return DateTime.now();
                                            }

                                            // Calculate age type from birthdate based on API thresholds
                                            // adult: 12-200, child: 2-12, infant: 0-2
                                            // Uses flight departure date for accurate age calculation
                                            String
                                                calculateAgeTypeFromBirthdate(
                                                    String? birthdate,
                                                    String
                                                        fallbackPassengerType) {
                                              if (birthdate == null ||
                                                  birthdate.isEmpty) {
                                                // If no birthdate, use passengerType as fallback
                                                return mapAgeType(
                                                    fallbackPassengerType);
                                              }

                                              try {
                                                // Parse birthdate (format: YYYY-MM-DD after formatDate)
                                                final parts =
                                                    birthdate.split('-');
                                                if (parts.length != 3) {
                                                  return mapAgeType(
                                                      fallbackPassengerType);
                                                }

                                                final year =
                                                    int.parse(parts[0]);
                                                final month =
                                                    int.parse(parts[1]);
                                                final day = int.parse(parts[2]);
                                                final birth =
                                                    DateTime(year, month, day);

                                                // Use flight departure date for age calculation
                                                // This ensures age is calculated at the time of travel, not current date
                                                final referenceDate =
                                                    getFlightDepartureDate();

                                                // Calculate age at the time of flight
                                                int age = referenceDate.year -
                                                    birth.year;
                                                if (referenceDate.month <
                                                        birth.month ||
                                                    (referenceDate.month ==
                                                            birth.month &&
                                                        referenceDate.day <
                                                            birth.day)) {
                                                  age--;
                                                }

                                                // Determine age type based on API thresholds
                                                // adult: >= 12, child: >= 2 and < 12, infant: >= 0 and < 2
                                                String ageType;
                                                if (age >= 12) {
                                                  ageType = 'adt';
                                                } else if (age >= 2) {
                                                  ageType = 'chd';
                                                } else if (age >= 0) {
                                                  ageType = 'inf';
                                                } else {
                                                  // Invalid age (future date), default to adult
                                                  ageType = 'adt';
                                                }

                                                // Age calculation debug log removed
                                                return ageType;
                                              } catch (e) {
                                                // If parsing fails, use passengerType as fallback
                                                return mapAgeType(
                                                    fallbackPassengerType);
                                              }
                                            }

                                            // Map citizenship to country code
                                            String mapCitizenship(
                                                String? citizenship) {
                                              if (citizenship == null ||
                                                  citizenship.isEmpty)
                                                return 'UZ';

                                              // Check if already a country code (2 letters)
                                              if (citizenship.length == 2)
                                                return citizenship
                                                    .toUpperCase();

                                              // Map from display name to code
                                              final citizenshipMap = {
                                                'avia.formalization.uzbekistan':
                                                    'UZ',
                                                'O\'zbekiston': 'UZ',
                                                'Uzbekistan': 'UZ',
                                                'avia.formalization.russia':
                                                    'RU',
                                                'Rossiya': 'RU',
                                                'Russia': 'RU',
                                                'avia.formalization.kazakhstan':
                                                    'KZ',
                                                'Qozog\'iston': 'KZ',
                                                'Kazakhstan': 'KZ',
                                                'avia.formalization.kyrgyzstan':
                                                    'KG',
                                                'Qirg\'iziston': 'KG',
                                                'Kyrgyzstan': 'KG',
                                              };

                                              return citizenshipMap[
                                                      citizenship] ??
                                                  'UZ';
                                            }

                                            final formattedBirthdate =
                                                formatDate(p.returnDate);
                                            final calculatedAgeType =
                                                calculateAgeTypeFromBirthdate(
                                                    formattedBirthdate,
                                                    p.passengerType);

                                            final passenger = PassengerModel(
                                              lastName: p.surname.trim(),
                                              firstName: p.name.trim(),
                                              age:
                                                  calculatedAgeType, // Use calculated age type from birthdate
                                              birthdate: formattedBirthdate,
                                              gender: p.gender == 'Erkak'
                                                  ? 'M'
                                                  : 'F',
                                              citizenship:
                                                  mapCitizenship(p.citizenship),
                                              tel: _normalizePhoneForApi(
                                                  p.phone),
                                              docType: 'P', // Passport
                                              docNumber: p.passportSeries
                                                  .replaceAll(' ', ''),
                                              docExpire:
                                                  formatDate(p.passportExpiry),
                                            );

                                            // Passenger debug log removed
                                            return passenger;
                                          }).toList();

                                          final request =
                                              CreateBookingRequestModel(
                                            payerName: _customerNameController
                                                .text
                                                .trim(),
                                            payerEmail: _customerEmailController
                                                .text
                                                .trim(),
                                            payerTel: _normalizePhoneForApi(
                                                _customerPhoneController.text),
                                            passengers: passengersList,
                                          );

                                          // Payer debug log removed

                                          context.read<AviaBloc>().add(
                                                CreateBookingRequested(
                                                  offerId: widget
                                                          .outboundOffer.id ??
                                                      '', // Using outbound offer ID for booking
                                                  request: request,
                                                ),
                                              );
                                        } catch (e) {
                                          // Error preparing booking request
                                          SnackbarHelper.showError(
                                            context,
                                            '${'avia.status.error_message'.tr()}: ${e.toString()}',
                                            duration: Duration(seconds: 5),
                                          );
                                        }
                                      } else {
                                        String message =
                                            'avia.formalization.fill_all_fields'
                                                .tr();
                                        if (firstInvalidIndex != null) {
                                          message =
                                              'avia.formalization.fill_passenger_fields'
                                                  .tr(
                                            namedArgs: {
                                              'index': (firstInvalidIndex + 1)
                                                  .toString(),
                                            },
                                          );
                                        }
                                        SnackbarHelper.showWarning(
                                          context,
                                          message,
                                        );
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPassengerTabs(bool isDark) {
    return SizedBox(
      height: 50.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        cacheExtent: 200, // Cache optimization for horizontal scroll
        itemCount: _totalPassengers,
        itemBuilder: (context, index) {
          final isExpanded = index == _expandedPassengerIndex;
          final passenger = _passengers[index];
          final isFilled = passenger.isFilled;

          return GestureDetector(
            onTap: () {
              _togglePassengerCard(index);
            },
            child: Container(
              margin: EdgeInsets.only(right: AppSpacing.sm),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isExpanded
                    ? AppColors.primaryBlue
                    : (isFilled
                        ? AppColors.primaryBlue.withValues(alpha: 0.2)
                        : AppColors.getCardBg(isDark)),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isExpanded
                      ? AppColors.primaryBlue
                      : AppColors.getBorderColor(isDark),
                  width: isExpanded ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isFilled && !isExpanded)
                    Icon(
                      Icons.check_circle,
                      size: 16.sp,
                      color: AppColors.primaryBlue,
                    ),
                  if (isFilled && !isExpanded) SizedBox(width: 4.w),
                  Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isExpanded
                          ? AppColors.white
                          : AppColors.getTextColor(isDark),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _getPassengerTypeLabel(index),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isExpanded
                          ? AppColors.white
                          : AppColors.getSubtitleColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPassengerCard(int index, bool isDark) {
    // Safety check
    if (index >= _passengers.length ||
        index >= _passengerNameControllers.length ||
        index >= _passengerSurnameControllers.length) {
      return SizedBox.shrink();
    }

    final isExpanded = index == _expandedPassengerIndex;
    final passenger = _passengers[index];
    final isFilled = passenger.isFilled;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getCardBg(isDark),
        borderRadius: BorderRadius.circular(16.r),
        border:
            isDark ? Border.all(color: AppColors.darkBorder, width: 1) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          // Card header (clickable)
          InkWell(
            onTap: () => _togglePassengerCard(index),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
            ),
            child: Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isExpanded
                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? AppColors.primaryBlue
                          : AppColors.primaryBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isFilled && !isExpanded
                          ? Icon(
                              Icons.check,
                              color: AppColors.primaryBlue,
                              size: 20.sp,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: isExpanded
                                    ? AppColors.white
                                    : AppColors.primaryBlue,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${'avia.formalization.passenger'.tr()} ${index + 1} (${_getPassengerTypeLabel(index)})',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.getTextColor(isDark),
                                ),
                              ),
                            ),
                            Text(
                              '${_formatPrice(_getPassengerPrice(passenger.passengerType))} ${widget.currency}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        if (isFilled)
                          Text(
                            'avia.formalization.filled'.tr(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.getSubtitleColor(isDark),
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          // Card content (expandable)
          if (isExpanded)
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentPassengerSelectionIndex = index;
                        });
                        context.read<AviaBloc>().add(GetHumansRequested());
                      },
                      icon: Icon(
                        Icons.people_outline,
                        color: AppColors.primaryBlue,
                        size: 20.sp,
                      ),
                      label: Text(
                        'avia.formalization.my_passengers'.tr(),
                        style: TextStyle(color: AppColors.primaryBlue),
                      ),
                    ),
                  ),
                  _buildInputField(
                    controller: _passengerNameControllers[index],
                    label: 'avia.formalization.first_name'.tr(),
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Ism kiritish majburiy";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: AppSpacing.md),
                  _buildInputField(
                    controller: _passengerSurnameControllers[index],
                    label: 'avia.formalization.last_name'.tr(),
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Familiya kiritish majburiy";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: AppSpacing.md),
                  _buildInputField(
                    controller: _passengerPatronymicControllers[index],
                    label: 'avia.formalization.patronymic'.tr(),
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: AppSpacing.md),
                  _buildInputField(
                    controller: _passengerReturnDateControllers[index],
                    label: 'avia.formalization.birth_date'.tr(),
                    icon: Icons.calendar_today_outlined,
                    hintText: 'dd/mm/yyyy',
                    keyboardType: TextInputType.number,
                    inputFormatters: [DateFormatter()],
                    suffixIcon: Icons.calendar_month,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Tug'ilgan sana kiritish majburiy";
                      }
                      // Simple regex check dd/MM/yyyy
                      if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
                        return "Noto'g'ri sana formati";
                      }
                      return null;
                    },
                    // Allow typing, open picker only on icon tap
                    onSuffixIconTap: () => _selectDate(
                      _passengerReturnDateControllers[index],
                      index,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  // Gender selection
                  _buildGenderSelector(index),
                  SizedBox(height: AppSpacing.md),
                  _buildInputField(
                    controller: _passportSeriesControllers[index],
                    label: 'avia.formalization.passport_series'.tr(),
                    icon: Icons.credit_card_outlined,
                    inputFormatters: [PassportFormatter()],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Pasport seriya/raqam majburiy";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: AppSpacing.md),
                  _buildInputField(
                    controller: _passportExpiryControllers[index],
                    label: 'avia.formalization.passport_expiry'.tr(),
                    icon: Icons.calendar_today_outlined,
                    hintText: 'dd/mm/yyyy',
                    keyboardType: TextInputType.number,
                    inputFormatters: [DateFormatter()],
                    suffixIcon: Icons.calendar_month,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Amal qilish muddati majburiy";
                      }
                      if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
                        return "Noto'g'ri sana formati";
                      }
                      return null;
                    },
                    onSuffixIconTap: () =>
                        _selectDate(_passportExpiryControllers[index], index),
                  ),
                  SizedBox(height: AppSpacing.md),
                  _buildInputField(
                    controller: _citizenshipControllers[index],
                    label: 'avia.formalization.citizenship'.tr(),
                    icon: Icons.flag_outlined,
                    readOnly: true,
                    suffixIcon: Icons.arrow_drop_down,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Fuqarolik tanlash majburiy";
                      }
                      return null;
                    },
                    onTap: () {
                      _showCitizenshipPicker(index);
                    },
                  ),
                  SizedBox(height: AppSpacing.md),
                  _buildInputField(
                    controller: _passengerPhoneControllers[index],
                    label: 'Telefon raqami',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [PhoneFormatter()],
                  ),
                  SizedBox(height: AppSpacing.md),
                  // Save passenger info checkbox (matches hotel style)
                  Row(
                    children: [
                      Checkbox(
                        value: _savePassengerInfo[index],
                        onChanged: (value) {
                          setState(() {
                            _savePassengerInfo[index] = value ?? false;
                          });
                        },
                        activeColor: AppColors.primaryBlue,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _savePassengerInfo[index] = !_savePassengerInfo[index];
                            });
                          },
                          child: Text(
                            'avia.formalization.save_passenger_info'.tr(),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.getTextColor(isDark),
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
  }

  Widget _buildSectionTitle(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.getTextColor(isDark),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    String? hintText,
    IconData? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
    VoidCallback? onSuffixIconTap,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      validator: validator,
      // Prevent keyboard from opening when readOnly is true
      enableInteractiveSelection: !readOnly,
      style: TextStyle(color: AppColors.getTextColor(isDark)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.getSubtitleColor(isDark)),
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.getPlaceholderColor(isDark)),
        prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20.sp),
        suffixIcon: suffixIcon != null
            ? (onSuffixIconTap != null
                ? IconButton(
                    icon: Icon(suffixIcon,
                        color: AppColors.getSubtitleColor(isDark)),
                    onPressed: onSuffixIconTap,
                  )
                : Icon(suffixIcon, color: AppColors.getSubtitleColor(isDark)))
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.getBorderColor(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.getBorderColor(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        filled: true,
        fillColor: AppColors.getCardBg(isDark),
      ),
    );
  }

  Widget _buildGenderSelector(int index) {
    return Row(
      children: [
        Expanded(
          child: _buildGenderButton(
            label: 'avia.formalization.male'.tr(),
            isSelected: _selectedGenders[index] == 'Erkak',
            onTap: () {
              setState(() {
                _selectedGenders[index] = 'Erkak';
              });
            },
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildGenderButton(
            label: 'avia.formalization.female'.tr(),
            isSelected: _selectedGenders[index] == 'Ayol',
            onTap: () {
              setState(() {
                _selectedGenders[index] = 'Ayol';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenderButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 16.h,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              : (isDark ? AppColors.darkCardBg : AppColors.grayLight),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : AppColors.getBorderColor(isDark),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppColors.white
                    : AppColors.getSubtitleColor(isDark),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? AppColors.white
                  : AppColors.getSubtitleColor(isDark),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showCitizenshipPicker(int passengerIndex) {
    // Close keyboard before showing bottom sheet
    FocusScope.of(context).unfocus();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.getCardBg(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      // Prevent keyboard from opening when bottom sheet is shown
      isScrollControlled: false,
      enableDrag: true,
      builder: (context) {
        final citizenships = [
          'avia.formalization.uzbekistan'.tr(),
          'avia.formalization.russia'.tr(),
          'avia.formalization.kazakhstan'.tr(),
          'avia.formalization.kyrgyzstan'.tr(),
        ];
        return ListView.builder(
          shrinkWrap: true,
          itemCount: citizenships.length,
          itemBuilder: (context, index) {
            final citizenship = citizenships[index];
            return ListTile(
              title: Text(
                citizenship,
                style: TextStyle(color: AppColors.getTextColor(isDark)),
              ),
              onTap: () {
                setState(() {
                  _citizenshipControllers[passengerIndex].text = citizenship;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _showHumansList(BuildContext context, List<HumanModel> humans) {
    AppLogger.debug('_showHumansList called with ${humans.length} humans');

    if (humans.isEmpty) {
      AppLogger.warning('Humans list is empty');
      SnackbarHelper.showWarning(
        context,
        'avia.formalization.no_passengers_found'.tr(),
      );
      return;
    }

    AppLogger.success('Showing ${humans.length} humans in bottom sheet');

    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.getCardBg(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(
                'avia.formalization.select_passenger'.tr(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(isDark),
                ),
              ),
            ),
            Divider(color: AppColors.getBorderColor(isDark)),
            Expanded(
              child: ListView.builder(
                itemCount: humans.length,
                itemBuilder: (context, index) {
                  final human = humans[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.primaryBlue.withValues(alpha: 0.1),
                      child: Text(
                        human.firstName[0].toUpperCase(),
                        style: TextStyle(color: AppColors.primaryBlue),
                      ),
                    ),
                    title: Text(
                      '${human.lastName} ${human.firstName}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextColor(isDark),
                      ),
                    ),
                    subtitle: Text(
                      human.passportNumber,
                      style: TextStyle(
                        color: AppColors.getSubtitleColor(isDark),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16.sp,
                      color: AppColors.getSubtitleColor(isDark),
                    ),
                    onTap: () {
                      if (_currentPassengerSelectionIndex != null) {
                        _fillPassengerData(
                          _currentPassengerSelectionIndex!,
                          human,
                        );
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Format date from YYYY-MM-DD to DD/MM/YYYY for UI
  String _formatDateForUi(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    // Check YYYY-MM-DD
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateStr)) {
      try {
        final parts = dateStr.split('-');
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      } catch (e) {
        return dateStr;
      }
    }
    return dateStr;
  }

  // Format phone number to match PhoneFormatter format: +998 90 123-45-67
  String _formatPhoneForDisplay(String phone) {
    if (phone.trim().isEmpty) return '+998';

    // Extract only digits
    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // If empty, return default
    if (digitsOnly.isEmpty) return '+998';

    // If 9 digits (without 998), add 998 prefix
    final fullDigits = digitsOnly.length == 9 ? '998$digitsOnly' : digitsOnly;

    // Limit to 12 digits (998 + 9 digits)
    final limitedDigits =
        fullDigits.length > 12 ? fullDigits.substring(0, 12) : fullDigits;

    // If doesn't start with 998, return default
    if (!limitedDigits.startsWith('998')) {
      return '+998';
    }

    // Format: +998 90 123-45-67 (same as PhoneFormatter)
    String formatted = '+';

    // Add country code (998)
    if (limitedDigits.isNotEmpty) {
      final countryCode = limitedDigits.substring(
          0, limitedDigits.length > 3 ? 3 : limitedDigits.length);
      formatted += countryCode;
    }

    // Add operator code (90)
    if (limitedDigits.length > 3) {
      formatted +=
          ' ${limitedDigits.substring(3, limitedDigits.length > 5 ? 5 : limitedDigits.length)}';
    }

    // Add first part (123)
    if (limitedDigits.length > 5) {
      formatted +=
          ' ${limitedDigits.substring(5, limitedDigits.length > 8 ? 8 : limitedDigits.length)}';
    }

    // Add second part (45)
    if (limitedDigits.length > 8) {
      formatted +=
          '-${limitedDigits.substring(8, limitedDigits.length > 10 ? 10 : limitedDigits.length)}';
    }

    // Add third part (67)
    if (limitedDigits.length > 10) {
      formatted +=
          '-${limitedDigits.substring(10, limitedDigits.length > 12 ? 12 : limitedDigits.length)}';
    }

    return formatted;
  }

  void _fillPassengerData(int index, HumanModel human) {
    // Close keyboard before filling data
    FocusScope.of(context).unfocus();

    setState(() {
      _passengerNameControllers[index].text = human.firstName;
      _passengerSurnameControllers[index].text = human.lastName;
      _passengerPatronymicControllers[index].text = human.middleName ?? '';

      // Format dates if needed. HumanModel has String dates.
      _passengerReturnDateControllers[index].text =
          _formatDateForUi(human.birthDate);

      if (human.gender.toLowerCase().contains('m') ||
          human.gender.toLowerCase() == 'male') {
        _selectedGenders[index] = 'Erkak';
      } else {
        _selectedGenders[index] = 'Ayol';
      }

      _passportSeriesControllers[index].text = human.passportNumber;
      _passportExpiryControllers[index].text =
          _formatDateForUi(human.passportExpiry);
      _citizenshipControllers[index].text = human.citizenship;

      // Agar "Mening yo'lovchilarim" dan tanlansa, saqlash tugmasini o'chirib qo'yish (chunki allaqachon saqlangan)
      // Ammo foydalanuvchi o'zgartirib qayta saqlashni xohlashi mumkin, shuning uchun o'zgarmaydi yoki true qoladi.
      // Hozirchalik o'zgarishsiz qoldiramiz.

      // Format phone number to match PhoneFormatter format
      final phoneToFormat = human.phone.trim().isEmpty
          ? '+998'
          : AuthService.normalizeContact(human.phone);
      _passengerPhoneControllers[index].text =
          _formatPhoneForDisplay(phoneToFormat);

      // Update validation state
      _savePassengerData(index);
    });

    // Ensure keyboard stays closed after filling data
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  // Booking muvaffaqiyatli bo'lgandan keyin passenger'larni "My Passengers"ga saqlash
  void _savePassengersToMyList() {
    for (int i = 0; i < _passengers.length; i++) {
      final p = _passengers[i];

      // Agar foydalanuvchi ma'lumotlarni saqlashni xohlamasa, o'tkazib yuborish
      if (!_savePassengerInfo[i]) {
        continue;
      }

      // Ma'lumotlar to'liqligini tekshirish
      if ((p.name.trim().isEmpty) ||
          (p.surname.trim().isEmpty) ||
          (p.passportSeries.trim().isEmpty)) {
        continue; // To'liq bo'lmagan ma'lumotlarni o'tkazib yuborish
      }

      try {
        // Tug'ilgan sana formatini tekshirish
        String birthDate = '';
        final returnDate = p.returnDate?.trim() ?? '';
        if (returnDate.isNotEmpty) {
          try {
            // DD/MM/YYYY formatini YYYY-MM-DD ga o'zgartirish
            final parts = returnDate.split('/');
            if (parts.length == 3) {
              birthDate = '${parts[2]}-${parts[1]}-${parts[0]}';
            } else {
              birthDate = returnDate;
            }
          } catch (e) {
            birthDate = returnDate;
          }
        }

        // Passport muddati formatini tekshirish
        String passportExpiry = '';
        final expiryDate = p.passportExpiry?.trim() ?? '';
        if (expiryDate.isNotEmpty) {
          try {
            // DD/MM/YYYY formatini YYYY-MM-DD ga o'zgartirish
            final parts = expiryDate.split('/');
            if (parts.length == 3) {
              passportExpiry = '${parts[2]}-${parts[1]}-${parts[0]}';
            } else {
              passportExpiry = expiryDate;
            }
          } catch (e) {
            passportExpiry = expiryDate;
          }
        }

        // Citizenship mapping
        String mapCitizenship(String? citizenship) {
          if (citizenship == null || citizenship.isEmpty) return 'UZ';
          if (citizenship.length == 2) return citizenship.toUpperCase();

          final citizenshipMap = {
            'avia.formalization.uzbekistan': 'UZ',
            'O\'zbekiston': 'UZ',
            'Uzbekistan': 'UZ',
            'avia.formalization.russia': 'RU',
            'Rossiya': 'RU',
            'Russia': 'RU',
            'avia.formalization.kazakhstan': 'KZ',
            'Qozog\'iston': 'KZ',
            'Kazakhstan': 'KZ',
            'avia.formalization.kyrgyzstan': 'KG',
            'Qirg\'iziston': 'KG',
            'Kyrgyzstan': 'KG',
          };

          return citizenshipMap[citizenship] ?? 'UZ';
        }

        // HumanModel yaratish
        final human = HumanModel(
          firstName: p.name.trim(),
          lastName: p.surname.trim(),
          middleName: p.patronymic.trim().isEmpty ? null : p.patronymic.trim(),
          birthDate: birthDate,
          gender: p.gender == 'Erkak' ? 'M' : 'F',
          citizenship: mapCitizenship(p.citizenship),
          passportNumber: p.passportSeries.replaceAll(' ', ''),
          passportExpiry: passportExpiry,
          phone: _normalizePhoneForApi(p.phone),
        );

        // API'ga yuborish (background'da, xatolikni ko'rsatmasdan)
        // Bu asinxron ishlaydi, shuning uchun booking page'ga o'tishni kutmaydi
        context.read<AviaBloc>().add(CreateHumanRequested(human));
      } catch (e) {
        // Xatolik bo'lsa, o'tkazib yuborish (passenger saqlash booking'ni to'xtatmasligi kerak)
        AppLogger.warning('Passenger saqlashda xatolik: $e');
      }
    }
  }
}
