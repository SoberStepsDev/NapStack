# NapStack — Kompletna lista konfiguracji

Krok po kroku od zera do działającej apki.

---

## 🔴 BLOKERY — bez tych nie skompiluje się

### 1. `flutter create .` — inicjalizacja projektu

```bash
cd /Users/tpltd145/Projects/NapStack
flutter create . --org com.patrykdev --project-name napstack
```

> Tworzy brakującą strukturę: `android/app/build.gradle`, `android/local.properties`,
> `lib/main.dart` (nadpisz swoim), `ios/`, `test/`, itd.
> **Po wykonaniu**: przywróć swój `lib/main.dart` (flutter create nadpisze go).

---

### 2. `dart run build_runner build` — generowanie Freezed

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Generuje `lib/features/timer/timer_state.freezed.dart`.

---

### 3. Dźwięki alarmu — MP3 i OGG w assetach, OGG w `res/raw/`

- **`assets/sounds/*.mp3`** i **`assets/sounds/*.ogg`** — oba formaty (Ogg/Opus); katalog jest w `pubspec.yaml`.
- **`android/app/src/main/res/raw/gentle_rise.ogg`** — jeden zasób `gentle_rise` dla `RawResourceAndroidNotificationSound('gentle_rise')` (nie trzymaj jednocześnie `gentle_rise.mp3` w `raw/`).

Regeneracja OGG z MP3 (przykład):

```bash
ffmpeg -y -i assets/sounds/gentle_rise.mp3 -c:a libopus -b:a 96k assets/sounds/gentle_rise.ogg
ffmpeg -y -i assets/sounds/gentle_rise.mp3 -c:a libopus -b:a 96k android/app/src/main/res/raw/gentle_rise.ogg
```

> Mixkit + atrybucja: `assets/sounds/ATTRIBUTION.txt`.

### 4. `android/app/build.gradle` — minSdk + targetSdk

```groovy
android {
    compileSdk 34

    defaultConfig {
        applicationId "com.patrykdev.napstack"
        minSdk 23        // wymagane przez flutter_secure_storage i exact alarms
        targetSdk 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

---

## 🟡 APPWRITE — konfiguracja projektu

### 5. Utwórz projekt na Appwrite Cloud

1. Wejdź na [cloud.appwrite.io](https://cloud.appwrite.io)
2. **Create Project** → nazwa: `NapStack`
3. Skopiuj **Project ID** (np. `abc123xyz`)
4. **Settings → Platforms → Add Platform → Android**
   - Package name: `com.patrykdev.napstack`
   - (opcjonalnie SHA-256 fingerprint do OAuth)

---

### 6. Uruchom Schema Provisioner

```bash
cd tools
dart pub get

APPWRITE_ENDPOINT=https://fra.cloud.appwrite.io/v1 \
APPWRITE_PROJECT_ID=abc123xyz \
APPWRITE_API_KEY=twoj_klucz_api \
  dart run provision_schema.dart
```

> **Klucz API**: Appwrite Console → Settings → API Keys → Create Key
> Wymagane uprawnienia: `databases.write`, `collections.write`

Po wykonaniu w Appwrite pojawią się:
- Baza `napstack`
- Tabele: `nap_sessions`, `nap_stack`, `user_prefs`
- Wszystkie kolumny i indeksy

Alternatywnie (REST / ten sam schemat): `python3 tool/provision_appwrite.py` z `APPWRITE_API_KEY` w `.env`.

---

### 6a. Referencja wdrożenia — Appwrite Cloud (NapStack)

| Zasób | Wartość |
|--------|---------|
| **Project ID** | `69d7218d001dd20138f6` (domyślnie w `appwrite_constants.dart`; nadpisz `--dart-define` w CI) |
| **Baza (TablesDB)** | ID `napstack` |
| **Tabele** | `nap_sessions`, `nap_stack`, `user_prefs` |
| **Funkcja** | ID `pro_gate` — weryfikacja Pro (RevenueCat API v2) |

Zmienne środowiskowe **`pro_gate`** ustaw wyłącznie w konsoli Appwrite: `RC_PROJECT_ID`, `PRO_ENTITLEMENT_ID`, `RC_SECRET_KEY_ANDROID`. **Nie zapisuj** wartości `RC_SECRET_KEY_ANDROID` w repozytorium ani w plikach typu „raport konfiguracji”; przy wycieku **zrotuj klucz** w RevenueCat i zaktualizuj zmienne funkcji.

---

### 7. Ustaw zmienne środowiskowe (--dart-define)

```bash
# Development
flutter run \
  --dart-define=APPWRITE_ENDPOINT=https://fra.cloud.appwrite.io/v1 \
  --dart-define=APPWRITE_PROJECT_ID=abc123xyz

