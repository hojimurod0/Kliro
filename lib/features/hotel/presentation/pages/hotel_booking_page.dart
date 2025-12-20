import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/hotel.dart';
import 'hotel_success_page.dart';

class HotelBookingPage extends StatefulWidget {
  final Hotel hotel;

  const HotelBookingPage({Key? key, required this.hotel}) : super(key: key);

  @override
  State<HotelBookingPage> createState() => _HotelBookingPageState();
}

class _HotelBookingPageState extends State<HotelBookingPage> {
  final _formKey = GlobalKey<FormState>();
  int _selectedPaymentMethod = 1; // 1: Payme, 2: Click

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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info
              Text(
                'hotel.booking.user_info'.tr(),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                  'hotel.booking.name'.tr(), Icons.person),
              SizedBox(height: 16.h),
              _buildTextField(
                  'hotel.booking.email'.tr(), Icons.email,
                  isEmail: true),
              SizedBox(height: 16.h),
              _buildTextField('hotel.booking.phone'.tr(),
                  Icons.phone),
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
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Simulate API call
                  Future.delayed(const Duration(seconds: 1), () {
                     Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const HotelSuccessPage(),
                      ),
                    );
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
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

  Widget _buildTextField(String label, IconData icon, {bool isEmail = false}) {
    return TextFormField(
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
