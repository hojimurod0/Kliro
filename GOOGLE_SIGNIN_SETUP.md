# Google Sign-In Sozlash Qo'llanmasi

Bu qo'llanma Google Sign-In'ni sozlash uchun kerakli qadamlarni tushuntiradi.

## Muammo
`ApiException: 10` (DEVELOPER_ERROR) - Bu xato odatda quyidagilar sabab bo'ladi:
- `google-services.json` fayli yo'q
- SHA-1/SHA-256 fingerprint'lar Firebase Console'da qo'shilmagan
- OAuth client ID to'g'ri sozlanmagan

## Qadamlarni bajarish

### 1-qadam: SHA-1 va SHA-256 fingerprint'larni olish

#### Usul 1: Android Studio orqali (Tavsiya etiladi)
1. Android Studio'ni oching
2. Terminal'ni oching (Alt+F12 yoki View → Tool Windows → Terminal)
3. Quyidagi buyruqni bajaring:
   ```bash
   cd android
   gradlew signingReport
   ```
4. Chiqgan natijadan quyidagilarni toping:
   - `SHA1:` - SHA-1 fingerprint
   - `SHA-256:` - SHA-256 fingerprint

#### Usul 2: Command Prompt orqali
1. Command Prompt'ni oching (cmd)
2. Quyidagi buyruqni bajaring (Java SDK path'ini o'zgartiring):
   ```cmd
   keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```
3. Chiqgan natijadan SHA-1 va SHA-256 qiymatlarini ko'chirib oling

#### Usul 3: Flutter orqali
1. Terminal'da:
   ```bash
   cd android
   flutter build apk --debug
   ```
2. Keyin:
   ```bash
   keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```

### 2-qadam: Firebase Console'ga fingerprint'larni qo'shish

1. [Firebase Console](https://console.firebase.google.com/) ga kiring
2. Loyihangizni tanlang (yoki yangi loyiha yarating)
3. **Project Settings** (⚙️) → **Your apps** → **Android app** bo'limiga o'ting
4. Agar Android app yo'q bo'lsa:
   - **"Add app"** tugmasini bosing
   - **Android** ni tanlang
   - Package name: `com.example.klero`
   - App nickname (ixtiyoriy)
   - **"Register app"** ni bosing
5. **"Download google-services.json"** tugmasini bosing
6. SHA-1 va SHA-256 fingerprint'larni qo'shing:
   - **"Add fingerprint"** tugmasini bosing
   - SHA-1 ni qo'shing
   - Yana **"Add fingerprint"** tugmasini bosing
   - SHA-256 ni qo'shing
   - **"Save"** ni bosing

### 3-qadam: google-services.json faylini qo'yish

1. Firebase Console'dan yuklab olgan `google-services.json` faylini oching
2. Faylni quyidagi joyga qo'ying:
   ```
   android/app/google-services.json
   ```
3. **Muhim:** Fayl `android/app/` papkasida bo'lishi kerak, `android/` papkasida emas!

### 4-qadam: google-services.json faylini tekshirish

Fayl ichida quyidagilar bo'lishi kerak:
- `package_name`: `com.example.klero` (to'g'ri package name)
- `oauth_client` bo'limi bo'lishi kerak (Android client ID)

Misol:
```json
{
  "project_info": {
    "project_number": "...",
    "project_id": "...",
    "storage_bucket": "..."
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "...",
        "android_client_info": {
          "package_name": "com.example.klero"
        }
      },
      "oauth_client": [
        {
          "client_id": "...",
          "client_type": 1
        },
        {
          "client_id": "...",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "..."
        }
      ]
    }
  ]
}
```

### 5-qadam: OAuth Consent Screen sozlash

1. [Google Cloud Console](https://console.cloud.google.com/) ga kiring
2. Firebase loyihangiz bilan bog'langan loyihani tanlang
3. **APIs & Services** → **OAuth consent screen** ga o'ting
4. Agar test mode'da bo'lsa, test users qo'shing:
   - **"Add Users"** tugmasini bosing
   - Test qilmoqchi bo'lgan email'larni qo'shing
   - **"Save"** ni bosing

### 6-qadam: Loyihani qayta build qilish

1. Terminal'da quyidagi buyruqlarni bajaring:
   ```bash
   flutter clean
   cd android
   gradlew clean
   cd ..
   flutter pub get
   flutter run
   ```

## Tekshiruvlar

Agar muammo davom etsa, quyidagilarni tekshiring:

1. **Package name mosligi:**
   - `android/app/build.gradle.kts` da: `applicationId = "com.example.klero"`
   - `google-services.json` da: `package_name` ham `com.example.klero` bo'lishi kerak

2. **google-services.json fayli to'g'ri joyda:**
   - Fayl `android/app/google-services.json` da bo'lishi kerak
   - `android/google-services.json` da emas!

3. **Google Services plugin qo'llangan:**
   - `android/build.gradle.kts` da Google Services plugin classpath qo'shilgan
   - `android/app/build.gradle.kts` da plugin qo'llangan

4. **SHA fingerprint'lar qo'shilgan:**
   - Firebase Console'da SHA-1 va SHA-256 fingerprint'lar qo'shilgan
   - Fingerprint'lar to'g'ri ko'chirilgan (bo'sh joylar yo'q)

## Yordam

Agar muammo davom etsa:
1. Firebase Console'da loyiha sozlamalarini qayta tekshiring
2. `google-services.json` faylini qayta yuklab oling
3. Loyihani to'liq clean qilib qayta build qiling
4. Log'larni tekshiring - qaysi xato chiqayotganini ko'ring

