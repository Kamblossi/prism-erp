# PrismERP Dev Backup Runbook

## Purpose

This runbook explains how to manually back up the current PrismERP dev/staging sites.

## Current sites

- dev-erp.prismtechco.com
- tenant1-dev-erp.prismtechco.com

## Script

```bash
/opt/prismerp/src/prism-erp/deploy/scripts/backup-prism-dev-sites.sh
```

## Backup destination

```
/opt/prismerp/backups/manual/<timestamp>/<site>/
```

## Logs

```
/opt/prismerp/backups/logs/
```

## What is included

- database backup
- private files
- public files

## What is not yet included

- Azure Blob Storage offsite sync
- scheduled cron/systemd timer
- restore automation
- backup retention policy

## Manual backup command

```bash
/opt/prismerp/src/prism-erp/deploy/scripts/backup-prism-dev-sites.sh
```

## Verification

```bash
LATEST_RUN="$(find /opt/prismerp/backups/manual -maxdepth 1 -mindepth 1 -type d | sort | tail -1)"
cat "${LATEST_RUN}/MANIFEST.txt"
```

## Security notes

- Do not print `site_config.json`.
- Do not commit backup files.
- Do not store backups inside Git repositories.
- Backup directories are local staging backups only.
- Production must later use encrypted offsite storage, preferably Azure Blob Storage.
