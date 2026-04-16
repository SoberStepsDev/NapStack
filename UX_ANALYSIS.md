# NapStack — Analiza UX

## Przegląd
Aplikacja mobilna (Flutter) do zarządzania drzemkami z timerami, planowaniem sesji i statystykami. Architektura: Riverpod (state), GoRouter (nawigacja), Supabase backend.

---

## Strengths ✓

### 1. **Minimalistyczny design**
- Głębokie tło (ciemny motyw nocny) redukuje zmęczenie oczu
- Spójne palette barw: lodowy błękit (#60C5FF) + mint/fiolet dla presetów
- Czystà typografia (Syne + DM Sans) — hierarchia jasna

### 2. **Intuicyjna nawigacja główna**
- 4 główne ekrany (Home, Timer, NapStack, Stats) w bottom nav
- Clear CTAs: "Wybierz preset i naciśnij start" (Home Screen)
- Back navigation + modalny bottom sheet do potwierdzeń

### 3. **Zadaniowe user flows**
- Home → Timer: preset card → /timer/:type
- NapStack: planowanie kolejki drzemek z FAB (add)
- Stats: pull-to-refresh, empty states obsługiwane

### 4. **Responsywne stany**
- Loading spinners (CircularProgressIndicator, accent color)
- Error states z retry (Stats Screen)
- Empty states dla każdej sekcji
- Validacja przed przerwaniem (confirmStop dialog)

---

## Pain Points & Improvement Opportunities

### 1. **Fragmentacja nawigacji i modal flow'u** ⚠️
**Problem:**  
- HomeScreen redirects do `/paywall` dla locked presetów
- TimerScreen otwiera modalny bottom sheet po ukończeniu drzemki  
- Mieszane: push (go_router) + pop (Navigator.pop)

**Efekt:**  
- Użytkownik może się zagubić w stack'u nawigacji
- Trudno przewidzieć, czy "back" wyrzuci go z timera czy na home

**Rekomendacja:**  
Unifikacja: go_router dla głównych flow'ów, modalne tylko dla lokalnych decyzji (stop confirmation). Usuń Navigator.pop z _DoneSheet.

---

### 2. **Słaba widoczność Pro status & upgrade path** ⚠️
**Problem:**  
- Pro badge (header) zmienia się tylko w header, mały element  
- Paywall screen nie widoczny z home (trzeba kliknąć locked card)
- Slot counter na NapStackScreen (_SlotCounter) — 3/3 free, ale nie jasne co ponad

**Efekt:**  
- Free users mogą nie wiedzieć, ile slotów im zostało  
- Upgrade moment jest przypadkowy (locked preset)

**Rekomendacja:**  
- Promo banner na Home lub Stats jeśli free (3-5 sesji to limit?)  
- Explain trial conversion moments (e.g. "2/3 slots — upgrade for unlimited")

---

### 3. **RingTimerWidget — brak feedback'u przed startem** ⚠️
**Problem:**  
- Timer widget (260px ring) wyświetla się zanim timer jest uruchomiony  
- _EmptyWakeCard pokazuje "Naciśnij START" — OK, ale UI nie zmienia się dynamicznie  
- Gradient ring może być ciemny (kAccentDim) — słaba czytelność

**Efekt:**  
- User może myśleć, że timer już działa (ring animuje?)  
- Brak wizualnego potwierdzenia, że START zadziałał

**Rekomendacja:**  
- Pulse/glow effect na ring gdy running (kAccentGlow) vs static gdy idle  
- Toast: "Drzemka trwa! Wstaniesz o 14:30" po kliknięciu START

---

### 4. **Stats screen — data story słaba** ⚠️
**Problem:**  
- StatsScreen otwiera CustomScrollView z RefreshIndicator  
- Kody są zaciemnione (_StatsContent, _StatsHeader czytane limit 80 linii)  
- Nie widać, czy chart'y, czy listy, czy metryki

**Efekt:**  
- Stats mogą być zbyt surowe (raw numbers) bez kontekstu  
- Brak comparison (wczoraj vs. dziś, tydzień vs. miesiąc)

**Rekomendacja:**  
- Weekly sparkline + "Średnio 3.2 sesji/dzień w tym tygodniu"  
- YTD badge ("👑 25 sesji w tym roku!")

---

### 5. **NapStack screen — planowanie UX fragmented** ⚠️
**Problem:**  
- FAB do dodawania (standard), ale flow po kliknięciu nie pokazany  
- Stack slots limited (3 free) — ale user nie widzi progressu (save state?)  
- StackItemTile ma swipe-to-delete (type?)

**Efekt:**  
- User nie wie czy schedule zaoszczędzony (drag reorder?)  
- Slot limit nie objaśniony visually

**Rekomendacja:**  
- Inline card: "2/3 slots used. Upgrade for unlimited."  
- Confirm before delete (swipe + dialog, nie instant)

---

### 6. **Paywall screen — conversion funnel unknown** ⚠️
**Problem:**  
- Paywall screen (544 LOC — biggest!) ale structure unknown z limitów read  
- RevenueCat integration (z pubspec) — ale purchase flow nie widoczny

**Efekt:**  
- Nie wiadomo czy paywall ma:  
  - Clear pricing  
  - Social proof (reviews)  
  - Trial CTA vs. paid-only  
  - Restore purchases

**Rekomendacja:**  
- Explicit trial → paid flow (7 days free, then $2.99/mo)  
- "See what Pro users love" (bullet points: unlimited slots, no ads, custom presets)

---

### 7. **Onboarding journey — unknown** ⚠️
**Problem:**  
- Nie widzę onboarding screen (tutorial, permissions prompt)  
- main.dart/routing nie przeczytany  
- First-time user experience unknown

**Efekt:**  
- User może nie zrozumieć co to "Nap Stack" vs. timer  
- Permission prompts (notifications?) mogą być zaskoczeniem

**Rekomendacja:**  
- 3-slide carousel: Timer intro → NapStack (scheduling) → Stats (progress)  
- Notification permission prompt before first timer start

---

### 8. **Accessibility — contrast & touch targets** ⚠️
**Problem:**  
- kTextMuted (#445570) na kBgBase (#0D1120) = low contrast?  
- IconButtons (40x40 min size) — OK, ale small icons?  
- No haptic feedback mentioned

**Efekt:**  
- Users with low vision may struggle  
- No tactile confirmation of interactions

**Rekomendacja:**  
- WCAG AA check (contrast ratio ≥4.5:1 for text)  
- HapticFeedback.mediumImpact() on button taps

---

## Specyficzne fragmenty kodu

### HomeScreen
```dart
// Pro badge jest mały, header-only
if (isPro)
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    child: Row(children: [Icon(...), Text('Pro')])
  )
```
**Fix:** Przenieść do persystentnego bannera lub use dynamic CTA in CTA card.

### TimerScreen — Navigator.pop fragmentation
```dart
void _showDoneSheet(...) {
  showModalBottomSheet(
    builder: (_) => _DoneSheet(
      onClose: () {
        Navigator.pop(context);  // ← closses modal
        context.pop();           // ← goes back in go_router stack
      }
    )
  );
}
```
**Fix:** Unified route: go_router path `/timer/:type/done` instead of bottom sheet.

### PresetCard — no loading state
```dart
PresetCard(
  preset: preset,
  isLocked: locked,
  onTap: () => locked ? context.push('/paywall') : context.push('/timer/...')
)
```
**Fix:** Add loading state if timer init is async (Appwrite fetch?).

---

## Checklist — Next Steps

- [ ] Audit Paywall screen details (pricing, trial messaging)
- [ ] Test onboarding flow (new user)
- [ ] Run WCAG AA accessibility scan
- [ ] Add haptic feedback + toast confirmations
- [ ] Unify navigation (go_router modal vs. bottom sheet)
- [ ] Add Pro upgrade promo to Home / Stats
- [ ] Clarify NapStack slot limit visually
- [ ] Add weekly stats sparkline (not just raw numbers)
- [ ] Create restart/restore purchase flow

---

## Podsumowanie

**NapStack ma solidny core UX:**  
- Minimalistyczne, nocne, skupione na task'u  
- Jasne state management (Riverpod)  
- Prawie wszystkie edge case'y obsługiwane (empty, error, loading)

**Ale brakuje:**  
- Cohesive upgrade funnel (Pro path zamazany)  
- Data storytelling w Stats (raw numbers → insights)  
- Onboarding + deep linking  
- Haptic/toast confirmations

**Priority:** Unify nav stack + clarify Pro upgrade + add stats insights.
