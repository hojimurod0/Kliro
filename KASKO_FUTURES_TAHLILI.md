# 📊 KASKO FUTURES MODULI TO'LIQ TAHLILI

## 🎯 UMUMIY MA'LUMOT

**Loyiha:** KLiRO (Flutter ilovasi)  
**Modul:** Kasko Futures (KAСКО sug'urta)  
**Arxitektura:** Clean Architecture + BLoC Pattern  
**Til:** Dart/Flutter

---

## 🚀 KIRISH NUQTASI VA BIRINCHI SAHIFA

### Ilovaning asosiy kirish nuqtasi:

**Fayl:** `lib/main.dart`

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(EasyLocalization(...child: const App()));
}
```

### Ilova ochilganda birinchi sahifa:

**Fayl:** `lib/core/navigation/app_router.dart`

```56:56:lib/core/navigation/app_router.dart
AutoRoute(page: SplashRoute.page, initial: true),
```

**Birinchi sahifa:** `SplashPage` → `OnboardingPage` → `HomePage`

### Kasko Futures ga yo'l:

1. **Asosiy sahifa** (`HomePage`)
   ↓
2. **Xizmatlar sahifasi** (`ServicesPage`) → "Sug'urta xizmatlari" ga navigatsiya
   ↓
3. **Sug'urta xizmatlari sahifasi** (`InsuranceServicesPage`)
   - Fayl: `lib/features/insurance/presentation/pages/insurance_services_page.dart`
   - "KASKO" tugmasi bosilganda:
   ```dart
   context.router.push(const KaskoModuleRoute());
   ```
   ↓
4. **Kasko Module** (`KaskoModule`) - **BU KASKO FUTURES BIRINCHI SAHIFASI**
   - Fayl: `lib/features/kasko/kasko_module.dart`
   - Ko'rsatadi: `KaskoFormSelectionPage`

---

## 📱 KASKO FUTURES SAHIFALARI (TARTIB BO'YICHA)

### 1. **KaskoFormSelectionPage** (Modulning birinchi sahifasi)

**Fayl:** `lib/features/kasko/presentation/pages/kasko_form_selection_page.dart`

**Funksionallik:**

- Avtomobil markasini tanlash (Brand)
- Avtomobil modelini tanlash (Model)
- Komplektatsiya/pozitsiyani tanlash (Position)
- Ishlab chiqarilgan yilni tanlash (Year)

**API chaqiruqlari:**

- `FetchCarsMinimal` - avtomobillar haqida minimal ma'lumotlarni yuklash (brand, model, position)
- `CalculateCarPrice` - barcha parametrlar tanlangandan keyin avtomobil narxini hisoblash

**Navigatsiya:**

- Barcha parametrlar tanlangandan keyin → avtomatik ravishda `KaskoTariffPage` ga o'tadi

---

### 2. **KaskoTariffPage** (Tarif tanlash sahifasi)

**Fayl:** `lib/features/kasko/presentation/pages/kasko_tariff_page.dart`

**Funksionallik:**

- Mavjud sug'urta tariflarini ko'rsatish
- Tarif tanlash (Basic, Standard, Premium va boshqalar)
- Tanlangan tarif asosida polis narxini hisoblash
- Tarif foiziga qarab narxni ko'rsatish

**API chaqiruqlari:**

- `FetchRates` - sug'urta tariflarini yuklash
- `CalculatePolicy` - polis narxini hisoblash

**Navigatsiya:**

- Tarif tanlangandan keyin → hujjatlar kiritish sahifasiga o'tish

---

### 3. **KaskoDocumentDataPage** (Hujjatlar ma'lumotlarini kiritish)

**Fayl:** `lib/features/kasko/presentation/pages/kasko_document_data_page.dart`

**Funksionallik:**

- Avtomobil raqamini kiritish (gosp. raqam)
- VIN raqamini kiritish
- Pasport seriyasi va raqamini kiritish

---

### 4. **KaskoPersonalDataPage** (Shaxsiy ma'lumotlar)

**Fayl:** `lib/features/kasko/presentation/pages/kasko_personal_data_page.dart`

**Funksionallik:**

- Egasi FIO sini kiritish
- Tug'ilgan sanani kiritish
- Telefon raqamini kiritish
- Pasport ma'lumotlarini kiritish

---

### 5. **KaskoOrderDetailsPage** (Buyurtma tafsilotlari)

**Fayl:** `lib/features/kasko/presentation/pages/kasko_order_details_page.dart`

**Funksionallik:**

- Barcha kiritilgan ma'lumotlarni ko'rish
- Buyurtmani tasdiqlash

**API chaqiruqlari:**

- `SaveOrder` - buyurtmani saqlash

---

### 6. **KaskoPaymentTypePage** (To'lov usulini tanlash)

**Fayl:** `lib/features/kasko/presentation/pages/kasko_payment_type_page.dart`

**Funksionallik:**

- To'lov usulini tanlash (Payme yoki Click)
- To'lov havolasini yaratish

**API chaqiruqlari:**

- `CreatePaymentLink` - to'lov havolasini yaratish

---

### 7. **KaskoPaymentPage** (To'lov sahifasi)

**Fayl:** `lib/features/kasko/presentation/pages/kasko_payment_page.dart`

**Funksionallik:**

- To'lov havolasini ko'rsatish
- To'lov holatini tekshirish

**API chaqiruqlari:**

- `CheckPayment` - to'lov holatini tekshirish

---

### 8. **KaskoSuccessPage** (Muvaffaqiyat sahifasi)

**Fayl:** `lib/features/kasko/presentation/pages/kasko_success_page.dart`

**Funksionallik:**

- Polis muvaffaqiyatli rasmiylashtirilganini ko'rsatish

---

## 🔌 API ENDPOINT LAR

**Asosiy URL:** `https://api.kliro.uz`

