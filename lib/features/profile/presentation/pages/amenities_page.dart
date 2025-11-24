import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// === Ranglar va Uslublar ===
const Color _primaryBlue = Color(0xFF007BFF); // Asosiy ko'k rang (ikonka)
const Color _lightBlue = Color(0xFFE5F5FF); // Ikonka fonidagi yengil ko'k
const Color _darkText = Color(0xFF2C2C2C); // Sarlavha va yozuvlar rangi
const Color _backgroundColor = Colors.white; // Sahifa foni

// === Ma'lumot Modeli ===
class Amenity {
  final String title;
  final IconData icon;

  Amenity({required this.title, required this.icon});
}

// Rasmga asoslanib ma'lumotlar ro'yxati
final List<Amenity> _amenities = [
  // Chap ustun
  Amenity(title: "Televizor", icon: Icons.tv),
  Amenity(title: "Xolodilnik", icon: Icons.kitchen),
  Amenity(title: "Basseyin", icon: Icons.pool),
  Amenity(title: "Televizor", icon: Icons.tv),
  Amenity(title: "Xolodilnik", icon: Icons.kitchen),
  Amenity(title: "Basseyin", icon: Icons.pool),
  Amenity(title: "Televizor", icon: Icons.tv),
  Amenity(title: "Xolodilnik", icon: Icons.kitchen),
  Amenity(title: "Basseyin", icon: Icons.pool),
  // O'ng ustun (rasmda 9 ta chapda, 9 ta o'ngda ko'rinadi)
  Amenity(title: "Garaj", icon: Icons.directions_car_outlined),
  Amenity(title: "Kuxnya", icon: Icons.flatware),
  Amenity(title: "Mangal", icon: Icons.outdoor_grill),
  Amenity(title: "Garaj", icon: Icons.directions_car_outlined),
  Amenity(title: "Kuxnya", icon: Icons.flatware),
  Amenity(title: "Mangal", icon: Icons.outdoor_grill),
  Amenity(title: "Garaj", icon: Icons.directions_car_outlined),
  Amenity(title: "Kuxnya", icon: Icons.flatware),
  Amenity(title: "Mangal", icon: Icons.outdoor_grill),
];

@RoutePage()
class AmenitiesPage extends StatelessWidget {
  const AmenitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ikkita mustaqil ro'yxatga ajratamiz (rasmga o'xshatish uchun)
    final int halfLength = (_amenities.length ~/ 2);
    final List<Amenity> leftColumnAmenities = _amenities.sublist(0, halfLength);
    final List<Amenity> rightColumnAmenities = _amenities.sublist(halfLength);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20.h),
            // Sarlavha
            Text(
              "Qulaylik va Xizmatlar",
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color ??
                    _darkText,
              ),
            ),
            SizedBox(height: 20.h),
            // 2 ustunli ro'yxat
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chap ustun
                Expanded(
                  child: _buildAmenitiesColumn(context, leftColumnAmenities),
                ),
                SizedBox(width: 16.w),
                // O'ng ustun
                Expanded(
                  child: _buildAmenitiesColumn(context, rightColumnAmenities),
                ),
              ],
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // === AppBar UI ===
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
          Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).iconTheme.color ?? Colors.black,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Qulayliklar",
        style: TextStyle(
          color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }

  // === Ro'yxat elementlari ustuni ===
  Widget _buildAmenitiesColumn(BuildContext context, List<Amenity> amenities) {
    return Column(
      children: amenities.map((amenity) {
        return _buildAmenityItem(amenity.title, amenity.icon, context);
      }).toList(),
    );
  }

  // === Har bir qulaylik elementi UI ===
  Widget _buildAmenityItem(String title, IconData icon, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h), // Elementlar orasidagi masofa
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikonka va fon (Rasmga o'xshashlik uchun Container ichida)
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          // Yozuv
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 8.h), // Vertikal joylashuvni to'g'irlash
              child: Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color ??
                      _darkText,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

