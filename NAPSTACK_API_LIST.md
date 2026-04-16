# 📋 NapStack — Pełna lista wymaganych API

## Kategoria 1: Appwrite Backend (wymagane)

### 1.1 Appwrite Endpoint
- **Klucz env:** `APPWRITE_ENDPOINT`
- **Format:** URL
- **Bieżąca wartość:** `https://fra.cloud.appwrite.io/v1`
- **Gdzie:** `.env`, `--dart-define` w buildzie
- **Przeznaczenie:** Połączenie z backendem Appwrite Cloud
- **Uzyskanie:** Appwrite Cloud Console → Settings → Endpoint

### 1.2 Appwrite Project ID
- **Klucz env:** `APPWRITE_PROJECT_ID`
- **Format:** 25 znaków (hex)
- **Bieżąca wartość:** `69d7218d001dd20138f6`
- **Gdzie:** `.env`, `--dart-define` w buildzie
- **Przeznaczenie:** Identyfikacja projektu NapStack w Appwrite
- **Uzyskanie:** Appwrite Cloud Console → Project Settings → Project ID

### 1.3 Appwrite API Key
- **Klucz env:** `APPWRITE_API_KEY`
- **Format:** 50+ znaków (base64)
- **Wymagane uprawnienia:** `collections.write`, `documents.write`, `databases.read`
- **Gdzie:** Tylko `.env` lokalnie (nigdy w repo, nigdy w GitHub Secrets)
- **Przeznaczenie:** Autoryzacja do provisioning schematu (`tools/provision_schema.dart`)
- **Uzyskanie:** Appwrite Cloud Console → Settings → API Keys → Create Key
- **⚠️ Ważne:** Tego klucza **nigdy nie ujawniaj publicznie**, nigdy nie commituj do repo

---

## Kategoria 2: RevenueCat In-App Purchases (wymagane)

### 2.1 RevenueCat Public Key (Android)
- **Klucz env:** `RC_PUBLIC_KEY_ANDROID`
- **Format:** `goog_xxxxxxxx` (Google Play billing)
- **Bieżąca wartość:** `goog_CAWCkqmXbVVmPfjzrTKDxAQMuvs`
- **⚠️ UWAGA:** Ta wartość wskazuje na **SoberSteps**, nie NapStack — trzeba zmienić
- **Gdzie:** `.env`, `--dart-define` w buildzie
- **Przeznaczenie:** In-app purchase SDK w aplikacji Flutter
- **Uzyskanie:** RevenueCat Dashboard → NapStack Project Settings → SDK Keys → Android Public Key
- **Projekt:** Musi być **oddzielny projekt RevenueCat dla NapStack** (nie SoberSteps)

### 2.2 RevenueCat Project ID
- **Klucz env:** `RC_PROJECT_ID`
- **Format:** `projxxxxxxxx`
- **Gdzie:** Appwrite Function `pro_gate` → Environment Variables (nigdy w `.env`)
- **Przeznaczenie:** Server-side weryfikacja produktów w Appwrite Function
- **Uzyskanie:** RevenueCat Dashboard → NapStack Project Settings → Project ID

### 2.3 RevenueCat Secret API Key (Android)
- **Klucz env:** `RC_SECRET_KEY_ANDROID`
- **Format:** Secret API Key v2 (50+ znaków)
- **Gdzie:** Appwrite Function `pro_gate` → Environment Variables (nigdy w `.env`)
- **Przeznaczenie:** Server-side autoryzacja API RevenueCat z Appwrite Function
- **Uzyskanie:** RevenueCat Dashboard → NapStack Project Settings → API Keys → Secret API Key (v2)
- **⚠️ Ważne:** Secret key — nigdy w publicznych plikach

### 2.4 RevenueCat Entitlement ID
- **Klucz env:** `PRO_ENTITLEMENT_ID`
- **Format:** String ID (domyślnie: `pro`)
- **Gdzie:** Appwrite Function `pro_gate` → Environment Variables
- **Przeznaczenie:** Identyfikacja Pro entitlementu do weryfikacji
- **Uzyskanie:** RevenueCat Dashboard → NapStack Project → Entitlements → ID
- **Bieżąca wartość:** `pro`

---

## Kategoria 3: Google Play Console (wymagane do publikacji)