**Konstantalar fayli:** `lib/core/constants/constants.dart`

### Kasko uchun barcha API endpoint lar:

1. **GET `/insurance/kasko/cars`**

   - To'liq avtomobillar ro'yxatini olish
   - Ishlatiladi: `KaskoRemoteDataSource.getCars()`

2. **GET `/insurance/kasko/cars/minimal`**

   - Minimal ma'lumotlarni olish (brand, model, position)
   - Ishlatiladi: `KaskoRemoteDataSource.getCarsMinimal()`
   - Fallback: agar 404 bo'lsa, to'liq endpoint ishlatiladi

3. **GET `/insurance/kasko/rates`**

   - Sug'urta tariflarini olish
   - Ishlatiladi: `KaskoRemoteDataSource.getRates()`
   - Javob formati: `{result: true, tarif: [{id, name, percent}, ...]}`

4. **POST `/insurance/kasko/car-price`**

   - Avtomobil narxini hisoblash
   - Ishlatiladi: `KaskoRemoteDataSource.calculateCarPrice()`
   - Parametrlar: `carId` (car_position_id), `tarifId`, `year`
   - Javob formati: `{price: 280000000}`

5. **POST `/insurance/kasko/calculate`**

   - Polis narxini hisoblash
   - Ishlatiladi: `KaskoRemoteDataSource.calculatePolicy()`
   - Parametrlar: `carId`, `year`, `price`, `beginDate`, `endDate`, `driverCount`, `franchise`

6. **POST `/insurance/kasko/save`**

   - Buyurtmani saqlash
   - Ishlatiladi: `KaskoRemoteDataSource.saveOrder()`
   - Parametrlar: barcha buyurtma ma'lumotlari (carId, year, price, dates, driverCount, franchise, premium, ownerName, ownerPhone, ownerPassport, carNumber, vin)

7. **POST `/insurance/kasko/payment-link`**

   - To'lov havolasini yaratish
   - Ishlatiladi: `KaskoRemoteDataSource.getPaymentLink()`
   - Parametrlar: `orderId`, `amount`, `returnUrl`, `callbackUrl`

8. **POST `/insurance/kasko/check-payment`**

   - To'lov holatini tekshirish
   - Ishlatiladi: `KaskoRemoteDataSource.checkPaymentStatus()`
   - Parametrlar: `orderId`, `transactionId`

9. **POST `/insurance/kasko/image-upload`**
   - Hujjat rasmlarini yuklash
   - Ishlatiladi: `KaskoRemoteDataSource.uploadImage()`
   - Parametrlar: `file` (MultipartFile), `order_id`, `image_type`

---

## 🏗️ ARXITEKTURA VA STRUKTURA

### Papkalar tuzilishi:

