import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/input_formatters.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../../../../core/dio/singletons/service_locator.dart';
import '../../../../features/register/domain/usecases/get_profile.dart';
import '../../../../features/register/domain/entities/user_profile.dart';
import '../../../../features/avichiptalar/presentation/bloc/avia_bloc.dart';
import '../../../../features/avichiptalar/data/models/human_model.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/entities/hotel_booking.dart';
import '../../domain/entities/reference_data.dart';
import '../bloc/hotel_bloc.dart';
import 'hotel_success_page.dart';
import 'hotel_booking_summary_page.dart';

class HotelBookingPage extends StatefulWidget {
  final Hotel hotel;
  final HotelOption? selectedOption;
  final String? quoteId; // Quote ID from previous step
  final int roomCount; // Tanlangan xona soni

  const HotelBookingPage({
    Key? key,
    required this.hotel,
    this.selectedOption,
    this.quoteId,
    this.roomCount = 1, // Default 1 xona
  }) : super(key: key);

  @override
  State<HotelBookingPage> createState() => _HotelBookingPageState();
}

class _HotelBookingPageState extends State<HotelBookingPage> {
  final _formKey = GlobalKey<FormState>();

  // Contact Information
  final _contactNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  // Main Guest Information
  String? _personTitle; // MR, MRS, MS
  String? _nationality; // uz, ru, kz, us
  final _guestFirstNameController = TextEditingController();
  final _guestLastNameController = TextEditingController();
  bool _saveGuestInfo = false;
  int _adultCount = 1;

  // Special Requests
  final _commentsController = TextEditingController();

  // Privacy
  bool _agreedToPrivacy = false;

  int _selectedPaymentMethod = 1;
  String? _quoteId;
  bool _isLoading = false;
  List<RoomType> _roomTypes = [];
  HotelOption? _quoteOption; // Quote'dan olingan yangi option ma'lumotlari

