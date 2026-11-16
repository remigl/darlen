# Jeu de test personnel

Les modèles sont choisis sur ces données, pas sur des classements génériques. Chaque erreur rencontrée à l'usage devient un cas de test.

## Organisation

```
eval/
├── cases/            annotations versionnées (un fichier JSON par cas)
└── data/
    ├── public/       fichiers partageables
    └── private/      tes photos et documents — ignorés par git
```

Les fichiers personnels restent dans `data/private/` ; seules les annotations sont versionnées, et elles désignent le fichier par son empreinte SHA-256.

## Format d'un cas

```json
{
  "id": "affiche-001",
  "kind": "photo",
  "sha256": "<empreinte du fichier>",
  "lang": "fr",
  "reference_date": "2026-11-16",
  "tags": ["affiche", "date-sans-annee"],
  "expected": {
    "type": "event",
    "title": "Conférence de neurosciences",
    "date": "2026-11-25",
    "time": "18:30",
    "location": "ENS Paris",
    "ocr_text": "Conférence de neurosciences\n25 novembre\n18h30\nENS Paris"
  }
}
```

`reference_date` est la date de capture : elle sert à résoudre les expressions relatives et les dates sans année.

## Premier lot à constituer

30 photos (dont 20 affiches pour le critère du MVP), 30 notes, 20 événements. Varier : français et anglais, dates relatives (« lundi prochain »), formats français (« 12/03 », « 18h30 »), noms accentués, photos de travers ou mal éclairées.

## Mesures prévues

Taux d'erreur OCR par caractère, exactitude stricte des dates et heures, F1 des entités, taux de JSON valide au premier essai, rappel@10 de la recherche, calibration de la confiance, latence et mémoire. Les scripts arrivent avec la phase 2.
