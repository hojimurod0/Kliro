import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/navigation/app_router.dart';

// Asosiy ko'k rang
const Color _primaryBlue = Color(0xFF1976D2); // Material Blue 700

@RoutePage()
class KaskoFormPage extends StatefulWidget {
  const KaskoFormPage({super.key});

  @override
  State<KaskoFormPage> createState() => _KaskoFormPageState();
}

class _KaskoFormPageState extends State<KaskoFormPage> {
  // Controllers для полей формы
  final TextEditingController _markaController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _pozitsiyaController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  @override
  void dispose() {
    _markaController.dispose();
    _modelController.dispose();
    _pozitsiyaController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  // Yozish mumkin bo'lgan universal form maydoni uchun yangilangan widget
  Widget _buildWritableField(
    String label,
    TextEditingController controller, {
    String? hintText,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey.shade300;
    final hintColor = isDark ? Colors.grey[600]! : Colors.grey.shade500;
    final fillColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Maydonning labeli
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        SizedBox(height: 8.0.h),
        // Yozish mumkin bo'lgan TextFormField
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText ?? 'Tanlash',
            hintStyle: TextStyle(color: hintColor),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.0.w,
              vertical: 14.0.h,
            ),
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0.r),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0.r),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0.r),
              borderSide: const BorderSide(
                color: _primaryBlue,
                width: 1.5,
              ),
            ),
          ),
          style: TextStyle(
            color: textColor,
            fontSize: 16.sp,
          ),
          onChanged: (value) {
            // Kiritilgan ma'lumotni saqlash logikasi
            debugPrint('$label: $value');
          },
        ),
        SizedBox(height: 20.0.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : Colors.white;
    final appBarBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () {
            context.router.pop();
          },
        ),
        title: Text(
          'KASKO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      // FORM BODY
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 1. Avtomobile markasi (Endi yozish mumkin)
                _buildWritableField(
                  'Avtomobile markasi',
                  _markaController,
                ),

                // 2. Modeli (Endi yozish mumkin)
                _buildWritableField(
                  'Modeli',
                  _modelController,
                ),

                // 3. Pozitsiya (Endi yozish mumkin)
                _buildWritableField(
                  'Pozitsiya',
                  _pozitsiyaController,
                ),

                // 4. Ishlab chiqarilgan yili (Endi yozish mumkin)
                _buildWritableField(
                  'Ishlab chiqarilgan yili',
                  _yearController,
                  hintText: 'Masalan: 2020',
                ),

                SizedBox(height: 40.0.h), // Pastki tugma uchun joy
              ],
            ),
          ),

          // FIXED BOTTOM BUTTON
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16.0.w,
                10.0.h,
                16.0.w,
                10.0.h + bottomPadding,
              ),
              decoration: BoxDecoration(
                color: appBarBg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    // Keyingi sahifaga o'tish - tariflar sahifasiga
                    context.router.push(const KaskoTariffRoute());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Davom etish',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

