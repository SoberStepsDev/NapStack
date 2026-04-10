#!/usr/bin/env python3
"""Provision NapStack TablesDB resources on Appwrite via REST API.

Reads APPWRITE_API_KEY (required), APPWRITE_API_ENDPOINT, APPWRITE_PROJECT_ID from
the environment or from a .env file (same layout as sync_dart_defines_from_env).
Legacy alias: APPWRITE_APP_ID → treated like APPWRITE_PROJECT_ID.

  python3 tool/provision_appwrite.py [path/to/.env]

Does not print secret values. Requires an API key with scopes that can manage
databases/tables (e.g. full databases access on the key).

If Anonymous login is disabled in the project, enable it in the console:
Auth → Anonymous — that toggle is not covered by this script.
"""

from __future__ import annotations

import json
import os
import ssl
import sys
import urllib.error
import urllib.request
from pathlib import Path


def _ssl_context() -> ssl.SSLContext:
    ctx = ssl.create_default_context()
    try:
        import certifi

        ctx.load_verify_locations(certifi.where())
    except Exception:
        pass
    return ctx

# ——— Matches lib/core/appwrite/appwrite_constants.dart ———
DATABASE_ID = "napstack"
TABLE_SESSIONS = "nap_sessions"
TABLE_STACK = "nap_stack"
TABLE_USER_PREFS = "user_prefs"

TABLE_CREATE_PERM = 'create("users")'

# Domyślny jak w lib/core/appwrite/appwrite_constants.dart (nadpisz APPWRITE_PROJECT_ID).
_DEFAULT_PROJECT_ID = "69d7218d001dd20138f6"


def parse_env_file(path: Path) -> dict[str, str]:
    out: dict[str, str] = {}
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, val = line.partition("=")
        out[key.strip()] = val.strip().strip('"').strip("'")
    return out


def resolve_credentials(env_file: Path | None) -> tuple[str, str, str]:
    file_vars: dict[str, str] = {}
    if env_file and env_file.is_file():
        file_vars = parse_env_file(env_file)

    def g(name: str, *aliases: str) -> str | None:
        for key in (name, *aliases):
            v = os.environ.get(key)
            if v:
                return v
        if name in file_vars and file_vars[name]:
            return file_vars[name]
        for a in aliases:
            if a in file_vars and file_vars[a]:
                return file_vars[a]
        return None

    endpoint = (
        g("APPWRITE_API_ENDPOINT")
        or g("APPWRITE_ENDPOINT")
        or "https://fra.cloud.appwrite.io/v1"
    )
    endpoint = endpoint.rstrip("/")
    if not endpoint.endswith("/v1"):
        endpoint = f"{endpoint}/v1"

    project = g("APPWRITE_PROJECT_ID", "APPWRITE_APP_ID") or _DEFAULT_PROJECT_ID

    api_key = g("APPWRITE_API_KEY")
    if not api_key:
        print(
            "Brak APPWRITE_API_KEY (env lub plik .env).",
            file=sys.stderr,
        )
        sys.exit(1)

    return endpoint, project, api_key


