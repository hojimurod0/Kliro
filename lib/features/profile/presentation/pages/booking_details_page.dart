import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/navigation/app_router.dart';

// === Ranglar va Uslublar ===
const Color _primaryBlue = Color(0xFF007BFF); // Asosiy ko'k rang
const Color _secondaryBlue = Color(0xFF00C6FF); // Gradyentdagi ikkinchi ko'k
const Color _lightGreen = Color(0xFFC8E6C9); // Tasdiqlangan fon rangi
const Color _darkGreen = Color(0xFF4CAF50); // Tasdiqlangan yozuv rangi
const Color _darkText = Color(0xFF2C2C2C); // Umumiy to'q yozuv rangi

@RoutePage()
class BookingDetailsPage extends StatelessWidget {
  const BookingDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Status Bar rangini theme'ga moslash
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).scaffoldBackgroundColor,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // Asosiy kontent
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 10.h,
              bottom: 100.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Bron ma'lumotlari (Birinchi qism)
                _buildBookingHeader(context),
                SizedBox(height: 20.h),
                // Xona tafsilotlari 1
                _buildRoomDetailsCard(context),
                SizedBox(height: 15.h),
                // Xona tafsilotlari 2 (Uzun rasmga asoslanib)
                _buildRoomDetailsCard(context),
                SizedBox(height: 15.h),
                // QR kod
                _buildQRCodeSection(context),
                SizedBox(height: 15.h),
                // Barcode
                _buildBarcodeSection(context),
              ],
            ),
          ),
          // Pastki navigatsiya paneli (Aloqa)
          _buildBottomPanel(context),
        ],
      ),
    );
  }

  // === AppBar UI (Yuqori qism) ===
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor:
          Theme.of(context).appBarTheme.backgroundColor ??
          Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      toolbarHeight: 0, // Faqat Status Bar uchun bo'sh joy qoldirish
    );
  }

  // === 1. Bron ma'lumotlari Header (Tashqi qismi) ===
  Widget _buildBookingHeader(BuildContext context) {
    return Column(
      children: [
        // Title va Close tugmasi
        Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bron ma'lumotlari",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color:
                      Theme.of(context).textTheme.titleLarge?.color ??
                      Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.close,
                  color: Theme.of(context).iconTheme.color ?? Colors.black,
                ),
              ),
            ],
          ),
        ),
        // Bron ID va Tasdiqlangan belgisi
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Bron #HYT2024121500123",
              style: TextStyle(
                color:
                    Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
                fontSize: 14.sp,
              ),
            ),
            _buildConfirmationBadge(context),
          ],
        ),
        SizedBox(height: 15.h),
        // Asosiy moviy ma'lumot kartasi
        _buildBookingDetailsCard(),
      ],
    );
  }

  // === Tasdiqlangan yorliq UI ===
  Widget _buildConfirmationBadge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? _darkGreen.withOpacity(0.2) : _lightGreen;
    final textColor = isDark ? _darkGreen : _darkGreen;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: textColor, size: 16.sp),
          SizedBox(width: 4.w),
          Text(
            "Tasdiqlangan",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  // === Bron ma'lumotlari KARTASI (Moviy gradyent) ===
  Widget _buildBookingDetailsCard() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        gradient: const LinearGradient(
          colors: [_primaryBlue, _secondaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Hotel nomi va Ikonka
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hyatt Regency Tashkent",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.white70,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "1A Navoi Street, Tashkent",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.apartment, color: Colors.white, size: 40.sp),
            ],
          ),
          SizedBox(height: 20.h),
          // Ma'lumotlar ro'yxati (Sanadan boshlab)
          _buildInfoRow(
            Icons.calendar_month,
            "15.12.2025 - 18.12.2025",
            "2 kecha",
          ),
          _buildInfoRow(Icons.person_outline, "Alisher Valiyev", null),
          _buildInfoRow(Icons.people_outline, "3 kishi", null),
          _buildInfoRow(Icons.king_bed_outlined, "Deluxe King Room", "Deluxe"),
          SizedBox(height: 20.h),
          // To'lov holati va Summa
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "To'lov holati",
                    style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Oldindan to'langan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Jami summa",
                    style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "1,200,000 UZS",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // === Ma'lumot qatori (Moviy kartochka ichida) ===
  Widget _buildInfoRow(IconData icon, String label, String? detail) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Colors.white, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 15.sp),
            ),
          ),
          if (detail != null)
            Text(
              detail,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
        ],
      ),
    );
  }

  // === 2. Xona tafsilotlari kartasi ===
  Widget _buildRoomDetailsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Xona tafsilotlari",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color ?? _darkText,
            ),
          ),
          SizedBox(height: 15.h),
          // Xona turi
          _buildDetailRow(context, "Xona turi", "Deluxe King Room"),
          _buildDetailRow(context, "O'lchami", "53 m2"),
          _buildDetailRow(context, "Kravat", "2 kishilik"),
          SizedBox(height: 20.h),
          Text(
            "Qulayliklar",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color ?? _darkText,
            ),
          ),
          SizedBox(height: 15.h),
          // Qulayliklar ro'yxati (2 ustun)
          _buildAmenitiesGrid(context, [
            // Rasmda ko'rsatilganlar
            {"icon": Icons.tv, "label": "Televizion"},
            {"icon": Icons.garage_outlined, "label": "Garage"},
            {"icon": Icons.kitchen, "label": "Refrigerator"},
            {"icon": Icons.deck, "label": "Kitchen"},
            {"icon": Icons.pool, "label": "Swimming pool"},
            {"icon": Icons.outdoor_grill, "label": "Grill"},
          ]),
          SizedBox(height: 10.h),
          // Ko'proq...
          InkWell(
            onTap: () {
              context.router.push(const AmenitiesRoute());
            },
            child: Row(
              children: [
                Text(
                  "Ko'proq...",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14.sp,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === Oddiy tafsilot qatori (Xona tafsilotlari ichida) ===
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color:
                  Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
              fontSize: 15.sp,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color ?? _darkText,
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }

  // === Qulayliklar uchun 2 ustunli Grid ===
  Widget _buildAmenitiesGrid(
    BuildContext context,
    List<Map<String, dynamic>> amenities,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: amenities.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5, // Kenglik/balandlik nisbati
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 5.h,
      ),
      itemBuilder: (context, index) {
        return Row(
          children: [
            Icon(
              amenities[index]["icon"],
              color: Theme.of(context).colorScheme.primary,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              amenities[index]["label"],
              style: TextStyle(
                color:
                    Theme.of(context).textTheme.titleLarge?.color ?? _darkText,
                fontSize: 14.sp,
              ),
            ),
          ],
        );
      },
    );
  }

  // === QR Kod bo'limi ===
  Widget _buildQRCodeSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.qr_code_2,
                color: Theme.of(context).colorScheme.primary,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                "QR Kod",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: _darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // QR Kodni tasvirlash (Placeholder)
          Container(
            width: 200.w,
            height: 200.w,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.qr_code_2,
              size: 100.sp,
              color: Theme.of(context).iconTheme.color ?? Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "Kirish uchun ushbu QR kodni ko'rsating",
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  // === Barcode bo'limi ===
  Widget _buildBarcodeSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart,
                color: Theme.of(context).colorScheme.primary,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                "Barcode",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: _darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Barcodeni tasvirlash (Placeholder)
          Container(
            width: double.infinity,
            height: 100.h,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.bar_chart,
              size: 50.sp,
              color: Theme.of(context).iconTheme.color ?? Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "BYT2024121500123", // Bron ID rasmda Barcode ostida yozilgan
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  // === Pastki panel (Button va Narx) ===
  Widget _buildBottomPanel(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Chapdagi narx
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Jami summa",
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "1,200,000 sum",
                    style: TextStyle(
                      color:
                          Theme.of(context).textTheme.titleLarge?.color ??
                          _darkText,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 15.w),
              // O'ngdagi tugma
              Expanded(
                child: Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: TextButton(
                    onPressed: () {
                      // Aloqa funksiyasi
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      "Aloqa",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
