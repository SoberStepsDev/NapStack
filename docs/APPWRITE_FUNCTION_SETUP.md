# Appwrite Function `pro_gate` — Konfiguracja zmiennych środowiskowych

## Overview
Appwrite Function `pro_gate` weryfikuje Pro entitlementy użytkownika poprzez RevenueCat API. Wymaga 3 zmiennych środowiskowych do działania.

---

## 📋 Zmienne do ustawienia w Appwrite Cloud Console

### Kroki:
1. Otwórz [Appwrite Cloud Console](https://cloud.appwrite.io)
2. Wybierz projekt **NapStack** (ID: `69d7218d001dd20138f6`)
3. Przejdź do **Functions** → `pro_gate`
4. Kliknij **Settings** (ikona gear)
5. Sekcja **Environment Variables**
6. Dodaj poniższe 3 zmienne

---

## 🔑 Zmienna 1: RevenueCat Project ID

**Key:** `RC_PROJECT_ID`

**Format:** `projxxxxxxxx` (zwykle zaczyna się od `proj`)

**Gdzie uzyskać:**
1. Zaloguj się na [RevenueCat Dashboard](https://app.revenuecat.com)
2. Otwórz **NapStack project** (NIE SoberSteps)
3. Project Settings (ikona gear/⚙️)
4. Sekcja **General** lub **Project ID**
5. Skopiuj wartość (wygląda: `proj_...`)

**Zapisz w Appwrite:**
- Key: `RC_PROJECT_ID`
- Value: `proj_xxxxxxxxxxxxxxxx` (skopiowana wartość)

---

## 🔑 Zmienna 2: RevenueCat Secret API Key (Android)

**Key:** `RC_SECRET_KEY_ANDROID`

**Format:** Secret API Key v2 (50+ znaków)

**Gdzie uzyskać:**
1. [RevenueCat Dashboard](https://app.revenuecat.com) → NapStack Project
2. Project Settings
3. Sekcja **API Keys** lub **Integration**
4. **Secret API Key (v2)** — kliknij "Copy"
5. ⚠️ To jest SECRET — nigdy nie ujawniaj publicznie

**Zapisz w Appwrite:**
- Key: `RC_SECRET_KEY_ANDROID`
- Value: `sk_xxxxxxxxxxxxxxxxxxxxxx` (skopiowana wartość)

---

## 🔑 Zmienna 3: RevenueCat Entitlement ID

**Key:** `PRO_ENTITLEMENT_ID`

**Format:** String ID (domyślnie: `pro`)

**Gdzie uzyskać:**
1. [RevenueCat Dashboard](https://app.revenuecat.com) → NapStack Project
2. Project Settings
3. Sekcja **Entitlements** lub **Products**
4. Znajdź entitlement dla Pro (domyślnie: `pro`)
5. Skopiuj ID

**Zapisz w Appwrite:**
- Key: `PRO_ENTITLEMENT_ID`
- Value: `pro` (lub custom ID jeśli inny)

---

## ✅ Weryfikacja — przed i po

### Przed konfiguracją
App loguje błąd:
```
❌ ServerException: Environment variable RC_PROJECT_ID is required
❌ pro_gate function failed: RC_SECRET_KEY_ANDROID not set
```

### Po konfiguracji
Appwrite Function `pro_gate`:
- ✅ Pomyślnie weryfikuje RevenueCat produkty
- ✅ Zwraca `isPro: true/false` dla użytkownika
- ✅ App wyświetla lock icon dla Non-Pro, odblokowuje funkcje Pro dla Pro

---

## 🔧 Troubleshooting

### Problem: "Cannot find environment variable X"
**Rozwiązanie:** Wróć do Settings → Environment Variables → zweryfikuj że wszystkie 3 zmienne są ustawione

### Problem: "RevenueCat API key invalid"
**Rozwiązanie:** 
1. Sprawdź czy kopiujesz **Secret API Key v2** (nie Public Key)
2. Sprawdź czy to klucz z **NapStack projektu** (nie SoberSteps)
3. Jeśli nowszy klucz — usuń stary i utwórz nowy

### Problem: "Entitlement pro not found"
**Rozwiązanie:**
1. RevenueCat → NapStack Project → Entitlements
2. Sprawdź czy entitlement `pro` istnieje
3. Jeśli nie — utwórz nowy: Products → New → Type: Entitlement → ID: `pro`

---

## 📝 Checklist konfiguracji

```
[ ] Otwarte: Appwrite Cloud Console → NapStack Project → Functions → pro_gate
[ ] Kliknięte: Settings (ikona gear)
[ ] Widoczna: Sekcja "Environment Variables"
[ ] Dodane: RC_PROJECT_ID = proj_xxxxxxx
[ ] Dodane: RC_SECRET_KEY_ANDROID = sk_xxxxxxx
[ ] Dodane: PRO_ENTITLEMENT_ID = pro
[ ] Kliknięte: Save (jeśli przycisk jest dostępny)
[ ] Otwarte: pro_gate function code
[ ] Kliknięte: Deploy / Redeploy
[ ] Status: "Function deployed successfully" ✅
```

---

## 🔗 Bezpośrednie linki

- [Appwrite Cloud Console](https://cloud.appwrite.io/console)
- [RevenueCat Dashboard](https://app.revenuecat.com)

---

## Następny krok

Po ustawieniu zmiennych env i deployu function:
1. Na urządzeniu: `flutter run -d 24117RN76E`
2. Hot-reload: Naciśnij `R` w terminalu
3. App powinna załadować Pro features
4. Sprawdź logów: `flutter logs | grep pro_gate`