class AppwriteTables:
    def __init__(self, endpoint_v1: str, project_id: str, api_key: str) -> None:
        self._base = endpoint_v1.rstrip("/")
        self._project = project_id
        self._key = api_key
        self._opener = urllib.request.build_opener(
            urllib.request.HTTPSHandler(context=_ssl_context())
        )

    def _req(
        self,
        method: str,
        path: str,
        body: dict | None = None,
    ) -> tuple[int, dict | list | None]:
        url = f"{self._base}{path}"
        data = None
        headers = {
            "X-Appwrite-Project": self._project,
            "X-Appwrite-Key": self._key,
            "X-Appwrite-Response-Format": "1.8.0",
        }
        if body is not None:
            data = json.dumps(body).encode("utf-8")
            headers["Content-Type"] = "application/json"

        req = urllib.request.Request(url, data=data, method=method, headers=headers)
        try:
            with self._opener.open(req, timeout=120) as resp:
                raw = resp.read().decode("utf-8")
                if not raw:
                    return resp.status, None
                return resp.status, json.loads(raw)
        except urllib.error.HTTPError as e:
            raw = e.read().decode("utf-8")
            try:
                payload = json.loads(raw) if raw else None
            except json.JSONDecodeError:
                payload = {"raw": raw}
            return e.code, payload

    def ensure_database(self) -> None:
        code, data = self._req("GET", f"/tablesdb/{DATABASE_ID}")
        if code == 200:
            print(f"Baza „{DATABASE_ID}” już istnieje — pomijam tworzenie.")
            return
        if code != 404:
            print(f"GET /tablesdb/{DATABASE_ID} → {code}: {data}", file=sys.stderr)
            sys.exit(1)

        code, data = self._req(
            "POST",
            "/tablesdb",
            {
                "databaseId": DATABASE_ID,
                "name": "NapStack",
                "enabled": True,
            },
        )
        if code in (200, 201):
            print(f"Utworzono bazę „{DATABASE_ID}”.")
            return
        print(f"POST /tablesdb → {code}: {data}", file=sys.stderr)
        sys.exit(1)

    def ensure_table(self, table_id: str, display_name: str, spec: dict) -> None:
        code, _ = self._req(
            "GET", f"/tablesdb/{DATABASE_ID}/tables/{table_id}"
        )
        if code == 200:
            print(f"Tabela „{table_id}” już istnieje — pomijam.")
            return
        if code != 404:
            print(
                f"GET table {table_id} → {code}",
                file=sys.stderr,
            )
            sys.exit(1)

        body = {
            "tableId": table_id,
            "name": display_name,
            "permissions": [TABLE_CREATE_PERM],
            "rowSecurity": True,
            "enabled": True,
            **spec,
        }
        code, data = self._req(
            "POST",
            f"/tablesdb/{DATABASE_ID}/tables",
            body,
        )
        if code in (200, 201):
            print(f"Utworzono tabelę „{table_id}” (kolumny/indeksy w kolejce).")
            return
        print(f"POST table {table_id} → {code}: {data}", file=sys.stderr)
        sys.exit(1)


def main() -> int:
    default_file = Path.home() / "Documents" / "SoberSteps-env-secrets" / ".env"
    env_path = Path(sys.argv[1]).expanduser() if len(sys.argv) > 1 else default_file
    endpoint, project, api_key = resolve_credentials(env_path if env_path.is_file() else None)

    if not env_path.is_file() and not os.environ.get("APPWRITE_API_KEY"):
        print("Brak pliku .env i brak APPWRITE_API_KEY w środowisku.", file=sys.stderr)
        return 1

    aw = AppwriteTables(endpoint, project, api_key)
    aw.ensure_database()

    aw.ensure_table(
        TABLE_SESSIONS,
        "Nap Sessions",
        {
            "columns": [
                {"key": "user_id", "type": "string", "size": 36, "required": True},
                {"key": "started_at", "type": "string", "size": 36, "required": True},
                {"key": "ended_at", "type": "string", "size": 36, "required": True},
                {"key": "nap_type", "type": "string", "size": 32, "required": True},
                {"key": "completed", "type": "boolean", "required": True},
                {
                    "key": "planned_min",
                    "type": "integer",
                    "required": True,
                    "min": 1,
                    "max": 180,
                },
                {
                    "key": "quality_rating",
                    "type": "integer",
                    "required": False,
                    "min": 1,
                    "max": 5,
                },
            ],
            "indexes": [
                {
                    "key": "idx_sessions_user_started",
                    "type": "key",
                    "attributes": ["user_id", "started_at"],
                    "orders": ["ASC", "DESC"],
                },
            ],
        },
    )

    aw.ensure_table(
        TABLE_STACK,
        "Nap Stack",
        {
            "columns": [
                {"key": "user_id", "type": "string", "size": 36, "required": True},
                {"key": "scheduled_iso", "type": "string", "size": 36, "required": True},
                {"key": "nap_type", "type": "string", "size": 32, "required": True},
                {"key": "done", "type": "boolean", "required": True},
            ],
            "indexes": [
                {
                    "key": "idx_stack_user_done_sched",
                    "type": "key",
                    "attributes": ["user_id", "done", "scheduled_iso"],
                    "orders": ["ASC", "ASC", "ASC"],
                },
            ],
        },
    )

    aw.ensure_table(
        TABLE_USER_PREFS,
        "User prefs",
        {
            "columns": [
                {"key": "user_id", "type": "string", "size": 36, "required": True},
                {"key": "pro_active", "type": "boolean", "required": True},
                {"key": "rc_user_id", "type": "string", "size": 128, "required": True},
                {"key": "onboarded", "type": "boolean", "required": True},
            ],
            "indexes": [],
        },
    )

    print("Gotowe. W konsoli Appwrite włącz Auth → Anonymous, jeśli jeszcze nie.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
