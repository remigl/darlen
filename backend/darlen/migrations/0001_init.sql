-- Schéma initial de Darlen. Requiert PostgreSQL 18 (uuidv7) et pgvector.

CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Conventions documentées : types, formes, couleurs, schémas ------------------

CREATE TABLE entity_types (
    name        text PRIMARY KEY,
    label       text NOT NULL,
    description text NOT NULL DEFAULT '',
    shape       text NOT NULL,
    color       text NOT NULL,
    json_schema jsonb NOT NULL DEFAULT '{}'
);

CREATE TABLE relation_types (
    name        text PRIMARY KEY,
    label       text NOT NULL,
    description text NOT NULL DEFAULT ''
);

INSERT INTO entity_types (name, label, shape, color) VALUES
    ('concept',  'Concept',                'circle',       'blue'),
    ('document', 'Document',               'rectangle',    'gray'),
    ('paper',    'Article scientifique',   'rectangle',    'purple'),
    ('book',     'Livre',                  'rectangle',    'purple'),
    ('note',     'Note',                   'rectangle',    'blue'),
    ('person',   'Personne',               'capsule',      'green'),
    ('place',    'Lieu',                   'capsule',      'green'),
    ('organization', 'Organisation',       'capsule',      'green'),
    ('project',  'Projet',                 'hexagon',      'orange'),
    ('task',     'Tâche',                  'rounded-square', 'red'),
    ('decision', 'Décision',               'diamond',      'red'),
    ('question', 'Question',               'star',         'yellow'),
    ('idea',     'Idée',                   'circle',       'yellow'),
    ('event',    'Événement',              'calendar',     'red'),
    ('source',   'Source',                 'rectangle',    'gray'),
    ('image',    'Image',                  'rectangle',    'gray');

INSERT INTO relation_types (name, label) VALUES
    ('related_to',     'lié à'),
    ('contains',       'contient'),
    ('part_of',        'fait partie de'),
    ('mentions',       'mentionne'),
    ('cites',          'cite'),
    ('written_by',     'écrit par'),
    ('located_at',     'situé à'),
    ('scheduled_at',   'planifié le'),
    ('scheduled_as',   'planifié comme'),
    ('generated_from', 'généré à partir de'),
    ('derived_from',   'dérivé de'),
    ('example_of',     'exemple de'),
    ('supports',       'appuie'),
    ('contradicts',    'contredit'),
    ('causes',         'cause'),
    ('influenced_by',  'influencé par'),
    ('about',          'traite de'),
    ('asks',           'pose'),
    ('answers',        'répond à');

-- Graphe ----------------------------------------------------------------------

