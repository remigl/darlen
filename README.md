# Darlen

Système personnel de connaissance, d'apprentissage et d'organisation : un « second cerveau » spatial, local-first, auto-hébergé, construit en assemblant des logiciels libres existants.

Darlen n'est que la couche d'orchestration : capture, pipeline d'extraction, modèle entités/relations avec provenance et confiance, propositions soumises à validation, canvas. Le calendrier (CalDAV), la bibliographie (Zotero), le stockage objet (S3) et les modèles (API compatible OpenAI) sont des services externes derrière des adaptateurs remplaçables.

## État

Phase 0 — socle. Voir [docs/decisions.md](docs/decisions.md) pour les choix d'architecture et [docs/roadmap.md](docs/roadmap.md) pour les phases.

## Organisation du dépôt

| Dossier | Contenu |
| --- | --- |
| `backend/` | API FastAPI, worker, adaptateurs, migrations SQL |
| `web/` | Canvas (React + React Flow) et PWA de capture — à partir de la phase 1 |
| `deploy/` | `compose.yaml`, configuration de Garage |
| `eval/` | Jeu de test personnel et scripts de mesure |
| `docs/` | Décisions, feuille de route |

## Démarrer le socle

Prérequis : Podman (ou Docker) avec `compose`.

```sh
cp .env.example .env          # puis remplacer chaque valeur « change-me »
cd deploy
podman compose --env-file ../.env --profile core up -d
curl http://127.0.0.1:8000/health
```

L'initialisation de Garage (une seule fois) est décrite dans [deploy/README.md](deploy/README.md).

## Tests

```sh
cd backend
pip install -e ".[dev]"
pytest
```

## Principes

- PostgreSQL est la source de vérité ; le canvas est une vue.
- Le LLM propose, le système vérifie, la base stocke, le calendrier exécute.
- Toute action externe passe par une proposition acceptée par l'utilisateur.
- Chaque composant externe est remplaçable ; les licences sont suivies dans [LICENSES.md](LICENSES.md).
