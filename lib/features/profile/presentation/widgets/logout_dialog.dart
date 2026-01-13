import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Maxsus ranglarni aniqlash
const Color _dialogBackgroundColor = Color.fromARGB(
  46,
  5,
  48,
  108,
); // Dialogning o'rta-ko'k foni

const Color _cancelButtonColor = Color.fromARGB(
  77,
  219,
  229,
  234,
); // Chap (Cancel) tugmasining yorug' foni

const Color _logoutButtonColor = Color.fromARGB(
  65,
  255,
  0,
  0,
); // O'ng (Logout) tugmasining qizil/pushti foni

const Color _iconCircleColor = Color.fromARGB(
  80,
  255,
  0,
  0,
); // Icon aylanasi (qizil/pushti)

void showLogoutDialog(
  BuildContext context,
  VoidCallback onConfirm,
) {
  showDialog(
    context: context,
    barrierDismissible: true, // Tashqariga bosilganda yopilishi
    barrierColor: Colors.black.withOpacity(0.5), // Orqa fonda yarim-shaffof qora overlay
    builder: (BuildContext context) {
      return AlertDialog(
        actionsOverflowButtonSpacing: 20,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: Color.fromARGB(83, 0, 103, 186),
            strokeAlign: 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(30.0.r),
        ),
        // Dialogning maxsus ko'k foni
        backgroundColor: _dialogBackgroundColor,
        // Content/Kontent ichki tuzilmasi
        content: Column(
          mainAxisSize: MainAxisSize.min, // Kerakli minimal joyni egallash
          children: <Widget>[
            // 3. Icon (Qizil aylana va ichida oq chiqish strelkasi)
            Container(
              width: 50.w,
              height: 50.w,
              decoration: const BoxDecoration(
                color: _iconCircleColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded, // Chiqish ikonkasi
                color: Colors.white,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 16.h), // Bo'shliq
            // 4. Title (Logout)
            const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h), // Bo'shliq
            // 5. Message (Are you sure...)
            const Text(
              'Are you sure you want to logout?',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h), // Tugmalar uchun katta bo'shliq
            // 6. Buttons (Tugmalar qatori)
            Row(
              children: <Widget>[
                // Chap tugma (Cancel - Bekor qilish)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Dialogni yopish
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _cancelButtonColor, // Yorug' ko'k fon
                      elevation: 0, // Soya effektini yo'qotish
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12.0.r,
                        ), // Yumaloq burchaklar
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      minimumSize: Size(0, 40.h),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w), // Tugmalar orasidagi bo'shliq
                // O'ng tugma (Yes, Logout - Ha, Chiqish)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Chiqish logikasi shu yerga yoziladi
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _logoutButtonColor, // Qizil/pushti fon (Destructive action)
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      minimumSize: Size(0, 40.h),
                    ),
                    child: Text(
                      'Yes, Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