CREATE TABLE entities (
    id          uuid PRIMARY KEY DEFAULT uuidv7(),
    type        text NOT NULL REFERENCES entity_types (name),
    title       text NOT NULL,
    content     text,
    metadata    jsonb NOT NULL DEFAULT '{}',
    status      text NOT NULL DEFAULT 'confirmed'
                CHECK (status IN ('confirmed', 'proposed', 'archived')),
    created_by  text NOT NULL CHECK (created_by IN ('user', 'pipeline', 'agent')),
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX entities_type_idx ON entities (type);
CREATE INDEX entities_title_trgm_idx ON entities USING gin (title gin_trgm_ops);

CREATE TABLE entity_aliases (
    entity_id   uuid NOT NULL REFERENCES entities ON DELETE CASCADE,
    alias       text NOT NULL,
    normalized  text NOT NULL,
    PRIMARY KEY (entity_id, normalized)
);
CREATE INDEX entity_aliases_normalized_idx ON entity_aliases (normalized);

CREATE TABLE relations (
    id            uuid PRIMARY KEY DEFAULT uuidv7(),
    source_id     uuid NOT NULL REFERENCES entities ON DELETE CASCADE,
    target_id     uuid NOT NULL REFERENCES entities ON DELETE CASCADE,
    relation_type text NOT NULL REFERENCES relation_types (name),
    status        text NOT NULL CHECK (status IN ('confirmed', 'inferred', 'uncertain')),
    confidence    real CHECK (confidence BETWEEN 0 AND 1),
    metadata      jsonb NOT NULL DEFAULT '{}',
    created_by    text NOT NULL CHECK (created_by IN ('user', 'pipeline', 'agent')),
    created_at    timestamptz NOT NULL DEFAULT now(),
    UNIQUE (source_id, target_id, relation_type)
);
CREATE INDEX relations_target_idx ON relations (target_id);

-- Fichiers et captures --------------------------------------------------------

CREATE TABLE assets (
    id          uuid PRIMARY KEY DEFAULT uuidv7(),
    sha256      text NOT NULL UNIQUE CHECK (sha256 ~ '^[0-9a-f]{64}$'),
    storage_key text NOT NULL,
    mime        text NOT NULL,
    bytes       bigint NOT NULL CHECK (bytes >= 0),
    created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE captures (
    id          uuid PRIMARY KEY DEFAULT uuidv7(),
    source      text NOT NULL,
    source_ref  jsonb NOT NULL DEFAULT '{}',
    asset_id    uuid REFERENCES assets,
    text        text,
    captured_at timestamptz NOT NULL,
    timezone    text NOT NULL,
    status      text NOT NULL DEFAULT 'received'
                CHECK (status IN ('received', 'processing', 'processed', 'failed')),
    created_at  timestamptz NOT NULL DEFAULT now(),
    CHECK (asset_id IS NOT NULL OR text IS NOT NULL)
);

-- Sortie de chaque étape du pipeline, rejouable
CREATE TABLE extractions (
    id            uuid PRIMARY KEY DEFAULT uuidv7(),
    capture_id    uuid NOT NULL REFERENCES captures ON DELETE CASCADE,
    step          text NOT NULL,
    model         text,
    model_version text,
    output        jsonb NOT NULL,
    confidence    real CHECK (confidence BETWEEN 0 AND 1),
    duration_ms   integer,
    created_at    timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX extractions_capture_idx ON extractions (capture_id, step);

-- Recherche -------------------------------------------------------------------

CREATE TABLE chunks (
    id              uuid PRIMARY KEY DEFAULT uuidv7(),
    entity_id       uuid REFERENCES entities ON DELETE CASCADE,
    asset_id        uuid REFERENCES assets,
    ordinal         integer NOT NULL,
    text            text NOT NULL,
    lang            text,
    tsv             tsvector,
    embedding       vector(1024),
    embedding_model text
);
CREATE INDEX chunks_embedding_idx ON chunks USING hnsw (embedding vector_cosine_ops);
CREATE INDEX chunks_tsv_idx ON chunks USING gin (tsv);

-- Liens vers les systèmes externes (Zotero, CalDAV) ---------------------------

CREATE TABLE external_refs (
    id          uuid PRIMARY KEY DEFAULT uuidv7(),
    entity_id   uuid NOT NULL REFERENCES entities ON DELETE CASCADE,
    system      text NOT NULL,
    external_id text NOT NULL,
    etag        text,
    url         text,
    synced_at   timestamptz,
    UNIQUE (system, external_id)
);

-- Provenance : pourquoi une entité ou une relation existe ---------------------

CREATE TABLE provenance (
    id              uuid PRIMARY KEY DEFAULT uuidv7(),
    entity_id       uuid REFERENCES entities ON DELETE CASCADE,
    relation_id     uuid REFERENCES relations ON DELETE CASCADE,
    origin          text NOT NULL CHECK (origin IN ('source', 'ai_interpretation', 'user')),
    capture_id      uuid REFERENCES captures,
    chunk_id        uuid REFERENCES chunks ON DELETE SET NULL,
    external_ref_id uuid REFERENCES external_refs ON DELETE SET NULL,
    quote           text,
    locator         jsonb NOT NULL DEFAULT '{}',
    created_at      timestamptz NOT NULL DEFAULT now(),
    CHECK (num_nonnulls(entity_id, relation_id) = 1)
);
CREATE INDEX provenance_entity_idx ON provenance (entity_id);
CREATE INDEX provenance_relation_idx ON provenance (relation_id);

-- Canvas : une vue, jamais la source ------------------------------------------

CREATE TABLE canvases (
    id         uuid PRIMARY KEY DEFAULT uuidv7(),
    name       text NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE canvas_nodes (
    canvas_id uuid NOT NULL REFERENCES canvases ON DELETE CASCADE,
    entity_id uuid NOT NULL REFERENCES entities ON DELETE CASCADE,
    x         double precision NOT NULL DEFAULT 0,
    y         double precision NOT NULL DEFAULT 0,
    width     real,
    height    real,
    collapsed boolean NOT NULL DEFAULT false,
    PRIMARY KEY (canvas_id, entity_id)
);

-- Actions soumises à validation -----------------------------------------------

CREATE TABLE proposals (
    id         uuid PRIMARY KEY DEFAULT uuidv7(),
    kind       text NOT NULL,
    payload    jsonb NOT NULL,
    confidence real CHECK (confidence BETWEEN 0 AND 1),
    capture_id uuid REFERENCES captures,
    status     text NOT NULL DEFAULT 'pending'
               CHECK (status IN ('pending', 'accepted', 'edited', 'rejected', 'auto_applied')),
    created_at timestamptz NOT NULL DEFAULT now(),
    decided_at timestamptz,
    result     jsonb
);
CREATE INDEX proposals_pending_idx ON proposals (created_at) WHERE status = 'pending';

-- File de tâches (SELECT … FOR UPDATE SKIP LOCKED) ----------------------------

CREATE TABLE jobs (
    id         uuid PRIMARY KEY DEFAULT uuidv7(),
    kind       text NOT NULL,
    payload    jsonb NOT NULL DEFAULT '{}',
    status     text NOT NULL DEFAULT 'queued'
               CHECK (status IN ('queued', 'running', 'done', 'failed')),
    attempts   integer NOT NULL DEFAULT 0,
    run_after  timestamptz NOT NULL DEFAULT now(),
    last_error text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX jobs_queue_idx ON jobs (run_after) WHERE status = 'queued';

-- Journal des appels d'outils de l'agent --------------------------------------

CREATE TABLE tool_calls (
    id          uuid PRIMARY KEY DEFAULT uuidv7(),
    tool        text NOT NULL,
    arguments   jsonb NOT NULL,
    result      jsonb,
    permission  text NOT NULL CHECK (permission IN ('read', 'write_internal', 'write_sensitive')),
    proposal_id uuid REFERENCES proposals,
    created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE settings (
    key        text PRIMARY KEY,
    value      jsonb NOT NULL,
    updated_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO settings (key, value) VALUES
    ('confidence.auto_internal', '0.9'),
    ('confidence.propose',       '0.6');
