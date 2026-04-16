# Raport gotowości NapStack do publikacji w Google Play — zaktualizowany 2026-04-15

## Streszczenie wykonawcze

**Status ogólny**: 🟡 **Gotowość 70%** — aplikacja jest na zaawansowanym etapie przygotowania. Większość elementów infrastrukturalnych i konfiguracyjnych jest na miejscu. Pozostałe prace dotyczą głównie konfiguracji paneli online (Google Play Console, RevenueCat, Appwrite) oraz testów wdrażania.

**Ścieżka krytyczna** (max ~2-3 tygodnie):
1. Konfiguracja GitHub Secrets (CI/CD) — ~15 min
2. Ustawienie produktu i entitlementów w RevenueCat/Play — ~2-3 dni
3. Wdrożenie funkcji `pro_gate` w Appwrite — ~1 dzień
4. Testy wewnętrzne w Play (Internal Testing) — ~3-5 dni
5. Uzupełnienie formularzy (Data Safety, Content Rating, Special Permissions) — ~2-3 dni

---

## 1. Konfiguracja Android ✅ Gotowa

Wszystkie elementy konfiguracji Androida są na miejscu.

| Element | Status | Opis |
|---------|--------|------|
| **Klucz podpisywania (JKS)** | ✅ Gotowy | `android/app/napstack-upload.jks` (2.8 KB) |
| **Plik kluczy** | ✅ Gotowy | `android/key.properties` skonfigurowany ze wskaźnikami na JKS |
| **Dźwięki alarmu — MP3** | ✅ Gotowy | W `assets/sounds/`: gentle_rise.mp3, mixkit_bell_notification.mp3, mixkit_happy_bells_notification.mp3, napstack_*.mp3 |
| **Dźwięki alarmu — OGG** | ✅ Gotowy | W `assets/sounds/` i `android/app/src/main/res/raw/` |
| **Build config — signingConfig** | ✅ Gotowy | `android/app/build.gradle.kts` — blok `release` czyta z `key.properties` |
| **ProGuard rules** | ✅ Gotowy | `android/app/proguard-rules.pro` — reguły dla Appwrite, RevenueCat, flutter_secure_storage |
| **AndroidManifest.xml** | ✅ Gotowy | Wszystkie wymagane uprawnienia: `INTERNET`, `SCHEDULE_EXACT_ALARM`, `USE_EXACT_ALARM`, `WAKE_LOCK`, `VIBRATE`, `USE_FULL_SCREEN_INTENT`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED` |

---

## 2. Appwrite ⚠️ Częściowo gotowy

Konfiguracja SDK jest w repozytorium. Wymaga weryfikacji stanu chmury.

| Element | Status | Opis |
|---------|--------|------|
| **Project ID** | ✅ Skonfigurowany | `69d7218d001dd20138f6` w `dart_defines.local.json` |
| **Endpoint** | ✅ Skonfigurowany | `https://fra.cloud.appwrite.io/v1` |
| **Platforma Android (w panelu Appwrite)** | ⚠️ Weryfikacja | Package: `com.patrykdev.napstack` — brak dostępu do panelu aby potwierdzić |
| **Schema bazy danych** | ⚠️ Weryfikacja | Tabele: `nap_sessions`, `nap_stack`, `user_prefs` w bazie `napstack` — skrypt `tool/provision_appwrite.py` istnieje |
| **Funkcja `pro_gate`** | ❌ Do wdrożenia | Kod w `functions/pro_gate/src/main.js` jest gotowy · wymaga deploy w panelu Appwrite + ustawienia ENV |
| **Zmienne ENV dla `pro_gate`** | ❌ Do ustawienia | `RC_SECRET_KEY_ANDROID` (Secret API Key), `RC_PROJECT_ID`, `PRO_ENTITLEMENT_ID` — wymaga dodania w panelu |

---

## 3. RevenueCat 🟡 Częściowo skonfigurowany

SDK jest wbudowany, konfiguracja online wymaga weryfikacji.

