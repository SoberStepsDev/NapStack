# Google Play — Data safety (NapStack)

Użyj poniższych odpowiedzi w **Google Play Console → Twoja aplikacja → Zasady programu → Bezpieczeństwo danych** (Data safety). Dostosuj je, jeśli zmienisz SDK, analitykę lub backend.

**Zasada:** deklaracje muszą być **zgodne** z faktycznym działaniem aplikacji, polityką prywatności i uprawnieniami w manifeście.

---

## 1. Czy zbierasz lub udostępniasz wymagane typy danych?

**Tak.**

---

## 2. Czy wszystkie dane użytkownika przesyłane są szyfrowane podczas przesyłu?

**Tak** (HTTPS / TLS do Appwrite, RevenueCat, Google Play).

---

## 3. Czy użytkownik może poprosić o usunięcie danych?

**Tak** — opisz proces (np. e-mail wsparcia z karty Google Play + usunięcie konta / żądanie usunięcia danych po weryfikacji). W polityce prywatności masz już zapowiedź usunięcia / anonimizacji na żądanie.

---

## 4. Czy aplikacja jest przeznaczona głównie dla dzieci?

**Nie** (o ile nie zmienisz pozycjonowania).

---

## 5. Deklaracja typów danych (zbiór / udostępnianie)

Poniżej typowe mapowanie dla obecnego stacku: **Appwrite** (sync, konto anonimowe), **RevenueCat** (zakupy Pro), **Google Play** (płatności). W formularzu zaznacz **zbierane** i/lub **udostępniane** zgodnie z definicjami Google (Collected = przesyłane z urządzenia lub powiązane z użytkownikiem; Shared = przekazywane do podmiotu trzeciego).

### 5.1. Identyfikatory użytkownika (User IDs)

| Pole w formularzu | Sugestia |
|-------------------|----------|
| Zbierane | **Tak** |
| Udostępniane | **Tak** |
| Do czego | **Funkcjonalność aplikacji**, **Zarządzanie kontem** (opcjonalnie **Bezpieczeństwo, zapobieganie oszustwom** przy zakupach) |
| Czy obowiązkowe | Funkcje sync / Pro: praktycznie **wymagane** do tych funkcji |
| Czy możliwe do wyłączenia | Sync off-line tylko lokalnie — przy korzystaniu z chmury **nie** |

**Komu:** Appwrite (backend), RevenueCat (powiązanie zakupu z `app user id`).

---

### 5.2. Aktywność w aplikacji — treści generowane przez użytkownika (np. „Other user-generated content”)

| Pole | Sugestia |
|------|----------|
| Zbierane | **Tak** — dane o zaplanowanych / zakończonych drzemkach (typ, czas, status) wysyłane do synchronizacji |
| Udostępniane | **Tak** — do **Appwrite** (hosting bazy) |
| Do czego | **Funkcjonalność aplikacji** (sync, historia między urządzeniami) |
| Szyfrowanie w trakcie przesyłu | **Tak** |

*Uwaga:* Nie pozycjonujecie aplikacji jako medycznej — sensowniej jest traktować to jako **aktywność w aplikacji**, a nie „dane zdrowotne”, o ile nie zbieracie np. tętna z urządzeń medycznych.

---

### 5.3. Informacje finansowe (np. historia zakupów / dane transakcji w kontekście sklepu)

| Pole | Sugestia |
|------|----------|
| Zbierane | **Tak** — weryfikacja statusu Pro / przywracanie zakupów |
| Udostępniane | **Tak** — **Google Play** (płatność), **RevenueCat** (weryfikacja) |
| Do czego | **Funkcjonalność aplikacji**, **Zarządzanie kontem**, ewent. **Zapobieganie oszustwom** |
| Szyfrowanie w trakcie przesyłu | **Tak** |

---

### 5.4. Identyfikatory urządzenia (Device or other IDs)

| Pole | Sugestia |
|------|----------|
| Zbierane / udostępniane | **Oceń po integracji RevenueCat** — często **Tak** (identyfikatory pomocnicze przy przywracaniu zakupów). Jeśli wyłączysz wszystkie identyfikatory reklamowe i RC używa wyłącznie `appUserId`, możesz to zweryfikować z [dokumentacją RevenueCat](https://www.revenuecat.com/docs) i zaktualizować deklarację. |

*Bezpieczniej:* po pierwszym wypełnieniu przejrzyj **App content → Data safety** pod kątem ostrzeżeń Play i zestawienia z **szczegółami SDK** w konsoli.

---

## 6. Czego zwykle **nie** zgłaszasz (przy obecnym manifeście)

- **Lokalizacja** (GPS / przybliżona z uprawnień) — brak `ACCESS_*_LOCATION` w `AndroidManifest.xml`.
- **Kontakty, SMS, kalendarz, zdjęcia** — brak takich uprawnień.
- **Dane zdrowotne z czujników medycznych** — brak w obecnym zakresie funkcji.

---

## 7. Powiadomienia i alarmy

**Nie** są to dane „treści wiadomości”. Lokalne powiadomienia / alarmy realizują funkcję przypomnienia — nie wymaga to osobnej kategorii „messages”, o ile nie czytacie skrzynek mailowych użytkownika.

---

## 8. Spójność z polityką prywatności

URL polityki w Play musi opisywać te same kategorie (Appwrite, RevenueCat, Google, dane drzemek, ID konta). Zobacz: `hosting/privacy_pl.html` oraz `assets/legal/privacy_*.md`.

---

*Szablon roboczy — nie jest poradą prawną. W razie wątpliwości skonsultuj formularz z prawnikiem.*
