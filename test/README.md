# Test Documentation

Bu papka KLIRO ilovasi uchun testlarni o'z ichiga oladi.

## Test Strukturasi

```
test/
├── core/
│   └── utils/
│       ├── error_message_helper_test.dart
│       ├── retry_helper_test.dart
│       └── global_error_handler_test.dart
├── domain/
│   └── usecases/
│       └── (use case testlari)
├── presentation/
│   └── pages/
│       └── (widget testlari)
└── widget_test.dart
```

## Testlar Turi

### 1. Unit Testlar
- **Core utilities** - error handling, retry mechanism, va boshqa utility funksiyalar
- **Use cases** - business logic testlari
- **Repositories** - data layer testlari

### 2. Widget Testlar
- **UI komponentlar** - widgetlar va sahifalar
- **BLoC testlar** - state management testlari

### 3. Integration Testlar
- **End-to-end flow** - to'liq user flow testlari

## Testlarni Ishga Tushirish

```bash
# Barcha testlarni ishga tushirish
flutter test

# Muayyan test faylini ishga tushirish
flutter test test/core/utils/error_message_helper_test.dart

# Coverage bilan ishga tushirish
flutter test --coverage
```

## Test Coverage

Maqsad: **80%+ code coverage**

Hozirgi holat:
- Core utilities: ✅
- Use cases: ⏳
- Repositories: ⏳
- Widgets: ⏳

## Qo'shimcha Testlar

Keyingi qadamlar:
1. Use case testlari (GetCurrencies, GetCardOffers, va boshqalar)
2. Repository testlari (mock data source bilan)
3. BLoC testlari (state management)
4. Widget testlari (UI komponentlar)
5. Integration testlari (end-to-end flow)

