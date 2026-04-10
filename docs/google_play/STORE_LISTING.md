# Google Play — opis sklepu, URL polityki, teksty promocyjne (NapStack)

## Polityka prywatności — URL (wymagane w Play)

**Instrukcja wdrożenia (krok po kroku):** `[hosting/README.md](hosting/README.md)`.

1. Opublikuj `docs/google_play/hosting/privacy_pl.html` pod **HTTPS** (szczegóły: GitHub Pages, Firebase, własna domena itd. — w `hosting/README.md`).
2. W **Google Play Console** w pole **Polityka prywatności** wklej **ten sam** publiczny URL.
3. Opcjonalnie — **identyczny** URL w buildzie, żeby link „(www)” w aplikacji nie rozjechał się z Play:
  - `flutter build appbundle --dart-define=PRIVACY_POLICY_URL=<URL>`
  - albo `PRIVACY_POLICY_URL=<URL>` w `.env` + `python3 tool/sync_dart_defines_from_env.py …` + `--dart-define-from-file=dart_defines.local.json`  
   (patrz `[tool/sync_dart_defines_from_env.py](../../tool/sync_dart_defines_from_env.py)`).

**Szablon URL (podmień host i ścieżkę; użyj dokładnie tej samej wartości w Play i w `PRIVACY_POLICY_URL`):**

```text
https://twoja-domena.pl/napstack/privacy.html
```

Przykład z katalogiem zamiast pliku (wtedy na serwerze użyj `index.html`):

```text
https://twoja-domena.pl/napstack/privacy/
```

---

## Krótki opis (max 80 znaków) — PL

```
Drzemki z alarmem, statystyki i sync. Pro: pełne funkcje w Google Play.
```

*(80 znaków — skróć jeśli Play liczy inaczej; w razie potrzeby usuń spacje końcowe.)*

Alternatywa krótsza:

```
Timer drzemki i alarmy — sync chmury, wersja Pro w sklepie.
```

---

## Pełny opis — PL (dostosuj emoji i akapity do swojego stylu)

```
NapStack pomaga zaplanować krótką drzemkę i wybudzić się na czas — bez zbędnego chaosu w interfejsie.

• Presety drzemek (m.in. power nap, dłuższa regeneracja) i czytelny timer
• Alarmy i powiadomienia dopasowane do Androida (w tym dokładne alarmy tam, gdzie system na to pozwala)
• Statystyki — zobacz, jak wykorzystujesz drzemki
• Opcjonalna synchronizacja między urządzeniami (konto techniczne w chmurze)

NapStack Pro
Odblokuj rozszerzone możliwości w jednym zakupie w Google Play (szczegóły na ekranie zakupu). Płatność realizuje Google.

Ważne
Aplikacja służy organizacji odpoczynku i nie zastępuje porady medycznej. W razie problemów ze snem skonsultuj się z lekarzem.

Polityka prywatności i regulamin dostępne w aplikacji oraz pod adresem podanym w sklepie.
```

---

## Short description — EN (max 80 characters)

```
Nap timers & alarms, stats, optional cloud sync. Pro on Google Play.
```

---

## Full description — EN

```
NapStack helps you plan a short nap and wake up on time — with a calm, focused interface.

• Nap presets and a clear timer
• Alarms and notifications tuned for Android (including exact alarms where the OS allows)
• Statistics to see how you use naps
• Optional sync across devices (technical cloud account)

NapStack Pro
Unlock extended features with a one-time purchase on Google Play (see the in-app paywall for details). Google processes payments.

Important
The app is for organising rest and is not medical advice. For sleep or health concerns, speak to a professional.

Privacy policy and terms are available in the app and at the URL shown on the store listing.
```

---

## Tekst promocyjny (opcjonalny, PL)

```
Wybierz drzemkę, ustaw alarm — NapStack pilnuje czasu. Sync między telefonami i statystyki w jednym miejscu.
```

---

## Grafiki (lokalnie w repozytorium)


| Plik                                             | Przeznaczenie                                                                                   |
| ------------------------------------------------ | ----------------------------------------------------------------------------------------------- |
| `store_graphics/feature_graphic_1024x500.png`    | **Feature graphic** — dokładnie **1024 × 500 px** (gotowe pod Play)                             |
| `store_graphics/phone_screenshot_1080x1920.png`  | Przykładowy zrzut **1080 × 1920** — **zastąp** realnymi screenshotami z builda przed publikacją |
| `store_graphics/phone_screenshot_promo_9x16.png` | Oryginał przed skalowaniem (możesz usunąć, jeśli niepotrzebny)                                  |


Google Play wymaga co najmniej **2 zrzuty ekranu** na telefon; wygenerowana grafika nie zastępuje obowiązkowych screenshotów z działającej aplikacji.

---

## Grafika — wytyczne szybkie

- **Ikona aplikacji:** już w projekcie (`android/app/src/main/res/mipmap-`*).
- **Feature graphic:** bez naruszania wytycznych Google (czytelna, bez mylących przycisków „Install”).
- **Zrzuty:** tryb ciemny, kluczowe ekrany: timer, lista presetów, statystyki, ewent. paywall / ustawienia prawne.