| Element | Status | Opis |
|---------|--------|------|
| **Publiczny klucz SDK** | ✅ Skonfigurowany | `RC_PUBLIC_KEY_ANDROID: goog_qQwUjJrVBmjSrRgChpmSoVroQFp` w `dart_defines.local.json` |
| **Integracja SDK w kodzie** | ✅ Gotowa | `lib/features/pro/purchase_service.dart` — entitlement: `pro`, produkt: `napstack_pro_lifetime` |
| **Projekt w RevenueCat** | ⚠️ Weryfikacja | Projekt `NapStack` — brak dostępu do panelu |
| **Entitlement `pro`** | ⚠️ Weryfikacja | Musi być utworzony w panelu RevenueCat |
| **Oferta `current`** | ⚠️ Weryfikacja | Pakiet z produktem `napstack_pro_lifetime` |
| **Service Account JSON** | ❌ Brak | Łączy RevenueCat z Google Play — musi być wygenerowany w Google Play Console |
| **Produkt w Google Play** | ⚠️ Weryfikacja | `napstack_pro_lifetime` (one-time purchase) — wymaga stworzenia w Play Console |

---

## 4. Google Play Store Listing ✅ Prawie gotowy

**Nowa informacja**: Polityka prywatności została opublikowana pod HTTPS. Checklist wyniku: 6/9 gotowych.

| Element | Status | Opis |
|---------|--------|------|
| **Polityka prywatności — plik** | ✅ Gotowy | `docs/google_play/hosting/privacy_pl.html` |
| **Polityka prywatności — hosting** | ✅ Opublikowana | URL: `https://soberstepsdev.github.io/NapStack/napstack/privacy_pl.html` · HTTP 200 OK |
| **Polityka w dart_defines** | ✅ Dodana | `PRIVACY_POLICY_URL` w `dart_defines.local.json` |
| **Feature graphic 1024×500** | ✅ Gotowy | `docs/google_play/store_graphics/feature_graphic_1024x500.png` |
| **Zrzuty ekranu** | ✅ Gotowe | 2 pliki: `phone_screenshot_1080x1920.png`, `phone_screenshot_promo_9x16.png` |
| **Opisy sklepu (PL/EN)** | ✅ Gotowe | `docs/google_play/STORE_LISTING.md` — krótki, pełny, promocyjny |
| **Formularz Data Safety** | ⚠️ Do wypełnienia | Wskazówki w `docs/google_play/DATA_SAFETY.md` — zbierane dane: user IDs, aktywność, finansowe, device IDs |
| **Kwestionariusz Content Rating (IARC)** | ⚠️ Do wypełnienia | Wskazówki w `docs/google_play/CONTENT_RATING.md` |
| **Deklaracja Special Permissions** | ⚠️ Do wypełnienia | `USE_FULL_SCREEN_INTENT`, `USE_EXACT_ALARM` — gotowe uzasadnienia w `docs/google_play/SPECIAL_ACCESS_DECLARATIONS.md` |

---

## 5. CI/CD i proces wydania ⚠️ Workflow gotowy, sekrety do dodania

Workflow GitHub Actions jest zaimplementowany. Wymaga dodania sekretów.

| Element | Status | Opis |
|---------|--------|------|
| **GitHub Actions workflow** | ✅ Gotowy | `.github/workflows/android-release.yml` — buduje `.aab` na Ubuntu, trigger: `workflow_dispatch` (ręczny) |
| **GitHub Secret: `ANDROID_KEY_PROPERTIES`** | ❌ Do dodania | Settings → Secrets → `ANDROID_KEY_PROPERTIES` = zawartość `android/key.properties` |
| **GitHub Secret: `ANDROID_KEYSTORE_BASE64`** | ❌ Do dodania | Settings → Secrets → `ANDROID_KEYSTORE_BASE64` = `base64 napstack-upload.jks` |
| **GitHub Secret: `DART_DEFINES_JSON`** | ❌ Do dodania (opcjonalne) | Settings → Secrets → `DART_DEFINES_JSON` = zawartość `dart_defines.local.json` |
| **Testy Internal Testing** | ⚠️ Planowane | Wgraj `.aab` do Internal Testing w Play Console · zweryfikuj alarmy na fizycznym urządzeniu w trybie Doze |

---

## 6. Ścieżka wdrażania — szczegółowe kroki

