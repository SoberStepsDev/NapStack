#!/usr/bin/env bash
# Deploy kodu do istniejącej funkcji Appwrite `pro_gate` (Etap API_SETUP + appwrite CLI).
# Wymaga: .env z APPWRITE_API_KEY, APPWRITE_PROJECT_ID, opcj. APPWRITE_ENDPOINT
#         oraz ID funkcji: pierwszy argument albo zmienna APPWRITE_PRO_GATE_FN_ID
#
# Zmiennych serwerowych (RC_*) NIE wklejaj do repo — ustaw w Console albo
#   appwrite functions create-variable --function-id ... --key ... --value ...
#
# Użycie:  bash script/deploy_pro_gate.sh [FUNCTION_ID]

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ ! -f .env ]]; then
  echo "Brak .env w katalogu głównym (patrz docs/API_SETUP.md)" >&2
  exit 1
fi
set -a
# shellcheck disable=SC1091
. ./.env
set +a

: "${APPWRITE_API_KEY:?Ustaw APPWRITE_API_KEY w .env}"
: "${APPWRITE_PROJECT_ID:?Ustaw APPWRITE_PROJECT_ID w .env}"
END="${APPWRITE_ENDPOINT:-https://fra.cloud.appwrite.io/v1}"
FN_ID="${1:-${APPWRITE_PRO_GATE_FN_ID:-}}"

if [[ -z "$FN_ID" ]]; then
  echo "Podaj ID funkcji: bash script/deploy_pro_gate.sh <FUNCTION_ID> lub APPWRITE_PRO_GATE_FN_ID w .env" >&2
  exit 1
fi

appwrite client -e "$END" -p "$APPWRITE_PROJECT_ID" -k "$APPWRITE_API_KEY" >/dev/null

echo "Pakuje i wysyła deployment (funkcja: ${FN_ID})…"
if ! appwrite functions create-deployment \
  --function-id "$FN_ID" \
  --code "./functions/pro_gate" \
  --entrypoint "src/main.js" \
  --commands "npm install" \
  --activate true; then
  echo >&2
  echo "Jeśli komunikat wspomina o „paused / inactivity” — wznów projekt w Appwrite Console, potem uruchom skrypt ponownie." >&2
  exit 1
fi

echo "OK — deployment pro_gate. Sprawdź zmienne: RC_SECRET_KEY_ANDROID, RC_PROJECT_ID, PRO_ENTITLEMENT_ID (Console lub CLI)."
