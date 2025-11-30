# OSAGO Sug'urta Logikasi - Batafsil Tushuntirish

## 📋 Umumiy Ma'lumot

OSAGO (Obligatory State Auto Insurance) - majburiy avtomobil sug'urtasi tizimi. Ushbu hujjatda barcha API so'rovlari, ma'lumotlar oqimi va muammolar batafsil tushuntirilgan.

---

## 🔄 OSAGO Flow (Ish Jarayoni)

### 1️⃣ **BIRINCHI SAHIFA: Avtomobil Ma'lumotlari** (`osago_vehicle_screen.dart`)

#### ✅ **Qanday Ma'lumotlar Olinadi:**

- **Avtomobil raqami**: Region (01) + Raqam (A 000 AA)
- **Passport seriyasi va raqami**: Seriya (AA) + Raqam (1234567)
- **Tex passport**: Seriya (AAA) + Raqam (1234567)
- **Sug'urta muddati**: "1 yil" yoki "6 oy" (dropdown)
- **OSAGO turi**: "Cheklanmagan", "VIP", "Oddiy" (dropdown)

#### ❌ **Muammolar:**

1. **Brand va Model yo'q** - Hozirda "Не указано" deb hardcode qilingan
2. **Tug'ilgan sana yo'q** - Default: `DateTime(1990, 1, 1)`
3. **Period ID mapping yo'q** - "1 yil" va "6 oy" string sifatida yuboriladi, lekin API "6" yoki "12" raqamini kutadi
4. **OSAGO turi ishlatilmaydi** - `_typeCtrl` to'ldiriladi, lekin hech qanday joyda ishlatilmaydi

#### 📤 **Yuboriladigan Ma'lumotlar:**

```dart
OsagoVehicle {
  brand: "Не указано",           // ❌ Muammo: Hardcode
  model: "Не указано",            // ❌ Muammo: Hardcode
  gosNumber: "01A000AA",          // ✅ To'g'ri
  techSeria: "AAA",               // ✅ To'g'ri
  techNumber: "1234567",          // ✅ To'g'ri
  ownerPassportSeria: "AA",       // ✅ To'g'ri
  ownerPassportNumber: "1234567", // ✅ To'g'ri
  ownerBirthDate: DateTime(1990,1,1), // ❌ Muammo: Default
  isOwner: true                   // ✅ To'g'ri
}

OsagoDriver {
  passportSeria: "AA",            // ✅ To'g'ri
  passportNumber: "1234567",      // ✅ To'g'ri
  driverBirthday: DateTime(1990,1,1), // ❌ Muammo: Default
  relative: 0,                    // ✅ To'g'ri
  name: null,                     // ⚠️ Bo'sh
  licenseSeria: null,             // ⚠️ Bo'sh
  licenseNumber: null             // ⚠️ Bo'sh
}
```

---

### 2️⃣ **IKKINCHI SAHIFA: Sug'urta Kompaniyasi** (`osago_company_screen.dart`)

#### ✅ **Qanday Ma'lumotlar Olinadi:**

- **Kompaniya**: "Gross Insurance" yoki "NEO Insurance" (dropdown)
- **Boshlanish sanasi**: DatePicker orqali (dd/mm/yyyy)
- **Telefon raqami**: +998 formatida

#### ❌ **Muammolar:**

1. **Period ID mapping yo'q** - "6 oy" hardcode, lekin API "6" yoki "12" raqamini kutadi
2. **Number Drivers ID muammosi** - "1" deb hardcode, lekin calc response dan kelishi kerak

#### 📤 **Yuboriladigan Ma'lumotlar:**

```dart
OsagoInsurance {
  provider: "gross" yoki "neo",   // ✅ To'g'ri
  companyName: "Gross Insurance",  // ✅ To'g'ri
  periodId: "6",                   // ⚠️ Hardcode, mapping yo'q
  numberDriversId: "1",            // ❌ Muammo: Hardcode, calc dan kelishi kerak
  startDate: DateTime,             // ✅ To'g'ri
  phoneNumber: "998331108810",     // ✅ To'g'ri (normalized)
  ownerInn: "",                    // ⚠️ Bo'sh
  isUnlimited: false              // ✅ To'g'ri
}
```

---

