# Déploiement

## Premier démarrage

```sh
cp ../.env.example ../.env    # remplacer les « change-me »
podman compose --env-file ../.env --profile core up -d postgres garage
```

## Initialiser Garage (une seule fois)

Garage démarre sans disposition de stockage ni bucket. Ces commandes sont à exécuter une fois ; elles n'ont pas encore été testées sur la machine cible, et les options peuvent varier selon la version de Garage (`garage --help`).

```sh
alias garage="podman compose --env-file ../.env exec garage /garage"

garage status                              # relever l'identifiant du nœud
garage layout assign -z dc1 -c 20G <identifiant>
garage layout apply --version 1

garage bucket create darlen
garage key create darlen-app               # affiche l'identifiant et le secret de la clé
garage bucket allow --read --write --owner darlen --key darlen-app
```

Reporter l'identifiant et le secret de la clé dans `../.env` (`S3_ACCESS_KEY_ID`, `S3_SECRET_ACCESS_KEY`), puis lancer le reste :

```sh
podman compose --env-file ../.env --profile core up -d
curl http://127.0.0.1:8000/health
```

## Points à valider sur la machine cible

- L'étiquette `pg18` de l'image pgvector et l'étiquette `v2.3.0` de Garage : prendre la dernière version stable disponible.
- PostgreSQL 18 est requis pour `uuidv7()`.
- Rien n'est exposé hors de `127.0.0.1` à ce stade.

## Sauvegarde

À mettre en place avant la phase 1 : `pg_dump` quotidien et volumes `garage-*` vers un dépôt restic chiffré, avec un test de restauration.
