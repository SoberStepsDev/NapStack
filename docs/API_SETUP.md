# NapStack — Konfiguracja API i sekretów

Przewodnik bezpiecznego skonfigurowania wszystkich API i kluczy dla NapStack (Appwrite, RevenueCat, Google Play).

---

## 📋 Przegląd wymaganych kluczy

| Klucz | Źródło | Używane w |
|-------|--------|----------|
| `APPWRITE_ENDPOINT` | Appwrite Cloud | appwrite_constants.dart |
| `APPWRITE_PROJECT_ID` | Appwrite Cloud → Settings | appwrite_constants.dart |
| `APPWRITE_API_KEY` | Appwrite Cloud → API Keys | provision_schema.dart (setup) |
| `RC_PUBLIC_KEY_ANDROID` | RevenueCat → SDK Key (Android) | purchase_service.dart |
| `RC_SECRET_KEY_ANDROID` | RevenueCat → API Keys (v2) | Appwrite Function `pro_gate` (server-side only) |
| `RC_PROJECT_ID` | RevenueCat → Project Settings | Appwrite Function `pro_gate` |
| `PRO_ENTITLEMENT_ID` | RevenueCat → Entitlements | Appwrite Function `pro_gate` |
| `ANDROID_KEYSTORE_BASE64` | Generated with keytool → base64 encoded | GitHub Secrets (CI/CD) |
| `ANDROID_KEY_PROPERTIES` | Generated locally → base64 encoded | GitHub Secrets (CI/CD) |

---

## 🔧 1. Konfiguracja lokalna (development)

### A. Plik `.env`

Utwórz plik `.env` w głównym katalogu projektu (ignoruje się w `.gitignore`):

```bash
# Appwrite (Appwrite Cloud)
APPWRITE_ENDPOINT=https://fra.cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=69d7218d001dd20138f6
APPWRITE_API_KEY=your_appwrite_api_key_here

# RevenueCat (Android)
RC_PUBLIC_KEY_ANDROID=goog_xxxxxxxx

# Appwrite Function pro_gate (server-side variables, nie w .env)
# — ustaw bezpośrednio w Appwrite Console
```

### B. Synchronizacja --dart-define z .env

Uruchom Python script, który konwertuje `.env` na `dart_defines.local.json`:

```bash
python3 tool/sync_dart_defines_from_env.py
```

Następnie builduj:

```bash
flutter run --dart-define-from-file=dart_defines.local.json
```

Lub ręcznie:

```bash
flutter run \
  --dart-define=APPWRITE_ENDPOINT=https://fra.cloud.appwrite.io/v1 \
  --dart-define=APPWRITE_PROJECT_ID=69d7218d001dd20138f6 \
  --dart-define=RC_PUBLIC_KEY_ANDROID=goog_xxxxxxxx
```

### C. Weryfikacja lokalnego setupu

```bash
# 1. Sprawdzenie czy .env istnieje
ls -la .env

# 2. Przebieg build z debug output
flutter run -v --dart-define-from-file=dart_defines.local.json 2>&1 | grep -i "appwrite\|revenuecat"

# 3. Test konektywności Appwrite (w aplikacji: open NapStack na widoku Home)
#    — jeśli się zaloguje, klucze są poprawne
```

---

## 🚀 2. GitHub Secrets dla CI/CD

### A. Wygenerowanie kluczy podpisywania

```bash
# Generowanie klucza RSA do podpisywania APK
keytool -genkey -v -keystore napstack.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias napstack

# Skopiowanie do local backup (BEZ commitowania!)
cp napstack.jks ~/napstack-backup.jks
```

### B. Enkodowanie klucza do base64

```bash
# Zakoduj .jks do base64 (używane w GitHub Actions)
base64 -i napstack.jks -o napstack.jks.b64

# Wyświetl zawartość (całość to jedna linia — skopiuj ją całą)
cat napstack.jks.b64
```

### C. Enkodowanie key.properties do base64

Załóż `android/key.properties`:

```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=napstack
storeFile=../napstack.jks
```

Zakoduj:

```bash
base64 -i android/key.properties -o android/key.properties.b64
cat android/key.properties.b64
```

### D. Tworzenie GitHub Secret: DART_DEFINES_JSON

Na GitHub (repo → Settings → Secrets and variables → Actions → New repository secret):

**Name:** `DART_DEFINES_JSON`

**Value:** (cała zawartość jako JSON w jednej linii)

```json
{"APPWRITE_ENDPOINT":"https://fra.cloud.appwrite.io/v1","APPWRITE_PROJECT_ID":"69d7218d001dd20138f6","RC_PUBLIC_KEY_ANDROID":"goog_xxxxxxxx"}
```

### E. Dodaj trzy pozostałe Secrets

1. **ANDROID_KEYSTORE_BASE64** = zawartość `napstack.jks.b64`
2. **ANDROID_KEY_PROPERTIES** = zawartość `android/key.properties.b64`
3. **GOOGLE_PLAY_KEY_JSON** = plik JSON Service Account z Google Cloud (jeśli publikujesz na Play Store)

---

## 🔐 3. Appwrite Function `pro_gate` — zmienne środowiskowe

⚠️ **WAŻNE:** Te zmienne NIGDY nie trafiają do .env ani do repo.

### 3a. Projekt „paused” (bezczynność)

