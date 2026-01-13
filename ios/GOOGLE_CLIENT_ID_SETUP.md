# iOS Google Client ID Sozlash Qo'llanmasi

## ⚠️ Muammo

`Info.plist` da `YOUR_CLIENT_ID` placeholder qolgan. Bu iOS'da Google Sign-In ishlamasligiga sabab bo'ladi.

## 📋 Qadamlar

### 1-qadam: Google Client ID olish

#### Firebase Console orqali:
1. [Firebase Console](https://console.firebase.google.com/) ga kiring
2. Loyihangizni tanlang
3. **Project Settings** (⚙️) → **Your apps** → **iOS app** bo'limiga o'ting
4. Agar iOS app yo'q bo'lsa:
   - **"Add app"** tugmasini bosing
   - **iOS** ni tanlang
   - Bundle ID: `$(PRODUCT_BUNDLE_IDENTIFIER)` (Xcode'dan oling)
   - App nickname (ixtiyoriy)
   - **"Register app"** ni bosing
5. **GoogleService-Info.plist** faylini yuklab oling

#### Google Cloud Console orqali:
1. [Google Cloud Console](https://console.cloud.google.com/) ga kiring
2. Firebase loyihangiz bilan bog'langan loyihani tanlang
3. **APIs & Services** → **Credentials** ga o'ting
4. **OAuth 2.0 Client IDs** bo'limida iOS client ID ni toping
5. **Client ID** ni ko'chirib oling (format: `123456789-abcdefghijklmnop.apps.googleusercontent.com`)

### 2-qadam: Info.plist ni tuzatish

`ios/Runner/Info.plist` faylini oching va quyidagini toping:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

**YOUR_CLIENT_ID** ni **to'liq Client ID** bilan almashtiring, lekin **reversed format**da:

#### Reversed format:
Agar Client ID: `123456789-abcdefghijklmnop.apps.googleusercontent.com` bo'lsa,
reversed format: `com.googleusercontent.apps.123456789-abcdefghijklmnop`

#### Misol:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.123456789-abcdefghijklmnop</string>
        </array>
    </dict>
</array>
```

### 3-qadam: GoogleService-Info.plist qo'shish

1. Firebase Console'dan yuklab olgan `GoogleService-Info.plist` faylini `ios/Runner/` papkasiga qo'ying
2. Xcode'da loyihani oching
3. Faylni loyihaga qo'shing (drag & drop)
4. "Copy items if needed" ni belgilang

### 4-qadam: Associated Domains qo'shish (Universal Links uchun)

`ios/Runner/Info.plist` ga quyidagini qo'shing:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:api.kliro.uz</string>
</array>
```

**Yoki** Xcode orqali:
1. Xcode'da loyihani oching
2. Runner target'ni tanlang
3. **Signing & Capabilities** tab'ga o'ting
4. **+ Capability** tugmasini bosing
5. **Associated Domains** ni qo'shing
6. `applinks:api.kliro.uz` qo'shing

### 5-qadam: apple-app-site-association fayli (Server'da)

Server'da quyidagi fayl bo'lishi kerak:
```
https://api.kliro.uz/.well-known/apple-app-site-association
```

**Fayl format (JSON, Content-Type: application/json):**
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.BUNDLE_ID",
        "paths": ["/auth/google/callback/*"]
      }
    ]
  }
}
```

**TEAM_ID va BUNDLE_ID ni topish:**
- TEAM_ID: [Apple Developer Account](https://developer.apple.com/account/) → Membership → Team ID
- BUNDLE_ID: Xcode → Runner target → General → Bundle Identifier

**Misol:**
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "ABC123XYZ.com.kliro.app",
        "paths": ["/auth/google/callback/*"]
      }
    ]
  }
}
```

### 6-qadam: Verification

#### 1. Xcode'da build qilish:
```bash
cd ios
pod install
cd ..
flutter build ios
```

#### 2. Test qilish:
1. Simulator yoki real device'da app'ni o'rnatish
2. Browser'da quyidagi linkni ochish:
   ```
   https://api.kliro.uz/auth/google/callback?code=test
   ```
3. App avtomatik ochilishi kerak

#### 3. Apple App Site Association Validator:
- [Branch.io Universal Links Validator](https://branch.io/resources/aasa-validator/)
- URL: `https://api.kliro.uz/.well-known/apple-app-site-association`

## ⚠️ Muhim eslatmalar

1. **Content-Type:** `apple-app-site-association` fayli **Content-Type: application/json** bilan serve qilinishi kerak
2. **No extension:** Fayl nomi `.well-known/apple-app-site-association` (extension yo'q!)
3. **HTTPS:** Server HTTPS bilan ishlashi kerak
4. **Cache:** iOS cache'ini tozalash kerak bo'lishi mumkin

## 🔍 Muammolarni hal qilish

### Google Sign-In ishlamasa:

1. **Client ID to'g'rimi?**
   - Reversed format ishlatilganmi?
   - Bo'sh joylar yo'qmi?

2. **GoogleService-Info.plist qo'shilganmi?**
   - Fayl `ios/Runner/` da bormi?
   - Xcode'da loyihaga qo'shilganmi?

3. **Bundle ID mosmi?**
   - `Info.plist` dagi Bundle ID
   - Firebase Console'dagi Bundle ID
   - Xcode'dagi Bundle Identifier

### Universal Links ishlamasa:

1. **Associated Domains qo'shilganmi?**
   - Info.plist da
   - Xcode Capabilities'da

2. **apple-app-site-association mavjudmi?**
   ```bash
   curl https://api.kliro.uz/.well-known/apple-app-site-association
   ```

3. **Content-Type to'g'rimi?**
   ```bash
   curl -I https://api.kliro.uz/.well-known/apple-app-site-association
   ```
   `Content-Type: application/json` bo'lishi kerak

4. **Path mosmi?**
   - `Info.plist`: Associated Domain path
   - `apple-app-site-association`: paths array

## 📚 Qo'shimcha manbalar

- [Google Sign-In for iOS](https://developers.google.com/identity/sign-in/ios)
- [Apple App Site Association](https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app)
- [Universal Links Troubleshooting](https://developer.apple.com/ios/universal-links/)