  @override
  void initState() {
    super.initState();
    _quoteId = widget.quoteId;
    // Initialize phone with +998 prefix
    _contactPhoneController.text = '+998';
    // If no quoteId, get quote first
    if (_quoteId == null && widget.selectedOption != null) {
      _getQuote();
    }
    // Load user data to auto-fill form
    _loadUserData();
    // Load room types for displaying room type name
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<HotelBloc>()
          .add(GetHotelRoomTypesRequested(widget.hotel.hotelId));
    });
  }

  /// Build body with AviaBloc provider if available
  Widget _buildBodyWithAviaBloc() {
    // Try to get existing AviaBloc, or create one via ServiceLocator
    AviaBloc? aviaBloc;
    try {
      aviaBloc = context.read<AviaBloc>();
    } catch (_) {
      // AviaBloc not available in context, create one via ServiceLocator
      try {
        aviaBloc = ServiceLocator.resolve<AviaBloc>();
      } catch (e) {
        AppLogger.warning('AviaBloc not available via ServiceLocator', e);
        // Continue without AviaBloc - it's optional for hotel booking
      }
    }

    final listeners = <BlocListener>[
      BlocListener<HotelBloc, HotelState>(
        listener: (context, state) {
          if (state is HotelQuoteSuccess) {
            setState(() {
              _quoteId = state.quote.quoteId;
              _isLoading = false;
              // Quote'dan olingan yangi option ma'lumotlarini saqlash
              if (state.quote.hotel.options != null &&
                  state.quote.hotel.options!.isNotEmpty) {
                // Tanlangan optionRefId ga mos option'ni topish
                if (widget.selectedOption != null) {
                  _quoteOption = state.quote.hotel.options!.firstWhere(
                    (opt) =>
                        opt.optionRefId == widget.selectedOption!.optionRefId,
                    orElse: () => state.quote.hotel.options!.first,
                  );
                } else {
                  _quoteOption = state.quote.hotel.options!.first;
                }
              }
            });
          } else if (state is HotelQuoteFailure) {
            setState(() => _isLoading = false);
            SnackbarHelper.showError(context, state.message);
            // Show retry option
            if (mounted && widget.selectedOption != null) {
              _showQuoteRetryDialog(context);
            }
          } else if (state is HotelRoomTypesSuccess) {
            setState(() {
              _roomTypes = state.roomTypes;
            });
          } else if (state is HotelBookingCreateSuccess) {
            // After creating booking, confirm it
            _confirmBooking(state.booking.bookingId);
          } else if (state is HotelBookingCreateFailure) {
            setState(() => _isLoading = false);
            SnackbarHelper.showError(context, state.message);
          } else if (state is HotelBookingConfirmSuccess) {
            // Navigate to success page
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HotelSuccessPage(
                  booking: state.booking,
                ),
              ),
            );
          } else if (state is HotelBookingConfirmFailure) {
            setState(() => _isLoading = false);
            SnackbarHelper.showError(context, state.message);
          }
        },
      ),
    ];

    // Add AviaBloc listener only if AviaBloc is available
    if (aviaBloc != null) {
      listeners.add(
        BlocListener<AviaBloc, AviaState>(
          bloc: aviaBloc,
          listener: (context, state) {
            if (state is AviaGetHumansSuccess) {
              _showHumansList(context, state.humans);
            } else if (state is AviaGetHumansFailure) {
              SnackbarHelper.showError(context, state.message);
            } else if (state is AviaCreateHumanSuccess) {
              // Show success message when passenger is saved
              SnackbarHelper.showSuccess(
                context,
                'avia.formalization.passenger_saved'.tr(),
              );
              // Optionally refresh the list
              if (aviaBloc != null) {
                aviaBloc.add(GetHumansRequested());
              }
            } else if (state is AviaCreateHumanFailure) {
              SnackbarHelper.showError(context, state.message);
            }
          },
        ),
      );
    }

    // Get the actual body content - we'll use the existing build method's content
    // Get the actual body content
    Widget bodyWidget = BlocBuilder<HotelBloc, HotelState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hotel Info Summary Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hotel Name
                      Text(
                        widget.hotel.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      // Dates
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14.sp, color: Colors.grey),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              '${DateFormat('dd MMM yyyy').format(widget.hotel.checkInDate)} - ${DateFormat('dd MMM yyyy').format(widget.hotel.checkOutDate)}',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                        if (widget.selectedOption != null ||
                          _quoteOption != null) ...[
                        SizedBox(height: 12.h),
                        Divider(color: Theme.of(context).dividerColor),
                        SizedBox(height: 10.h),
                        // Room Type Name
                        Row(
                          children: [
                            Icon(Icons.bed,
                                size: 16.sp,
                                color: Theme.of(context).colorScheme.primary),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'hotel.details.room_type'.tr(),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                _getRoomTypeName(),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                                textAlign: TextAlign.end,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        // Meal Plan
                        if ((_quoteOption?.includedMealOptions ??
                                    widget
                                        .selectedOption?.includedMealOptions) !=
                                null &&
                            (_quoteOption?.includedMealOptions ??
                                    widget.selectedOption?.includedMealOptions)!
                                .isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Icon(Icons.restaurant,
                                  size: 16.sp,
                                  color: Theme.of(context).colorScheme.primary),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'hotel.summary.meal_plan'.tr(),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  (_quoteOption?.includedMealOptions ??
                                          widget.selectedOption
                                              ?.includedMealOptions)!
                                      .join(', '),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                  textAlign: TextAlign.end,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: 6.h),
                        // Room Count
                        Row(
                          children: [
                            Icon(Icons.hotel,
                                size: 16.sp,
                                color: Theme.of(context).colorScheme.primary),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'hotel.details.room'.tr(),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                ),
                              ),
                            ),
                            Text(
                              '${widget.roomCount} ${'hotel.details.room'.tr()}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        // Nights
                        Row(
                          children: [
                            Icon(Icons.nightlight_round,
                                size: 16.sp,
                                color: Theme.of(context).colorScheme.primary),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'hotel.details.nights'.tr(),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                ),
                              ),
                            ),
                            Builder(
                              builder: (context) {
                                int totalNights = widget.hotel.checkOutDate
                                    .difference(widget.hotel.checkInDate)
                                    .inDays;
                                if (totalNights <= 0) totalNights = 1;
                                return Text(
                                  '$totalNights ${'hotel.details.nights'.tr()}',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Divider(color: Theme.of(context).dividerColor),
                        SizedBox(height: 10.h),
                        // Total Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'hotel.details.total_amount'.tr(),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.color,
                              ),
                            ),
                            Builder(
                              builder: (context) {
                                int totalNights = widget.hotel.checkOutDate
                                    .difference(widget.hotel.checkInDate)
                                    .inDays;
                                if (totalNights <= 0) totalNights = 1;
                                // Quote'dan olingan narxni ishlatish, agar mavjud bo'lsa
                                final option =
                                    _quoteOption ?? widget.selectedOption;
                                final price = option?.price ?? 0;
                                // Xona sonini hisobga olish
                                final totalPrice =
                                    price * widget.roomCount * totalNights;
                                final currency =
                                    (option?.currency ?? 'uzs').toLowerCase();
                                return Text(
                                  NumberFormat.currency(
                                    locale: 'uz_UZ',
                                    symbol: currency == 'uzs'
                                        ? 'so\'m'
                                        : currency.toUpperCase(),
                                    decimalDigits: 0,
                                  ).format(totalPrice),
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                // Contact Information Card
                _buildCard(
                  title: 'hotel.guest_details.contact_info'.tr(),
                  icon: Icons.contact_mail,
                  child: Column(
                    children: [
                      _buildTextField(
                        label: 'hotel.guest_details.name'.tr(),
                        icon: Icons.person,
                        controller: _contactNameController,
                        isRequired: false,
                      ),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        label: 'hotel.guest_details.email'.tr(),
                        icon: Icons.email,
                        controller: _contactEmailController,
                        hint: 'hotel.guest_details.email_hint'.tr(),
                        keyboardType: TextInputType.emailAddress,
                        isRequired: true,
                        requiredMessage: 'Emailni to‘ldiring',
                      ),
                      SizedBox(height: 12.h),
                      _buildPhoneTextField(
                        label: 'hotel.guest_details.phone'.tr(),
                        controller: _contactPhoneController,
                        isRequired: false,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                // Main Guest Card
                _buildCard(
                  title: 'hotel.guest_details.main_guest'.tr(),
                  icon: Icons.person_outline,
                  child: Column(
                    children: [
                      // Mening yo'lovchilarim button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            try {
                              try {
                                final bloc = context.read<AviaBloc>();
                                bloc.add(GetHumansRequested());
                              } catch (_) {
                                try {
                                  final bloc =
                                      ServiceLocator.resolve<AviaBloc>();
                                  bloc.add(GetHumansRequested());
                                } catch (e2) {
                                  AppLogger.warning(
                                      'AviaBloc not available', e2);
                                  SnackbarHelper.showError(
                                    context,
                                    'hotel.guest_details.load_error'.tr(),
                                  );
                                }
                              }
                            } catch (e) {
                              AppLogger.warning('AviaBloc not available', e);
                              SnackbarHelper.showError(
                                context,
                                'hotel.guest_details.load_error'.tr(),
                              );
                            }
                          },
                          icon: Icon(
                            Icons.people_outline,
                            color: Colors.blue,
                            size: 18.sp,
                          ),
                          label: Text(
                            'avia.formalization.my_passengers'.tr(),
                            style:
                                TextStyle(color: Colors.blue, fontSize: 13.sp),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      // Title, Nationality, First Name, Last Name, etc.
                      _buildDropdownField(
                        label: 'hotel.guest_details.title_label'.tr(),
                        value: _personTitle,
                        items: [
                          DropdownMenuItem(
                              value: 'MR',
                              child: Text('hotel.guest_details.title_mr'.tr())),
                          DropdownMenuItem(
                              value: 'MRS',
                              child:
                                  Text('hotel.guest_details.title_mrs'.tr())),
                        ],
                        hint: 'hotel.guest_details.select_title'.tr(),
                        onChanged: (value) =>
                            setState(() => _personTitle = value),
                        isRequired: true,
                      ),
                      SizedBox(height: 12.h),
                      _buildDropdownField(
                        label: 'hotel.guest_details.nationality'.tr(),
                        value: _nationality,
                        items: [
                          DropdownMenuItem(
                              value: 'uz',
                              child: Text(
                                  'hotel.guest_details.nationality_uz'.tr())),
                          DropdownMenuItem(
                              value: 'ru',
                              child: Text(
                                  'hotel.guest_details.nationality_ru'.tr())),
                          DropdownMenuItem(
                              value: 'kz',
                              child: Text(
                                  'hotel.guest_details.nationality_kz'.tr())),
                          DropdownMenuItem(
                              value: 'us',
                              child: Text(
                                  'hotel.guest_details.nationality_us'.tr())),
                        ],
                        hint: 'hotel.guest_details.select_nationality'.tr(),
                        onChanged: (value) =>
                            setState(() => _nationality = value),
                        isRequired: true,
                      ),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        label: 'hotel.guest_details.first_name'.tr(),
                        icon: Icons.person_outline,
                        controller: _guestFirstNameController,
                        hint: 'hotel.guest_details.first_name_hint'.tr(),
                        isRequired: true,
                      ),
                      SizedBox(height: 12.h),
                      _buildTextField(
                        label: 'hotel.guest_details.last_name'.tr(),
                        icon: Icons.person_outline,
                        controller: _guestLastNameController,
                        hint: 'hotel.guest_details.last_name_hint'.tr(),
                        isRequired: true,
                      ),
                      SizedBox(height: 12.h),
                      // Save guest info checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _saveGuestInfo,
                            onChanged: (value) =>
                                setState(() => _saveGuestInfo = value ?? false),
                            activeColor: Colors.blue,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(
                                  () => _saveGuestInfo = !_saveGuestInfo),
                              child: Text(
                                'hotel.guest_details.save_guest_info'.tr(),
                                style: TextStyle(fontSize: 13.sp),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                // Comments Card (without special requests title)
                _buildCard(
                  title: 'hotel.guest_details.comments'.tr(),
                  icon: Icons.note_outlined,
                  child: _buildTextArea(
                    controller: _commentsController,
                    hint: 'hotel.guest_details.comments_hint'.tr(),
                    maxLength: 500,
                    isRequired: true,
                    requiredMessage: 'Fikringizni bildiring, bu biz uchun muhim',
                  ),
                  isSmall: true,
                ),
                SizedBox(height: 20.h),
                // Privacy Policy Checkbox - moved to bottom
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _agreedToPrivacy,
                        onChanged: (value) =>
                            setState(() => _agreedToPrivacy = value ?? false),
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(
                              () => _agreedToPrivacy = !_agreedToPrivacy),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      'hotel.guest_details.privacy_prefix'.tr(),
                                ),
                                TextSpan(
                                  text: 'hotel.guest_details.privacy_link'.tr(),
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _openPrivacyPolicy(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );

    // Wrap with AviaBloc provider if available
    if (aviaBloc != null) {
      bodyWidget = BlocProvider<AviaBloc>.value(
        value: aviaBloc,
        child: bodyWidget,
      );
    }

    return MultiBlocListener(
      listeners: listeners,
      child: bodyWidget,
    );
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _guestFirstNameController.dispose();
    _guestLastNameController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _getQuote() async {
    if (widget.selectedOption == null ||
        widget.selectedOption!.optionRefId.isEmpty) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          'hotel.booking.option_not_found'.tr(),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      context.read<HotelBloc>().add(
            GetQuoteRequested([widget.selectedOption!.optionRefId]),
          );
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SnackbarHelper.showError(
          context,
          'hotel.booking.quote_error'.tr(),
        );
      }
    }
  }

  /// Load logged-in user data into form fields
  Future<void> _loadUserData() async {
    try {
      final authService = AuthService.instance;
      final user = await authService.fetchActiveUser();

      // Only load data if user exists and widget is mounted
      if (user != null && mounted) {
        // Load profile to get email and phone separately
        UserProfile? profile;
        try {
          final getProfile = ServiceLocator.resolve<GetProfile>();
          profile = await getProfile();
        } catch (e) {
          // If profile fails to load, use contact only
          AppLogger.warning('Failed to load profile, using contact only', e);
        }

        setState(() {
          // Fill contact name if empty
          if (_contactNameController.text.trim().isEmpty) {
            _contactNameController.text = user.fullName;
          }

          final currentEmail = _contactEmailController.text.trim();
          final currentPhone = _contactPhoneController.text.trim();

          // Fill email field (from user.email, profile.email, or user.contact)
          if (currentEmail.isEmpty) {
            if (user.email != null && user.email!.isNotEmpty) {
              _contactEmailController.text = user.email!;
            } else if (profile?.email != null && profile!.email!.isNotEmpty) {
              _contactEmailController.text = profile.email!;
            } else if (user.contact.contains('@')) {
              _contactEmailController.text = user.contact;
            }
          }

          // Fill phone field (from user.phone, profile.phone, or user.contact)
          if (currentPhone.isEmpty || currentPhone == '+998') {
            String? phoneToSet;
            if (user.phone != null && user.phone!.isNotEmpty) {
              final normalizedPhone = AuthService.normalizeContact(user.phone!);
              phoneToSet = _formatPhoneForDisplay(normalizedPhone);
            } else if (profile?.phone != null && profile!.phone!.isNotEmpty) {
              final normalizedPhone =
                  AuthService.normalizeContact(profile.phone!);
              phoneToSet = _formatPhoneForDisplay(normalizedPhone);
            } else if (!user.contact.contains('@')) {
              final normalizedPhone =
                  AuthService.normalizeContact(user.contact);
              phoneToSet = _formatPhoneForDisplay(normalizedPhone);
            }

            if (phoneToSet != null &&
                phoneToSet.isNotEmpty &&
                phoneToSet != '+998') {
              _contactPhoneController.text = phoneToSet;
            } else {
              _contactPhoneController.text = '+998';
            }
          }

          // Fill guest first name if empty
          if (_guestFirstNameController.text.trim().isEmpty) {
            _guestFirstNameController.text = user.firstName;
          }

          // Fill guest last name if empty
          if (_guestLastNameController.text.trim().isEmpty) {
            _guestLastNameController.text = user.lastName;
          }
        });
      }
    } catch (e) {
      // Continue even if error occurs - login is not required
      AppLogger.warning('Failed to load user data', e);
    }
  }

  /// Format phone number for display using PhoneFormatter format
  String _formatPhoneForDisplay(String phone) {
    if (phone.isEmpty || phone == '+998') return '+998';

    // Remove all non-digits except +
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty || digitsOnly == '998') return '+998';

    // Apply PhoneFormatter logic
    final limitedDigits =
        digitsOnly.length > 12 ? digitsOnly.substring(0, 12) : digitsOnly;

    String formatted = '+';

    // Add country code (998)
    if (limitedDigits.isNotEmpty) {
      final countryCode = limitedDigits.substring(
          0, limitedDigits.length > 3 ? 3 : limitedDigits.length);
      formatted += countryCode;
    }

    // Add operator code (99)
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

  void _proceedToSummary() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToPrivacy) {
      SnackbarHelper.showError(
        context,
        'hotel.guest_details.privacy_required'.tr(),
      );
      return;
    }
    if (_personTitle == null || _nationality == null) {
      SnackbarHelper.showError(
        context,
        'hotel.guest_details.fill_all_fields'.tr(),
      );
      return;
    }

    // Require email + comment per UX requirement
    if (_contactEmailController.text.trim().isEmpty) {
      SnackbarHelper.showError(context, 'Emailni to‘ldiring');
      return;
    }
    if (_commentsController.text.trim().isEmpty) {
      SnackbarHelper.showError(
        context,
        'Fikringizni bildiring, bu biz uchun muhim',
      );
      return;
    }

    // Save guest information if checkbox is checked
    if (_saveGuestInfo) {
      _saveGuestToMyList();
    }

    // Validate quoteId before navigation
    if (_quoteId == null || _quoteId!.isEmpty) {
      SnackbarHelper.showError(
        context,
        'hotel.booking.quote_not_found'.tr(),
      );
      // Try to get quote again if option is available
      if (widget.selectedOption != null && !_isLoading) {
        setState(() => _isLoading = true);
        _getQuote();
      }
      return;
    }

    // Navigate to summary page
    final hotelBloc = context.read<HotelBloc>();
    // Use quote option if available, otherwise use selectedOption
    final optionToUse = _quoteOption ?? widget.selectedOption;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: hotelBloc,
          child: HotelBookingSummaryPage(
            hotel: widget.hotel,
            selectedOption: optionToUse,
            quoteId: _quoteId,
            personTitle: _personTitle,
            firstName: _guestFirstNameController.text.trim(),
            lastName: _guestLastNameController.text.trim(),
            nationality: _nationality,
            contactName: _contactNameController.text.trim(),
            contactEmail: _contactEmailController.text.trim(),
            contactPhone: _contactPhoneController.text.trim(),
            adultCount: _adultCount,
            roomCount: widget.roomCount,
            comment: _commentsController.text.trim(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text(
          'hotel.guest_details.title'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        centerTitle: true,
      ),
      body: _buildBodyWithAviaBloc(),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _proceedToSummary,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'hotel.guest_details.proceed_to_summary'.tr(),
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
    bool isSmall = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 10.w : 12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: isSmall ? 16.sp : 18.sp, color: Theme.of(context).colorScheme.primary),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmall ? 13.sp : 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmall ? 10.h : 12.h),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool isRequired = false,
    String? requiredMessage,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(fontSize: 13.sp),
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        labelStyle: TextStyle(fontSize: 13.sp),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13.sp),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return requiredMessage ??
                    'hotel.guest_details.fill_all_fields'.tr();
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildPhoneTextField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
  }) {
    // Ensure +998 is set initially
    if (controller.text.isEmpty || !controller.text.startsWith('+998')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.text.isEmpty || !controller.text.startsWith('+998')) {
          controller.text = '+998';
          // Ensure selection is valid (not zero length)
          if (controller.text.length >= 4) {
            controller.selection = TextSelection.collapsed(offset: 4);
          }
        }
      });
    }

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      maxLength: 17, // +998 99 123-45-67
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
        PhoneFormatter(),
      ],
      onChanged: (value) {
        // Ensure +998 is always present
        if (!value.startsWith('+998')) {
          if (value.isEmpty) {
            controller.text = '+998';
            // Ensure selection is valid (not zero length)
            if (controller.text.length >= 4) {
              controller.selection = TextSelection.collapsed(offset: 4);
            }
          } else if (value.startsWith('998')) {
            controller.text = '+$value';
            // Ensure selection is valid (not zero length)
            final selectionOffset = controller.text.length;
            if (selectionOffset > 0) {
              controller.selection =
                  TextSelection.collapsed(offset: selectionOffset);
            }
          } else {
            // Remove all non-digits, add +998 prefix
            final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
            if (digitsOnly.isNotEmpty) {
              controller.text = '+998$digitsOnly';
              // Apply formatter
              final formatted = PhoneFormatter().formatEditUpdate(
                TextEditingValue(text: controller.text),
                TextEditingValue(text: controller.text),
              );
              if (formatted.text.isNotEmpty) {
                controller.text = formatted.text;
                // Ensure selection is valid (not zero length)
                final selectionOffset = formatted.text.length;
                if (selectionOffset > 0 &&
                    selectionOffset <= formatted.text.length) {
                  controller.selection =
                      TextSelection.collapsed(offset: selectionOffset);
                } else if (controller.text.isNotEmpty) {
                  controller.selection =
                      TextSelection.collapsed(offset: controller.text.length);
                }
              }
            }
          }
        }
      },
      style: TextStyle(fontSize: 13.sp),
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        labelStyle: TextStyle(fontSize: 13.sp),
        hintText: 'hotel.guest_details.phone_hint'.tr(),
        hintStyle: TextStyle(fontSize: 13.sp),
        prefixIcon: Icon(Icons.phone, color: Colors.grey, size: 20.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        counterText: '',
      ),
      validator: isRequired
          ? (value) {
              if (value == null ||
                  value.trim().isEmpty ||
                  value.trim() == '+998') {
                return 'hotel.guest_details.fill_all_fields'.tr();
              }
              // Validate phone format: +998 99 123-45-67 (17 chars)
              final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
              if (digitsOnly.length < 12) {
                return 'hotel.guest_details.fill_all_fields'.tr();
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required String hint,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final fieldFillColor = cs.surface; // adapts for light/dark
    final borderColor = theme.dividerColor.withOpacity(isDark ? 0.35 : 0.5);
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: double.infinity,
        child: DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          style: TextStyle(
            fontSize: 13.sp,
            color: value != null
                ? cs.primary
                : theme.textTheme.bodyLarge?.color ?? cs.onSurface,
            fontWeight: value != null ? FontWeight.w600 : FontWeight.normal,
          ),
          dropdownColor: fieldFillColor,
          icon: Icon(
            Icons.arrow_drop_down,
            color: theme.iconTheme.color?.withOpacity(0.8) ??
                cs.onSurface.withOpacity(0.7),
            size: 20.sp,
          ),
          menuMaxHeight: 300.h,
          borderRadius: BorderRadius.circular(12.r),
          decoration: InputDecoration(
            labelText: label + (isRequired ? ' *' : ''),
            labelStyle: TextStyle(
              fontSize: 13.sp,
              color: theme.textTheme.bodyMedium?.color ?? cs.onSurface,
            ),
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13.sp,
              color: (theme.textTheme.bodyMedium?.color ?? cs.onSurface)
                  .withOpacity(0.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: cs.primary, width: 2),
            ),
            filled: true,
            fillColor: fieldFillColor,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          ),
          selectedItemBuilder: (BuildContext context) {
            return items.map<Widget>((DropdownMenuItem<String> item) {
              // Extract text from child widget for selected display
              String itemText = '';
              if (item.child is Text) {
                itemText = (item.child as Text).data ?? '';
              } else {
                itemText = item.value ?? '';
              }
              return Text(
                itemText,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              );
            }).toList();
          },
          items: items.map((item) {
            final isSelected = item.value == value;
            // Extract text from child widget
            String itemText = '';
            if (item.child is Text) {
              itemText = (item.child as Text).data ?? '';
            } else {
              // Fallback: try to get text from widget
              itemText = item.value ?? '';
            }
            return DropdownMenuItem<String>(
              value: item.value,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cs.primary.withOpacity(isDark ? 0.18 : 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                  border: isSelected
                      ? Border.all(color: cs.primary.withOpacity(0.85), width: 2)
                      : Border.all(color: Colors.transparent, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        itemText,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isSelected
                              ? cs.primary
                              : theme.textTheme.bodyLarge?.color ??
                                  cs.onSurface,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'hotel.guest_details.fill_all_fields'.tr();
                  }
                  return null;
                }
              : null,
        ),
      ),
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String hint,
    int maxLength = 500,
    bool isRequired = false,
    String? requiredMessage,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      maxLength: maxLength,
      style: TextStyle(fontSize: 13.sp),
      decoration: InputDecoration(
        labelText: null,
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: EdgeInsets.all(12.w),
        counterText: '${controller.text.length}/$maxLength',
        counterStyle: TextStyle(fontSize: 11.sp),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return requiredMessage ??
                    'hotel.guest_details.fill_all_fields'.tr();
              }
              return null;
            }
          : null,
    );
  }

  Future<void> _openPrivacyPolicy() async {
    const url =
        'https://docs.google.com/document/d/1UcdZv5QTRs2AheZlvroe0d86Dk2oILYB4R41Rp2pocE/view';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
            context, 'hotel.guest_details.privacy_error'.tr());
      }
    }
  }

  /// Show list of saved guests
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

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'avia.formalization.select_passenger'.tr(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color ??
                      Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Divider(color: Theme.of(context).dividerColor),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: humans.length,
                itemBuilder: (context, index) {
                  final human = humans[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: Text(
                        human.firstName.isNotEmpty
                            ? human.firstName[0].toUpperCase()
                            : '?',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    title: Text(
                      '${human.lastName} ${human.firstName}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleMedium?.color ??
                            Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      human.passportNumber,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color ??
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16.sp,
                      color: Theme.of(context).iconTheme.color ??
                          Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                    ),
                    onTap: () {
                      _fillGuestData(human);
                      Navigator.pop(context);
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

  /// Fill guest data from selected human
  void _fillGuestData(HumanModel human) {
    // Close keyboard before filling data
    FocusScope.of(context).unfocus();

    setState(() {
      _guestFirstNameController.text = human.firstName;
      _guestLastNameController.text = human.lastName;

      // Fill contact phone if passenger has phone and contact phone is empty or default
      if (human.phone.isNotEmpty && 
          (_contactPhoneController.text.trim().isEmpty || 
           _contactPhoneController.text.trim() == '+998')) {
        _contactPhoneController.text = _formatPhoneForDisplay(human.phone);
      }

      // Map gender
      if (human.gender.toLowerCase().contains('m') ||
          human.gender.toLowerCase() == 'male') {
        _personTitle = 'MR';
      } else {
        _personTitle = 'MRS';
      }

      // Map citizenship to nationality
      final citizenshipMap = {
        'UZ': 'uz',
        'RU': 'ru',
        'KZ': 'kz',
        'US': 'us',
        'KG': 'uz', // Default to uz if not found
      };
      _nationality = citizenshipMap[human.citizenship.toUpperCase()] ?? 'uz';
      
      // Do not auto-enable saving; user decides explicitly via checkbox
      _saveGuestInfo = false;
    });
    // Do not auto-save selected person; saving is user-controlled via checkbox
  }

  /// Save guest information to saved list
  void _saveGuestToMyList() {
    // Check if data is complete
    if (_guestFirstNameController.text.trim().isEmpty ||
        _guestLastNameController.text.trim().isEmpty) {
      return; // Don't save incomplete data
    }

    try {
      // Map nationality to citizenship
      final nationalityMap = {
        'uz': 'UZ',
        'ru': 'RU',
        'kz': 'KZ',
        'us': 'US',
      };
      final citizenship = nationalityMap[_nationality] ?? 'UZ';

      // Map title to gender
      final gender = _personTitle == 'MR' ? 'M' : 'F';

      // Create HumanModel
      final human = HumanModel(
        firstName: _guestFirstNameController.text.trim(),
        lastName: _guestLastNameController.text.trim(),
        middleName: null,
        birthDate: '', // Hotel booking doesn't require birth date
        gender: gender,
        citizenship: citizenship,
        passportNumber: '', // Hotel booking doesn't require passport
        passportExpiry: '',
        phone: _normalizePhoneForApi(_contactPhoneController.text),
      );

      // Save to API (background, don't block booking)
      // Try to get AviaBloc from context, or create via ServiceLocator
      try {
        final aviaBloc = context.read<AviaBloc>();
        aviaBloc.add(CreateHumanRequested(human));
      } catch (_) {
        // AviaBloc not available in context, try ServiceLocator
        try {
          final aviaBloc = ServiceLocator.resolve<AviaBloc>();
          aviaBloc.add(CreateHumanRequested(human));
        } catch (e) {
          AppLogger.warning(
              'Failed to save guest info: AviaBloc not available', e);
          // Don't show error to user - saving is optional
        }
      }
    } catch (e) {
      AppLogger.warning('Error saving guest info: $e');
      // Don't show error to user - saving is optional
    }
  }

  /// Normalize phone number for API
  String _normalizePhoneForApi(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return '';
    if (digitsOnly.startsWith('998')) {
      return '+$digitsOnly';
    }
    return '+998$digitsOnly';
  }

  /// Get room type name from roomTypes list
  String _getRoomTypeName() {
    // Quote'dan olingan option'ni ishlatish, agar mavjud bo'lsa
    final option = _quoteOption ?? widget.selectedOption;
    if (option?.roomTypeId == null) {
      return 'hotel.details.room'.tr();
    }

    if (_roomTypes.isEmpty) {
      return '${'hotel.details.room'.tr()} #${option!.roomTypeId}';
    }

    try {
      final matching = _roomTypes.firstWhere(
        (rt) => rt.id == option!.roomTypeId,
      );
      // Safe locale extraction with fallback
      Locale locale;
      try {
        locale = context.locale;
      } catch (e) {
        // Fallback to default locale if context.locale fails
        locale = const Locale('uz');
      }
      final normalizedLocale = _normalizeLocale(locale);
      return matching.getDisplayName(normalizedLocale);
    } catch (e) {
      // Room type not found, return fallback
      return '${'hotel.details.room'.tr()} #${option!.roomTypeId}';
    }
  }

  /// Normalize locale for API
  String _normalizeLocale(Locale locale) {
    try {
      // Handle Cyrillic Uzbek specially
      if (locale.languageCode == 'uz' && locale.countryCode == 'CYR') {
        return 'uz_CYR'; // API format
      }

      // For other locales, use just the language code
      // en_US -> en, ru_RU -> ru, uz -> uz
      return locale.languageCode.isNotEmpty ? locale.languageCode : 'uz';
    } catch (e) {
      // Fallback to default locale if error occurs
      return 'uz';
    }
  }

  void _confirmBooking(String bookingId) {
    // Generate unique transaction ID similar to avia format
    final random = DateTime.now().millisecondsSinceEpoch % 10000000;
    final transactionId = 'hotel${random.toString().padLeft(7, '0')}';

    final paymentInfo = PaymentInfo(
      paymentMethod: 'multicard', // Multicard to'lov tizimi (avia kabi)
      transactionId: transactionId,
    );

    context.read<HotelBloc>().add(
          ConfirmBookingRequested(
            bookingId: bookingId,
            paymentInfo: paymentInfo,
          ),
        );
  }

  /// Show retry dialog for quote failure
  void _showQuoteRetryDialog(BuildContext context) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('hotel.booking.quote_failed_title'.tr()),
        content: Text('hotel.booking.quote_failed_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('hotel.common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (mounted) {
                _getQuote();
              }
            },
            child: Text('hotel.common.retry'.tr()),
          ),
        ],
      ),
    );
  }
}
