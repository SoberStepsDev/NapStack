# NapStack — Kontekst dla Manus AI
> Data: 2026-04-11 | Przekazanie pracy z Claude (Cowork)

---

## Projekt

**NapStack** — aplikacja Flutter/Android do zarządzania drzemkami (nap timer) z Pro tier.
- Package: `com.patrykdev.napstack`
- Wersja: `1.0.0+1`
- Backend: Appwrite Cloud (`fra.cloud.appwrite.io`, project ID w `.env`)
- IAP: RevenueCat (Google Play Billing)
- State management: Riverpod
- Root repo: `/Users/tpltd145/Projects/NapStack`

---

## Stan na moment przekazania

### ✅ Zrobione (w tej sesji)
1. **Wszystkie Pro features zaimplementowane** — Pro gate, ringtone selector, pro banner, secure storage cache
2. **Appwrite schema** — dodano atrybut `selected_ringtone` do kolekcji `user_prefs` (via `tools/provision_schema.dart`)
3. **Appwrite Function `pro_gate`** — kod w `functions/pro_gate/src/main.js` jest poprawny, zmienne środowiskowe ustawione w Appwrite Cloud
4. **BootReceiver.kt** — przeniesiony do właściwej ścieżki: `android/app/src/main/kotlin/com/patrykdev/napstack/BootReceiver.kt` (był błędnie w `kotlin/BootReceiver.kt` poza pakietem — to powodowało `Dart_LookupLibrary` crash przy starcie)
5. **Dokumentacja API** — `docs/NAPSTACK_API_KEYS.md`, `docs/NAPSTACK_API_LIST.md`, `docs/APPWRITE_FUNCTION_SETUP.md`
6. **Google Play Console** — aplikacja NapStack utworzona, App access ustawiony na "restricted", kategoria: Productivity

### ❌ Nierozwiązane blokery

#### Bloker 1 — RevenueCat "API Key not recognized"
- **Błąd:** `The specified API Key is not recognized. Ensure that you are using the public app-specific API key`
- **Gdzie:** `lib/features/pro/purchase_service.dart` → `PurchaseService.configure()`
- **Przyczyna:** Klucz publiczny RevenueCat (`RC_PUBLIC_KEY_ANDROID` z `.env`) jest poprawny formatowo (`goog_...`), ale app jest budowana **bez `--dart-define-from-file=.env`**, więc Dart dostaje placeholder `REPLACE_WITH_RC_KEY`
- **Fix:** zawsze budować z flagą:
  ```bash
  flutter run -d 24117RN76E --dart-define-from-file=.env
  # lub release:
  flutter build apk --dart-define-from-file=.env
  ```

#### Bloker 2 — Google Play Console setup niekompletny
- **Stan:** 1 z 13 kroków ukończony
- **Pozostałe kroki do uzupełnienia:**
  - `Set privacy policy` → URL: `https://soberstepsdev.github.io/NapStack/napstack/privacy_pl.html`
  - `App access` → ustawiony (restricted), ale brakuje instrukcji dla recenzentów
  - `Ads` → NapStack nie ma reklam → "No ads"
  - `Content rating` → wypełnić questionnaire
  - `Target audience` → 18+
  - `Data safety` → wypełnić (zbierane dane: email/auth, brak sprzedaży danych)
  - `Government apps` → No
  - `Financial features` → No
  - `Health` → No (nie jest to health app — kategoria: Productivity)
  - `Select app category` → Productivity, email: `sobersteps@pm.me`
  - Store listing (ikony, screenshoty, opisy) — jeszcze nie zaczęte
  - APK/AAB upload — jeszcze nie zrobione
- **Credentials recenzentów Google Play:**
  - Email: `sobersteps@pm.me`
  - Hasło: w pliku `.env` pod kluczem `APPWRITE_PASSWORD` (nie ujawniać)

#### Bloker 3 — Network na urządzeniu (drugorzędny)
- Podczas `flutter run` wystąpiły błędy DNS:
  - `Failed host lookup: 'fra.cloud.appwrite.io'`
  - `Unable to resolve host 'api.revenuecat.com'`
- Prawdopodobnie tymczasowy problem z siecią na urządzeniu `24117RN76E`

---

## Kluczowe pliki

| Plik | Rola |
|------|------|
| `lib/main.dart` | Entry point — inicjalizacja Appwrite, RevenueCat, AlarmService |
| `lib/features/pro/purchase_service.dart` | RevenueCat SDK — `RC_PUBLIC_KEY_ANDROID` via `String.fromEnvironment()` |
| `lib/features/pro/user_prefs_service.dart` | Appwrite `user_prefs` collection — ringtone selector |
| `lib/features/boot_recovery/` | Boot recovery po restarcie urządzenia |
| `lib/boot_recovery_entry.dart` | Headless Dart entry point dla BootReceiver |
| `android/app/src/main/kotlin/com/patrykdev/napstack/BootReceiver.kt` | Kotlin — odbiera BOOT_COMPLETED, startuje headless Flutter engine |
| `android/app/src/main/AndroidManifest.xml` | Uprawnienia + rejestracja BootReceiver |
| `functions/pro_gate/src/main.js` | Appwrite Function — weryfikacja Pro przez RevenueCat V2 API |
| `tools/provision_schema.dart` | Narzędzie do provisioning Appwrite schema |
| `.env` | Wszystkie klucze API — **nigdy nie ujawniać zawartości** |

---

## Architektura Pro

```
[User] → purchasePro() → Google Play Billing → RevenueCat
                                                    ↓
[App] → PurchaseService.isProUnlocked() ← RC SDK (cached w SecureStorage)
                                                    ↓
[Backend] → Appwrite Function pro_gate → RevenueCat V2 REST API
```

- `RC_PUBLIC_KEY_ANDROID` — używany **tylko w app** (Flutter SDK)
- `RC_SECRET_API_KEY` — używany **tylko na serwerze** (Appwrite Function `pro_gate`)
- `RC_SECRET_API_KEY` **nigdy** nie trafia do kodu Flutter

---

## Następne kroki (priorytet)

1. **Natychmiast:** zbudować app z `--dart-define-from-file=.env` i zweryfikować że RevenueCat się inicjalizuje poprawnie
2. **Uzupełnić Google Play Console** — wszystkie 13 kroków store listing
3. **Stworzyć produkt in-app** w Google Play Console: `napstack_pro_lifetime` (one-time purchase)
4. **Połączyć RevenueCat z Google Play** — w RC Dashboard dodać Google Play jako store, wgrać `google-services.json` jeśli wymagany
5. **Upload APK/AAB** do Play Console (Internal Testing track)
6. **Testowanie zakupów** na urządzeniu fizycznym

---

## Zasady pracy (ważne — stosuj bezwzględnie)

- Przed edycją pliku: cytuj pełną ścieżkę względną od rootu repo
- Nie zgaduj nazw plików — szukaj przez grep/glob
- Jedna zmiana = jeden wyraźny cel
- Każdy błąd: pełny komunikat → hipoteza → minimalna zmiana → weryfikacja
- **Klucze API: czytaj z `.env`, nigdy nie ujawniaj w żadnym czacie, pliku, logu, komentarzu**
- Nie ruszaj `pubspec.yaml` ani zależności bez wyraźnej potrzeby
- Po zmianach: uruchom `flutter analyze` i wąski zestaw testów
- Nie twierdzić że problem rozwiązany dopóki nie ma wyniku `flutter test` lub `flutter analyze`

---

## Komenda do uruchomienia (zawsze z .env)

```bash
cd /Users/tpltd145/Projects/NapStack
flutter run -d 24117RN76E --dart-define-from-file=.env
```
