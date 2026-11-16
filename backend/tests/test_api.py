import pytest

pytest.importorskip("fastapi")
pytest.importorskip("httpx")

from fastapi.testclient import TestClient  # noqa: E402

from darlen import api  # noqa: E402


@pytest.fixture
def client(monkeypatch):
    monkeypatch.setenv("DARLEN_DATABASE_URL", "postgresql://darlen:secret@localhost:5432/darlen")
    return TestClient(api.app)


def test_health_ok_when_database_answers(client, monkeypatch):
    monkeypatch.setattr(api, "database_ok", lambda url: True)
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_health_degraded_when_database_is_down(client, monkeypatch):
    monkeypatch.setattr(api, "database_ok", lambda url: False)
    response = client.get("/health")
    assert response.status_code == 503
    assert response.json()["status"] == "degraded"