### Faza 1: Przygotowanie (do wykonania teraz)

1. **Dodanie GitHub Secrets** (~15 min)
   ```bash
   # Kopiuj zawartość android/key.properties
   cat android/key.properties
   # → Settings → Secrets → ANDROID_KEY_PROPERTIES
   
   # Kopiuj base64 JKS
   base64 android/app/napstack-upload.jks | pbcopy
   # → Settings → Secrets → ANDROID_KEYSTORE_BASE64
   
   # Opcjonalnie: dart_defines.local.json
   cat dart_defines.local.json
   # → Settings → Secrets → DART_DEFINES_JSON
   ```

2. **Testowe uruchomienie workflow** (~5-10 min)
   - GitHub → Actions → Android release bundle → Run workflow
   - Czekaj na `.aab` (ścieżka: Downloads z artefaktów workflow)

### Faza 2: Google Play Console (~2-3 dni)

1. **Utwórz aplikację** (jeśli nie istnieje)
   - Play Console → Create App
   - App name: NapStack
   - Default language: Polish
   - Category: Productivity (lub Lifestyle)

2. **Wejdź w App content** → **App policies**
   - **Privacy policy URL**: `https://soberstepsdev.github.io/NapStack/napstack/privacy_pl.html`

3. **App safety — Data Safety**
   - Fill form za dane zbierane: user IDs, aktywność użytkownika, info finansowe (zakupy Pro), device IDs
   - Patrz: `docs/google_play/DATA_SAFETY.md`

4. **Content rating — IARC**
   - Wypełnij kwestionariusz (IARC)
   - Patrz: `docs/google_play/CONTENT_RATING.md`

5. **API permissions — Special app access**
   - Uzasadnij `USE_FULL_SCREEN_INTENT` i `USE_EXACT_ALARM`
   - Patrz: `docs/google_play/SPECIAL_ACCESS_DECLARATIONS.md`

6. **Store listing**
   - Title: NapStack
   - Short description: (patrz `STORE_LISTING.md`)
   - Full description: (patrz `STORE_LISTING.md`)
   - Feature graphic: `feature_graphic_1024x500.png`
   - Screenshots: co najmniej 2 (masz 2 pliki — mogą być)

7. **Utwórz produkt** (dla subscription/in-app purchase)
   - In-app products (or Subscriptions) → Create
   - Product ID: `napstack_pro_lifetime`
   - Type: One-time purchase
   - Status: Inactive (dopóki nie skonfigurować RevenueCat)

### Faza 3: RevenueCat (~2-3 dni)

1. **Utwórz projekt w RevenueCat**
   - App name: NapStack
   - Platform: Android
   - Package: com.patrykdev.napstack
   - Add RevenueCat public key do dart_defines (już masz)

2. **Utwórz entitlement** (`pro`)
   - Entitlements → Create
   - ID: `pro`

3. **Zaimportuj produkt z Play**
   - Products → Import from Google Play
   - Produkt: `napstack_pro_lifetime`
   - Link do entitlementu: `pro`

4. **Utwórz ofertę** (`current`)
   - Offerings → Create
   - ID: `current`
   - Default package → `napstack_pro_lifetime`

5. **Połącz z Google Play** (Service Account)
   - Google Play Console → API access → Create Service Account
   - Pobierz JSON
   - RevenueCat → Settings → Google Play
   - Upload JSON

### Faza 4: Appwrite (~1-2 dni)

1. **Sprawdź projekt** w https://cloud.appwrite.io
   - Project ID: `69d7218d001dd20138f6`
   - Baza: `napstack`
   - Tabele: `nap_sessions`, `nap_stack`, `user_prefs`
   - Jeśli nie istnieje → uruchom skrypt:
     ```bash
     python3 tool/provision_appwrite.py
     ```

2. **Dodaj platformę Android** (jeśli nie istnieje)
   - Settings → Platforms → Add Platform → Android
   - Package: com.patrykdev.napstack
   - (opcjonalnie SHA-256 fingerprint)

3. **Wdróż funkcję `pro_gate`**
   - Panel Appwrite → Functions → Create Function
   - Runtime: Node.js
   - Kod: zawartość `functions/pro_gate/src/main.js`
   - Deploy

