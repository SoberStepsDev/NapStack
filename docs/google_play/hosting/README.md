# Wdrożenie polityki prywatności (HTTPS) — NapStack

Źródło treści: plik **`privacy_pl.html`** w tym katalogu. Musi być dostępny publicznie po **HTTPS** (wymóg Google Play).

---

## Skrót — o czym jest ta instrukcja

| Temat | Gdzie w dokumencie |
|--------|---------------------|
| **Jeden wspólny URL** — przykłady `…/privacy.html` oraz `…/privacy/` + `index.html` | [§1](#1-ustal-docelowy-url-jeden-wspólny) |
| **Publikacja** — własny serwer/CDN, GitHub Pages, Firebase / Cloudflare / Netlify | [§2](#2-opublikuj-plik-na-hostingu) |
| **Play Console** — gdzie wkleić politykę, weryfikacja `curl -sI` | [§3](#3-google-play-console--pole-polityka-prywatności) |
| **Build** — `PRIVACY_POLICY_URL` przez `--dart-define` albo `.env` + [`tool/sync_dart_defines_from_env.py`](../../../tool/sync_dart_defines_from_env.py) + `dart_defines.local.json` (ścieżka do `.env` jako argument) | [§4](#4-build-aplikacji--privacy_policy_url-opcjonalnie-ten-sam-url) |
| **Spójność po zmianach** — `privacy_pl.html`, `privacy_pl.md`, `privacy_en.md` | [§5](#5-spójność-treści-po-zmianach) |
| **Checklist** (checkboxy w Markdown) | [§6](#6-checklist) |

---

## 1. Ustal docelowy URL (jeden, wspólny)

Wybierz **jeden** finalny adres HTTPS — **tego samego** użyjesz w Google Play i (opcjonalnie) w `PRIVACY_POLICY_URL` przy buildzie.

**Wariant A — bezpośredni plik HTML**

- Przykład: `https://twoja-domena.pl/napstack/privacy.html`  
- Na serwerze leży plik `privacy_pl.html` (lub nazwa zgodna ze ścieżką).

**Wariant B — katalog z `index.html`**

- Przykład: `https://twoja-domena.pl/napstack/privacy/`

- W katalogu `privacy/` musi być **`index.html`** (możesz skopiować treść `privacy_pl.html` do `index.html`).

**Zasady**

- Ten sam pełny URL w **§3** (Play) i **§4** (Flutter), bez rozjazdu: ścieżki, końcowego slasha, `http` vs `https`.
- Szablony adresów są też w [`../STORE_LISTING.md`](../STORE_LISTING.md) (sekcja *Polityka prywatności — URL*).

---

## 2. Opublikuj plik na hostingu

### Opcja A — własny serwer / CDN

1. Skopiuj `privacy_pl.html` na hosting (FTP, SFTP, panel, **S3 + CloudFront** itd.).
2. Upewnij się, że odpowiedź ma sensowny typ: `Content-Type: text/html; charset=utf-8`.
3. Otwórz URL w przeglądarce — widać pełny dokument bez logowania.

### Opcja B — GitHub Pages

1. Repozytorium z włączonym Pages (publiczne lub zgodne z Twoją konfiguracją).
2. Umieść plik w gałęzi / folderze publikowanym przez Pages (np. `/docs`, root repo, albo `gh-pages`).
3. Ustal **finalny HTTPS URL** (np. `https://<user>.github.io/<repo>/ścieżka/privacy_pl.html` lub `…/privacy/` z `index.html`).

### Opcja C — Firebase Hosting

1. `firebase init hosting`, katalog z `privacy_pl.html` (lub `napstack/privacy/index.html`).
2. `firebase deploy` — zapisz publiczny URL (własna domena lub `*.web.app`).

### Opcja D — Cloudflare Pages / Netlify

1. Nowy projekt „static site”, root z plikiem lub podkatalogiem (np. `public/napstack/privacy/` + `index.html`).
2. Deploy z repozytorium lub wrzutki ZIP; skopiuj **produkcyjny HTTPS URL**.

---

## 3. Google Play Console — pole „Polityka prywatności”

1. Wejdź na [Google Play Console](https://play.google.com/console).
2. Wybierz aplikację **NapStack**.
3. W menu znajdź sekcję dotyczącą treści / zgodności, np. **Polityka aplikacji** (*App content*) — często podpunkt **Polityka prywatności** (*Privacy policy*). W nowszych układach może być też pod **Monitoruj i ulepszaj** → **Szczegóły aplikacji** w kontekście wymagań sklepu. **Szukaj pola tekstowego „Privacy policy URL” / adresu polityki.**
4. Wklej **identyczny** URL co w §1 (np. `https://twoja-domena.pl/napstack/privacy.html`).
5. Zapisz. Link musi zwracać **200** i HTML bez logowania.

**Weryfikacja nagłówków (`curl -sI`)**

```bash
curl -sI "https://twoja-domena.pl/napstack/privacy.html" | head -n 8
```

- Oczekuj **`HTTP/2 200`** (lub `HTTP/1.1 200`).
- Przekierowania **`301` / `302`** akceptowalne tylko jeśli **ostatecznie** wskazują na tę samą publiczną stronę polityki — najlepiej unikać zbędnych hopów.

---

## 4. Build aplikacji — `PRIVACY_POLICY_URL` (opcjonalnie, ten sam URL)

Ten sam adres co w Play warto ustawić w aplikacji, żeby link **(www)** w *Informacjach prawnych* nie prowadził gdzie indziej.

### Bezpośrednio: `--dart-define`

```bash
flutter build appbundle --dart-define=PRIVACY_POLICY_URL=https://twoja-domena.pl/napstack/privacy.html
```

### Przez `.env` → `dart_defines.local.json` (skrypt)

Skrypt: [`tool/sync_dart_defines_from_env.py`](../../../tool/sync_dart_defines_from_env.py).

1. W pliku **`.env`** dodaj (jedna linia, bez cudzysłowów wokół URL, chyba że tak masz w `.env`):

   ```env
   PRIVACY_POLICY_URL=https://twoja-domena.pl/napstack/privacy.html
   ```

2. Z **katalogu głównego repo** NapStack:

   ```bash
   python3 tool/sync_dart_defines_from_env.py /pełna/ścieżka/do/twojego/.env
   ```

   **Ważne:** jako **pierwszy argument** możesz podać **dowolną ścieżkę do `.env`** — domyślna ścieżka w skrypcie może wskazywać inny projekt; dla NapStack zwykle **zawsze** podawaj jawny plik, np. `python3 tool/sync_dart_defines_from_env.py ~/.config/napstack.env`.

3. Wygeneruje się `dart_defines.local.json` w katalogu głównym (plik jest w `.gitignore` — nie commituj sekretów).

4. Build:

   ```bash
   flutter build appbundle --dart-define-from-file=dart_defines.local.json
   ```

---

## 5. Spójność treści po zmianach

Po każdej **istotnej** zmianie polityki zaktualizuj **wszystkie źródła** i ponów publikację HTML:

| Plik | Ścieżka w repo |
|------|----------------|
| Strona pod URL (hosting) | `docs/google_play/hosting/privacy_pl.html` |
| Treść w aplikacji (PL) | `assets/legal/privacy_pl.md` |
| Treść w aplikacji (EN) | `assets/legal/privacy_en.md` |

Następnie:

1. Wgraj zaktualizowany HTML na hosting (**bez zmiany URL**, jeśli możesz).
2. W Play zwykle **nie zmieniasz** URL — tylko podmieniasz treść pod tym samym linkiem.
3. Zbuduj i wydaj nową wersję aplikacji, jeśli zmieniły się pliki `.md` w assetach.

---

## 6. Checklist

- [ ] HTML opublikowany pod **HTTPS** (wariant `privacy.html` lub `privacy/` + `index.html`).
- [ ] `curl -sI "TWÓJ-URL"` (lub przeglądarka) potwierdza dostępność — docelowo **200**.
- [ ] Ten sam URL w **Google Play** → pole polityki prywatności.
- [ ] Ten sam URL w **`PRIVACY_POLICY_URL`** (jeśli używasz linku www w aplikacji).
- [ ] Zsynchronizowane: `hosting/privacy_pl.html` + `assets/legal/privacy_pl.md` + `assets/legal/privacy_en.md`.

---

*Hosting i treść mają charakter szablonu — nie zastępują porady prawnej.*
