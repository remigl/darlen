"""API HTTP de Darlen. Phase 0 : état de santé uniquement."""

from __future__ import annotations

from fastapi import FastAPI, Response, status

from darlen import __version__
from darlen.config import load_settings

app = FastAPI(title="Darlen", version=__version__)


def database_ok(database_url: str) -> bool:
    import psycopg

    try:
        with psycopg.connect(database_url, connect_timeout=3) as conn:
            conn.execute("SELECT 1")
        return True
    except psycopg.Error:
        return False


@app.get("/health")
def health(response: Response) -> dict[str, str]:
    settings = load_settings()
    ok = database_ok(settings.database_url)
    if not ok:
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
    return {"status": "ok" if ok else "degraded", "version": __version__}