## 🌐 API So'rovlari (3 ta Endpoint)

### **1. POST `/osago/calc` - Hisoblash**

#### 📤 **Yuboriladigan Ma'lumotlar (CalcRequest):**

```json
{
  "gos_number": "01A000AA", // Avtomobil raqami (space yo'q)
  "tech_sery": "AAA", // Tex passport seriyasi (UPPERCASE)
  "tech_number": "1234567", // Tex passport raqami
  "owner__pass_seria": "AA", // Passport seriyasi (UPPERCASE)
  "owner__pass_number": "1234567", // Passport raqami
  "period_id": "6", // "6" yoki "12" (oylar)
  "number_drivers_id": "1" // ⚠️ Muammo: Hardcode, API dan kelishi kerak
}
```

#### 📥 **Qabul Qilinadigan Ma'lumotlar (CalcResponse):**

```json
{
  "success": true,
  "data": {
    "session_id": "1308e0f6-942f-4da3-a58c-e4425d6f1ebf",
    "calc": {
      "amount_uzs": 275000.0,
      "juridik": {
        "name": "Owner Name" // ⚠️ Ba'zida bo'lmaydi
      },
      "requestsData": {
        "owner_name": "Owner Name", // ⚠️ Ba'zida bo'lmaydi
        "number_drivers_id": "5" // ✅ API dan keladi
      }
    }
  }
}
```

#### ✅ **Qaytariladigan Ma'lumotlar:**

- `sessionId` - Keyingi so'rovlar uchun
- `amount` - Sug'urta summasi (UZS)
- `currency` - "UZS"
- `ownerName` - Egasining ismi (API dan)
- `numberDriversId` - Haydovchilar soni ID (API dan) ⚠️ **MUAMMO: Ba'zida null**

---

### **2. POST `/osago/create` - Polis Yaratish**

#### 📤 **Yuboriladigan Ma'lumotlar (CreateRequest):**

```json
{
  "provider": "gross", // "gross" yoki "neo"
  "session_id": "1308e0f6-...", // Calc dan kelgan
  "drivers": [
    {
      "passport_seria": "AD", // Passport seriyasi
      "passport_number": "7784524", // Passport raqami
      "driver_birthday": "1990-01-01", // Tug'ilgan sana
      "relative": 0, // 0 = egasi, 1+ = qarindosh
      "name": null, // ⚠️ Bo'sh bo'lishi mumkin
      "license_seria": null, // ⚠️ Bo'sh bo'lishi mumkin
      "license_number": null // ⚠️ Bo'sh bo'lishi mumkin
    }
  ],
  "applicant_is_driver": true, // Egasining haydovchi ekanligi
  "phone_number": "998331108810", // Telefon (998 bilan)
  "number_drivers_id": "5", // ⚠️ MUAMMO: Calc response dan kelishi kerak
  "owner__inn": "", // ⚠️ Bo'sh
  "applicant__license_seria": "", // ⚠️ Bo'sh (agar applicant_is_driver=true bo'lsa)
  "applicant__license_number": "", // ⚠️ Bo'sh (agar applicant_is_driver=true bo'lsa)
  "start_date": "29.11.2025" // Boshlanish sanasi (dd.MM.yyyy)
}
```

#### ❌ **MUAMMOLAR:**

1. **`number_drivers_id` noto'g'ri** - "5" yuboriladi, lekin API boshqa qiymatni kutadi
2. **`applicant__license_seria` va `applicant__license_number` bo'sh** - Agar `applicant_is_driver=true` bo'lsa, to'ldirilishi kerak
3. **`owner__inn` bo'sh** - Juridik shaxslar uchun kerak bo'lishi mumkin

#### 📥 **Qabul Qilinadigan Ma'lumotlar (CreateResponse):**

```json
{
  "success": true,
  "data": {
    "session_id": "1308e0f6-...",
    "policy_number": "OSAGO-35153",
    "amount": 275000.0,
    "currency": "UZS",
    "payment_url": "...",
    "pay": {
      "click": "...",
      "payme": "..."
    }
  }
}
```

---

### **3. POST `/osago/check` - Polis Holatini Tekshirish**

#### 📤 **Yuboriladigan Ma'lumotlar (CheckRequest):**

