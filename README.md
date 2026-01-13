# Kliro

Flutter asosida yaratilgan ko'p funksiyali mobil ilova. Ilova sug'urta, bank xizmatlari, sayohat, aviachiptalar va boshqa moliyaviy xizmatlarni bitta platformada birlashtiradi.

## Ilova Ishlash Ketma-ketligi (User Flow)

### 1. Ilova Boshlanishi (App Initialization)

**Fayl:** `lib/main.dart`

1. **main() funksiyasi** ishga tushadi
   - Stopwatch yaratiladi (performance monitoring uchun)
   - Release mode'da **Sentry** error tracking sozlanadi
   - `_runApp()` chaqiriladi

2. **AppInitializer.initialize()** - Asosiy servislarni ishga tushiradi
   - **WidgetsFlutterBinding** ishga tushadi
   - **SystemChrome** sozlanadi (status bar)
   - **GlobalErrorHandler** ishga tushadi
   - **EasyLocalization** ishga tushadi (til qo'llab-quvvatlash)
   - **Critical Services** ishga tushadi:
     - `ApiConfigService` - API base URL sozlanadi
     - `SharedPreferences` yuklanadi
     - `AuthService` ishga tushadi
     - `ServiceLocator` ishga tushadi (dependency injection)
   - **Non-critical Services** background'da ishga tushadi:
     - `RootService` (locale management)
     - `ThemeController` (dark/light mode)
     - `DateFormatting` (sana formatlari)

3. **EasyLocalization** bilan `App` widget ishga tushadi
   - Qo'llab-quvvatlanadigan tillar: `uz`, `uz-CYR`, `ru`, `en`
   - Fallback til: `en`
   - Translation fayllar: `assets/translations/`

### 2. Splash Screen (Boshlang'ich Ekran)

**Fayl:** `lib/features/splash/presentation/pages/splash_page.dart`

1. **SplashPage** - Ilovaning birinchi ekrani
   - `assets/videos/kliro_intro.mp4` video o'ynatiladi
   - Video 3 soniya davom etadi yoki video tugaguncha
   - Xatolik bo'lsa, 2 soniyadan keyin avtomatik o'tadi
   - Video tugagach → **OnboardingPage** ga o'tadi

### 3. Onboarding (Tanishuv)

**Fayl:** `lib/features/register/presentation/pages/onboarding_page.dart`

1. **Til tanlash** (OnboardingLanguagePage)
   - Foydalanuvchi tilni tanlaydi: O'zbek (Lotin), O'zbek (Kirill), Rus, Ingliz
   - Tanlangan til `LocalePrefs` ga saqlanadi
   - `EasyLocalization` yangilanadi

2. **Onboarding slaydlari** (3 ta slayd)
   - Har bir slaydda rasm, sarlavha va tavsif
   - PageView orqali slaydlar ko'rsatiladi
   - Progress indicator (dots) va Next button
   - Skip tugmasi (oxirgi slaydda ko'rinmaydi)
   - Oxirgi slayddan keyin → **HomeRoute** ga o'tadi

### 4. Asosiy Navigatsiya (Main Navigation)

**Fayl:** `lib/features/home/presentation/pages/main_navigation_page.dart`

**MainNavigationPage** - Asosiy ekran, 3 ta tab bilan:

1. **Home Tab** (`HomePage`)
   - Ilovaning asosiy sahifasi
   - Xizmatlar ro'yxati (sug'urta, bank, sayohat, va h.k.)
   - Banner va reklamalar
   - Tezkor kirishlar

2. **Favorites Tab** (`FavoritesPage`)
   - Foydalanuvchi saqlagan xizmatlar
   - Sevimli mahsulotlar

3. **Profile Tab** (`ProfilePage`)
   - Foydalanuvchi profili
   - Sozlamalar
   - Buyurtmalar tarixi
   - Chiqish (logout)

### 5. Autentifikatsiya (Authentication)

**Fayl:** `lib/features/register/presentation/pages/`

#### 5.1. Ro'yxatdan o'tish (Registration)

1. **RegisterPage** - Ro'yxatdan o'tish formasi
   - Ism, familiya, telefon/email, parol
   - Google Sign In imkoniyati

2. **RegisterVerificationScreen** - OTP tasdiqlash
   - Telefon/email ga yuborilgan kodni kiritish
   - Kod tasdiqlangach → **UserDetailsScreen**

3. **UserDetailsScreen** - Qo'shimcha ma'lumotlar
   - Hudud tanlash
   - Profil to'ldirilgach → **HomeRoute**

#### 5.2. Kirish (Login)

1. **LoginPage** - Kirish formasi
   - Telefon/email va parol
   - Google Sign In
   - "Parolni unutdingizmi?" tugmasi

2. **LoginVerificationPage** - OTP tasdiqlash (agar kerak bo'lsa)
   - Ikki bosqichli autentifikatsiya

3. Muvaffaqiyatli kirish → **HomeRoute**

#### 5.3. Parolni tiklash (Password Reset)

1. **LoginForgotPasswordPage** - Telefon/email kiritish
2. **LoginResetPasswordPage** - OTP tasdiqlash
3. **LoginNewPasswordPage** - Yangi parol o'rnatish

### 6. Asosiy Xizmatlar (Main Services)

#### 6.1. Sug'urta Xizmatlari (Insurance)

**Fayl:** `lib/features/insurance/` va `lib/features/kasko/`

1. **InsuranceServicesPage** - Sug'urta xizmatlari ro'yxati
   - KASKO (avtomobil sug'urtasi)
   - OSAGO (majburiy sug'urta)
   - Travel Insurance (sayohat sug'urtasi)
   - Accident Insurance (baxtsiz hodisa sug'urtasi)

2. **KASKO sug'urta jarayoni:**
   - `KaskoFormSelectionPage` - Forma tanlash
   - `KaskoCarsListPage` - Avtomobillar ro'yxati
   - `KaskoTariffPage` - Tarif tanlash
   - `KaskoDocumentDataPage` - Hujjat ma'lumotlari
   - `KaskoPersonalDataPage` - Shaxsiy ma'lumotlar
   - `KaskoOrderDetailsPage` - Buyurtma tafsilotlari
   - `KaskoPaymentTypePage` - To'lov usuli tanlash
   - `KaskoPaymentPage` - To'lov
   - `KaskoSuccessPage` - Muvaffaqiyatli yakunlanish

3. **OSAGO Module** - Majburiy sug'urta
4. **Travel Module** - Sayohat sug'urtasi
5. **Accident Module** - Baxtsiz hodisa sug'urtasi

#### 6.2. Bank Xizmatlari (Banking)

**Fayl:** `lib/features/bank/`

1. **BankServicesPage** - Bank xizmatlari
   - Kreditlar (Auto Credit, Mortgage, Micro Loan)
   - Depozitlar
   - Kartalar
   - Valyuta kurslari
   - Pul o'tkazmalari

2. **AutoCreditPage** - Avtokredit
3. **MortgagePage** - Ipoteka krediti
4. **MicroLoanPage** - Mikrokredit
5. **DepositPage** - Depozitlar
6. **CardsPage** - Bank kartalari
7. **CurrencyRatesPage** - Valyuta kurslari
8. **CurrencyDetailPage** - Valyuta tafsilotlari
9. **TransferAppsPage** - Pul o'tkazish ilovalari

#### 6.3. Sayohat Xizmatlari (Travel)

**Fayl:** `lib/features/avichiptalar/` va `lib/features/hotel/`

1. **Aviachiptalar (Flight Booking):**
   - `FlightSearchRoute` - Parvoz qidirish
   - `FlightResultsRoute` - Natijalar
   - `FlightDetailsRoute` - Parvoz tafsilotlari
   - `AviaBookingRoute` - Bron qilish
   - `PaymentRoute` - To'lov
   - `FlightConfirmationRoute` - Tasdiqlash
   - `FlightFormalizationRoute` - Rasmiylashtirish
   - `BookingSuccessRoute` - Muvaffaqiyatli bron

2. **Mehmonxonalar (Hotels):**
   - `HotelModuleRoute` - Mehmonxona qidirish va bron qilish

#### 6.4. Profil va Sozlamalar (Profile & Settings)

**Fayl:** `lib/features/profile/`

1. **ProfilePage** - Asosiy profil sahifasi
2. **ProfileEditRoute** - Profilni tahrirlash
3. **MyOrdersRoute** - Buyurtmalar tarixi
4. **BookingDetailsRoute** - Bron tafsilotlari
5. **SupportRoute** - Yordam markazi
6. **SupportChatRoute** - Yordam chat
7. **SecurityRoute** - Xavfsizlik sozlamalari
8. **AboutAppRoute** - Ilova haqida

### 7. Texnik Detallar

#### 7.1. Navigation

- **AutoRoute** - Deklarativ routing
- **AppRouter** - Barcha route'lar markazlashtirilgan
- Deep linking qo'llab-quvvatlanadi

#### 7.2. State Management

- **Provider** - Asosiy state management (KaskoProvider)
- **BLoC Pattern** - Ba'zi feature'lar uchun (RegisterBloc)
- **ServiceLocator** - Dependency injection

#### 7.3. Localization

- **EasyLocalization** - Ko'p tillilik
- Qo'llab-quvvatlanadigan tillar: `uz`, `uz-CYR`, `ru`, `en`
- Translation fayllar: `assets/translations/*.json`

#### 7.4. Theme

- **ThemeController** - Dark/Light mode
- Material 3 dizayn
- Responsive dizayn (ScreenUtil)

#### 7.5. Error Handling

- **Sentry** - Production error tracking
- **GlobalErrorHandler** - Global xatolarni tutish
- Sensitive data filtering (parol, token, PIN)

#### 7.6. Authentication

- **AuthService** - Autentifikatsiya servisi
- Token management (Access Token, Refresh Token)
- SharedPreferences'da ma'lumotlarni saqlash
- Google Sign In qo'llab-quvvatlanadi

### 8. Ilova Strukturasi

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # Asosiy App widget
├── core/                     # Core funksiyalar
│   ├── init/                # Initialization
│   ├── navigation/          # Routing
│   ├── services/           # Services (Auth, Theme, Locale)
│   ├── dio/                # API client
│   └── utils/              # Utilities
└── features/                # Feature modullar
    ├── splash/             # Splash screen
    ├── register/           # Auth (Login/Register)
    ├── home/               # Home page
    ├── insurance/          # Insurance services
    ├── kasko/              # KASKO insurance
    ├── osago/              # OSAGO insurance
    ├── travel/             # Travel insurance
    ├── accident/           # Accident insurance
    ├── bank/               # Banking services
    ├── avichiptalar/       # Flight booking
    ├── hotel/              # Hotel booking
    ├── profile/            # User profile
    └── ...
```

### 9. Asosiy Xususiyatlar

- ✅ Ko'p tillilik (4 til)
- ✅ Dark/Light mode
- ✅ Sug'urta xizmatlari (KASKO, OSAGO, Travel, Accident)
- ✅ Bank xizmatlari (Kreditlar, Depozitlar, Kartalar)
- ✅ Aviachiptalar va mehmonxonalar
- ✅ Google Sign In
- ✅ OTP autentifikatsiya
- ✅ To'lov integratsiyalari
- ✅ Error tracking (Sentry)
- ✅ Responsive dizayn

### 10. Ishlatilgan Texnologiyalar

- **Flutter** - Cross-platform framework
- **Dart** - Programming language
- **AutoRoute** - Navigation
- **Provider** - State management
- **EasyLocalization** - Localization
- **Dio** - HTTP client
- **Sentry** - Error tracking
- **SharedPreferences** - Local storage
- **ScreenUtil** - Responsive design

---

## Developerlar uchun Qo'shimcha Ma'lumot

### Ilovani ishga tushirish

```bash
flutter pub get
flutter run
```

### Environment sozlash

- `lib/core/services/config/api_config_service.dart` - API base URL
- `android/app/google-services.json` - Firebase sozlamalari
- `android/key.properties` - Signing keys

### Testing

Test fayllar `test/` papkasida joylashgan.

---

## Kod Yozish Standartlari (Coding Standards)

### Ranglar va Text Stillar

**MUHIM:** Barcha ranglar va text stillar markazlashtirilgan fayllardan foydalanishi kerak.

#### ✅ To'g'ri:
```dart
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

// Ranglar
Container(
  color: AppColors.primaryBlue,
  child: Text(
    'Salom',
    style: AppTypography.headingL,
  ),
)

// Theme-aware ranglar
final isDark = Theme.of(context).brightness == Brightness.dark;
final backgroundColor = AppColors.getScaffoldBg(isDark);
final textColor = AppColors.getTextColor(isDark);
```

#### ❌ Noto'g'ri:
```dart
// Hardcoded ranglar
Container(
  color: Color(0xFF0095EB), // ❌ AppColors.primaryBlue ishlatish kerak
  child: Text(
    'Salom',
    style: TextStyle(  // ❌ AppTypography dan foydalanish kerak
      fontSize: 20.sp,
      fontWeight: FontWeight.w700,
    ),
  ),
)
```

#### Mavjud Resurslar:

**Ranglar:** `lib/core/constants/app_colors.dart`
- `AppColors.primaryBlue`, `AppColors.white`, `AppColors.black`
- `AppColors.getScaffoldBg(isDark)`, `AppColors.getTextColor(isDark)`
- Barcha mavjud ranglar uchun faylni ko'rib chiqing

**Text Stillar:** `lib/core/constants/app_typography.dart`
- `AppTypography.headingXL`, `AppTypography.headingL`, `AppTypography.headingM`
- `AppTypography.bodyLarge`, `AppTypography.bodyMedium`, `AppTypography.bodyPrimary`
- `AppTypography.buttonPrimary`, `AppTypography.buttonLarge`
- Barcha mavjud stillar uchun faylni ko'rib chiqing

#### Yangi Rang yoki Text Style Qo'shish:

Agar yangi rang yoki text style kerak bo'lsa:
1. `AppColors` yoki `AppTypography` ga qo'shing
2. Mavjud ranglar/stillarni ishlatishga harakat qiling
3. Faqat haqiqatan kerak bo'lganda yangi qo'shing

### Code Review Checklist

Kod review qilishda quyidagilarni tekshiring:

- [ ] Hardcoded `Color(0x...)` ishlatilmaganmi?
- [ ] `Colors.xxx` to'g'ridan-to'g'ri ishlatilmaganmi? (faqat `AppColors` dan)
- [ ] Hardcoded `TextStyle(...)` ishlatilmaganmi? (faqat `AppTypography` dan)
- [ ] Theme-aware ranglar to'g'ri ishlatilganmi? (`AppColors.getXxx(isDark)`)
- [ ] Import'lar to'g'ri qo'shilganmi? (`app_colors.dart`, `app_typography.dart`)

### Linter Qoidalari

`analysis_options.yaml` faylida quyidagi qoidalar yoqilgan:
- `prefer_const_constructors` - Const constructor'larni afzal ko'rish
- `prefer_final_locals` - Final o'zgaruvchilarni afzal ko'rish

**Eslatma:** Hardcoded ranglar va text stillarni avtomatik topish uchun IDE'da "Find in Files" funksiyasidan foydalaning:
- `Color(0x` qidirish
- `Colors.` qidirish
- `TextStyle(` qidirish

---

**Eslatma:** Bu README ilovaning asosiy ishlash ketma-ketligini tushuntirish uchun yaratilgan. Qo'shimcha ma'lumot uchun kod ichidagi comment'larni ko'rib chiqing.
