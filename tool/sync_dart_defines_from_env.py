#!/usr/bin/env python3
"""Wczytuje wybrane klucze z pliku .env i zapisuje JSON dla --dart-define-from-file.

Domyślny plik: `.env` w katalogu głównym NapStack (lub nadpisz pierwszym argumentem).
Uruchom z katalogu głównym projektu:

  python3 tool/sync_dart_defines_from_env.py

Nie loguj wyjścia ani zawartości wygenerowego pliku.
Opcjonalnie: PRIVACY_POLICY_URL, TERMS_OF_SERVICE_URL, CONSUMER_INFO_URL (HTTPS).
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path


def load_env_key(path: Path, name: str) -> str | None:
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        key, _, val = line.partition("=")
        if key.strip() == name:
            return val.strip().strip('"').strip("'")
    return None


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    default_env = root / ".env"
    env_path = Path(sys.argv[1]).expanduser() if len(sys.argv) > 1 else default_env
    if not env_path.is_file():
        print("Brak pliku .env:", env_path, file=sys.stderr)
        return 1

    defines: dict[str, str] = {}
    rc_direct = load_env_key(env_path, "RC_PUBLIC_KEY_ANDROID")
    rc_legacy = load_env_key(env_path, "REVENUECAT_SDK_API_KEY")
    if rc_direct:
        defines["RC_PUBLIC_KEY_ANDROID"] = rc_direct
    elif rc_legacy:
        defines["RC_PUBLIC_KEY_ANDROID"] = rc_legacy

    endpoint = load_env_key(env_path, "APPWRITE_API_ENDPOINT")
    if endpoint:
        defines["APPWRITE_ENDPOINT"] = endpoint

    project = load_env_key(env_path, "APPWRITE_PROJECT_ID") or load_env_key(
        env_path, "APPWRITE_APP_ID"
    )
    if project:
        defines["APPWRITE_PROJECT_ID"] = project

    privacy = load_env_key(env_path, "PRIVACY_POLICY_URL")
    if privacy:
        defines["PRIVACY_POLICY_URL"] = privacy
    terms = load_env_key(env_path, "TERMS_OF_SERVICE_URL")
    if terms:
        defines["TERMS_OF_SERVICE_URL"] = terms
    consumer = load_env_key(env_path, "CONSUMER_INFO_URL")
    if consumer:
        defines["CONSUMER_INFO_URL"] = consumer

    if not defines:
        print(
            "Brak mapowalnych kluczy: RC_PUBLIC_KEY_ANDROID (lub REVENUECAT_SDK_API_KEY), "
            "APPWRITE_*, PRIVACY_POLICY_URL, TERMS_OF_SERVICE_URL, CONSUMER_INFO_URL.",
            file=sys.stderr,
        )
        return 1

    out = root / "dart_defines.local.json"
    out.write_text(
        json.dumps(defines, ensure_ascii=False, separators=(",", ":")) + "\n",
        encoding="utf-8",
    )
    print(f"Zapisano {out.name} — dołącz do polecenia flutter, np.:")
    print(
        "  flutter run --dart-define-from-file=dart_defines.local.json",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
