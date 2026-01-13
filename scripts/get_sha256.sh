#!/bin/bash
# SHA-256 Fingerprint olish skripti (Linux/Mac)
# Bu skript Android keystore'dan SHA-256 fingerprint'ni oladi

echo "🔐 SHA-256 Fingerprint olish..."
echo ""

# Debug keystore path
DEBUG_KEYSTORE="$HOME/.android/debug.keystore"
DEBUG_ALIAS="androiddebugkey"
DEBUG_PASSWORD="android"

# Release keystore path
RELEASE_KEYSTORE="android/app/kliro-release-key.jks"
RELEASE_ALIAS="kliro"  # O'zgartirishingiz mumkin

echo "1. Debug keystore uchun SHA-256 fingerprint:"
echo ""

if [ -f "$DEBUG_KEYSTORE" ]; then
    keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias "$DEBUG_ALIAS" -storepass "$DEBUG_PASSWORD" -keypass "$DEBUG_PASSWORD" 2>/dev/null | grep -A 1 "SHA256:"
    
    if [ $? -eq 0 ]; then
        SHA256=$(keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias "$DEBUG_ALIAS" -storepass "$DEBUG_PASSWORD" -keypass "$DEBUG_PASSWORD" 2>/dev/null | grep "SHA256:" | sed 's/.*SHA256: //' | tr -d ' ')
        echo ""
        echo "✅ SHA-256 (Debug):"
        echo "$SHA256"
    else
        echo "❌ SHA-256 topilmadi"
    fi
else
    echo "⚠️ Debug keystore topilmadi: $DEBUG_KEYSTORE"
fi

echo ""
echo "2. Release keystore uchun SHA-256 fingerprint:"
echo ""

if [ -f "$RELEASE_KEYSTORE" ]; then
    read -sp "Release keystore parolini kiriting: " RELEASE_PASSWORD
    echo ""
    
    keytool -list -v -keystore "$RELEASE_KEYSTORE" -alias "$RELEASE_ALIAS" -storepass "$RELEASE_PASSWORD" -keypass "$RELEASE_PASSWORD" 2>/dev/null | grep -A 1 "SHA256:"
    
    if [ $? -eq 0 ]; then
        SHA256=$(keytool -list -v -keystore "$RELEASE_KEYSTORE" -alias "$RELEASE_ALIAS" -storepass "$RELEASE_PASSWORD" -keypass "$RELEASE_PASSWORD" 2>/dev/null | grep "SHA256:" | sed 's/.*SHA256: //' | tr -d ' ')
        echo ""
        echo "✅ SHA-256 (Release):"
        echo "$SHA256"
    else
        echo "❌ SHA-256 topilmadi yoki alias/parol noto'g'ri"
    fi
else
    echo "⚠️ Release keystore topilmadi: $RELEASE_KEYSTORE"
fi

echo ""
echo "📝 Qadamlar:"
echo "1. SHA-256 fingerprint'ni ko'chirib oling"
echo "2. .well-known/assetlinks.json faylini oching"
echo "3. YOUR_SHA256_FINGERPRINT_HERE ni o'zgartiring"
echo "4. Server'ga .well-known/assetlinks.json yuklang"
echo ""