Jeśli `appwrite functions list` lub deploy zgłasza *„Project is paused due to inactivity”*, **wznów projekt** w [Appwrite Console](https://cloud.appwrite.io) (projekt → Settings / banner „Restore”) — inaczej żadne wywołania API (deploy, list) nie zadziałają.

### 3b. Deploy kodu z repozytorium (CLI)

Przy **aktywnym** projekcie, z katalogu głównego (po uzupełnieniu `.env` o klucze z sekcji 1):

```bash
bash script/deploy_pro_gate.sh <FUNCTION_ID>
```

`FUNCTION_ID` znajdziesz w Console → Functions → `pro_gate` (albo w GitHub Secret `APPWRITE_PRO_GATE_FN_ID`, jeśli go dodano).

### 3c. Zmienne w panelu (obowiązkowo dla działania RC)

1. Wejdź na [app.appwrite.io](https://app.appwrite.io) → NapStack project
2. Functions → `pro_gate`
3. **Settings → Environment Variables** → dodaj:

```
RC_PROJECT_ID = proj1bd829aa
PRO_ENTITLEMENT_ID = pro
RC_SECRET_KEY_ANDROID = [Secret API Key v2 z RevenueCat]
```

4. Zapisz i redeploy funkcji

---

## 📱 4. Google Play Console — Produkt i Service Account

### A. Utwórz produkt (one-time purchase)

1. [play.google.com/console](https://play.google.com/console)
2. NapStack app → **Monetize → Products (in-app) → Create product**
3. Product ID: `napstack_pro_lifetime`
4. Type: **One-time purchase** (nie subscription)
5. Price: 3,99 EUR
6. Status: **Active**
7. Skopiuj **Product ID** do RevenueCat dashboard

### B. Service Account JSON

Do publikacji automatycznej (CI/CD):

1. Google Cloud Console → [console.cloud.google.com](https://console.cloud.google.com)
2. Service Accounts → Create Service Account
3. Grant roles: `Play Console Editor` lub `Editor` na Project
4. Keys → Add Key → Create new (JSON format)
5. Skopiuj JSON → GitHub Secrets `GOOGLE_PLAY_KEY_JSON`

---

## 💰 5. RevenueCat — Konfiguracja

### A. Entitlements i Products

1. [app.revenuecat.com](https://app.revenuecat.com) → NapStack project
2. **Entitlements** → utwórz `pro`
3. **Products** → import `napstack_pro_lifetime` z Google Play
4. **Offerings** → offering `current` → package `napstack_pro_lifetime`
5. Skopiuj **Public SDK Key (Android)** → `RC_PUBLIC_KEY_ANDROID` w .env

### B. API Keys (server-side)

1. **Project Settings → API Keys**
2. Secret API Key (v2) → Appwrite Function `pro_gate` tylko
3. Nie komituj, nie wyświetlaj w chat, nie przechowuj lokalnie

---

## ✅ 6. Checklist pre-release

Zanim pushniesz do Play Store:

```
[ ] .env istnieje i jest w .gitignore
[ ] flutter run z --dart-define-from-file zadziała bez błędów
[ ] DART_DEFINES_JSON ustawiony w GitHub Secrets
[ ] ANDROID_KEYSTORE_BASE64 ustawiony
[ ] ANDROID_KEY_PROPERTIES ustawiony
[ ] napstack.jks istnieje lokalnie (NIE commituj)
[ ] android/key.properties istnieje lokalnie (NIE commituj)
[ ] Appwrite pro_gate function ma zmienne: RC_PROJECT_ID, PRO_ENTITLEMENT_ID, RC_SECRET_KEY_ANDROID
[ ] Google Play Console: napstack_pro_lifetime product aktywny
[ ] RevenueCat: public key dla Android skopiowany do .env
[ ] RevenueCat: entitlement pro istnieje
[ ] GitHub workflow android-release.yml jest symetryczny do zmiennych powyżej
[ ] Test na fizycznym urządzeniu (Doze Mode, Pro flow)
```

---

## 🔄 7. Rotacja kluczy (security incident)

### Jeśli wyciek `RC_SECRET_KEY_ANDROID`:

1. [app.revenuecat.com](https://app.revenuecat.com) → Project Settings
2. API Keys → delete stary key, generate nowy
3. Appwrite Console → pro_gate function → update `RC_SECRET_KEY_ANDROID`
4. Deploy function

### Jeśli wyciek `APPWRITE_API_KEY`:

1. [app.appwrite.io](https://app.appwrite.io) → Settings → API Keys
2. Delete stary key, create nowy z uprawnieniami `databases.write, collections.write`
3. Update GitHub Secret `DART_DEFINES_JSON`
4. Update .env lokalnie

### Jeśli wyciek `napstack.jks`:

1. Wygeneruj nowy keystore (patrz punkt 2A)
2. Update GitHub Secret `ANDROID_KEYSTORE_BASE64`
3. Upload updated APK do Play Store internal testing
4. Google Play Console: zmień fingerprint dla Android (Settings → App signing)

---

## 📚 Referencja

- [Appwrite Cloud](https://cloud.appwrite.io)
- [RevenueCat Dashboard](https://app.revenuecat.com)
- [Google Play Console](https://play.google.com/console)
- [NapStack GitHub Workflows](.github/workflows/android-release.yml)
- [Setup Checklist](SETUP_CHECKLIST.md)
