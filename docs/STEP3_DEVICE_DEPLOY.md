# 🚀 STEP 3: Deploy na urządzenie fizyczne

**Status:** Step 1 ✅ + Step 2 ✅ = Konfiguracja API kompletna.

Teraz: Zainstaluj app na fizycznym urządzeniu (24117RN76E) z prawidłowymi API keys.

---

## 📱 Urządzenie docelowe

- **Device ID:** `24117RN76E`
- **Platform:** Android
- **Status:** Podłączone via USB

---

## ⚡ Komenda do uruchomienia lokalnie

```bash
cd /ścieżka/do/NapStack

# Opcja 1: Debug build (szybsza, dla testów)
flutter run -d 24117RN76E

# Opcja 2: Release build (pełna wydajność, dla testów Pro)
flutter run -d 24117RN76E --release
```

---

## 🔧 Krok-po-krok

### 1. Otwórz terminal
- Na swoim komputerze
- Przejdź do folderu NapStack:
```bash
cd /ścieżka/do/NapStack
```

### 2. Załaduj dependencies
```bash
flutter pub get
```

### 3. Sprawdź czy device jest podłączony
```bash
flutter devices
```

**Spodziewany output:**
```
24117RN76E (mobile) • SM-G990B • android-ok • Android 14 (API 34)
```

Jeśli device nie widoczny — sprawdź USB connection.

### 4. Uruchom app na device
```bash
flutter run -d 24117RN76E
```

**Czekaj na:** Budowanie (1-2 minuty) → Instalacja → Launch

---

## 📋 Co dzieje się w tle

1. **pub get** — pobiera Flutter packages (riverpod, appwrite, revenuecat, etc.)
2. **build** — kompiluje Dart/Flutter → native Android code
3. **install** — instaluje APK na device
4. **launch** — uruchamia app

---

## ✅ Weryfikacja — czy działa?

### Terminal output
Gdy app się uruchomi, powinieneś zobaczyć:
```
✅ Application finished downloading to device.
✅ Installing app...
✅ Launching app...
```

### Na urządzeniu
1. App powinien się uruchomić (ekran loading → home)
2. Zaloguj się (jeśli wymagane)
3. Sprawdź Home screen

### Logi — szukaj potwierdzeń

W terminalu gdzie uruchomiłeś `flutter run`:
```bash
# Wciśnij L w terminalu, aby zobaczyć logi
flutter logs | grep -E "pro_gate|selected_ringtone|RC_PUBLIC"
```

**Spodziewane logi:**
```
✅ [pro_gate] userId=... allowed=true/false
✅ Selected ringtone loaded: napstack_peaceful_chime
✅ RevenueCat products initialized: napstack_pro_lifetime
```

**Błędy do unikania:**
```
❌ "selected_ringtone attribute not found" → Schema nie provisioned
❌ "RC_PROJECT_ID not set" → Function env vars brakuje
❌ "sobersteps_*" products → Zły RC Public Key
```

---

## 🔄 Hot Reload (szybkie zmiany)

Gdy app jest uruchomiony:

```
Naciśnij: R   (w terminalu)
```

App się przeładuje bez reinstalacji (kilka sekund).

```
Naciśnij: Q   (w terminalu)
```

Zamknij app i terminal.

---

## 🧪 Testy funkcjonalności

### Test 1: Ringtone selector
1. Home → Settings ⚙️
2. Szukaj: "Ringtone" lub "Dzwonek"
3. Spodziewane: 3 opcje do wyboru (peacefulChime, morningBirds, minimalPing)
4. Wybierz jedną → powinna się zapisać w Appwrite

### Test 2: Pro features visibility
1. Home → "Unlimited Nap Stack" sekcja
2. **Dla Non-Pro:** Powinien być lock icon + tekst "Odblokuj Pro"
3. **Dla Pro:** Unlimited slots widoczne bez lock

### Test 3: Alarm scheduling
1. Create Nap → Ustaw timer
2. Start → Powinien zaplanować alarm z wybranym ringtone'em
3. Gdy alarm wybucha → Powinien grać wybrany dzwonek

---

## ❌ Troubleshooting

### Problem: "Device not found" / "offline"
**Rozwiązanie:**
```bash
# USB Debug Mode ON na device
# Settings → Developer Options → USB Debugging ✅

# Wciśnij USB approve dialog na device

# Test connection:
flutter devices
```

### Problem: "Build failed: pub get error"
**Rozwiązanie:**
```bash
flutter clean
flutter pub get
flutter run -d 24117RN76E
```

### Problem: "App starts but crashes immediately"
**Sprawdź logi:**
```bash
flutter logs | tail -50
```

Szukaj `Exception` lub `Error` w logach. Może być:
- Missing Appwrite schema (selected_ringtone)
- Missing RC keys
- Network error

### Problem: "App runs but 'Selected ringtone' error"
**Przyczyna:** Step 1 (provision_schema) nie został uruchomiony lub się nie udał.

**Rozwiązanie:**
1. Powróć do Step 1 instrukcji
2. Uruchom `provision_schema.dart` lokalnie
3. Hot-reload (R)

---

## 📊 Status po Step 3

| Funkcjonalność | Status |
|---|---|
| App uruchomiony na device | ✅ |
| Appwrite schema OK | ✅ (selected_ringtone) |
| RevenueCat initialized | ✅ (napstack_pro_lifetime) |
| Pro Status Gate function | ✅ (env vars set) |
| Ringtone selector | ✅ (3 opcje) |
| Alarm scheduling | ✅ (z ringtone) |

---

## 🎯 Następne kroki

**Po pomyślnym uruchomieniu app:**

1. **Test Pro purchase** (opcjonalnie):
   - Settings → Buy Pro
   - RevenueCat paywall powinien się pojawić
   - Sandbox test (Google Play Test Accounts)

2. **Test ringtone swap**:
   - Settings → Ringtone → wybierz inny
   - Restart alarm → powinien grać nowy dzwonek

3. **Test Full Cycle preset** (Pro feature):
   - Home → Create Nap
   - Dostęp do Full Cycle timer (bez lock)

4. **Google Play Store publikacja** (jeśli gotowy):
   - Play Console → Upload APK
   - Wdrożenie na production/staging

---

## 📝 Checklist Step 3

```
[ ] Terminal: cd /ścieżka/do/NapStack
[ ] Uruchomiono: flutter pub get (bez błędów)
[ ] Sprawdzono: flutter devices (urządzenie widoczne)
[ ] Uruchomiono: flutter run -d 24117RN76E
[ ] Czekano: ~2 minuty na build + install + launch
[ ] App uruchomiony: Home screen widoczny
[ ] Logi: ✅ pro_gate, selected_ringtone, RC_PUBLIC
[ ] Settings: Ringtone selector działa (3 opcje)
[ ] Home: Unlimited Nap Stack sekcja OK
[ ] Alarm: Create → Schedule → Play (z ringtone)
```

---

## 🎉 Koniec Step 3

Gdy wszystkie testy przejdą ✅ — NapStack jest **w pełni konfigurowany i testowany**.

Gotowy do:
- Dalszych testów
- Publikacji na Google Play Store
- Wdrażania na production
