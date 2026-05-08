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

## Required project volumes

| Volume | Purpose | Status | Delete? |
|--------|---------|--------|---------|
| `frappe_docker_sites` | Frappe sites, site configs, assets, files | Used by running stack | **No** |
| `frappe_docker_apps` | App directories for frontend asset serving | Used by running stack | **No** |
| `frappe_docker_db-data` | MariaDB database data | Used by running stack | **No** |
| `frappe_docker_redis-queue-data` | Redis queue persistence | Used by running stack | **No** |

## Current volume counts

As of **2026-05-07**:

- **All volumes:** 68
- **Used volumes:** 10 (4 named, 6 anonymous)
- **Unused volumes:** 58
- **Likely anonymous volumes:** 64
- **Unused anonymous candidates:** 58

## Used volumes by running containers

The `prism-dev` stack uses 4 named volumes and 6 anonymous volumes.

**Named:**
- `frappe_docker_sites` (26M)
- `frappe_docker_apps` (570M)
- `frappe_docker_db-data` (449M)
- `frappe_docker_redis-queue-data` (96K)

**Anonymous:**
- 6 anonymous volumes attached to containers (likely for logs or tmp).

## Unused anonymous cleanup candidates

There are **58 unused anonymous volumes**. These are likely leftovers from previous container runs (e.g., `prism-dev-frontend-1` from before a restart).

These are candidates only. **They were not deleted.**

Candidate list (first 10 of 58):
1. `00bd143080004732ef6d2068356fd3337dc6f475aa51f0593ceea892684a2b96`
2. `0a195ea994afd3c9be172bddebb13e389eae49915a13ec0c54afd369d4505de1`
3. `0cd17160df601da22f7645f8eef67603b687bbc3f7077852cf7d06947d58415f`
... (and 55 more)

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

No urgent deletion is recommended. Volume cleanup should be scheduled after another successful backup and, ideally, after a restore drill. Future deletion must use explicit volume names and require user approval.
