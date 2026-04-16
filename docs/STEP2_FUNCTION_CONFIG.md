# ⚡ STEP 2: Appwrite Function `pro_gate` — Konfiguracja zmiennych env

## ✅ Stan: Step 1 ukończony
Atrybut `selected_ringtone` został dodany do Appwrite Cloud — baza gotowa.

---

## 🎯 Cel Step 2
Skonfigurować Appwrite Function `pro_gate` z 3 zmiennymi RevenueCat, aby weryfikacja Pro entitlementu działała.

---

## 📋 Co trzeba zrobić (ręcznie — w Appwrite Cloud Console)

### Zmienne do ustawienia

| Zmienna | Format | Gdzie uzyskać |
|---------|--------|---------------|
| `RC_PROJECT_ID` | `proj_xxxxxxx` | RevenueCat Dashboard → NapStack Project → Settings → Project ID |
| `RC_SECRET_KEY_ANDROID` | `sk_xxxxxxxx...` (Secret API Key v2) | RevenueCat Dashboard → NapStack Project → Settings → API Keys → Secret API Key (v2) |
| `PRO_ENTITLEMENT_ID` | `pro` (lub custom) | RevenueCat Dashboard → NapStack Project → Entitlements → ID |

---

## 🔧 Instrukcja krok-po-krok

### 1. Otwórz Appwrite Cloud
- URL: https://cloud.appwrite.io/console
- Projekt: **NapStack** (ID: `69d7218d001dd20138f6`)

### 2. Przejdź do Functions
- Left menu: **Functions**
- Funkcja: `pro_gate`

### 3. Otwórz Settings
- Przycisk/ikona: **Settings** (zwykle ⚙️ lub "Settings" w top-right)

### 4. Environment Variables
- Sekcja: **Environment Variables** (może być pod Settings)
- Przycisk: **+ Add Variable** (lub podobny)

### 5. Dodaj 3 zmienne

#### Zmienna 1: RC_PROJECT_ID
```
Key: RC_PROJECT_ID
Value: <skopiuj z RevenueCat Project Settings>
```

#### Zmienna 2: RC_SECRET_KEY_ANDROID
```
Key: RC_SECRET_KEY_ANDROID
Value: <skopiuj z RevenueCat API Keys — Secret Key v2>
```

#### Zmienna 3: PRO_ENTITLEMENT_ID
```
Key: PRO_ENTITLEMENT_ID
Value: pro
```

### 6. Deploy Function
- Przycisk: **Deploy** (zwykle u góry lub w Settings)
- Status: Czekaj na "Deployment successful" ✅

---

## 📍 Gdzie znaleźć wartości w RevenueCat

### RevenueCat Project ID
1. [RevenueCat Dashboard](https://app.revenuecat.com)
2. **NapStack** project (NOT SoberSteps)
3. Settings (ikona ⚙️ lub "Project Settings")
4. Sekcja **General** lub **Project ID**
5. Wartość: `proj_xxxxxxxxxxxxxxxx`

### RevenueCat Secret API Key v2
1. RevenueCat Dashboard → **NapStack** project
2. Settings
3. Sekcja **API Keys** lub **Integration**
4. **Secret API Key (v2)** — kliknij copy
5. Wartość: `sk_xxxxxxxxxxxxxxxx...` (50+ chars)
6. ⚠️ To jest SECRET — nie ujawniaj publicznie

### RevenueCat Entitlement ID
1. RevenueCat Dashboard → **NapStack** project
2. Sekcja **Products** lub **Entitlements**
3. Znajdź entitlement (domyślnie: `pro`)
4. Wartość: `pro`

---

## ✅ Checklist przed Deploy

```
[ ] Otwarta: Appwrite Cloud Console
[ ] Wybrany: NapStack project
[ ] Otwarta: Functions → pro_gate
[ ] Kliknięte: Settings
[ ] Widoczna: Sekcja Environment Variables
[ ] Dodana: RC_PROJECT_ID = proj_...
[ ] Dodana: RC_SECRET_KEY_ANDROID = sk_...
[ ] Dodana: PRO_ENTITLEMENT_ID = pro
[ ] Kliknięty: Deploy (lub Save + Deploy)
[ ] Status: "Deployment successful" ✅
```

---

## 🔍 Weryfikacja po Deploy

W aplikacji:
```bash
flutter run -d 24117RN76E
# W logach sprawdź:
flutter logs | grep "pro_gate"

# Powinno być:
✅ "pro_gate function returned: {isPro: true/false}"

# Jeśli błąd:
❌ "RC_PROJECT_ID not set" → Zmienne env brakuje
❌ "RevenueCat API key invalid" → Złe Secret Key
```

---

## ❌ Troubleshooting

### Problem: "Cannot read environment variable RC_PROJECT_ID"
**Rozwiązanie:**
1. Wróć do Settings → Environment Variables
2. Sprawdź czy wszystkie 3 zmienne są tam
3. Deploy function ponownie

### Problem: "Invalid RevenueCat API key"
**Rozwiązanie:**
1. RevenueCat Dashboard → Settings → API Keys
2. Sprawdź czy kopiujesz **Secret API Key v2** (nie Public Key)
3. Sprawdź czy to **NapStack projekt** (nie SoberSteps)
4. Usuń starą zmienną, dodaj nową z prawdziwą wartością
5. Deploy function

### Problem: "Entitlement pro not found in RevenueCat"
**Rozwiązanie:**
1. RevenueCat → NapStack Project → Products/Entitlements
2. Sprawdź czy entitlement `pro` istnieje
3. Jeśli nie — utwórz: **+ New** → Type: **Entitlement** → ID: `pro`
4. Dodaj do Appwrite Function env vars
5. Deploy

### Problem: "Function deployment failed"
**Rozwiązanie:**
1. Sprawdź czy `pro_gate` function kod jest prawidłowy (nie edytowałeś?)
2. Spróbuj Deploy ponownie (czasem timeout)
3. Jeśli dalej błąd — czytaj error message i zgłoś

---

## 📝 Status

**Step 1:** ✅ DONE (Appwrite schema provisioned)  
**Step 2:** 🔄 IN PROGRESS (Czekamy na env vars setup + Deploy)  
**Step 3:** ⏳ NEXT (flutter run na device)

---

## Gdy skończysz Step 2

Napisz mi: **"Step 2 done"**

Wtedy przejdziemy do **Step 3** — Deploy app na urządzenie.
