import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Asosiy ranglar
const Color _bluePrimary = Color(0xFF007AFF); // iOS ga xos ko'k rang
const Color _scaffoldBackground = Color(0xFF555555); // Fon uchun to'q kulrang
const Color _cardBackground = Colors.white; // Dialog foni
const Color _textDark = Color(0xFF333333); // Asosiy matn rangi
const Color _textLight = Color(0xFF999999); // Kichik matnlar (label)
const Color _successGreen = Color(0xFF28B775); // Yashil rang

@RoutePage()
class OsagoSuccessPage extends StatelessWidget {
  const OsagoSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sahifa yuklanganda darhol dialogni ko'rsatish
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSuccessDialog(context);
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : _scaffoldBackground;
    final textColor = isDark ? Colors.white : _textDark;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        toolbarHeight: 56.0.h,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.router.pop(),
        ),
        title: Text(
          "OSAGO",
          style: TextStyle(
            color: textColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),
      body: Container(
        color: Colors.transparent,
      ),
    );
  }

  // ----------------------------------------------------
  // Muvaffaqiyatli AlertDialog Funksiyasi
  // ----------------------------------------------------
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0.r),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 20.0.w),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(16.0.w, 30.0.h, 16.0.w, 16.0.h),
            child: SuccessContent(),
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------
// Dialogning asosiy kontenti
// ----------------------------------------------------
class SuccessContent extends StatelessWidget {
  SuccessContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Yashil doira va Galochka
        Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: _successGreen,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, color: _cardBackground, size: 36.sp),
        ),
        SizedBox(height: 16.0.h),

        // Muvaffaqiyatli xabar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w),
          child: Text(
            "Sug'urta muvaffaqiyatli rasmiylashtirildi",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: _textDark,
              height: 1.3,
            ),
          ),
        ),
        SizedBox(height: 24.0.h),

        // Ma'lumotlar ro'yxati (Polis, Sana, Summa)
        SuccessInfoRow(
          label: "Polisni raqami",
          value: "#OSAGO-35153",
          isLink: true,
        ),
        Divider(color: const Color(0xFFEEEEEE), height: 1.0.h, thickness: 1.0),
        SuccessInfoRow(label: "Sana", value: "2025-10-28"),
        Divider(color: const Color(0xFFEEEEEE), height: 1.0.h, thickness: 1.0),
        SuccessInfoRow(label: "Summasi", value: "275 000 so'm"),
        Divider(color: const Color(0xFFEEEEEE), height: 1.0.h, thickness: 1.0),
        SizedBox(height: 32.0.h),

        // Polisni yuklab olish tugmasi (Outlined)
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: OutlinedButton.icon(
            onPressed: () {
              // Polisni yuklab olish logikasi
            },
            icon: Icon(Icons.file_download_outlined, color: _textDark, size: 20.sp),
            label: Text(
              "Polisni yuklab olish",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.0.h),

        // Ulashish tugmasi (Outlined)
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: OutlinedButton.icon(
            onPressed: () {
              // Ulashish logikasi
            },
            icon: Icon(Icons.share_outlined, color: _textDark, size: 20.sp),
            label: Text(
              "Ulashish",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.0.h),

        // Yopish tugmasi (Filled)
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Dialogni yopish
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _bluePrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0.r),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Text(
              "Yopish",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------
// Ma'lumot qatori (Polis/Sana/Summa)
// ----------------------------------------------------
class SuccessInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLink;

  const SuccessInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0.h, horizontal: 8.0.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              color: _textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isLink ? _bluePrimary : _textDark,
            ),
          ),
        ],
      ),
    );
  }
}

