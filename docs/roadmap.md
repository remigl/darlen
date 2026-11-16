# Feuille de route

Le MVP couvre les phases 1 à 3 : une photo d'affiche envoyée depuis le téléphone devient une proposition d'événement, acceptée d'un bouton, qui apparaît dans le calendrier.

**Critère de réussite du MVP** : sur 20 photos d'affiches réelles, au moins 17 donnent une date, une heure et un titre corrects sans correction manuelle, et aucune n'aboutit à un événement créé avec une date fausse sans avertissement.

| Phase | Contenu | Livrable vérifiable |
| --- | --- | --- |
| 0 — Socle | Dépôt, `compose.yaml` (profil `core`), migrations, `LICENSES.md`, début du jeu de test | PostgreSQL, Garage et l'API démarrent ; les tests passent |
| 1 — Capture | `POST /captures`, stockage par empreinte, PWA de capture avec file hors ligne | Une photo envoyée est retrouvée en base et dans Garage ; un doublon est détecté |
| 2 — Intelligence | OCR, règles et dates, NER, vision, LLM structuré, validation, confiance | Chaque capture produit un JSON validé et des `extractions` rejouables |
| 3 — Calendrier | Propositions, ntfy avec boutons, Radicale via CalDAV | **MVP** : l'événement accepté apparaît sur le téléphone avec son rappel |
| 4 — Canvas | Lecture seule, puis déplacement, création, liens ; panneau latéral | Les entités issues des captures sont visibles et déplaçables |
| 5 — Graphe et recherche | Liaison d'entités, relations, embeddings, recherche hybride, `/ask` avec citations | Une question retrouve une capture sans mot commun avec elle |
| 6 — Zotero | Lecture de la bibliothèque, liaison article ↔ concept | Un article Zotero apparaît sur le canvas avec ses auteurs |
| 7 — Apprentissage | Questions avec sources, cartes, FSRS, sessions de 20 minutes | Une session quotidienne proposée à partir du graphe |

Plus tard : relais Raspberry Pi (boîte de réception, Radicale, ntfy), audio, e-mail, extension de navigateur.
