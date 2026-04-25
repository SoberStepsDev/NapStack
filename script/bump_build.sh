#!/usr/bin/env bash
# Zwiększa numer buildu (część po +) w pubspec.yaml i version.txt.
# Użycie: bash script/bump_build.sh   (z katalogu głównego repo)

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBSPEC="$ROOT/pubspec.yaml"
VERFILE="$ROOT/version.txt"

if [[ ! -f "$PUBSPEC" ]]; then
  echo "Brak $PUBSPEC" >&2
  exit 1
fi

line=$(grep -E '^version:' "$PUBSPEC" | head -1)
# Oczekiwany format: version: 1.0.0+1
if [[ ! "$line" =~ ^version:[[:space:]]*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)[[:space:]]*$ ]]; then
  echo "Nieparsowalna linia version: $line" >&2
  exit 1
fi
name="${BASH_REMATCH[1]}"
build="${BASH_REMATCH[2]}"
next=$((build + 1))

if [[ "$(uname)" == "Darwin" ]]; then
  sed -i '' "s/^version: .*/version: ${name}+${next}/" "$PUBSPEC"
else
  sed -i "s/^version: .*/version: ${name}+${next}/" "$PUBSPEC"
fi

{
  echo "${name}+${next}"
  echo "# Lustrzane odbicie pubspec version (name+build). Ten plik: script/bump_build.sh"
} > "$VERFILE"
echo "version → ${name}+${next} (pubspec + version.txt)"
