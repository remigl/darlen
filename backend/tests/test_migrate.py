from darlen.migrate import list_migrations, pending


def test_migrations_are_found_in_order():
    names = [name for name, _ in list_migrations()]
    assert names, "au moins une migration attendue"
    assert names == sorted(names)
    assert names[0] == "0001_init.sql"


def test_initial_schema_declares_the_core_tables():
    sql = dict(list_migrations())["0001_init.sql"]
    for table in (
        "entities",
        "relations",
        "assets",
        "captures",
        "extractions",
        "chunks",
        "provenance",
        "canvas_nodes",
        "proposals",
        "external_refs",
        "jobs",
    ):
        assert f"CREATE TABLE {table} (" in sql


def test_pending_keeps_order_and_skips_applied():
    names = ["0001_init.sql", "0002_x.sql", "0003_y.sql"]
    assert pending(names, {"0001_init.sql"}) == ["0002_x.sql", "0003_y.sql"]
    assert pending(names, set(names)) == []
