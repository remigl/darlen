# Licences des composants

Règle : un composant n'entre dans la stack qu'une fois sa licence lue dans son dépôt ou sur sa fiche de modèle. La colonne « Vérifié » indique où en est ce contrôle.

- **source** : lu sur une source officielle ou concordante lors de l'étude du 16 novembre 2026 ;
- **à vérifier** : donné de mémoire ou tiré d'un comparatif, à confirmer dans le fichier `LICENSE` ou la fiche du modèle avant intégration.

## Logiciels

| Composant | Rôle | Licence | Vérifié |
| --- | --- | --- | --- |
| PostgreSQL | Base | Licence PostgreSQL | à vérifier |
| pgvector | Recherche vectorielle | Licence PostgreSQL | à vérifier |
| pg_textsearch | BM25 (option) | Licence PostgreSQL | source |
| Garage | Stockage objet S3 | AGPL-3.0 | source |
| FastAPI, Pydantic, Uvicorn | Backend | MIT / BSD | à vérifier |
| psycopg | Client PostgreSQL | LGPL-3.0 | à vérifier |
| llama.cpp | Runtime LLM | MIT | à vérifier |
| PaddleOCR | OCR | Apache 2.0 | source |
| Tesseract | OCR de secours | Apache 2.0 | à vérifier |
| GLiNER (bibliothèque) | NER | Apache 2.0 | source |
| spaCy | Segmentation | MIT (modèles : au cas par cas) | à vérifier |
| React Flow (`@xyflow/react`) | Canvas | MIT | source |
| Radicale | Serveur CalDAV | GPL-3.0 | à vérifier |
| DAVx⁵ | Synchronisation Android | GPL-3.0 | à vérifier |
| ntfy | Notifications | Apache 2.0 et GPLv2 | source |
| Zotero | Bibliographie | AGPL-3.0 | à vérifier |
| Caddy | Proxy inverse | Apache 2.0 | à vérifier |
| Podman | Conteneurs | Apache 2.0 | à vérifier |
| restic | Sauvegardes | BSD 2 clauses | à vérifier |

## Modèles (poids ouverts)

| Modèle | Rôle | Licence | Vérifié |
| --- | --- | --- | --- |
| Gemma 4 (E2B, E4B, 12B) | LLM + vision | Apache 2.0 | source (fiche officielle) |
| BGE-M3 | Embeddings | MIT | à vérifier (comparatif) |
| bge-reranker-v2-m3 | Reranker | Apache 2.0 | à vérifier (comparatif) |
| PP-OCRv6, PaddleOCR-VL-1.6 | OCR | Apache 2.0 | à vérifier (comparatif) |
| `gliner_multi-v2.1` | NER | Apache 2.0 | source |

## Écartés pour leur licence ou leur statut

| Composant | Raison |
| --- | --- |
| MinIO Community | Dépôt archivé, plus de binaires |
| tldraw SDK | Licence propriétaire, clé requise en production |
| n8n | Sustainable Use License : non open source |
| Telegram (API Bot) | Service propriétaire |
| Chandra OCR 2, Surya 2 | OpenRAIL-M modifiée |
| `jina-embeddings-v3`, `gliner_multi` v0 | Usage non commercial |

## Licence de Darlen

À choisir par l'auteur. AGPL et GPL des services ci-dessus ne contraignent pas ce choix tant qu'ils sont utilisés par le réseau, sans modification.
