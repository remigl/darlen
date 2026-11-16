import pytest
from pydantic import ValidationError

from darlen.config import load_settings

BASE = {"DARLEN_DATABASE_URL": "postgresql://darlen:secret@postgres:5432/darlen"}


def test_reads_prefixed_variables_and_ignores_the_rest():
    settings = load_settings({**BASE, "DARLEN_S3_BUCKET": "captures", "PATH": "/usr/bin"})
    assert settings.s3_bucket == "captures"
    assert settings.timezone == "Europe/Paris"


def test_database_url_is_required():
    with pytest.raises(ValidationError):
        load_settings({})


def test_rejects_non_postgres_url():
    with pytest.raises(ValidationError):
        load_settings({"DARLEN_DATABASE_URL": "sqlite:///darlen.db"})


def test_rejects_unknown_timezone():
    with pytest.raises(ValidationError):
        load_settings({**BASE, "DARLEN_TIMEZONE": "Europe/Bruxelles-sur-Mer"})