### 3.1 Google Play Service Account JSON
- **Klucz env:** `GOOGLE_PLAY_KEY_JSON`
- **Format:** JSON Service Account (z Google Cloud Console)
- **Gdzie:** GitHub Secrets `GOOGLE_PLAY_KEY_JSON` (dla CI/CD)
- **Przeznaczenie:** Automatyczne buildy i publikacja na Play Store
- **Uzyskanie:** Google Cloud Console → Service Accounts → Create & Download JSON
- **⚠️ Ważne:** Secret credentials — nigdy w repo

### 3.2 Google Play Product ID
- **Klucz env:** `NAPSTACK_PRODUCT_ID`
- **Format:** String ID (domyślnie: `napstack_pro_lifetime`)
- **Gdzie:** Google Play Console → In-app products
- **Przeznaczenie:** Identyfikacja produktu Pro lifetime na Play Store
- **Uzyskanie:** Google Play Console → NapStack app → In-app products → Manage
- **Musi być zsynchronizowana:** RevenueCat ↔ Google Play Console

---

## Kategoria 4: Legal & Regulatory (opcjonalnie, ale zalecane)

### 4.1 Privacy Policy URL
- **Klucz env:** `PRIVACY_POLICY_URL`
- **Format:** HTTPS URL
- **Bieżąca wartość:** `https://soberstepsdev.github.io/NapStack/napstack/privacy_pl.html`
- **Gdzie:** `.env`, dostępne w `pubspec.yaml` constants
- **Przeznaczenie:** Wyświetlanie w app (Settings screen)
- **Wymagane:** Google Play Store wymaga dla publikacji

### 4.2 Terms of Service URL
- **Klucz env:** `TERMS_OF_SERVICE_URL`
- **Format:** HTTPS URL
- **Bieżąca wartość:** `https://soberstepsdev.github.io/NapStack/napstack/privacy_pl.html`
- **Gdzie:** `.env`, dostępne w `pubspec.yaml` constants
- **Przeznaczenie:** Wyświetlanie w app (Settings screen)
- **Wymagane:** Google Play Store wymaga dla publikacji

### 4.3 Consumer Information URL
- **Klucz env:** `CONSUMER_INFO_URL`
- **Format:** HTTPS URL
- **Bieżąca wartość:** `https://soberstepsdev.github.io/NapStack/napstack/privacy_pl.html`
- **Gdzie:** `.env`, dostępne w `pubspec.yaml` constants
- **Przeznaczenie:** Wyświetlanie informacji dla konsumentów (App Store/Play Store)
- **Wymagane:** EU Digital Markets Act compliance

---

## 📊 Macierz: gdzie trafiają klucze

| API Key | .env | --dart-define | pubspec.yaml | GitHub Secrets | Appwrite Fn env | Git Repo |
|---------|------|----------------|-----------------|-----------------|----------|----------|
| APPWRITE_ENDPOINT | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| APPWRITE_PROJECT_ID | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| APPWRITE_API_KEY | ✅ (local) | ❌ | ❌ | ❌ | ❌ | ❌ |
| RC_PUBLIC_KEY_ANDROID | ✅ | ✅ | ❌ | ✅ | ❌ | ✅ |
| RC_PROJECT_ID | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| RC_SECRET_KEY_ANDROID | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| PRO_ENTITLEMENT_ID | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| GOOGLE_PLAY_KEY_JSON | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Legal URLs | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ |

---

## 🔴 Status bieżący

| API | Status | Notatka |
|-----|--------|---------|
| APPWRITE_ENDPOINT | ✅ OK | Działa |
| APPWRITE_PROJECT_ID | ✅ OK | Działa |
| APPWRITE_API_KEY | ❌ BRAK | Lokalnie do provision_schema.dart |
| RC_PUBLIC_KEY_ANDROID | ⚠️ WRONG | SoberSteps zamiast NapStack |
| RC_PROJECT_ID | ❌ BRAK | W Appwrite Function |
| RC_SECRET_KEY_ANDROID | ❌ BRAK | W Appwrite Function |
| PRO_ENTITLEMENT_ID | ❌ BRAK | W Appwrite Function |
| GOOGLE_PLAY_KEY_JSON | ❌ BRAK | Do CI/CD (opcjonalnie) |
| Legal URLs | ✅ OK | Skonfigurowane |

---

## ⚡ Plan działania

1. **Appwrite API Key** — Appwrite Console → Settings → API Keys → Create (collections.write)
2. **RevenueCat — nowy projekt** — RevenueCat → Create Project → Skopiuj Public Key
3. **Appwrite Function** — Settings → Env Variables → RC_PROJECT_ID, RC_SECRET_KEY_ANDROID, PRO_ENTITLEMENT_ID
4. **Test** — flutter run -d 24117RN76E
