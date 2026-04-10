# NapStack — Model Bezpieczeństwa Danych

## 1. Warstwy bezpieczeństwa

```
┌─────────────────────────────────────────────────────────────────┐
│  WARSTWA 1 — Data Validator (lib/core/security/data_validator)  │
│  Walidacja wejścia po stronie klienta przed każdym zapisem.     │
│  Blokuje: daty w przyszłości, nieprawidłowe typy, złe zakresy.  │
├─────────────────────────────────────────────────────────────────┤
│  WARSTWA 2 — Permissions Helper (lib/core/security/permissions) │
│  Każdy rekord tworzony z Permission.read/update/delete(         │
│    Role.user(userId)).                                          │
│  Żaden rekord nie ma Role.any() — zero danych publicznych.      │
├─────────────────────────────────────────────────────────────────┤
│  WARSTWA 3 — Appwrite Server (cloud)                            │
│  Atrybuty z required/min/max — serwer odrzuca nieprawidłowe dane│
│  Uprawnienia weryfikowane per-request po stronie serwera.       │
│  Kolekcja: Permission.create(Role.users()) — tylko sesje.       │
├─────────────────────────────────────────────────────────────────┤
│  WARSTWA 4 — Error Handler (lib/core/appwrite/error_handler)    │
│  401 → reinit sesji; 403 → forbidden; 429 → exponential backoff │
│  Offline → fallback na Secure Storage cache.                    │
├─────────────────────────────────────────────────────────────────┤
│  WARSTWA 5 — Secure Storage (lib/core/security/secure_storage)  │
│  userId i Pro status w Android Keystore / iOS Keychain.         │
│  NIE SharedPreferences (plaintext XML na Androidzie).           │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Model uprawnień Appwrite

### Zasady

| Zasada | Implementacja |
|--------|---------------|
| Zero publicznych danych | Nigdzie `Role.any()` dla danych użytkownika |
| Izolacja użytkowników | Każdy rekord: `Role.user(userId)` |
| Tylko zalogowani mogą tworzyć | Kolekcja: `Permission.create(Role.users())` |
| user_prefs jest trwały | Brak `Permission.delete` w user_prefs |
| Granularne uprawnienia | Brak `Permission.write()` — osobne read/update/delete |

### Matryca uprawnień

| Tabela | Create | Read | Update | Delete |
|--------|--------|------|--------|--------|
| `nap_sessions` | users() + user(id) | user(id) | user(id) | user(id) |
| `nap_stack` | users() + user(id) | user(id) | user(id) | user(id) |
| `user_prefs` | users() + user(id) | user(id) | user(id) | **brak** |

> `users()` na poziomie kolekcji = dowolny zalogowany użytkownik może tworzyć rekord w kolekcji.
> `user(id)` na poziomie dokumentu = tylko właściciel może odczytać / modyfikować.

---

## 3. Przechowywanie danych wrażliwych

| Dane | Lokalizacja | Szyfrowanie |
|------|-------------|-------------|
| `userId` (Appwrite) | flutter_secure_storage | AES-256-GCM, klucz w Android Keystore |
| `pro_cached` (bool) | flutter_secure_storage | j.w. |
| Historia sesji | Appwrite cloud | TLS w transporcie, Appwrite szyfruje at-rest |
| Nap Stack | Appwrite cloud | j.w. |
| RevenueCat Public Key | `--dart-define` (build time) | Nie w kodzie źródłowym |
| Appwrite Project ID | `--dart-define` (build time) | Nie w kodzie źródłowym |
| Appwrite API Key | Server-side ONLY (env var) | Nigdy w APK |

> `SharedPreferences` jest używany **wyłącznie** w `BootRecoveryService` —
> headless context (BootReceiver) nie ma dostępu do Android Keystore przez
> flutter_secure_storage plugin (wymaga FlutterPluginRegistry).
> W tym kontekście przechowujemy tylko userId (nie sekret sesji).

---

## 4. Anonimowa tożsamość a prywatność

- Konto anonimowe nie przesyła żadnych PII do Appwrite.
- `userId` to losowy UUID generowany przez Appwrite przy pierwszym logowaniu.
- Appwrite przechowuje: userId, czas created_at, czas last_seen (bez emaila/nazwy).
- GDPR: minimalne dane, użytkownik może usunąć konto przez `account.delete()`.
- `sleepQualityRating` (v1.1+): dane zdrowotne → rozważ szyfrowanie klienta przed zapisem.

---

## 5. Zagrożenia i mitigacje

| Zagrożenie | Ryzyko | Mitigacja |
|------------|--------|-----------|
| Root access do urządzenia | Wysokie | Keystore hardware-backed (API 23+) — klucz nie-eksportowalny |
| Wyciek API Key w APK | Krytyczne | API Key WYŁĄCZNIE server-side (tools/provision_schema.dart) |
| Man-in-the-middle | Średnie | HTTPS / TLS wymagane przez Appwrite SDK |
| Manipulacja danymi przez klienta | Niskie | Serwer Appwrite weryfikuje uprawnienia per-request |
| Utrata danych po reinstalacji | Wysokie (konto anonimowe) | Opcjonalny upgrade do email przy zakupie Pro |
| 401 — wygaśnięcie sesji | Średnie | SessionRecovery handler → auto-reinit |
| Rate limit (429) | Niskie | Exponential backoff z max 3 retry |
| Realtime — nieautoryzowane zdarzenia | Brak | Appwrite wysyła zdarzenia tylko dla zasobów z read permission |

---

## 6. Sekretne zmienne — workflow

```bash
# Development
flutter run \
  --dart-define=APPWRITE_PROJECT_ID=abc123 \
  --dart-define=RC_PUBLIC_KEY_ANDROID=appl_xyz

# CI/CD (GitHub Actions)
flutter build apk \
  --dart-define=APPWRITE_PROJECT_ID=${{ secrets.APPWRITE_PROJECT_ID }} \
  --dart-define=RC_PUBLIC_KEY_ANDROID=${{ secrets.RC_PUBLIC_KEY_ANDROID }}

# Schema Provisioner (NIGDY z klienta)
APPWRITE_ENDPOINT=https://fra.cloud.appwrite.io/v1 \
APPWRITE_PROJECT_ID=abc123 \
APPWRITE_API_KEY=$SECRET_API_KEY \
  dart run tools/provision_schema.dart
```

### .gitignore (krytyczne)

```gitignore
# Klucze — nigdy nie commituj
*.env
.env.local
secrets.xml
google-services.json    # zawiera project_id, nie jest "sekretny" ale ostrożność
key.properties          # Android signing key
*.jks
*.keystore
```

---

## 7. Przyszłe wzmocnienia (v1.1+)

- [ ] Szyfrowanie `sleepQualityRating` po stronie klienta (AES przed zapisem do Appwrite)
- [ ] Upgrade konta anonimowego → email przy zakupie Pro (stały userId)
- [ ] Appwrite + TOTP 2FA dla kont email (opcjonalne)
- [ ] Certificate pinning dla Appwrite endpoint (ochrona przed MitM na rootowanych urządzeniach)
- [ ] Audit log dla operacji Pro w Appwrite Functions
