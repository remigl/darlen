import hashlib

import pytest

from darlen.storage import derived_key, original_key, sha256_hex


def test_sha256_matches_hashlib_for_bytes_and_chunks():
    data = b"Conference de neurosciences - 25 novembre - 18h30"
    expected = hashlib.sha256(data).hexdigest()
    assert sha256_hex(data) == expected
    assert sha256_hex([data[:10], data[10:]]) == expected


def test_original_key_is_content_addressed():
    digest = sha256_hex(b"affiche")
    assert original_key(digest) == f"sha256/{digest[:2]}/{digest}"


@pytest.mark.parametrize("bad", ["", "abc", "A" * 64, "g" * 64, "../" + "a" * 61])
def test_original_key_rejects_anything_but_a_sha256(bad):
    with pytest.raises(ValueError):
        original_key(bad)


def test_derived_key_layout():
    assert derived_key("0198-abc", "ocr.txt") == "derived/0198-abc/ocr.txt"


@pytest.mark.parametrize("name", ["../secret", "a/b", "", "nom avec espace"])
def test_derived_key_rejects_path_tricks(name):
    with pytest.raises(ValueError):
        derived_key("asset", name)
