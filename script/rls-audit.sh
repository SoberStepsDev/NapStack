#!/usr/bin/env bash
# RLS / row security — checklist wdrożenia w Appwrite Console (NapStack).
# Appwrite nie ma SQL RLS; izolacja = Permission na wierszach (create z kodu).
# Uruchom ręcznie przed release:  bash script/rls-audit.sh

set -euo pipefail

echo "=== NapStack — audyt spójności uprawnień (docelowy stan) ==="
echo ""
echo "Tabele: nap_stack, nap_sessions, user_prefs (database: napstack)"
echo ""
echo "Dla KAŻDEJ tabeli sprawdź w Console:"
echo "  1) Odczyt/zapis tylko dla właściciela wiersza:"
echo "       user_id / rowId odpowiada auth.uid() sesji."
echo "  2) Nowe wiersze tworzone z:"
echo "       Permission.read/update/delete(Role.user('<userId>'))"
echo "     (user_prefs: read+update bez delete — patrz PermissionsHelperSafe.)"
echo "  3) Brak Role.any() na create/update/delete dla danych użytkownika."
echo ""
echo "Konkretne encje w kodzie:"
echo "  - nap_stack:     PermissionsHelperSafe.ownerFullAccessSafe(userId)"
echo "  - nap_sessions:  (jak w sessions_service — owner pełny dostęp)"
echo "  - user_prefs:    ownerReadUpdateSafe(userId)"
echo ""
echo "Gotowe. (Brak automatycznego wywołania API — weryfikacja w UI Appwrite.)"
