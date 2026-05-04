---
type: index
repo: postgres-restore
workspace: baunach-postgres
tenant: baunach
---

# postgres-restore Repo-Vault

Image-spezifische Doku fuer `postgres-restore` (Dump-Wiederherstellung, S3-Download optional).

## Inhalt

- `concepts/funktionsweise.md` — Ablauf: Validation → S3-Download → gunzip → dos2unix → psql
- `decisions/` — Image-spezifische Entscheidungen (TBD)
- `playbooks/` — Image-spezifische Prozeduren (TBD)
- `troubleshooting/` — Fehlerbilder bei Restore / Dump-Validierung

## Cross-Image-Themen → Workspace-Vault

Liegt unter `~/Workspaces/baunach-postgres/vault/`:

- Praefix-Pattern: `concepts/env-var-prefix-pattern.md`
- pg_dump vs. WAL-G: `concepts/pg-dump-vs-wal-g.md`
- Image-Konventionen: `stack/image-konventionen.md`
- Env-Var-Tabellen: `stack/env-var-konventionen.md`
- Project-MOC: `projects/postgres-restore.md`

## Doku-Output

`docs/src/content/docs/projekte/docker-images/Postgres-Restore/`
