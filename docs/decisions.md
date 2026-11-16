# Décisions d'architecture

État au 16 novembre 2026. Chaque décision est réversible : le composant vit derrière un adaptateur.

## Matériel et topologie

- PC unique, pas toujours allumé : Radeon RX 6600 (8 Go de VRAM), 16 Go de RAM.
- Tout tourne sur le PC. Un relais toujours allumé (Raspberry Pi) est prévu plus tard comme profil facultatif : il hébergera la boîte de réception des captures, Radicale et ntfy, sans changement de code.
- Le service de capture est donc un module autonome (réception, empreinte, journal), sans dépendance au pipeline.

## Composants

| Brique | Choix | Écartés et raison |
| --- | --- | --- |
| Base | PostgreSQL 18 + pgvector, plein texte intégré | — |
| Stockage objet | Garage (API S3) | MinIO : édition communautaire archivée |
| Runtime LLM | `llama-server` (llama.cpp), backend Vulkan | Ollama : Vulkan expérimental ; RX 6600 hors liste ROCm |
| LLM + vision | Gemma 4 E4B (NORMAL), Gemma 4 12B en déchargement partiel (DEEP, différé) | Modèles > 8 Go |
| Embeddings / reranker | BGE-M3 (1024 dim.) / bge-reranker-v2-m3, sur CPU | Modèles sous licence non commerciale |
| OCR | PP-OCRv6 (photos, CPU), PaddleOCR-VL-1.6 (documents), Tesseract en secours | Chandra, Surya : licence non libre |
| NLP classique | GLiNER multi v2.1, spaCy, règles, parseur de dates | LLM seul pour les dates : interdit |
| Canvas | React Flow (`@xyflow/react`) | tldraw : licence propriétaire ; Excalidraw : pas un graphe de données |
| Calendrier | Radicale (CalDAV) + DAVx⁵ sur Android | Nextcloud : trop lourd pour le seul calendrier |
| Capture | PWA Darlen (photo, note, cible de partage, file hors ligne) | Telegram : service propriétaire, messages gardés 24 h |
| Notifications | ntfy auto-hébergé, boutons d'action | — |
| Bibliographie | Zotero, API locale `localhost:23119` | — |
| Automatisation | File de tâches dans PostgreSQL | n8n : non open source |
| File de tâches | `SELECT … FOR UPDATE SKIP LOCKED` | Redis |

## Règles non négociables

1. Le canvas n'est jamais la base de données : positions dans `canvas_nodes`, contenu dans `entities`.
2. Le LLM ne produit jamais une date absolue ; un résolveur déterministe convertit l'expression repérée.
3. Toute sortie de LLM est validée par un schéma Pydantic avant d'être stockée.
4. Toute écriture externe (calendrier, Zotero) passe par une ligne `proposals` acceptée.
5. Chaque entité et chaque relation a une provenance ; une relation extraite automatiquement est `inferred` ou `uncertain` tant qu'elle n'est pas confirmée.
6. Les originaux sont immuables et adressés par leur empreinte SHA-256.
7. L'agent n'accède jamais à SQL : uniquement à des outils à schéma, permission et journal.

## À vérifier avant intégration

Les points donnés de mémoire ou tirés de comparatifs sont listés dans [LICENSES.md](../LICENSES.md) avec leur statut de vérification.
