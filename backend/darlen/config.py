"""Configuration lue depuis l'environnement (préfixe DARLEN_)."""

from __future__ import annotations

import os
from collections.abc import Mapping
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from pydantic import BaseModel, ConfigDict, field_validator

PREFIX = "DARLEN_"


class Settings(BaseModel):
    model_config = ConfigDict(frozen=True)

    database_url: str
    s3_endpoint: str = "http://garage:3900"
    s3_region: str = "garage"
    s3_bucket: str = "darlen"
    s3_access_key_id: str = ""
    s3_secret_access_key: str = ""
    timezone: str = "Europe/Paris"

    @field_validator("timezone")
    @classmethod
    def _known_timezone(cls, value: str) -> str:
        try:
            ZoneInfo(value)
        except (ZoneInfoNotFoundError, ValueError) as error:
            raise ValueError(f"fuseau horaire inconnu : {value}") from error
        return value

    @field_validator("database_url")
    @classmethod
    def _postgres_url(cls, value: str) -> str:
        if not value.startswith(("postgresql://", "postgres://")):
            raise ValueError("database_url doit être une URL postgresql://")
        return value


def load_settings(env: Mapping[str, str] | None = None) -> Settings:
    """Construit les réglages depuis les variables DARLEN_*."""
    source = os.environ if env is None else env
    values = {
        key[len(PREFIX) :].lower(): value for key, value in source.items() if key.startswith(PREFIX)
    }
    return Settings(**values)