4. **Ustaw ENV dla `pro_gate`**
   - Functions → `pro_gate` → Settings
   - Variables:
     - `RC_SECRET_KEY_ANDROID`: Secret Key z RevenueCat
     - `RC_PROJECT_ID`: Project ID z RevenueCat
     - `PRO_ENTITLEMENT_ID`: `pro`

### Faza 5: Internal Testing (~3-5 dni)

1. **Uruchom workflow na GitHub**
   - Actions → Android release bundle → Run workflow
   - Pobierz wygenerowany `.aab`

2. **Wgraj do Internal Testing**
   - Google Play Console → Testing → Internal testing
   - Upload `.aab`
   - Release notes: "First internal build"

3. **Zaprośmy testerów** (min. 1 device)
   - Add testers: np. twój mail + kilka testowych maili

4. **Zainstaluj na urządzeniu** i przetestuj:
   - Alarm w normalnym trybie
   - Alarm w trybie Doze (Battery Saver)
   - Zakup Pro
   - Synchronizacja z Appwrite
   - Atrybucja dźwięków (settings)

### Faza 6: Wydanie production (~1-2 dni)

1. **Przygotuj Release notes**
2. **Ustaw app version** (jeśli chcesz zmienić z `1.0.0+1`)
3. **Wgraj ostateczny `.aab`**
4. **Ustaw rollout %** (np. 20% → 50% → 100%)
5. **Monitor crash logs** w Play Console

---

## 7. Istotne pliki repozytorium

| Ścieżka | Cel |
|--------|-----|
| `android/app/napstack-upload.jks` | Klucz podpisywania release |
| `android/key.properties` | Wskaźniki na klucz (do GitHub Secrets) |
| `.github/workflows/android-release.yml` | Workflow budujący `.aab` |
| `dart_defines.local.json` | Zmienne środowiskowe (RC, Appwrite, Privacy) |
| `functions/pro_gate/src/main.js` | Funkcja Appwrite do weryfikacji Pro |
| `lib/features/pro/purchase_service.dart` | Integracja RevenueCat w kodzie |
| `docs/google_play/` | Wszystkie pliki do Play Store (listy, grafiki, polityka) |

---

## 8. Checklist interaktywna

Wygenerowana lista: **`docs/google_play/PUBLISH_CHECKLIST.html`**

Otwórz w przeglądarce aby śledzić postęp.

---

## 9. Ryzyka i uwagi

### Niskie ryzyko
- ✅ Konfiguracja Android complete — alarm sound files na miejscu
- ✅ Konfiguracja SDK (RC, Appwrite) w kodzie
- ✅ Polityka prywatności opublikowana
- ✅ GitHub Actions workflow zaimplementowany

### Średnie ryzyko
- ⚠️ **Synchronizacja między RevenueCat ↔ Play Console**: Musi być dokładna, aby SubStatus się zgadzały
- ⚠️ **Funkcja `pro_gate` w Appwrite**: Wymaga poprawnych SECRET KEY i Project ID
- ⚠️ **Alarmy w trybie Doze**: Wymaga testowania na rzeczywistym urządzeniu (nie emulator)

### Mitygacja
- Uruchom Internal Testing zanim pójdziesz na production
- Testuj na co najmniej 2 urządzeniach (normalize phone + older phone)
- Monitoruj crash logs w Play Console przez pierwszy tydzień

---

## 10. Następne kroki (summary)

1. ✅ **Teraz**: Polityka prywatności opublikowana — gotowe
2. ⏭️ **Dziś/Jutro**: Dodaj GitHub Secrets
3. ⏭️ **Następne 2-3 dni**: Google Play Console setup (produkty, formularze, listing)
4. ⏭️ **Następne 2-3 dni**: RevenueCat konfiguracja (entitlements, oferta, SA JSON)
5. ⏭️ **Następne 1 dzień**: Appwrite — wdrożenie `pro_gate`
6. ⏭️ **Następne 3-5 dni**: Internal Testing i testy
7. ⏭️ **Ostateczna publikacja**: Production rollout

---

*Raport wygenerowany automatycznie na podstawie analizy repozytorium NapStack, data: 2026-04-15*