```json
{
  "session_id": "1308e0f6-942f-4da3-a58c-e4425d6f1ebf"
}
```

#### 📥 **Qabul Qilinadigan Ma'lumotlar (CheckResponse):**

```json
{
  "success": true,
  "data": {
    "session_id": "1308e0f6-...",
    "status": "ready", // "ready", "pending", "failed"
    "policy_number": "OSAGO-35153",
    "issued_at": "2025-11-29",
    "amount": 275000.0,
    "currency": "UZS",
    "download_url": "https://..."
  }
}
```

#### ✅ **Logika:**

- Agar `status != "ready"` bo'lsa, 3 marta qayta urinib ko'riladi (har 3 soniyada)
- Agar 3 marta urinishdan keyin ham tayyor bo'lmasa, xatolik ko'rsatiladi

---

## 🔴 MUAMMOLAR RO'YXATI

### **1. Kritik Muammolar (Ishlamaydi):**

#### ❌ **`number_drivers_id` Muammosi**

- **Muammo**: `osago_company_screen.dart` da "1" deb hardcode qilingan
- **Muammo**: Calc response dan kelgan `numberDriversId` null bo'lishi mumkin
- **Muammo**: Create request da "5" yuboriladi, lekin API boshqa qiymatni kutadi
- **Yechim**: Calc response dan kelgan `numberDriversId` ni ishlatish kerak

#### ❌ **Period ID Mapping Yo'q**

- **Muammo**: "1 yil" va "6 oy" string sifatida saqlanadi
- **Muammo**: API "6" yoki "12" raqamini kutadi
- **Yechim**: Mapping qo'shish kerak: "1 yil" -> "12", "6 oy" -> "6"

#### ❌ **Brand va Model Yo'q**

- **Muammo**: "Не указано" deb hardcode qilingan
- **Muammo**: API dan kelishi kerak yoki formada to'ldirilishi kerak
- **Yechim**: Formaga qo'shish yoki API dan olish

#### ❌ **Tug'ilgan Sana Yo'q**

- **Muammo**: Default `DateTime(1990, 1, 1)` ishlatiladi
- **Muammo**: Formada to'ldirilmaydi
- **Yechim**: Formaga DatePicker qo'shish

### **2. Katta Muammolar (Ishlaydi, lekin noto'g'ri):**

#### ⚠️ **OSAGO Turi Ishlatilmaydi**

- **Muammo**: `_typeCtrl` to'ldiriladi, lekin hech qanday joyda ishlatilmaydi
- **Yechim**: API ga yuborish yoki calc request ga qo'shish

#### ⚠️ **Applicant License Ma'lumotlari Bo'sh**

- **Muammo**: Agar `applicant_is_driver=true` bo'lsa, license ma'lumotlari bo'sh
- **Yechim**: Formaga qo'shish yoki driver dan olish

#### ⚠️ **Owner INN Bo'sh**

- **Muammo**: Juridik shaxslar uchun kerak bo'lishi mumkin
- **Yechim**: Formaga qo'shish (optional)

### **3. Kichik Muammolar (Ishlaydi, lekin yaxshilash mumkin):**

#### ⚠️ **Driver Name Bo'sh**

- **Muammo**: Driver name null
- **Yechim**: Calc response dan `ownerName` ishlatiladi (fallback)

#### ⚠️ **Error Handling**

- **Muammo**: Ba'zi xatoliklar to'g'ri ko'rsatilmaydi
- **Yechim**: Xatolik xabarlarini yaxshilash

---

## ✅ QO'SHILISHI KERAK BO'LGAN FUNKSIYALAR

### **1. Formaga Qo'shish Kerak:**

- ✅ **Tug'ilgan sana** - DatePicker
- ✅ **Brand va Model** - Dropdown yoki API dan olish
- ✅ **Period ID mapping** - "1 yil" -> "12", "6 oy" -> "6"
- ✅ **OSAGO turi** - API ga yuborish
- ✅ **Applicant License** - Agar `applicant_is_driver=true` bo'lsa
- ⚠️ **Owner INN** - Optional, juridik shaxslar uchun

### **2. API Integratsiyasini Yaxshilash:**

- ✅ **Calc response dan `numberDriversId` ni to'g'ri olish**
- ✅ **Calc response dan `ownerName` ni to'g'ri olish**
- ✅ **Error handling yaxshilash**
- ✅ **Loading states yaxshilash**