# Lub przez launch.json w VS Code / Cursor:
```

**`.vscode/launch.json`:**
```json
{
  "configurations": [
    {
      "name": "NapStack Debug",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=APPWRITE_ENDPOINT=https://fra.cloud.appwrite.io/v1",
        "--dart-define=APPWRITE_PROJECT_ID=abc123xyz"
      ]
    }
  ]
}
```

---

## 🟡 REVENUECAT — konfiguracja zakupów

### 8. Google Play Console — produkt

1. [play.google.com/console](https://play.google.com/console) → Twoja apka
2. **Monetization → Products → In-app products**
3. **Create product**:
   - Product ID: `napstack_pro_lifetime`
   - Type: **One-time** (nie subskrypcja)
   - Price: 3,99 EUR
   - Status: Active

---

### 9. RevenueCat dashboard (stan docelowy NapStack)

W panelu powinno być spójnie z kodem (`purchase_service.dart`, `pro_gate`):

| Zasób | ID / wartość |
|--------|----------------|
| Projekt | `NapStack` |
| RevenueCat **Project ID** (API v2 / funkcja `pro_gate`) | `proj1bd829aa` |
| Aplikacja Android | `NapStack Android`, package `com.patrykdev.napstack` |
| **Entitlement** | `pro` |
| **Product** (Play) | `napstack_pro_lifetime` (one-time / lifetime) |
| **Offering** | `current` (domyślna oferta) |
| **Package** w ofercie | identifier `napstack_pro_lifetime` (zgodny z `offerings.current` w SDK) |

Kroki:

1. [app.revenuecat.com](https://app.revenuecat.com)
2. **Project → Add App → Google Play** — package `com.patrykdev.napstack`
3. Połączenie z Play: **Service Account JSON** z Google Cloud / Play (wymagane do produkcji)
4. **Entitlements** → `pro`
5. **Products** → import `napstack_pro_lifetime` z Play
6. **Offerings** → offering **`current`** → pakiet z powyższym produktem
7. **Public SDK Key (Android)** → trafia do builda jako `RC_PUBLIC_KEY_ANDROID` (nie commituj w repo)

**Appwrite Function `pro_gate`** (`functions/pro_gate`): ustaw zmienne środowiskowe w konsoli Appwrite:

- `RC_PROJECT_ID` = `proj1bd829aa`
- `PRO_ENTITLEMENT_ID` = `pro`
- `RC_SECRET_KEY_ANDROID` = **Secret API Key (v2)** z RevenueCat (Project Settings → API Keys) — wyłącznie po stronie serwera

---

### 10. RC Key w buildzie Flutter

**Opcja A — plik `.env` (np. `RC_PUBLIC_KEY_ANDROID=…` lub `REVENUECAT_SDK_API_KEY=…`):**

```bash
python3 tool/sync_dart_defines_from_env.py
flutter run --dart-define-from-file=dart_defines.local.json
```

**Opcja B — ręcznie:**

```bash
flutter run \
  --dart-define=APPWRITE_PROJECT_ID=abc123xyz \
  --dart-define=RC_PUBLIC_KEY_ANDROID=goog_xxxxxxxx
```

---

## 🟢 ANDROID — konfiguracja (po `flutter create`)

### 11. `android/app/build.gradle` — dodaj multidex (jeśli minSdk < 21)

```groovy
dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

### 12. `android/app/proguard-rules.pro` — reguły ProGuard dla release

```pro
# Appwrite
-keep class io.appwrite.** { *; }
-dontwarn io.appwrite.**

# RevenueCat
-keep class com.revenuecat.purchases.** { *; }

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Kotlin serialization
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
```

### 13. `android/gradle.properties`

```properties
android.useAndroidX=true
android.enableJetifier=true
```

---

## 🔵 OPCJONALNE — jakość i publish

### 14. Aplikacja testowa w Google Play (Internal Testing)

1. `flutter build apk --release --dart-define=...`
2. Upload do Play Console → Internal testing track
3. Test na fizycznym urządzeniu (Doze Mode, alarm przy blokadzie)

### 15. Ikona aplikacji

```bash
flutter pub add dev:flutter_launcher_icons
# Dodaj ikonę 1024x1024 PNG → assets/icon/icon.png
# Skonfiguruj flutter_launcher_icons w pubspec.yaml
dart run flutter_launcher_icons
```

Sugestia ikony: ciemne tło (#070B16) + lodowy półksiężyc (#60C5FF).

### 16. Splash screen

```bash
flutter pub add dev:flutter_native_splash
# Tło: #070B16, logo: biały księżyc
dart run flutter_native_splash:create
```

### 17. Klucz podpisywania (release build)

```bash
keytool -genkey -v -keystore napstack.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias napstack

# android/key.properties (dodaj do .gitignore!)
storePassword=...
keyPassword=...
keyAlias=napstack
storeFile=../napstack.jks
```

---

## Kolejność wykonania

```
[1] flutter create .           ← projekt Flutter
[2] build_runner build         ← Freezed
[3] Dodaj dźwięk alarmu        ← 2 pliki
[4] Appwrite: utwórz projekt   ← Project ID
[5] provision_schema.dart      ← schemat bazy
[6] launch.json z --dart-define ← sekrety
[7] RevenueCat: produkt + key  ← zakupy
[8] flutter run                ← pierwsze uruchomienie
[9] Test fizyczne urządzenie   ← alarmy + Doze
```

---

## Pliki które NIE trafiają do repo (.gitignore)

```gitignore
# Sekrety
.env
*.jks
*.keystore
key.properties
android/app/google-services.json

# Flutter/Dart
.dart_tool/
build/
*.g.dart        # NIE — te muszą być w repo
*.freezed.dart  # NIE — te muszą być w repo (lub generowane w CI)

# IDE
.vscode/settings.json   # OK, ale nie launch.json z sekretami
```
