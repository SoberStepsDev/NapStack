# NapStack — Schemat Appwrite

**Baza danych ID:** `napstack`

W **Appwrite Cloud** dane są w **TablesDB** (tabele o ID jak poniżej). Izolacja użytkowników = **row security** + uprawnienia per wiersz ustawiane z aplikacji (odpowiednik „document security” z raportów wdrożenia). Indeksy wdrożone skryptem `tool/provision_appwrite.py`: `idx_sessions_user_started`, `idx_stack_user_done_sched`.

---

## Tabela: `nap_sessions`

Przechowuje historię sesji drzemek — każda sesja to jeden rekord.

| Kolumna | Typ Appwrite | Wymagane | Opis |
|---------|-------------|----------|------|
| `user_id` | `varchar(36)` | tak | `auth.uid()` — do RLS |
| `started_at` | `varchar(30)` | tak | ISO 8601 UTC — np. `2026-04-09T14:30:00.000Z` |
| `ended_at` | `varchar(30)` | tak | ISO 8601 UTC |
| `nap_type` | `varchar(20)` | tak | `powerNap` / `coffeeNap` / `fullCycle` |
| `completed` | `bool` | tak | `false` = przerwana przez użytkownika |
| `planned_min` | `int` | tak | Planowany czas snu (minuty, bez fazy zasypiania) |
| `quality_rating` | `int` | nie | `null` w v1; zarezerwowane na MirrorMind Q3-2026 |

**Indeksy:**
- `idx_sessions_user_started` — `(user_id ASC, started_at DESC)` — pod `Query.equal('user_id')` + `Query.orderDesc('started_at')`

**Uprawnienia kolekcji:** Brak domyślnych — każdy dokument ma własne uprawnienia ustawione przy tworzeniu (`Permission.read/update/delete(Role.user(userId))`).

---

## Tabela: `nap_stack`

Zaplanowane drzemki w Nap Stack.

| Kolumna | Typ Appwrite | Wymagane | Opis |
|---------|-------------|----------|------|
| `user_id` | `varchar(36)` | tak | `auth.uid()` |
| `scheduled_iso` | `varchar(30)` | tak | Pełna data + czas alarmu ISO 8601 UTC |
| `nap_type` | `varchar(20)` | tak | `powerNap` / `coffeeNap` / `fullCycle` |
| `done` | `bool` | tak | Czy alarm minął / zrealizowany |

**Indeksy:**
- `idx_stack_user_done_sched` — `(user_id, done, scheduled_iso)` — pod filtrowanie po użytkowniku i `done` oraz sort `scheduled_iso`

**Ograniczenie Free:** Max 3 rekordy z `done == false` per użytkownik.
Sprawdzane po stronie klienta w `NapStackService.addItem()`.

---

## Tabela: `user_prefs`

Preferencje użytkownika — jeden rekord per konto.
`rowId == userId` (deterministic) — upraszcza getOrCreate.

| Kolumna | Typ Appwrite | Wymagane | Opis |
|---------|-------------|----------|------|
| `user_id` | `varchar(36)` | tak | `auth.uid()` |
| `pro_active` | `bool` | tak | Cache statusu Pro (sync z RC) |
| `rc_user_id` | `varchar(100)` | tak | RevenueCat user ID do cross-device restore |
| `onboarded` | `bool` | tak | Czy ukończył onboarding |

**Uprawnienia:** `Permission.read/update(Role.user(userId))` — bez delete (rekord trwały).

---

## Polityki RLS (Row Level Security)

Appwrite **nie ma** SQL-level RLS jak Supabase — izolacja użytkowników
realizowana jest przez uprawnienia na poziomie dokumentu.

Zasada dla NapStack:
```
Każdy rekord tworzony z:
  Permission.read(Role.user(userId))
  Permission.update(Role.user(userId))
  Permission.delete(Role.user(userId))   // tylko dla sessions i stack
```

Dzięki temu:
- Użytkownik A nie może odczytać ani zmodyfikować rekordów użytkownika B.
- Brak uprawnień dla `Role.any()` — żaden rekord nie jest publiczny.
- Konto anonimowe ma takie same prawa jak konto email — dopóki userId jest stały.

---

## Inicjalizacja bazy (Appwrite Console lub CLI)

```bash
# Tworzenie bazy
appwrite databases create \
  --database-id napstack \
  --name "NapStack"

# Tworzenie tabeli nap_sessions
appwrite databases createCollection \
  --database-id napstack \
  --collection-id nap_sessions \
  --name "Nap Sessions"

# Atrybuty nap_sessions
appwrite databases createStringAttribute \
  --database-id napstack --collection-id nap_sessions \
  --key user_id --size 36 --required true

appwrite databases createStringAttribute \
  --database-id napstack --collection-id nap_sessions \
  --key started_at --size 30 --required true

appwrite databases createStringAttribute \
  --database-id napstack --collection-id nap_sessions \
  --key ended_at --size 30 --required true

appwrite databases createStringAttribute \
  --database-id napstack --collection-id nap_sessions \
  --key nap_type --size 20 --required true

appwrite databases createBooleanAttribute \
  --database-id napstack --collection-id nap_sessions \
  --key completed --required true

appwrite databases createIntegerAttribute \
  --database-id napstack --collection-id nap_sessions \
  --key planned_min --required true --min 1 --max 180

appwrite databases createIntegerAttribute \
  --database-id napstack --collection-id nap_sessions \
  --key quality_rating --required false --min 1 --max 5

# Indeksy nap_sessions
appwrite databases createIndex \
  --database-id napstack --collection-id nap_sessions \
  --key idx_user_id --type key --attributes user_id

appwrite databases createIndex \
  --database-id napstack --collection-id nap_sessions \
  --key idx_started_at --type key --attributes started_at
```

> Analogicznie dla `nap_stack` i `user_prefs` — patrz modele w kodzie.
