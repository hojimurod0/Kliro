# Trust Insurance API Config Sozlash

## ⚠️ MUHIM: Config sozlash

Trust Insurance API ishlashi uchun Basic Auth credentials sozlash kerak!

## 🚀 Tezkor sozlash

### Variant 1: Environment Variables (Tavsiya etiladi)

```bash
flutter run --dart-define=TRUST_API_BASE_URL=https://api.trust-insurance.uz \
           --dart-define=TRUST_LOGIN=your_username \
           --dart-define=TRUST_PASSWORD=your_password
```

### Variant 2: Config faylda to'g'ridan-to'g'ri

`lib/core/constants/constants.dart` faylida `TrustInsuranceConfig` class ni yangilang:

```dart
class TrustInsuranceConfig {
  static String get baseUrl => 'https://api.trust-insurance.uz'; // Haqiqiy URL
  static String get username => 'your_username'; // Haqiqiy username
  static String get password => 'your_password'; // Haqiqiy password
}
```

## ✅ Config tekshiruvi

Config to'g'ri sozlanganligini tekshirish:

```dart
if (TrustInsuranceConfig.isConfigured) {
  print('Config to\'g\'ri sozlangan');
} else {
  print('Config sozlash kerak!');
  print(TrustInsuranceConfig.configInfo);
}
```

## 🔒 Xavfsizlik

**MUHIM:** 
- ❌ Git'ga credentials commit qilmang!
- ✅ Environment variables ishlating
- ✅ `.env` fayl ishlatsangiz, `.gitignore` ga qo'shing

## 📝 Qo'shimcha ma'lumot

Batafsil ma'lumot: `lib/features/accident/README.md`

