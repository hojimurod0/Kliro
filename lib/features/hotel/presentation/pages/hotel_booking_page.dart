import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/widgets/safe_network_image.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/entities/hotel_booking.dart';
import '../../domain/entities/reference_data.dart';
import '../bloc/hotel_bloc.dart';
import 'hotel_success_page.dart';

class HotelBookingPage extends StatefulWidget {
  final Hotel hotel;
  final HotelOption? selectedOption;
  final String? quoteId; // Quote ID from previous step

  const HotelBookingPage({
    Key? key,
    required this.hotel,
    this.selectedOption,
    this.quoteId,
  }) : super(key: key);

  @override
  State<HotelBookingPage> createState() => _HotelBookingPageState();
}

class _HotelBookingPageState extends State<HotelBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  int _selectedPaymentMethod = 1; // 1: Payme, 2: Oson
  String? _quoteId;
  bool _isLoading = false;
  
  // Cached data
  List<RoomType> _cachedRoomTypes = [];
  List<Equipment> _cachedEquipment = [];
  List<HotelPhoto> _cachedRoomPhotos = [];
  
  bool _isLoadingRoomTypes = false;
  bool _isLoadingEquipment = false;
  bool _isLoadingRoomPhotos = false;

  @override
  void initState() {
    super.initState();
    _quoteId = widget.quoteId;
    // If no quoteId, get quote first
    if (_quoteId == null && widget.selectedOption != null) {
      _getQuote();
    }
    // Load room types, equipment, and room photos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hotelId = widget.hotel.hotelId;
      context.read<HotelBloc>().add(GetHotelRoomTypesRequested(hotelId));
      
      // Try to get roomTypeId from selectedOption or first option
      int? roomTypeId = widget.selectedOption?.roomTypeId;
      if (roomTypeId == null && widget.hotel.options != null && widget.hotel.options!.isNotEmpty) {
        roomTypeId = widget.hotel.options!.first.roomTypeId;
      }
      
      if (roomTypeId != null) {
        context.read<HotelBloc>().add(
          GetRoomTypeEquipmentRequested(roomTypeId),
        );
        context.read<HotelBloc>().add(
          GetHotelRoomPhotosRequested(
            hotelId: hotelId,
            roomTypeId: roomTypeId,
          ),
        );
      } else {
        // Load all room photos if no specific room type
        context.read<HotelBloc>().add(
          GetHotelRoomPhotosRequested(hotelId: hotelId),
        );
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _getQuote() async {
    if (widget.selectedOption == null) return;
    
    setState(() => _isLoading = true);
    context.read<HotelBloc>().add(
      GetQuoteRequested([widget.selectedOption!.optionRefId]),
    );
  }

  Future<void> _createBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_quoteId == null) {
      SnackbarHelper.showError(
        context,
        'hotel.booking.quote_not_found'.tr(),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Generate unique external ID
    final externalId = 'HOTEL_${DateTime.now().millisecondsSinceEpoch}';

    // Create booking request
    final request = CreateHotelBookingRequest(
      quoteId: _quoteId!,
      externalId: externalId,
      bookingRooms: [
        BookingRoom(
          optionRefId: widget.selectedOption?.optionRefId ?? '',
          guests: [
            BookingGuest(
              personTitle: 'MR',
              firstName: _nameController.text.split(' ').first,
              lastName: _nameController.text.split(' ').length > 1
                  ? _nameController.text.split(' ').skip(1).join(' ')
                  : '',
              nationality: 'uz',
            ),
          ],
          price: widget.selectedOption?.price ?? widget.hotel.price ?? 0,
        ),
      ],
    );

    context.read<HotelBloc>().add(CreateBookingRequested(request));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'hotel.booking.title'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: BlocListener<HotelBloc, HotelState>(
        listener: (context, state) {
          if (state is HotelQuoteSuccess) {
            setState(() {
              _quoteId = state.quote.quoteId;
              _isLoading = false;
            });
          } else if (state is HotelQuoteFailure) {
            setState(() => _isLoading = false);
            SnackbarHelper.showError(context, state.message);
          } else if (state is HotelBookingCreateSuccess) {
            // After creating booking, confirm it
            _confirmBooking(state.booking.bookingId);
          } else if (state is HotelBookingCreateFailure) {
            setState(() => _isLoading = false);
            SnackbarHelper.showError(context, state.message);
          } else if (state is HotelBookingConfirmSuccess) {
            setState(() => _isLoading = false);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HotelSuccessPage(booking: state.booking),
              ),
              (route) => route.isFirst,
            );
          } else if (state is HotelBookingConfirmFailure) {
            setState(() => _isLoading = false);
            SnackbarHelper.showError(context, state.message);
          }
          
          // Update cached data
          if (state is HotelRoomTypesSuccess) {
            setState(() {
              _cachedRoomTypes = state.roomTypes;
              _isLoadingRoomTypes = false;
            });
          } else if (state is HotelRoomTypesLoading) {
            setState(() {
              _isLoadingRoomTypes = true;
            });
          } else if (state is HotelRoomTypesFailure) {
            setState(() {
              _isLoadingRoomTypes = false;
            });
          }

          if (state is HotelRoomTypeEquipmentSuccess) {
            setState(() {
              _cachedEquipment = state.equipment;
              _isLoadingEquipment = false;
            });
          } else if (state is HotelRoomTypeEquipmentLoading) {
            setState(() {
              _isLoadingEquipment = true;
            });
          } else if (state is HotelRoomTypeEquipmentFailure) {
            setState(() {
              _isLoadingEquipment = false;
            });
          }

          if (state is HotelRoomPhotosSuccess) {
            setState(() {
              _cachedRoomPhotos = state.photos;
              _isLoadingRoomPhotos = false;
            });
          } else if (state is HotelRoomPhotosLoading) {
            setState(() {
              _isLoadingRoomPhotos = true;
            });
          } else if (state is HotelRoomPhotosFailure) {
            setState(() {
              _isLoadingRoomPhotos = false;
            });
          }
        },
        child: BlocBuilder<HotelBloc, HotelState>(
          builder: (context, state) {
            // Use cached data
            final roomTypes = _cachedRoomTypes;
            final equipment = _cachedEquipment;
            final roomPhotos = _cachedRoomPhotos;

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Hotel Info Summary
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hotel.name,
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '${DateFormat('dd MMM yyyy').format(widget.hotel.checkInDate)} - ${DateFormat('dd MMM yyyy').format(widget.hotel.checkOutDate)}',
                        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      ),
                      if (widget.selectedOption != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          '${NumberFormat.currency(locale: 'uz_UZ', symbol: widget.selectedOption!.currency == 'uzs' ? 'so\'m' : widget.selectedOption!.currency?.toUpperCase() ?? 'so\'m', decimalDigits: 0).format(widget.selectedOption!.price ?? 0)}',
                          style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                if (roomPhotos.isNotEmpty || _isLoadingRoomPhotos)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'hotel.booking.room_photos'.tr(),
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.h),
                      if (_isLoadingRoomPhotos)
                        const Center(child: CircularProgressIndicator())
                      else
                        SizedBox(
                        height: 120.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: roomPhotos.length,
                          itemBuilder: (context, index) {
                            final photo = roomPhotos[index];
                            return Container(
                              width: 120.w,
                              margin: EdgeInsets.only(right: 12.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: SafeNetworkImage(
                                imageUrl: photo.thumbnailUrl ?? photo.url ?? '',
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),

                // Room Types
                if (roomTypes.isNotEmpty || _isLoadingRoomTypes)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'hotel.booking.room_types'.tr(),
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.h),
                      if (_isLoadingRoomTypes)
                        const Center(child: CircularProgressIndicator())
                      else
                        ...roomTypes.map((roomType) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                roomType.getDisplayName(context.locale.toString()),
                                style: TextStyle(
                                    fontSize: 14.sp, fontWeight: FontWeight.w600),
                              ),
                              if (roomType.maxOccupancy != null) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  'Max ${roomType.maxOccupancy} guests',
                                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 24.h),
                    ],
                  ),

                // Equipment
                if (equipment.isNotEmpty || _isLoadingEquipment)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'hotel.booking.equipment'.tr(),
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.h),
                      if (_isLoadingEquipment)
                        const Center(child: CircularProgressIndicator())
                      else
                        Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: equipment.map((eq) {
                          final locale = context.locale.toString();
                          final displayName = eq.getDisplayName(locale);
                          return Chip(
                            avatar: Icon(Icons.check, size: 16.sp),
                            label: Text(displayName, style: TextStyle(fontSize: 12.sp)),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),

                // User Info
                Text(
                  'hotel.booking.user_info'.tr(),
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),
                _buildTextField(
                    'hotel.booking.name'.tr(), Icons.person, _nameController),
                SizedBox(height: 16.h),
                _buildTextField(
                    'hotel.booking.email'.tr(), Icons.email, _emailController,
                    isEmail: true),
                SizedBox(height: 16.h),
                _buildTextField('hotel.booking.phone'.tr(),
                    Icons.phone, _phoneController),
                SizedBox(height: 32.h),

              // Payment Method
              Text(
                'hotel.booking.payment_type'.tr(),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              _buildPaymentOption(1, 'Payme', Icons.payment, Colors.blue),
              SizedBox(height: 12.h),
              _buildPaymentOption(2, 'Oson', Icons.account_balance_wallet,
                  Colors.orange),
              SizedBox(height: 32.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 50.h,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
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
                      'hotel.booking.pay'.tr(),
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmBooking(String bookingId) {
    final paymentInfo = PaymentInfo(
      paymentMethod: _selectedPaymentMethod == 1 ? 'payme' : 'oson',
      transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
    );

    context.read<HotelBloc>().add(
      ConfirmBookingRequested(
        bookingId: bookingId,
        paymentInfo: paymentInfo,
      ),
    );
  }

  Widget _buildTextField(
      String label, IconData icon, TextEditingController controller,
      {bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
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
      ),
      keyboardType:
          isEmail ? TextInputType.emailAddress : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Maydonni to\'ldiring';
        }
        return null;
      },
    );
  }

  Widget _buildPaymentOption(
      int value, String title, IconData icon, Color color) {
    bool isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.1)
              : Theme.of(context).cardColor,
          border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28.sp),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.blue
                      : Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.blue, size: 24.sp)
            else
              Icon(Icons.circle_outlined, color: Colors.grey, size: 24.sp),
          ],
        ),
      ),
    );
  }
}