```
lib/features/kasko/
├── data/
│   ├── datasources/
│   │   ├── kasko_remote_data_source.dart  # API chaqiruqlari
│   │   └── kasko_local_data_source.dart   # Lokal saqlash
│   ├── models/                            # DTO modellar (API uchun)
│   │   ├── car_model.dart
│   │   ├── rate_model.dart
│   │   ├── calculate_request.dart
│   │   ├── calculate_response.dart
│   │   └── ... (boshqa modellar)
│   └── repositories/
│       └── kasko_repository_impl.dart     # Repository amalga oshirish
├── domain/
│   ├── entities/                          # Biznes-entitilar
│   │   ├── car_entity.dart
│   │   ├── rate_entity.dart
│   │   ├── calculate_entity.dart
│   │   └── ... (boshqa entitilar)
│   ├── repositories/
│   │   └── kasko_repository.dart          # Repository interfeysi
│   └── usecases/                          # Use cases (biznes-mantiq)
│       ├── get_cars.dart
│       ├── get_cars_minimal.dart
│       ├── get_rates.dart
│       ├── calculate_car_price.dart
│       ├── calculate_policy.dart
│       ├── save_order.dart
│       ├── get_payment_link.dart
│       ├── check_payment_status.dart
│       └── upload_image.dart
├── presentation/
│   ├── bloc/
│   │   ├── kasko_bloc.dart                # BLoC mantiq
│   │   ├── kasko_event.dart               # Voqealar
│   │   └── kasko_state.dart               # Holatlar
│   ├── pages/                             # UI sahifalar
│   │   ├── kasko_form_selection_page.dart
│   │   ├── kasko_tariff_page.dart
│   │   ├── kasko_document_data_page.dart
│   │   ├── kasko_personal_data_page.dart
│   │   ├── kasko_order_details_page.dart
│   │   ├── kasko_payment_type_page.dart
│   │   ├── kasko_payment_page.dart
│   │   └── kasko_success_page.dart
│   ├── widgets/                           # Qayta ishlatiladigan widgetlar
│   │   ├── kasko_car_plate_input.dart
│   │   ├── kasko_passport_input.dart
│   │   ├── kasko_tech_passport_input.dart
│   │   └── ...
│   └── providers/
│       └── kasko_provider.dart            # Provider (BLoC alternativasi)
├── utils/                                  # Utilitlar
│   ├── car_plate_formatter.dart
│   └── upper_case_text_formatter.dart
└── kasko_module.dart                      # Modul kirish nuqtasi
```

---

## 🔄 MA'LUMOTLAR OQIMI (DATA FLOW)

### Clean Architecture qatlamlari:

1. **Presentation Layer** (UI)

   - `KaskoBloc` - holatni boshqarish
   - Sahifalar (Pages) - UI komponentlar
   - Widgetlar (Widgets) - qayta ishlatiladigan komponentlar

2. **Domain Layer** (Biznes-mantiq)

   - Entities - biznes-entitilar
   - Use Cases - biznes-operatsiyalar
   - Repository Interface - ma'lumotlar uchun shartnoma

