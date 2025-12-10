# Trust Accident Insurance API Integration

Полная интеграция Flutter для Trust Accident Insurance API с использованием Clean Architecture, BLoC pattern и Dio.

## 📁 Структура проекта

```
lib/features/accident/
├── data/
│   ├── datasources/
│   │   ├── trust_insurance_dio_client.dart      # Dio клиент с Basic Auth
│   │   └── trust_insurance_remote_data_source.dart
│   ├── models/                                  # JSON модели
│   │   ├── tariff_model.dart
│   │   ├── region_model.dart
│   │   ├── person_model.dart
│   │   ├── create_insurance_request.dart
│   │   ├── create_insurance_response.dart
│   │   ├── check_payment_request.dart
│   │   ├── check_payment_response.dart
│   │   ├── payment_urls_model.dart
│   │   ├── policy_info_model.dart
│   │   └── download_urls_model.dart
│   └── repositories/
│       └── trust_insurance_repository.dart
├── presentation/
│   ├── logic/
│   │   └── bloc/
│   │       ├── tariffs/                         # BLoC для тарифов
│   │       ├── regions/                         # BLoC для регионов
│   │       ├── create_insurance/                # BLoC для создания страхования
│   │       └── check_payment/                   # BLoC для проверки оплаты
│   └── pages/
│       ├── tariff_selection_page.dart
│       ├── region_selection_page.dart
│       ├── insurance_form_page.dart
│       ├── payment_screen.dart
│       └── payment_status_page.dart
└── core/
    └── validators/
        └── accident_validators.dart
```

## 🚀 Настройка

### 1. Настройка Basic Auth

✅ **Config fayl yaratildi!** Endi `lib/core/constants/constants.dart` faylida `TrustInsuranceConfig` class mavjud.

**Variant 1: Environment variables (Tavsiya etiladi)**

```bash
flutter run --dart-define=TRUST_API_BASE_URL=https://api.trust-insurance.uz \
           --dart-define=TRUST_LOGIN=your_username \
           --dart-define=TRUST_PASSWORD=your_password
```

**Variant 2: Config faylda to'g'ridan-to'g'ri**

`lib/core/constants/constants.dart` faylida:

```dart
class TrustInsuranceConfig {
  static String get baseUrl => 'https://api.trust-insurance.uz'; // Haqiqiy URL
  static String get username => 'your_username'; // Haqiqiy username
  static String get password => 'your_password'; // Haqiqiy password
}
```

**Environment variables:**
- `TRUST_LOGIN` - логин для Basic Auth
- `TRUST_PASSWORD` - пароль для Basic Auth
- `TRUST_API_BASE_URL` - базовый URL API

### 2. Генерация JSON моделей

После создания моделей выполните:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📋 Использование

### Пример использования в UI

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klero/core/dio/singletons/service_locator.dart';
import 'package:klero/features/accident/presentation/pages/insurance_form_page.dart';
import 'package:klero/features/accident/presentation/logic/bloc/tariffs/tariffs_bloc.dart';
import 'package:klero/features/accident/presentation/logic/bloc/regions/regions_bloc.dart';
import 'package:klero/features/accident/presentation/logic/bloc/create_insurance/create_insurance_bloc.dart';
import 'package:klero/features/accident/presentation/logic/bloc/check_payment/check_payment_bloc.dart';

// В вашем роутере или главном виджете:
MultiBlocProvider(
  providers: [
    BlocProvider.value(value: ServiceLocator.resolve<TariffsBloc>()),
    BlocProvider.value(value: ServiceLocator.resolve<RegionsBloc>()),
    BlocProvider.value(value: ServiceLocator.resolve<CreateInsuranceBloc>()),
    BlocProvider.value(value: ServiceLocator.resolve<CheckPaymentBloc>()),
  ],
  child: InsuranceFormPage(),
)
```

## 🔌 API Endpoints

### 1. GET /trust-insurance/accident/tarifs
Получить список тарифов

**Response:**
```json
[
  {
    "id": 1,
    "insurance_premium": 100000.0,
    "insurance_otv": 5000.0
  }
]
```

### 2. GET /trust-insurance/accident/regions
Получить список регионов

**Response:**
```json
[
  {
    "id": 10,
    "name": "Ташкент"
  }
]
```

### 3. POST /trust-insurance/accident/create
Создать страховку

**Request:**
```json
{
  "start_date": "2025-11-10",
  "tariff_id": 1,
  "person": {
    "pinfl": "30101995750028",
    "pass_sery": "AB",
    "pass_num": "0160608",
    "date_birth": "1999-01-01",
    "last_name": "Rasulov",
    "first_name": "Bunyod",
    "patronym_name": "Ravshan o`g`li",
    "region": 10,
    "phone": "998123456789",
    "address": "Tashkent, Yunusabad district"
  }
}
```

**Response:**
```json
{
  "anketa_id": 12345,
  "payment_urls": {
    "click": "https://...",
    "payme": "https://..."
  }
}
```

### 4. POST /trust-insurance/accident/check-payment
Проверить статус оплаты

**Request:**
```json
{
  "anketa_id": 12345,
  "lan": "uz"
}
```

**Response:**
```json
{
  "status_payment": 2,
  "status_policy": 3,
  "payment_type": "click",
  "policy_info": {
    "policy_number": "POL-12345",
    "issue_date": "2025-11-10",
    "expiry_date": "2026-11-10"
  },
  "download_urls": {
    "pdf": "https://...",
    "qr": "https://..."
  }
}
```

## ✅ Валидация

Все поля формы валидируются:

- **ПИНФЛ**: 14 цифр
- **Серия паспорта**: 2 заглавные буквы
- **Номер паспорта**: 7 цифр
- **Телефон**: начинается с 998, 12 цифр
- **Дата**: формат YYYY-MM-DD
- **Обязательные поля**: фамилия, имя, адрес

## 🎨 UI Flow

1. **TariffSelectionPage** - выбор тарифа
2. **RegionSelectionPage** - выбор региона
3. **InsuranceFormPage** - заполнение формы страхования
4. **PaymentScreen** - выбор способа оплаты (Click/Payme)
5. **PaymentStatusPage** - проверка статуса оплаты и скачивание полиса

## 🔧 Зависимости

Все необходимые зависимости уже включены в `pubspec.yaml`:
- `dio` - HTTP клиент
- `flutter_bloc` - управление состоянием
- `equatable` - сравнение объектов
- `json_annotation` - сериализация JSON
- `dartz` - функциональное программирование

## 📝 Примечания

- ✅ Все модели используют `json_serializable` для генерации `fromJson`/`toJson`
- ✅ BLoC'и используют `Equatable` для сравнения состояний
- ✅ Обработка ошибок реализована через `Either<Failure, Success>` из `dartz`
- ✅ Basic Auth настраивается автоматически через Dio interceptor
- ✅ Config fayl yaratildi - `TrustInsuranceConfig` class
- ✅ ServiceLocator avtomatik config dan credentials oladi
- ✅ AccidentModule yangilandi - yangi sahifalarni ko'rsatadi

## ⚠️ Muhim eslatmalar

1. **Credentials sozlash:** `lib/core/constants/constants.dart` faylida `TrustInsuranceConfig` ni yangilang yoki environment variables ishlating
2. **Eski ekranlar:** `accident_personal_data_screen.dart` hali eski kod ishlatmoqda. Agar kerak bo'lsa, uni yangi BLoC'lar bilan integratsiya qiling
3. **Localization:** Hozircha hardcoded matnlar ishlatilmoqda. Keyinchalik `easy_localization` qo'shish mumkin

