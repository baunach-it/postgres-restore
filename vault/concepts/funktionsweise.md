---
type: concept
repo: postgres-restore
status: active
tags: [psql, gzip, s3, restore]
---

# Funktionsweise — postgres-restore

Restore eines komprimierten SQL-Dumps in eine Ziel-Datenbank. Dump kommt entweder aus
einem lokalen Volume oder aus S3.

## Ablauf

1. **Validierung**: `POSTGRES_RESTORE_DUMPFILE` muss gesetzt sein, sonst Abbruch.
2. **Optional S3-Download**: wenn S3-Env-Vars gesetzt sind, wird AWS CLI zur Laufzeit
   installiert und die Datei nach `/restore/` heruntergeladen.
3. **Pruefung**: ob die Dump-Datei lokal vorhanden ist.
4. **`gzip -d`** dekomprimiert die `.sql.gz`-Datei.
5. **`dos2unix`** normalisiert Zeilenumbrueche.
6. **`psql -f`** spielt den Dump in die Ziel-DB ein.

## Lazy-Install der AWS CLI

Wie bei `postgres-backup`: AWS CLI wird nur installiert, wenn S3-Vars gesetzt sind.

## Ziel-DB (Pflicht)

`POSTGRES_RESTORE_TARGET_DB_HOST`, `_DB_PORT`, `_USER`, `_PASSWORD`, `_DB_NAME`,
`_DUMPFILE` (Dateiname relativ zum Volume bzw. S3-Pfad).

## S3-Download (optional)

`POSTGRES_RESTORE_AWS_*`, `_S3_ENDPOINT`, `_AWS_CLI_VERSION`

## Volume

`/restore` — lokaler Pfad fuer Dump-Dateien.

## Bezug

- Workspace-Vault: `stack/env-var-konventionen.md`, `concepts/pg-dump-vs-wal-g.md`
- Schwesterimage: `postgres-backup` (erzeugt die `.sql.gz` Dateien)
- Doku-Output: `docs/src/content/docs/projekte/docker-images/Postgres-Restore/uebersicht.md`
