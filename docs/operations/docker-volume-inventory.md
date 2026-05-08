# Docker Volume Inventory and Cleanup Tracking

## Purpose

This document tracks Docker volumes on the PrismERP staging VM and identifies cleanup candidates without deleting anything.

## Current rule

Do not prune or remove Docker volumes unless:

1. A fresh backup exists.
2. The volume is confirmed unused.
3. The volume is not one of the required project volumes.
4. The user explicitly approves deletion.
5. The cleanup command targets explicit volume names, not broad prune commands.

## Cleanup Run: 2026-05-08T00:15:03Z

A controlled cleanup of unused anonymous Docker volumes was performed after a successful fresh backup.

Backup used before cleanup:

`/opt/prismerp/backups/manual/20260508T001409Z`

Candidate rule:

Only hash-like anonymous volumes that were unused by both running and stopped containers were deleted.

Deleted volumes:

57 anonymous volumes (hash-like names, ~0 bytes each).

Failed deletions:

None.

Required project volumes retained:

- `frappe_docker_sites`
- `frappe_docker_apps`
- `frappe_docker_db-data`
- `frappe_docker_redis-queue-data`

Post-cleanup result:

- volumes before: 68
- volumes deleted: 57
- volumes after: 11
- containers restarted: no
- images rebuilt: no

Policy reminder:

Future cleanup must still use explicit volume names and must require user approval.

## Required project volumes

| Volume | Purpose | Status | Delete? |
|--------|---------|--------|---------|
| `frappe_docker_sites` | Frappe sites, site configs, assets, files | Used by running stack | **No** |
| `frappe_docker_apps` | App directories for frontend asset serving | Used by running stack | **No** |
| `frappe_docker_db-data` | MariaDB database data | Used by running stack | **No** |
| `frappe_docker_redis-queue-data` | Redis queue persistence | Used by running stack | **No** |

## Current volume counts

As of **2026-05-08 (Post-cleanup)**:

- **All volumes:** 11
- **Used volumes:** 10 (4 named, 6 anonymous)
- **Unused volumes:** 1

## Used volumes by running containers

The `prism-dev` stack uses 4 named volumes and 6 anonymous volumes.

**Named:**
- `frappe_docker_sites` (26M)
- `frappe_docker_apps` (570M)
- `frappe_docker_db-data` (449M)
- `frappe_docker_redis-queue-data` (96K)

**Anonymous:**
- 6 anonymous volumes attached to containers (likely for logs or tmp).

## Cleanup policy

Future cleanup must use explicit volume names only.

**Allowed later after approval:**

```bash
docker volume rm <explicit-volume-name>
```

**Forbidden unless separately approved:**

```bash
docker volume prune
docker system prune
manual deletion under /mnt/prismerp-data/docker/volumes
```

## Verification before future cleanup

Before deleting a candidate volume:

```bash
docker ps -a --filter volume=<volume-name>
docker volume inspect <volume-name>
docker system df -v
```

If any container references the volume, do not delete it.

## Current recommendation

Volume cleanup is largely complete. Only 1 unused anonymous candidate remains.
