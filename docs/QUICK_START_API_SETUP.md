# 🚀 NapStack — Szybki start API (3 kroki)

Instrukcja end-to-end. Masz wszystkie klucze API w `.env` — wystarczy je zastosować.

---

## 📍 Przed rozpoczęciem

✅ `.env` zawiera:
- `APPWRITE_ENDPOINT`
- `APPWRITE_PROJECT_ID`
- `APPWRITE_API_KEY`
- `RC_PUBLIC_KEY_ANDROID`
- `RC_SECRET_API_KEY` (Secret Key)

---

## ⚡ Krok 1: Provision Appwrite Schema (lokalnie)

**Cel:** Dodanie kolumny `selected_ringtone` do bazy danych Appwrite.

**Komenda:**
```bash
cd /ścieżka/do/NapStack
bash provision_schema.sh
```

**Co robi:**
- Ładuje zmienne z `.env`
- Uruchamia `dart run tools/provision_schema.dart`
- Dodaje atrybuty do kolekcji `user_prefs` w Appwrite Cloud

**Spodziewany output:**
```
✅ Zmienne Appwrite załadowane
🚀 Uruchamianie provision_schema.dart...
✅ Provisioning ukończony!
```

**Jeśli błąd:**
- "dart: command not found" → Flutter SDK nie w PATH
  - Rozwiązanie: `export PATH="$PATH:$HOME/flutter/bin"`
  - Lub: Pełna ścieżka: `/home/user/flutter/bin/dart run tools/provision_schema.dart`

---

## ⚡ Krok 2: Appwrite Function Environment Variables (w konsoli)

**Cel:** Skonfigurowanie `pro_gate` function do weryfikacji Pro features.

**Zmienne do ustawienia:**

| Key | Value | Źródło |
|-----|-------|--------|
| `RC_PROJECT_ID` | `proj_xxxxxxx` | RevenueCat Dashboard → NapStack Project → Project ID |
| `RC_SECRET_KEY_ANDROID` | `sk_xxxxxxx` | RevenueCat Dashboard → NapStack Project → API Keys → Secret Key v2 |
| `PRO_ENTITLEMENT_ID` | `pro` | RevenueCat → Entitlements → pro |

**Instrukcja:**
1. [Otwórz Appwrite Cloud](https://cloud.appwrite.io/console)
2. Projekt: **NapStack** (ID: `69d7218d001dd20138f6`)
3. Functions → **pro_gate**
4. Settings (ikona ⚙️)
5. Sekcja **Environment Variables**
6. Dodaj powyższe 3 zmienne
7. **Deploy function**

**Szczegóły:** → `docs/APPWRITE_FUNCTION_SETUP.md`

---

## ⚡ Krok 3: Deploy do urządzenia

**Cel:** Zainstalowanie app na fizycznym urządzeniu z Pop fixtures.

**Komenda:**
```bash
cd /ścieżka/do/NapStack

# Zainstaluj dependencies
flutter pub get

# Hot-build do urządzenia (w trybie Release dla testów Pro)
flutter run -d 24117RN76E --release
```

**Czekaj na:** Logi w terminalu:
```
✅ Application finished downloading.
✅ pro_gate function returned: {isPro: true}
```

**Hot-reload do szybkich zmian:**
```
Naciśnij: R (w terminalu gdzie uruchomiony flutter run)
```

---

## ✅ Weryfikacja — czy działa?

### Test 1: Appwrite schema OK?
```bash
# W app: Settings → Check if "Ringtone" selector wczytuje opcje bez błędów
# Logów: flutter logs | grep "selected_ringtone"
# Powinno: ✅ "Loaded ringtone from Appwrite"
```

### Test 2: Pro features OK?
```bash
# W app: Home → "Unlimited Nap Stack" sekcja
# Powinno: ✅ Przycisk "Odblokuj Pro" widoczny dla Non-Pro
#          ✅ Unlimited slots dla Pro (jeśli zakupiony)
```

### Test 3: RevenueCat OK?
```bash
# Logów: flutter logs | grep "RC_" or "RevenueCat"
# Powinno: ✅ "Products loaded: napstack_pro_lifetime"
#          ❌ NIE "sobersteps_*" — jeśli tak, błędy konfiguracji RC key
```

---

## 🛠️ Troubleshooting

### ❌ "Selected ringtone attribute not found"
**Problem:** Provision schema nie działał lub nie został uruchomiony.  
**Rozwiązanie:**
```bash
bash provision_schema.sh  # Spróbuj jeszcze raz
# Jeśli flutter SDK problem:
/home/user/flutter/bin/dart run tools/provision_schema.dart
```

### ❌ "Cannot verify Pro: RC_PROJECT_ID not set"
**Problem:** Appwrite Function env variables brakuje.  
**Rozwiązanie:**
1. [Appwrite Cloud](https://cloud.appwrite.io/console)
2. Functions → pro_gate → Settings
3. Dodaj wszystkie 3 zmienne (patrz Krok 2)
4. Deploy function

### ❌ "Products not found: sobersteps_*"
**Problem:** RC_PUBLIC_KEY_ANDROID wskazuje na SoberSteps, nie NapStack.  
**Rozwiązanie:**
1. [RevenueCat Dashboard](https://app.revenuecat.com)
2. Czy masz **NapStack project** (nie SoberSteps)?
3. Skopiuj **Android Public Key** z NapStack
4. Wstaw do `.env` jako `RC_PUBLIC_KEY_ANDROID`
5. `flutter run -d 24117RN76E` ponownie

### ❌ "Flutter SDK not found"
**Problem:** `dart: command not found`  
**Rozwiązanie:**
```bash
# Sprawdź gdzie jest Flutter
which flutter

# Jeśli "flutter: not found":
# 1. Zainstaluj Flutter: https://flutter.dev/docs/get-started/install
# 2. Lub: Dodaj do PATH
export PATH="$PATH:$HOME/flutter/bin"

# Spróbuj ponownie
dart run tools/provision_schema.dart
```

---

## 📊 Status po każdym kroku

| Krok | Cel | ✅ Done | ❌ Problem |
|------|-----|---------|-----------|
| 1 | Provision schema | Brak błędów w provision_schema.sh | "dart: command not found" |
| 2 | Appwrite Function env | 3 zmienne widoczne w Settings | "Error deploying function" |
| 3 | App na device | "Application finished downloading" | "Build failed" |

---

## 🎯 Po ukończeniu

1. **App uruchomiony** → Możliwość testowania Pro features
2. **Alarm scheduling** → Ringtone selector pobiera dane z Appwrite
3. **In-app purchases** → RevenueCat zintegrowany
4. **Next:** Integracja z Google Play Store (opcjonalnie)

---

## 📝 Pliki powiązane

- `docs/NAPSTACK_API_KEYS.md` — Pełna lista klucze API (rola, format, źródło)
- `docs/APPWRITE_FUNCTION_SETUP.md` — Szczegóły Appwrite Function env variables
- `provision_schema.sh` — Skrypt do uruchomienia lokalnie (Step 1)
- `NAPSTACK_API_LIST.md` — Macierz: gdzie trafiają wszystkie klucze

---

## 🔗 Konsole

- [Appwrite Cloud](https://cloud.appwrite.io/console)
- [RevenueCat](https://app.revenuecat.com)
- [Google Play Console](https://play.google.com/console) (opcjonalnie)

---

**Status:** Ready to deploy 🚀
