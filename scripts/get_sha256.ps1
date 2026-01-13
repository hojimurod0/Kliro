# SHA-256 Fingerprint olish skripti (PowerShell)
# Bu skript Android keystore'dan SHA-256 fingerprint'ni oladi

Write-Host "🔐 SHA-256 Fingerprint olish..." -ForegroundColor Cyan
Write-Host ""

# Debug keystore path
$debugKeystorePath = "$env:USERPROFILE\.android\debug.keystore"
$debugKeyAlias = "androiddebugkey"
$debugPassword = "android"

# Release keystore path (agar mavjud bo'lsa)
$releaseKeystorePath = "android\app\kliro-release-key.jks"
$releaseKeyAlias = "kliro"  # O'zgartirishingiz mumkin

Write-Host "1. Debug keystore uchun SHA-256 fingerprint:" -ForegroundColor Yellow
Write-Host ""

if (Test-Path $debugKeystorePath) {
    try {
        $output = & keytool -list -v -keystore $debugKeystorePath -alias $debugKeyAlias -storepass $debugPassword -keypass $debugPassword 2>&1
        
        # SHA-256 ni topish
        $sha256Line = $output | Select-String "SHA256:"
        if ($sha256Line) {
            Write-Host "✅ SHA-256 (Debug):" -ForegroundColor Green
            Write-Host $sha256Line.Line -ForegroundColor White
            Write-Host ""
            
            # Faqat fingerprint'ni ajratib olish
            $sha256 = ($sha256Line.Line -replace ".*SHA256:\s*", "").Trim()
            Write-Host "📋 Ko'chirish uchun:" -ForegroundColor Cyan
            Write-Host $sha256 -ForegroundColor White
            Write-Host ""
        } else {
            Write-Host "❌ SHA-256 topilmadi" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Xatolik: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Java SDK o'rnatilganligini tekshiring!" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️ Debug keystore topilmadi: $debugKeystorePath" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "2. Release keystore uchun SHA-256 fingerprint:" -ForegroundColor Yellow
Write-Host ""

if (Test-Path $releaseKeystorePath) {
    $releasePassword = Read-Host "Release keystore parolini kiriting" -AsSecureString
    $releasePasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($releasePassword))
    
    try {
        $output = & keytool -list -v -keystore $releaseKeystorePath -alias $releaseKeyAlias -storepass $releasePasswordPlain -keypass $releasePasswordPlain 2>&1
        
        $sha256Line = $output | Select-String "SHA256:"
        if ($sha256Line) {
            Write-Host "✅ SHA-256 (Release):" -ForegroundColor Green
            Write-Host $sha256Line.Line -ForegroundColor White
            Write-Host ""
            
            $sha256 = ($sha256Line.Line -replace ".*SHA256:\s*", "").Trim()
            Write-Host "📋 Ko'chirish uchun:" -ForegroundColor Cyan
            Write-Host $sha256 -ForegroundColor White
        } else {
            Write-Host "❌ SHA-256 topilmadi yoki alias noto'g'ri" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Xatolik: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️ Release keystore topilmadi: $releaseKeystorePath" -ForegroundColor Yellow
    Write-Host "   Release keystore'ni qo'shing yoki debug keystore'dan foydalaning" -ForegroundColor Gray
}

Write-Host ""
Write-Host "📝 Qadamlar:" -ForegroundColor Cyan
Write-Host "1. SHA-256 fingerprint'ni ko'chirib oling" -ForegroundColor White
Write-Host "2. .well-known/assetlinks.json faylini oching" -ForegroundColor White
Write-Host "3. YOUR_SHA256_FINGERPRINT_HERE ni o'zgartiring" -ForegroundColor White
Write-Host "4. Server'ga .well-known/assetlinks.json yuklang" -ForegroundColor White
Write-Host ""

