# Travel Insurance Flow - Flutter приложение

Полнофункциональное Flutter приложение для оформления страховки путешествий с использованием Clean Architecture, BLoC паттерна и строгой валидации.

## Структура проекта

Проект следует принципам Clean Architecture и разделен на слои:

```
lib/
├── core/                    # Основные компоненты
│   ├── constants/          # Константы и конфигурация
│   ├── errors/             # Исключения и ошибки
│   ├── network/            # Сетевой слой (Dio)
│   ├── di/                 # Dependency Injection (get_it)
│   └── utils/              # Утилиты (даты, валидация)
├── data/                   # Слой данных
│   ├── models/             # Модели данных (json_serializable)
│   ├── datasources/         # Удаленные источники данных
│   └── repositories/       # Реализация репозиториев
├── domain/                 # Бизнес-логика
│   ├── entities/           # Сущности домена
│   ├── repositories/       # Интерфейсы репозиториев
│   └── usecases/           # Use cases
└── presentation/           # UI слой
    ├── blocs/              # BLoC для управления состоянием
    ├── pages/              # Страницы приложения
    └── widgets/            # Переиспользуемые виджеты
```

## Основной поток (Flow)

Приложение реализует следующий поток:

1. **Purpose** → Выбор цели путешествия и стран назначения
2. **Details** → Ввод деталей путешествия (даты, путешественники)
3. **Calculate** → Расчет стоимости страховки
4. **Save** → Сохранение полиса с данными страхователя
5. **Check** → Проверка статуса сохраненного полиса

## Установка и запуск

### Предварительные требования

- Flutter SDK (версия 3.8.1 или выше)
- Dart SDK
- Android Studio / VS Code с расширениями Flutter

### Шаги установки

1. **Клонируйте репозиторий** (если необходимо)

2. **Установите зависимости:**
```bash
flutter pub get
```

3. **Сгенерируйте код для моделей:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Запустите тесты:**
```bash
flutter test
```

5. **Запустите приложение:**
```bash
flutter run
```

## Конфигурация

### Изменение базового URL API

Базовый URL по умолчанию: `http://localhost:8080`

Для изменения базового URL отредактируйте файл `lib/core/constants/config.dart`:

```dart
static String get baseUrl {
  const String? envUrl = String.fromEnvironment('API_BASE_URL');
  return envUrl ?? 'http://your-api-url.com';
}
```

Или используйте переменные окружения при запуске:

```bash
flutter run --dart-define=API_BASE_URL=http://your-api-url.com
```

### Включение/отключение логирования HTTP

Логирование включено по умолчанию. Для отключения измените `lib/core/constants/config.dart`:

```dart
static bool get enableLogging {
  return false; // или используйте переменные окружения
}
```

## API Endpoints

Приложение использует следующие endpoints:

- `POST /travel/purpose` - Создание цели путешествия
- `POST /travel/details` - Отправка деталей путешествия
- `POST /travel/calculate` - Расчет стоимости
- `POST /travel/save` - Сохранение полиса
- `POST /travel/check` - Проверка статуса сессии
- `GET /travel/country` - Получение списка стран
- `POST /travel/tarifs` - Получение тарифов по стране

Подробные примеры запросов см. в `docs/api_samples.md`

## Валидация

Приложение включает строгую валидацию всех полей:

- **Серия паспорта**: Ровно 2 заглавные буквы (A-Z)
- **Номер паспорта**: Ровно 7 цифр
- **ПИНФЛ**: Ровно 14 цифр
- **Телефон**: 9-15 цифр, может начинаться с +
- **Дата**: Формат DD-MM-YYYY, не раньше 01-01-1900
- **Даты путешествия**: Дата начала <= даты окончания

## Использование

### Демонстрационное приложение

Для запуска демонстрационного приложения используйте:

```bash
flutter run -t lib/main_travel_demo.dart
```

### Интеграция в существующее приложение

1. Инициализируйте зависимости в `main.dart`:

```dart
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init(); // Инициализация DI
  runApp(MyApp());
}
```

2. Используйте TravelSessionBloc в вашем приложении:

```dart
BlocProvider(
  create: (_) => getIt<TravelSessionBloc>(),
  child: TravelPurposePage(),
)
```

## Тестирование

### Unit тесты

Запуск всех unit тестов:

```bash
flutter test
```

### Widget тесты

Запуск widget тестов:

```bash
flutter test test/widget_test.dart
```

## Зависимости

### Основные зависимости

- `flutter_bloc: ^8.1.4` - Управление состоянием
- `dio: ^5.7.0` - HTTP клиент
- `get_it: ^7.7.0` - Dependency Injection
- `json_annotation: ^4.9.0` - Аннотации для JSON
- `equatable: ^2.0.5` - Сравнение объектов
- `formz: ^0.6.1` - Валидация форм
- `intl: ^0.20.2` - Интернационализация и форматирование дат
- `dartz: ^0.10.1` - Функциональное программирование (Either)

### Dev зависимости

- `build_runner: ^2.4.9` - Генерация кода
- `json_serializable: ^6.8.0` - Генерация JSON сериализации
- `mockito: ^5.4.4` - Моки для тестирования

## Формат дат

Все даты в приложении используют формат **DD-MM-YYYY** (например, `12-12-2025`).

## Примеры использования API

См. файл `docs/api_samples.md` для примеров запросов и ответов API.

## Troubleshooting

### Ошибка генерации кода

Если возникают ошибки при генерации кода:

```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Ошибки импорта

Убедитесь, что все зависимости установлены:

```bash
flutter pub get
```

### Проблемы с сетью

Проверьте настройки базового URL в `lib/core/constants/config.dart` и убедитесь, что сервер доступен.

## Лицензия

Этот проект создан для демонстрационных целей.

## Контакты

Для вопросов и предложений создайте issue в репозитории проекта.

