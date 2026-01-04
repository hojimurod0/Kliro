# Google Sign-In Sozlash Bo'yicha Qo'llanma

Sizda `ApiException: 10` xatoligi chiqmoqda. Bu xatolik deyarli har doim **SHA-1 fingerprint** Firebase Console ga qo'shilmaganligida kelib chiqadi.

Muammoni hal qilish uchun quyidagi qadamlarni bajaring:

## 1. SHA-1 Fingerprintni olish

Terminalda (yoki Windows PowerShell da) quyidagi buyruqni ishga tushiring. Bu buyruq sizning kompyuteringizdagi Debug kalitining SHA-1 kodini chiqaradi.

**Windows uchun:**
```powershell
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

*Agar `keytool` topilmadi desa, Java o'rnatilgan papkadagi `bin` ichidan ishlatishingiz kerak. Masalan:*
`"C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" ...`

Natijada shunday narsa chiqadi (bu sizning hozirgi kalitingiz):
```
SHA1: 48:C2:0D:31:BC:73:4C:A6:B1:E4:99:D0:00:5F:DB:5A:9C:4D:17:87
```
Shu **SHA1** kodini nusxalab oling.

## 2. Firebase Console ga qo'shish

1.  [Firebase Console](https://console.firebase.google.com/) ga kiring.
2.  Loyihangizni tanlang.
3.  **Project Settings** (sozlamalar) -> **General** bo'limiga o'ting.
4.  Pastda **Your apps** bo'limida Android ilovani tanlang.
5.  **Add fingerprint** tugmasini bosing va nusxalab olingan SHA1 kodini qo'shing va saqlang.

## 3. google-services.json faylini yangilash

1.  SHA-1 qo'shilgandan so'ng, xuddi shu sahifadan **google-services.json** faylini qaytadan yuklab oling.
2.  Yuklab olingan faylni loyihangizdagi `android/app/google-services.json` o'rniga joylashtiring.
    *   *Eslatma: Hozirgi faylingiz hajmi (~970 bayt) juda kichik, ehtimol u shunchaki namuna (example) faylidir.*

## 4. Ilovani qayta ishga tushirish

O'zgarishlar kuchga kirishi uchun ilovani to'xtatib, qaytadan `run` qiling (Hot Restart yetarli bo'lmasligi mumkin).

---
Barcha qadamlar bajarilgandan so'ng, Google orqali kirish ishlashi kerak.
