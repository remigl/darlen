"""Applique les migrations SQL dans l'ordre, une seule fois chacune.

Usage : python -m darlen.migrate
"""

from __future__ import annotations

import sys
from importlib import resources

from darlen.config import load_settings


def list_migrations() -> list[tuple[str, str]]:
    """Renvoie (nom, SQL) pour chaque migration, triées par nom."""
    folder = resources.files("darlen") / "migrations"
    files = sorted(
        (entry for entry in folder.iterdir() if entry.name.endswith(".sql")),
        key=lambda entry: entry.name,
    )
    return [(entry.name, entry.read_text(encoding="utf-8")) for entry in files]


def pending(all_names: list[str], applied: set[str]) -> list[str]:
    """Migrations restant à appliquer, dans l'ordre."""
    return [name for name in all_names if name not in applied]


def run(database_url: str) -> list[str]:
    import psycopg  # importé ici : les tests unitaires n'en ont pas besoin

    migrations = list_migrations()
    done: list[str] = []
    with psycopg.connect(database_url) as conn:
        conn.execute(
            "CREATE TABLE IF NOT EXISTS schema_migrations ("
            "name text PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now())"
        )
        conn.commit()
        applied = {row[0] for row in conn.execute("SELECT name FROM schema_migrations")}
        todo = set(pending([name for name, _ in migrations], applied))
        for name, sql in migrations:
            if name not in todo:
                continue
            with conn.transaction():
                conn.execute(sql)
                conn.execute("INSERT INTO schema_migrations (name) VALUES (%s)", (name,))
            done.append(name)
    return done


def main() -> int:
    settings = load_settings()
    for name in run(settings.database_url):
        print(f"appliquée : {name}")
    print("migrations à jour")
    return 0


if __name__ == "__main__":
    sys.exit(main())
