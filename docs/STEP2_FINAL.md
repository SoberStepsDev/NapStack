# ⚡ STEP 2: Appwrite Function Environment Variables — FINAL

**Status:** Funkcja **Pro Status Gate** znaleziona w Appwrite Cloud. Kod jest prawidłowy. Brakuje tylko zmiennych env.

---

## 🎯 Co trzeba zrobić

Ustawić 3 zmienne env w Appwrite Function **Pro Status Gate** na podstawie wartości z `.env`.

---

## 📋 Zmienne do skopiowania z .env

| Zmienna env | Wartość z .env |
|-------------|----------------|
| `RC_PROJECT_ID` | Linia 10 w `.env` |
| `RC_SECRET_KEY_ANDROID` | Linia 1 w `.env` |
| `PRO_ENTITLEMENT_ID` | Linia 11 w `.env` |

---

## 🔧 Instrukcja krok-po-krok

### 1. Otwórz Appwrite Cloud Console
- URL: https://cloud.appwrite.io/console
- Zaloguj się jeśli wymagane

### 2. Wybierz projekt NapStack
- W panelu левый: **Projects**
- Kliknij: **NapStack** (ID: `69d7218d001dd20138f6`)

### 3. Przejdź do Functions
- Left menu: **Functions**

### 4. Otwórz function Pro Status Gate
- Szukaj: **Pro Status Gate**
- Kliknij na nią

### 5. Otwórz Settings
- Top-right lub left menu: **Settings** (ikona ⚙️)

### 6. Przejdź do Environment Variables
- Sekcja: **Environment Variables** (powinna być w Settings)

### 7. Dodaj zmienną #1: RC_PROJECT_ID
```
Key:   RC_PROJECT_ID
Value: proj1bd829aa   (skopiuj z .env linia 10)
```
- Kliknij: **+ Add** lub **Save**

### 8. Dodaj zmienną #2: RC_SECRET_KEY_ANDROID
```
Key:   RC_SECRET_KEY_ANDROID
Value: sk_DzyYQcIgyPwtYiSNjbVaKoUXLbFuH   (skopiuj z .env linia 1)
```
- Kliknij: **+ Add** lub **Save**

### 9. Dodaj zmienną #3: PRO_ENTITLEMENT_ID
```
Key:   PRO_ENTITLEMENT_ID
Value: pro   (skopiuj z .env linia 11)
```
- Kliknij: **+ Add** lub **Save**

### 10. Deploy function
- Kliknij: **Deploy** (może być na górze lub w Settings)
- Czekaj na: ✅ "Deployment successful" lub "Function deployed"

---

## ✅ Weryfikacja po Deploy

Gdy Deploy się skończy (czekaj ~30-60 sekund):

1. W terminalu na urządzeniu:
```bash
flutter run -d 24117RN76E
```

2. Obserwuj logi:
```bash
flutter logs | grep "pro_gate"
```

3. Spodziewany output:
```
✅ [pro_gate] userId=... allowed=true/false
✅ Pro Status Gate working
```

---

## ❌ Troubleshooting

### Problem: "Cannot find Environment Variables section"
**Rozwiązanie:**
- W Settings szukaj zakładki **Variables** lub **Environment Variables**
- Możliwe że jest pod inną nazwą — poszukaj

### Problem: "Deploy failed — missing RC_SECRET_KEY_ANDROID"
**Rozwiązanie:**
1. Wróć do Environment Variables
2. Sprawdź czy wszystkie 3 zmienne są zapisane
3. Spróbuj Deploy ponownie

### Problem: "Authorization failed — invalid API key"
**Rozwiązanie:**
1. Sprawdź czy `RC_SECRET_KEY_ANDROID` jest **Secret API Key v2** (nie Public Key)
2. RevenueCat Dashboard → Settings → API Keys → Secret Key (v2)
3. Skopiuj całą wartość (powinno zaczynać się `sk_`)
4. Zaktualizuj w Appwrite

---

## 📱 Następny krok (Step 3)

Po Deploy function:
```bash
flutter run -d 24117RN76E
```

Appwrite schema + Function zmienne = app gotowy do testowania Pro features 🎉

---

## 📝 Checklist

```
[ ] Otwarta: Appwrite Cloud Console
[ ] Wybrany: NapStack project
[ ] Otwarta: Functions → Pro Status Gate
[ ] Otwarte: Settings → Environment Variables
[ ] Dodana: RC_PROJECT_ID
[ ] Dodana: RC_SECRET_KEY_ANDROID
[ ] Dodana: PRO_ENTITLEMENT_ID
[ ] Kliknięty: Deploy
[ ] Status: ✅ Deployment successful
[ ] Logów: ✅ flutter logs | grep pro_gate → pozytywny output
```

---

**Status Step 2:** ✅ Gotowy — czekamy na ręczne ustawienie zmiennych w konsoli