3. **Data Layer** (Ma'lumotlar)
   - Remote Data Source - API chaqiruqlari
   - Local Data Source - lokal saqlash
   - Repository Implementation - repository amalga oshirish
   - Models - API uchun DTO

### Ma'lumotlar oqimi:

```
UI (Page)
  → BLoC Event
    → Use Case
      → Repository
        → Data Source (Remote/Local)
          → API/Storage
            ↓
          Javob
            ↓
        Data Source → Model (DTO)
            ↓
      Repository → Entity
            ↓
    Use Case → Entity
            ↓
  BLoC State
            ↓
UI yangilanadi
```

---

## 📦 BOG'LIQLIKLAR VA ISHLATILADIGAN PAKETLAR

### Asosiy paketlar:

1. **auto_route** - sahifalar orasida navigatsiya
2. **flutter_bloc** - holatni boshqarish (BLoC pattern)
3. **dio** - API so'rovlari uchun HTTP klient
4. **provider** - holatni boshqarishning alternativ usuli
5. **equatable** - obyektlarni solishtirish
6. **freezed** - immutable klasslarni generatsiya qilish
7. **json_annotation** - JSON serializatsiya
8. **flutter_screenutil** - turli ekranlarga moslashtirish
9. **easy_localization** - lokalizatsiya (uz, ru, en)
10. **intl** - sanalar va raqamlarni formatlash

---

## 🎨 UI/UX XUSUSIYATLARI

### Temalar:

- Yorug' tema (Light Theme)
- Qorong'u tema (Dark Theme)
- `ThemeController` orqali boshqarish

### Ranglar:

- Asosiy rang: `#0085FF` (ko'k)
- Fon: `#F4F6F8` (yorug') / `#121212` (qorong'u)
- Kartochkalar: `#FFFFFF` (yorug') / `#1E1E1E` (qorong'u)

### Adaptivlik:

- Turli ekran o'lchamlari uchun `flutter_screenutil` ishlatiladi
- Dizayn o'lchami: `390x844` (iPhone 12/13 standart)

---

## ⚡ OPTIMIZATSIYALAR

### Ishlash:

1. **JSON parsing uchun Isolate**

   - Katta JSON javoblar alohida isolate da parse qilinadi
   - Main thread ni bloklamaydi
   - Fayl: `kasko_remote_data_source.dart` (`_parseCarsDataFromJson`, `_parseRatesDataFromJson` funksiyalari)

2. **Minimal ma'lumotlarni yuklash**

   - `getCarsMinimal()` - faqat kerakli maydonlarni yuklaydi (brand, model, position)
   - Birinchi sahifada tez yuklash uchun ishlatiladi

3. **Keshlash**

   - Avtomobillar ma'lumotlari BLoC da keshlanadi
   - Takroriy API so'rovlarini oldini oladi

4. **Debounced setState**

   - UI tez-tez yangilanishi uchun debounce ishlatiladi
   - Ortiqcha qayta chizishni oldini oladi

5. **Lazy loading**
   - Ma'lumotlar faqat kerak bo'lganda yuklanadi
   - Tariflar faqat tariflar sahifasida yuklanadi

---

## 🔐 XAVFSIZLIK

### Xatoliklarni boshqarish:

1. **Istisno turlari:**

   - `ApiException` - API xatoliklari (400, 404 va hokazo)
   - `NetworkException` - tarmoq xatoliklari
   - `ServerException` - server xatoliklari (500+)
   - `UnauthorizedException` - avtorizatsiya xatoliklari (401)

2. **Ma'lumotlarni tekshirish:**
   - UI darajasida tekshirish
   - BLoC darajasida tekshirish (`ValidatePersonalData` event)

---

## 📝 BLoC VOQEALARI (Events)

**Fayl:** `lib/features/kasko/presentation/bloc/kasko_event.dart`

### Asosiy voqealar:

1. `FetchCars` - avtomobillarni yuklash
2. `FetchCarsMinimal` - minimal ma'lumotlarni yuklash
3. `FetchRates` - tariflarni yuklash
4. `SelectCarBrand` - markani tanlash
5. `SelectCarModel` - modelni tanlash
6. `SelectCarPosition` - komplektatsiyani tanlash
7. `SelectYear` - yilni tanlash
8. `SelectRate` - tarifni tanlash
9. `CalculateCarPrice` - avtomobil narxini hisoblash
10. `CalculatePolicy` - polisni hisoblash
11. `SaveOrder` - buyurtmani saqlash
12. `CreatePaymentLink` - to'lov havolasini yaratish
13. `CheckPayment` - to'lovni tekshirish
14. `UploadImage` - rasmni yuklash
15. `ValidatePersonalData` - shaxsiy ma'lumotlarni tekshirish
16. `SavePersonalData` - shaxsiy ma'lumotlarni saqlash
17. `SavePaymentMethod` - to'lov usulini saqlash

---

## 📊 BLoC HOLATLARI (States)

**Fayl:** `lib/features/kasko/presentation/bloc/kasko_state.dart`

### Asosiy holatlar:

1. `KaskoInitial` - boshlang'ich holat
2. `KaskoLoading` - ma'lumotlar yuklanmoqda
3. `KaskoCarsLoaded` - avtomobillar yuklandi
4. `KaskoRatesLoaded` - tariflar yuklandi
5. `KaskoCarPriceCalculated` - avtomobil narxi hisoblandi
6. `KaskoPolicyCalculated` - polis hisoblandi
7. `KaskoSavingOrder` - buyurtma saqlanmoqda
8. `KaskoOrderSaved` - buyurtma saqlandi
9. `KaskoPaymentLinkCreated` - to'lov havolasi yaratildi
10. `KaskoPaymentChecked` - to'lov holati tekshirildi
11. `KaskoImageUploaded` - rasm yuklandi
12. `KaskoError` - xatolik
13. `KaskoValidationError` - tekshirish xatosi
14. `KaskoValidationSuccess` - tekshirish muvaffaqiyatli

---

## 🗺️ NAVIGATSIYA

### Marshrutlar (Routes):

**Fayl:** `lib/core/navigation/app_router.dart`

```dart
AutoRoute(page: KaskoModuleRoute.page),           // Kasko moduli
AutoRoute(page: KaskoFormSelectionRoute.page),    // Avtomobil tanlash
AutoRoute(page: KaskoTariffRoute.page),          // Tarif tanlash
AutoRoute(page: KaskoCarsListRoute.page),        // Avtomobillar ro'yxati
AutoRoute(page: KaskoPaymentRoute.page),         // To'lov
AutoRoute(page: KaskoDocumentDataRoute.page),    // Hujjatlar ma'lumotlari
AutoRoute(page: KaskoPersonalDataRoute.page),   // Shaxsiy ma'lumotlar
AutoRoute(page: KaskoOrderDetailsRoute.page),     // Buyurtma tafsilotlari
AutoRoute(page: KaskoPaymentTypeRoute.page),      // To'lov usuli
AutoRoute(page: KaskoSuccessRoute.page),          // Muvaffaqiyat
```

### Navigatsiya tartibi:

```
InsuranceServicesPage
  ↓ (KASKO tugmasi bosiladi)
KaskoModule
  ↓ (ko'rsatadi)
KaskoFormSelectionPage
  ↓ (avtomobil va yil tanlangandan keyin)
KaskoTariffPage
  ↓ (tarif tanlangandan keyin)
KaskoDocumentDataPage
  ↓
KaskoPersonalDataPage
  ↓
KaskoOrderDetailsPage
  ↓
KaskoPaymentTypePage
  ↓
KaskoPaymentPage
  ↓
KaskoSuccessPage
```

---

## 🔧 USE CASES (Biznes-mantiq)

**Papka:** `lib/features/kasko/domain/usecases/`

### Barcha Use Cases:

1. **GetCars** - avtomobillar ro'yxatini olish
2. **GetCarsMinimal** - minimal ma'lumotlarni olish
3. **GetRates** - tariflarni olish
4. **CalculateCarPrice** - avtomobil narxini hisoblash
5. **CalculatePolicy** - polis narxini hisoblash
6. **SaveOrder** - buyurtmani saqlash
7. **GetPaymentLink** - to'lov havolasini olish
8. **CheckPaymentStatus** - to'lov holatini tekshirish
9. **UploadImage** - rasmni yuklash

---

## 📋 MA'LUMOTLAR MODELLARI

### Entity (Domain Layer):

- `CarEntity` - avtomobil
- `RateEntity` - tarif
- `CarPriceEntity` - avtomobil narxi
- `CalculateEntity` - polis hisoblash natijasi
- `SaveOrderEntity` - saqlangan buyurtma
- `PaymentLinkEntity` - to'lov havolasi
- `CheckPaymentEntity` - to'lov holati
- `ImageUploadEntity` - rasm yuklash natijasi

### Model (Data Layer - DTO):

- `CarModel` - API uchun avtomobil modeli
- `RateModel` - API uchun tarif modeli
- `CarPriceRequest/Response` - narx so'rovi/javobi
- `CalculateRequest/Response` - hisoblash so'rovi/javobi
- `SaveOrderRequest/Response` - saqlash so'rovi/javobi
- `PaymentLinkRequest/Response` - to'lov havolasi so'rovi/javobi
- `CheckPaymentRequest/Response` - to'lovni tekshirish so'rovi/javobi
- `ImageUploadResponse` - rasm yuklash javobi

---

## 🎯 ASOSIY FAYLLAR VA ULARNING VAZIFALARI

### 1. **kasko_module.dart**

- Kasko modulining kirish nuqtasi
- Barcha bog'liqliklarni ishga tushiradi (Repository, Use Cases, BLoC)
- Birinchi sahifani ko'rsatadi (`KaskoFormSelectionPage`)

### 2. **kasko_remote_data_source.dart**

- Barcha API chaqiruqlari
- Xatoliklarni boshqarish
- JSON ni isolate da parse qilish

### 3. **kasko_repository.dart** (interfeys)

- Ma'lumotlar bilan ishlash uchun shartnoma
- Ma'lumotlarni olish metodlarini belgilaydi

### 4. **kasko_repository_impl.dart**

- Repository amalga oshirish
- Modellarni Entitilarga o'giradi

### 5. **kasko_bloc.dart**

- Butun modul holatini boshqarish
- Barcha voqealarni qayta ishlash
- Use Cases ni koordinatsiya qilish

### 6. **kasko_form_selection_page.dart**

- Modulning birinchi sahifasi
- Avtomobil parametrlarini tanlash

### 7. **kasko_tariff_page.dart**

- Sug'urta tarifini tanlash
- Polis narxini hisoblash

---

## 🚨 XATOLIKLARNI BOSHQARISH

### Xatolik turlari:

1. **Tarmoq xatoliklari:**

   - Timeout
   - Connection error
   - `NetworkException` sifatida qayta ishlanadi

2. **API xatoliklari:**

   - 400 Bad Request
   - 404 Not Found
   - `ApiException` sifatida qayta ishlanadi

3. **Server xatoliklari:**

   - 500 Internal Server Error
   - 502 Bad Gateway
   - `ServerException` sifatida qayta ishlanadi

4. **Avtorizatsiya xatoliklari:**
   - 401 Unauthorized
   - `UnauthorizedException` sifatida qayta ishlanadi

### Xatoliklarni ko'rsatish:

- UI da xatolik xabari bilan `SnackBar` ko'rsatiladi
- Qayta urinish uchun "Qayta urinish" tugmasi
- BLoC da `KaskoError` holati

---

## 📱 LOKALIZATSIYA

### Qo'llab-quvvatlanadigan tillar:

- O'zbek (uz)
- O'zbek kirill (uz-CYR)
- Rus (ru)
- Ingliz (en)

### Tarjima fayllari:

- `assets/translations/uz.json`
- `assets/translations/uz-CYR.json`
- `assets/translations/ru.json`
- `assets/translations/en.json`

### Ishlatish:

```dart
'insurance.kasko.form_selection.title'.tr()
```

---

## 🔄 MODUL HAYOT SIKLI

### Ishga tushirish:

1. Ilova ishga tushadi (`main.dart`)
2. Dio klienti bilan `ServiceLocator` ishga tushiriladi
3. Foydalanuvchi sug'urta xizmatlari sahifasiga o'tadi
4. "KASKO" ni bosadi
5. `KaskoModule` ochiladi
6. `KaskoModule` barcha bog'liqliklarni yaratadi:
   - Repository
   - Use Cases
   - BLoC
7. `KaskoFormSelectionPage` ko'rsatiladi
8. Avtomobillar haqida minimal ma'lumotlar yuklanadi (`FetchCarsMinimal`)

### Modul ishlashi:

1. Foydalanuvchi avtomobilni tanlaydi → `SelectCarBrand`, `SelectCarModel`, `SelectCarPosition`, `SelectYear`
2. Narx hisoblanadi → `CalculateCarPrice`
3. Tariflar sahifasiga o'tiladi → `KaskoTariffPage`
4. Tariflar yuklanadi → `FetchRates`
5. Tarif tanlanadi → `SelectRate`
6. Polis hisoblanadi → `CalculatePolicy`
7. Hujjatlar va shaxsiy ma'lumotlar kiritiladi
8. Buyurtma saqlanadi → `SaveOrder`
9. To'lov havolasi yaratiladi → `CreatePaymentLink`
10. To'lov holati tekshiriladi → `CheckPayment`
11. Muvaffaqiyat sahifasi ko'rsatiladi → `KaskoSuccessPage`

---

## 📊 KOD STATISTIKASI

### Fayllar soni:

- **Sahifalar:** 8 ta sahifa
- **Widgetlar:** 6 ta widget
- **Use Cases:** 9 ta use case
- **Entitilar:** 8 ta entity
- **Modellar:** 10+ ta model
- **BLoC:** 1 ta bloc, 1 ta event fayli, 1 ta state fayli
- **Data Sources:** 2 ta (remote + local)
- **Repositories:** 1 ta interfeys + 1 ta amalga oshirish

### Modulning umumiy hajmi:

- Taxminan **50+ ta fayl**
- **5000+ qator kod**

---

## ✅ XULOSA

**Kasko Futures** moduli quyidagilarga ega bo'lgan to'liq funksional avtomobil sug'urta moduli:

- ✅ Toza arxitektura (Clean Architecture)
- ✅ BLoC orqali holatni boshqarish
- ✅ Ishlash optimizatsiyasi (isolate, keshlash)
- ✅ To'liq xatoliklarni boshqarish
- ✅ 4 tilda lokalizatsiya
- ✅ Adaptiv dizayn
- ✅ Qorong'u tema qo'llab-quvvatlash

**Modulning birinchi sahifasi:** `KaskoFormSelectionPage` (`KaskoModule` orqali ochiladi)

**Asosiy API lar:** Avtomobillar, tariflar, hisob-kitoblar va to'lovlar bilan ishlash uchun 9 ta endpoint

**Arxitektura:** Clean Architecture tamoyillariga amal qiladi, qatlamlar aniq ajratilgan (Presentation, Domain, Data)
