# NapStack — Wymagane klucze API

Dokument defines **dokładnie** jakie klucze API są potrzebne do NapStack (tylko NapStack, nie SoberSteps).

---

## 🔑 Klucze wymagane (PRODUCTION)

### 1. Appwrite — projekt NapStack

| Zmienna | Format | Źródło | Gdzie używane |
|---------|--------|--------|---------------|
| `APPWRITE_ENDPOINT` | URL | [Appwrite Cloud Settings](https://cloud.appwrite.io/console/account/settings) | Backend connection |
| `APPWRITE_PROJECT_ID` | 25 hex chars | Appwrite Project → Settings → Project ID | Identyfikator projektu |
| `APPWRITE_API_KEY` | 50+ chars | Appwrite → Settings → API Keys → Create → `collections.write` scope | Schema provisioning (lokalnie tylko) |

**Gdzie:** `.env` lokalnie, `--dart-define` w build, GitHub Secrets dla CI/CD.

**Aktualne wartości (bezpieczne — nie credentials):**
- `APPWRITE_ENDPOINT`: `https://fra.cloud.appwrite.io/v1`
- `APPWRITE_PROJECT_ID`: `69d7218d001dd20138f6`

---

### 2. RevenueCat — projekt NapStack (nie SoberSteps!)

| Zmienna | Format | Źródło | Gdzie używane |
|---------|--------|--------|---------------|
| `RC_PUBLIC_KEY_ANDROID` | `goog_xxxxxxxx` | [RevenueCat Dashboard](https://app.revenuecat.com) → Project Settings → SDK Keys → **Android Public Key** | In-app purchases (Flutter app) |

**⚠️ WAŻNE:** Musisz mieć **osobny projekt NapStack** w RevenueCat (nie SoberSteps).

**Aktualna wartość w `.env`:** Wskazuje na **SoberSteps** — trzeba zmienić na NapStack RC key.

---

### 3. Appwrite Function `pro_gate` — zmienne serwera

Te zmienne **nie trafiają do `.env` ani do repo** — są tylko w Appwrite Function Settings.

| Zmienna | Format | Źródło | Gdzie używane |
|---------|--------|--------|---------------|
| `RC_PROJECT_ID` | `projxxxxxxxx` | [RevenueCat Dashboard](https://app.revenuecat.com) → Project Settings → Project ID | Appwrite Function `pro_gate` |
| `RC_SECRET_KEY_ANDROID` | Secret API Key v2 | RevenueCat → Project Settings → API Keys → Secret API Key (v2) | Appwrite Function `pro_gate` (server-side only) |
| `PRO_ENTITLEMENT_ID` | `pro` (lub custom) | RevenueCat → Entitlements → ID | Appwrite Function `pro_gate` |

**Setup:**
1. Wejdź na [Appwrite Cloud](https://cloud.appwrite.io) → NapStack project → Functions → `pro_gate`
2. **Settings → Environment Variables** → dodaj 3 zmienne powyżej
3. **Deploy** function

---

### 4. Google Play Console (opcjonalnie — do publikacji na Play Store)

| Zmienna | Format | Źródło | Gdzie używane |
|---------|--------|--------|---------------|
| `GOOGLE_PLAY_KEY_JSON` | JSON Service Account | [Google Cloud Console](https://console.cloud.google.com) → Service Accounts → Keys (JSON) | GitHub Secrets → CI/CD release build |
| `napstack_pro_lifetime` | Product ID | Google Play Console → In-app products | RevenueCat integration |

---

### 5. Legal URLs (opcjonalnie)

| Zmienna | Format | Źródło | Gdzie używane |
|---------|--------|--------|---------------|
| `PRIVACY_POLICY_URL` | HTTPS URL | Twoja strona | App settings, settings screen |
| `TERMS_OF_SERVICE_URL` | HTTPS URL | Twoja strona | App settings, settings screen |
| `CONSUMER_INFO_URL` | HTTPS URL | Twoja strona | App settings, settings screen |

---

## 📋 Checklist — co trzeba zrobić

```
[ ] Appwrite Cloud — projekt NapStack istnieje
    [ ] Project ID: 69d7218d001dd20138f6 (skopjowany do .env)
    [ ] API Key z collections.write scope (lokalnie w .env)
    [ ] Endpoint: https://fra.cloud.appwrite.io/v1

[ ] RevenueCat — projekt NapStack istnieje (nie SoberSteps!)
    [ ] Public SDK Key (Android) skopiowany do .env
    [ ] Project ID skopiowany do Appwrite Function env vars
    [ ] Secret API Key (v2) skopiowany do Appwrite Function env vars
    [ ] Entitlement "pro" istnieje

[ ] Appwrite Function pro_gate
    [ ] 3 zmienne RC w Settings → Environment Variables
    [ ] Function wdrożona (deployed)

[ ] Google Play Console (opcjonalnie)
    [ ] napstack_pro_lifetime product aktywny
    [ ] Service Account JSON dla CI/CD

[ ] Legal URLs (opcjonalnie)
    [ ] Prywatność, ToS, Consumer Info URLs w .env
```

---

## ❌ Co NIE należy do NapStack

- `sobersteps_*` produkty RevenueCat
- SoberSteps API keys
- SoberSteps Appwrite project
- SoberSteps RC Public Key

**Jeśli w `.env` lub logach widzisz `sobersteps_*` — coś jest źle skonfigurowane.**

---

## 🔗 Linki do konfiguracji

- [Appwrite Cloud Console](https://cloud.appwrite.io)
- [RevenueCat Dashboard](https://app.revenuecat.com)
- [Google Cloud Console](https://console.cloud.google.com)
- [Google Play Console](https://play.google.com/console)
