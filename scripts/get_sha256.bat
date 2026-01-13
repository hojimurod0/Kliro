@echo off
REM SHA-256 Fingerprint olish skripti (Windows CMD)
REM Bu skript Android keystore'dan SHA-256 fingerprint'ni oladi

echo.
echo ========================================
echo   SHA-256 Fingerprint Olish Skripti
echo ========================================
echo.

REM Debug keystore path
set DEBUG_KEYSTORE=%USERPROFILE%\.android\debug.keystore
set DEBUG_ALIAS=androiddebugkey
set DEBUG_PASSWORD=android

echo 1. Debug keystore uchun SHA-256 fingerprint:
echo.

if exist "%DEBUG_KEYSTORE%" (
    keytool -list -v -keystore "%DEBUG_KEYSTORE%" -alias %DEBUG_ALIAS% -storepass %DEBUG_PASSWORD% -keypass %DEBUG_PASSWORD% | findstr /C:"SHA256"
    if errorlevel 1 (
        echo SHA-256 topilmadi yoki xatolik yuz berdi
    )
) else (
    echo Debug keystore topilmadi: %DEBUG_KEYSTORE%
)

echo.
echo 2. Release keystore uchun SHA-256 fingerprint:
echo.

set RELEASE_KEYSTORE=android\app\kliro-release-key.jks
set RELEASE_ALIAS=kliro

if exist "%RELEASE_KEYSTORE%" (
    echo Release keystore parolini kiriting:
    set /p RELEASE_PASSWORD=
    
    keytool -list -v -keystore "%RELEASE_KEYSTORE%" -alias %RELEASE_ALIAS% -storepass %RELEASE_PASSWORD% -keypass %RELEASE_PASSWORD% | findstr /C:"SHA256"
    if errorlevel 1 (
        echo SHA-256 topilmadi, alias noto'g'ri yoki parol noto'g'ri
    )
) else (
    echo Release keystore topilmadi: %RELEASE_KEYSTORE%
)

echo.
echo ========================================
echo   Qadamlar:
echo   1. SHA-256 fingerprint'ni ko'chiring
echo   2. .well-known/assetlinks.json ni oching
echo   3. YOUR_SHA256_FINGERPRINT_HERE ni o'zgartiring
echo   4. Server'ga yuklang
echo ========================================
echo.
pause

