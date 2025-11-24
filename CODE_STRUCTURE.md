# 📁 Kod Strukturasi (Code Structure)

## 🏗️ Umumiy Struktura

```
lib/
├── core/
│   └── navigation/
│       ├── app_router.dart          # Barcha routelar ro'yxati
│       └── app_router.gr.dart       # Auto-generated (build_runner tomonidan)
│
└── features/
    └── insurance/
        ├── data/                    # Ma'lumotlar bilan ishlash
        │   ├── datasources/
        │   ├── models/
        │   └── repositories/
        │
        ├── domain/                   # Business logic
        │   ├── entities/
        │   ├── repositories/
        │   └── usecases/
        │
        └── presentation/             # UI qismi
            └── pages/                # Barcha sahifalar
                ├── insurance_services_page.dart    # Asosiy sug'urta sahifasi
                ├── osago_input_page.dart           # 1️⃣ OSAGO - Ma'lumot kiritish
                ├── osago_select_page.dart          # 2️⃣ OSAGO - Kompaniya tanlash
                ├── osago_order_page.dart           # 3️⃣ OSAGO - Buyurtma ma'lumotlari
                ├── osago_payment_page.dart         # 4️⃣ OSAGO - To'lov turi
                └── osago_success_page.dart         # 5️⃣ OSAGO - Muvaffaqiyatli yakunlanish
```

---

## 🔄 OSAGO Sahifalar Ketma-ketligi

### 1️⃣ **insurance_services_page.dart**

- **Joylashuvi:** `lib/features/insurance/presentation/pages/`
- **Vazifasi:** Asosiy sug'urta xizmatlari ro'yxati
- **Keyingi sahifa:** `OsagoInputRoute()` - "Rasmiylashtirish" tugmasi bosilganda

### 2️⃣ **osago_input_page.dart**

- **Joylashuvi:** `lib/features/insurance/presentation/pages/`
- **Vazifasi:** Avtomobil ma'lumotlarini kiritish
  - Avtomobil markasi
  - Modeli
  - Avtomobil raqami
  - Passport seriyasi va raqami
  - Tex passport
  - Tug'ilgan kun sanasi
  - "Men mashinaning egasi emasman" checkbox
- **Keyingi sahifa:** `OsagoSelectRoute()` - "Davom etish" tugmasi bosilganda

### 3️⃣ **osago_select_page.dart**

- **Joylashuvi:** `lib/features/insurance/presentation/pages/`
- **Vazifasi:** Sug'urta kompaniyasini tanlash
  - Kompaniyani tanlash
  - Sug'urta muddati
  - OSAGO turi
  - Boshlanish sanasi
  - Telefon raqami
- **Keyingi sahifa:** `OsagoOrderRoute()` - "Davom etish" tugmasi bosilganda

### 4️⃣ **osago_order_page.dart**

- **Joylashuvi:** `lib/features/insurance/presentation/pages/`
- **Vazifasi:** Buyurtma ma'lumotlarini ko'rsatish
  - Vehicle Number (🇺🇿 bayroq bilan)
  - Car Make
  - Passport Series
  - Technical Passport Number
  - Type of OSAGO
  - Insurance Term
  - Insurance Company
  - Start Date
  - Phone
  - Jami summa: 1,200,000 sum
- **Keyingi sahifa:** `OsagoPaymentRoute()` - "Rasmiylashtirish" tugmasi bosilganda

### 5️⃣ **osago_payment_page.dart**

- **Joylashuvi:** `lib/features/insurance/presentation/pages/`
- **Vazifasi:** To'lov turini tanlash
  - Payme (ko'k rang)
  - Click (ko'k rang)
  - Radio button dizayni
  - Jami summa: 1,200,000 sum
- **Keyingi sahifa:** `OsagoSuccessRoute()` - "To'lash" tugmasi bosilganda

### 6️⃣ **osago_success_page.dart**

- **Joylashuvi:** `lib/features/insurance/presentation/pages/`
- **Vazifasi:** Muvaffaqiyatli yakunlanish dialogi
  - ✅ Yashil doira va galochka
  - "Sug'urta muvaffaqiyatli rasmiylashtirildi" xabari
  - Polis raqami (#OSAGO-35153)
  - Sana (2025-10-28)
  - Summasi (275 000 so'm)
  - "Polisni yuklab olish" tugmasi
  - "Ulashish" tugmasi
  - "Yopish" tugmasi

---

## 🔗 Navigation (Navigatsiya) Strukturasi

### app_router.dart

**Joylashuvi:** `lib/core/navigation/app_router.dart`

```dart
// OSAGO routelar ketma-ketligi:
AutoRoute(page: InsuranceServicesRoute.page),    // Asosiy sahifa
AutoRoute(page: OsagoInputRoute.page),            // 1️⃣
AutoRoute(page: OsagoSelectRoute.page),           // 2️⃣
AutoRoute(page: OsagoOrderRoute.page),            // 3️⃣
AutoRoute(page: OsagoPaymentRoute.page),          // 4️⃣
AutoRoute(page: OsagoSuccessRoute.page),          // 5️⃣
```

---

## 📊 Fayllar O'rtasidagi Bog'lanish

```
insurance_services_page.dart
    │
    │ (onPressed: OsagoInputRoute)
    ▼
osago_input_page.dart
    │
    │ (onPressed: OsagoSelectRoute)
    ▼
osago_select_page.dart
    │
    │ (onPressed: OsagoOrderRoute)
    ▼
osago_order_page.dart
    │
    │ (onPressed: OsagoPaymentRoute)
    ▼
osago_payment_page.dart
    │
    │ (onPressed: OsagoSuccessRoute)
    ▼
osago_success_page.dart
    │
    │ (Dialog yopiladi)
    ▼
    (Orqaga qaytish)
```

---

## 🎨 Har bir Fayl Ichidagi Struktura

### Umumiy Pattern:

```dart
// 1. Importlar
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/navigation/app_router.dart';

// 2. Ranglar (constants)
const Color _bluePrimary = Color(0xFF007AFF);
// ...

// 3. Route annotation
@RoutePage()
class OsagoXxxPage extends StatefulWidget/StatelessWidget {
  // ...
}

// 4. Widget build method
@override
Widget build(BuildContext context) {
  // Theme detection
  final isDark = Theme.of(context).brightness == Brightness.dark;

  // Responsive values
  final scaffoldBg = isDark ? ... : ...;

  return Scaffold(
    // AppBar
    // Body
    // Navigation logic
  );
}
```

---

## 🔧 Build Runner

Har safar yangi route qo'shilganda yoki o'zgartirilganda:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Bu buyruq `app_router.gr.dart` faylini yangilaydi.

---

## 📝 Eslatmalar

1. **Barcha sahifalar** `@RoutePage()` annotation bilan belgilanadi
2. **Navigation** `context.router.push(RouteName())` orqali amalga oshiriladi
3. **Orqaga qaytish** `context.router.pop()` yoki `Navigator.pop(context)`
4. **Responsive dizayn** `flutter_screenutil` paketi orqali
5. **Dark/Light theme** `Theme.of(context).brightness` orqali aniqlanadi

---

## 🗂️ Boshqa Features Strukturasi

```
lib/features/
├── bank/              # Bank xizmatlari
├── currency/          # Valyuta kurslari
├── insurance/         # Sug'urta (OSAGO)
├── home/              # Asosiy sahifa
├── profile/           # Profil
└── register/          # Ro'yxatdan o'tish
```

Har bir feature o'z ichida `data/`, `domain/`, `presentation/` strukturasiga ega.