### **3. Validatsiya Qo'shish:**

- ✅ **Telefon raqami validatsiyasi** - 9 ta raqam
- ✅ **Passport raqami validatsiyasi** - 7 ta raqam
- ✅ **Tex passport raqami validatsiyasi** - 7 ta raqam
- ✅ **Avtomobil raqami validatsiyasi** - Format tekshiruvi

---

## 📊 MA'LUMOTLAR OQIMI DIAGRAMMASI

```
1. USER INPUT (osago_vehicle_screen.dart)
   ├─ Avtomobil raqami
   ├─ Passport ma'lumotlari
   ├─ Tex passport ma'lumotlari
   ├─ Sug'urta muddati
   └─ OSAGO turi (ishlatilmaydi)

2. BLoC EVENT: LoadVehicleData
   └─ OsagoVehicle + OsagoDriver[] saqlanadi

3. USER INPUT (osago_company_screen.dart)
   ├─ Kompaniya
   ├─ Boshlanish sanasi
   └─ Telefon raqami

4. BLoC EVENT: LoadInsuranceCompany
   └─ OsagoInsurance saqlanadi
   └─ CalcRequested avtomatik ishga tushadi

5. API CALL: POST /osago/calc
   ├─ Request: CalcRequest
   └─ Response: CalcResponse
      ├─ sessionId
      ├─ amount
      ├─ ownerName
      └─ numberDriversId ⚠️ (ba'zida null)

6. BLoC STATE: OsagoCalcSuccess
   └─ User preview sahifaga o'tadi

7. USER ACTION: Create Policy
   └─ BLoC EVENT: CreatePolicyRequested

8. API CALL: POST /osago/create
   ├─ Request: CreateRequest
   │  ├─ sessionId (calc dan)
   │  ├─ numberDriversId (calc dan) ⚠️ (muammo)
   │  └─ drivers[]
   └─ Response: CreateResponse
      ├─ policyNumber
      ├─ paymentUrl
      └─ pay {click, payme}

9. BLoC STATE: OsagoCreateSuccess
   └─ User payment sahifaga o'tadi

10. USER ACTION: Payment Selected
    └─ BLoC EVENT: PaymentSelected

11. USER ACTION: Check Status
    └─ BLoC EVENT: CheckPolicyRequested

12. API CALL: POST /osago/check
    ├─ Request: CheckRequest
    └─ Response: CheckResponse
       └─ status: "ready" | "pending" | "failed"

13. BLoC STATE: OsagoCheckSuccess
    └─ User success sahifaga o'tadi
```

---

## 🔧 TAVSIYALAR

### **1. Darhol Tuzatish Kerak:**

1. ✅ **Period ID mapping** qo'shish
2. ✅ **Calc response dan `numberDriversId` ni to'g'ri ishlatish**
3. ✅ **Tug'ilgan sana** formaga qo'shish
4. ✅ **Brand va Model** formaga qo'shish yoki API dan olish

### **2. Qisqa Muddatda:**

1. ✅ **OSAGO turi** ni API ga yuborish
2. ✅ **Applicant License** ma'lumotlarini to'ldirish
3. ✅ **Error handling** yaxshilash

### **3. Uzoq Muddatda:**

1. ✅ **Owner INN** qo'shish (juridik shaxslar uchun)
2. ✅ **Multiple drivers** qo'shish
3. ✅ **Offline mode** qo'llab-quvvatlash

---

## 📝 XULOSA

**Hozirgi holat:**

- ✅ Asosiy flow ishlaydi
- ⚠️ Ba'zi ma'lumotlar hardcode qilingan
- ❌ Ba'zi muhim ma'lumotlar yo'q

**Kerakli o'zgarishlar:**

1. Period ID mapping
2. Number Drivers ID ni calc response dan olish
3. Tug'ilgan sana formaga qo'shish
4. Brand va Model formaga qo'shish
5. OSAGO turi ni ishlatish

**Muammolar:**

- `number_drivers_id` noto'g'ri yuborilmoqda (kritik)
- Period ID mapping yo'q (kritik)
- Tug'ilgan sana yo'q (katta)
- Brand va Model yo'q (katta)
