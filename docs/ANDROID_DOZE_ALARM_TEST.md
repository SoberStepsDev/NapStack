# Test alarmu NapStack w Doze (fizyczne urządzenie)

Automatycznego „symulatora Doze” na emulatorze nie ma; **weryfikacja produkcyjna = telefon + ok. 30 min bezładowania**.

## Przygotowanie

1. Zainstaluj **release** AAB/APK (podpisany release).
2. Włącz **powiadomienia** i **dokładne alarmy** (oraz **pełny ekran** na Androidzie 14+), jeśli system pyta.
3. W NapStack ustaw drzemkę **≥ 30 min** (lub krótszą i poczekaj dłużej w Doze — poniżej).

## Wejście w Doze (uproszczony scenariusz)

1. Odłącz **ładowarkę**.
2. Wyłącz ekran; **nie ruszaj telefonu** przez co najmniej **~30 minut** (typowy czas wejścia w Doze zależy od OEM).
3. Opcjonalnie: *Ustawienia → Deweloper* — jeśli dostępne, wymuszenie stanu Doze (zależne od producenta; nie zawsze jest).

## Oczekiwany wynik

- Po upływie drzemki: **alarm / powiadomienie** odpala się **bez** konieczności odblokowania w tym samym momencie (dopuszczalne małe opóźnienie sekundowe zależnie od OEM).

## Gdy nie działa

- Sprawdź **bateria → nieograniczone / bez ograniczeń** dla NapStack (OEM często agresywnie ubija alarmy).
- Sprawdź **exact alarm** i **POST_NOTIFICATIONS** w ustawieniach aplikacji.

*Ten dokument zastępuje test wykonywany przez CI — musisz go przeprowadzić lokalnie.*
