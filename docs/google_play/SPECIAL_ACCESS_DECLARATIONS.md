# Play Console — uzasadnienie USE_FULL_SCREEN_INTENT i USE_EXACT_ALARM (NapStack)

NapStack to aplikacja **timera drzemki / alarmu wybudzenia**. Bez dokładnych alarmów i pełnoekranowego intentu użytkownik **nie zostałby wybudzony na czas** po zakończeniu drzemki, co jest rdzeniem produktu.

## USE_EXACT_ALARM / SCHEDULE_EXACT_ALARM

- Alarm musi odpalić się **o konkretnym czasie** (koniec drzemki), także w **Doze** i przy oszczędzaniu baterii.
- To nie jest budzik ogólnego przeznaczenia „dla rozrywki”, lecz **funkcja czasowa** powiązana z zaplanowaną drzemką zadeklarowaną przez użytkownika.

**Formułacja robocza do deklaracji w Play Console:**  
*„Exact alarms are required so the app can wake the user at the scheduled end of a user-started nap. Without exact scheduling, Doze and battery optimizations would delay or drop the alarm.”*

## USE_FULL_SCREEN_INTENT

- Na Androidzie 14+ pełny ekran alarmu wymaga jawnego uprawnienia; inaczej użytkownik może **przeoczyć koniec drzemki** (tylko ciche powiadomienie).
- Pełnoekranowe wejście jest spójne z kategorią **alarm** i oczekiwaniem użytkownika po ustawieniu czasu wybudzenia.

**Formułacja robocza:**  
*„Full-screen intent is used only for nap end alarms so the user is reliably alerted when a scheduled nap finishes, consistent with alarm-style notifications.”*

## Zgodność z polityką Google

- Uprawnienia są używane **wyłącznie** w kontekście zaplanowanego wybudzenia (kanał powiadomień typu alarm).
- Aplikacja nie udaje alarmu medycznego; opis w sklepie i regulaminie precyzują charakter narzędzia.

*Szablon informacyjny — dostosuj brzmienie do faktycznego opisu w konsoli i wersji aplikacji.*
