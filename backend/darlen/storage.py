"""Adressage des fichiers par leur contenu.

Les originaux sont immuables : leur clé d'objet dérive de leur empreinte
SHA-256, ce qui rend la déduplication gratuite. Les dérivés (texte OCR,
vignettes, JSON d'extraction) sont régénérables et rangés à part.
"""

from __future__ import annotations

import hashlib
import re
from collections.abc import Iterable
from typing import Protocol

_SHA256 = re.compile(r"^[0-9a-f]{64}$")
_SAFE_NAME = re.compile(r"^[A-Za-z0-9._-]+$")


def sha256_hex(chunks: bytes | Iterable[bytes]) -> str:
    """Empreinte SHA-256 d'un contenu, fourni d'un bloc ou par morceaux."""
    digest = hashlib.sha256()
    if isinstance(chunks, bytes):
        digest.update(chunks)
    else:
        for chunk in chunks:
            digest.update(chunk)
    return digest.hexdigest()


def original_key(sha256: str) -> str:
    """Clé d'objet d'un original : sha256/<2 premiers caractères>/<empreinte>."""
    if not _SHA256.match(sha256):
        raise ValueError("empreinte SHA-256 attendue (64 caractères hexadécimaux minuscules)")
    return f"sha256/{sha256[:2]}/{sha256}"


def derived_key(asset_id: str, name: str) -> str:
    """Clé d'objet d'un dérivé régénérable : derived/<asset_id>/<nom>."""
    if not _SAFE_NAME.match(asset_id) or not _SAFE_NAME.match(name):
        raise ValueError("identifiant ou nom de dérivé invalide")
    return f"derived/{asset_id}/{name}"


class ObjectStore(Protocol):
    """Interface du stockage objet ; l'implémentation S3 arrive en phase 1."""

    def put(self, key: str, data: bytes, content_type: str) -> None: ...

    def get(self, key: str) -> bytes: ...

    def exists(self, key: str) -> bool: ...
