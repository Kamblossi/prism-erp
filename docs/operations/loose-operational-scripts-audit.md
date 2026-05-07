# Loose Operational Scripts Audit

## Purpose

`/opt/prismerp/scripts` contains historical/emergency operational scripts created during early PrismERP Docker/branding recovery work (around May 1, 2026). These scripts were built during the "symlink trap" debugging and branding materialization phase.

They are **not canonical deployment automation** unless explicitly promoted into the repository. They must not be executed without understanding their target components and confirming compatibility with the current Docker stack.

## Current loose scripts

| Script | Apparent Purpose | Components Touched | Important Commands | Risk Level | Current Relevance | Recommendation |
|--------|------------------|--------------------|--------------------|------------|--------------------|----------------|
| `restore_symlinks.sh` | Remove materialized asset copies, restore symlinks | Host filesystem (bench sites/assets), bench setup | `rm -rf`, `bench setup assets --reset --rebuild-q-frontends`, `find`, `cp -r` | **CRITICAL** | **Obsolete** — Nginx now uses physical copies, not symlinks | Archive later; do not run |
| `force_prismerp_identity.py` | Force PrismERP branding into Frappe DB settings | Frappe DB (System Settings, Website Settings, Navbar Settings), Redis cache, site_config (in-memory) | `frappe.db.set_single_value`, `redis flushdb`, `frappe.conf` overrides | **HIGH** | **Obsolete** — replaced by `prism_brand/branding/setup.py` | Archive later; do not run |
| `prism_complete_branding.py` | Comprehensive branding override (translations, modules, workspaces, settings, caches) | Frappe DB (Translation, System Settings, Website Settings, Navbar Settings, Module Def, Workspace), Redis cache | `frappe.db.set_single_value`, `frappe.rename_doc`, `frappe.new_doc`, `redis flushdb`, `frappe.db.commit` | **HIGH** | **Superseded** — replaced by `prism_brand/branding/setup.py` hooks + branding constants | Archive later; do not run |
| `deploy_prism_branding.sh` | Orchestrated deployment: runs branding script, cache clear, asset rebuild, migration, Redis flush, restart | Docker containers, Redis, Frappe DB, assets, site_config | `docker compose exec`, `bench console`, `bench clear-cache`, `bench build`, `bench migrate`, `redis-cli FLUSHALL`, `docker compose restart` | **CRITICAL** | **Superseded** — replaced by Docker image build + `prism_brand` hooks | Archive later; do not run |
| `prismerp-utils.sh` | Interactive utility functions (status, restore, force identity, cache, restart, logs, console) | Docker containers, Redis, Frappe DB, symlinks, bench | `docker exec`, `bench console`, `redis-cli flushall`, `docker-compose down/up`, `find`, `curl` | **HIGH** | **Partially useful** — `prismerp-status` and `prismerp-logs` are handy diagnostics. Others invoke obsolete scripts. | Keep documented; do not source or run casually. Extract useful functions into canonical repo later. |

## Per-script analysis

### `restore_symlinks.sh`

- **Path:** `/opt/prismerp/scripts/restore_symlinks.sh`
- **Size:** 4,482 bytes
- **Permissions:** `-rwxrwxr-x` (755)
- **Executable:** yes
- **Purpose:** Remove materialized (copied) asset directories from `sites/assets/`, back them up, then run `bench setup assets --reset --rebuild-q-frontends` to restore symlinks.
- **What it touches:** Host filesystem at `/opt/prismerp/bench-workspace/frappe-bench/sites/assets/`, bench setup, creates backup directory.
- **Risk analysis:** Runs `rm -rf` on directories in `sites/assets/`. This is dangerous if run on a system where Nginx depends on physical copies (the current setup). Running this would **undo the symlink-trap fix** and break asset serving.
- **Still relevant:** **No.** The corrected architecture intentionally uses physical copies in the Docker volume because the Nginx frontend cannot follow symlinks across Docker volume boundaries. This script reverses the fix.
- **Recommendation:** **Do not run.** Archive under `/opt/prismerp/archive/scripts` for historical reference.

### `force_prismerp_identity.py`

- **Path:** `/opt/prismerp/scripts/force_prismerp_identity.py`
- **Size:** 7,170 bytes
- **Permissions:** `-rw-rw-r--` (664)
- **Executable:** no
- **Purpose:** Force PrismERP branding values into Frappe's System Settings, Website Settings, Navbar Settings, and site_config (in-memory). Flushes Redis cache.
- **What it touches:** Frappe database (Single DocTypes), Redis cache (flushdb on cache and queue databases), in-memory Frappe config.
- **Risk analysis:** Modifies database settings directly. Flushes **all** Redis data (not just PrismERP keys), which could disrupt active sessions or queued jobs. Designed to be piped into `bench console`.
- **Still relevant:** **No.** The corrected `prism_brand/branding/setup.py` now handles this automatically on `after_install` and `after_migrate` hooks. The `_update_site_config` function writes persistently to `site_config.json` instead of relying on in-memory overrides.
- **Recommendation:** **Do not run.** Archive for historical reference.

### `prism_complete_branding.py`

- **Path:** `/opt/prismerp/scripts/prism_complete_branding.py`
- **Size:** 11,960 bytes
- **Permissions:** `-rwxrwxr-x` (755)
- **Executable:** yes
- **Purpose:** Comprehensive one-stop branding script that creates Translation records (ERPNext → PrismERP), renames Workspaces and Modules, updates all settings, flushes Redis, and validates.
- **What it touches:** Frappe DB (Translation, System Settings, Website Settings, Navbar Settings, Module Def, Workspace), Redis cache (flushdb on cache and queue).
- **Risk analysis:** High. Renames Module Def and Workspace documents (irreversible without manual fix). Mod Translation records globally. Flushes all Redis. Multiple DB writes.
- **Still relevant:** **Superseded.** The `prism_brand` app now handles branding via `hooks.py` (`after_install` and `after_migrate`). The `_safe_set_single` and `_set_visible_workspace_labels` functions in `setup.py` do the same thing safely. Running this script could create duplicate Translation records or conflicting workspace names.
- **Recommendation:** **Do not run.** Archive. Some concepts (Translation records, workspace renaming) may be worth examining for future improvements to `prism_brand/branding/setup.py`, but the script itself should not be executed.

### `deploy_prism_branding.sh`

- **Path:** `/opt/prismerp/scripts/deploy_prism_branding.sh`
- **Size:** 10,328 bytes
- **Permissions:** `-rwxrwxr-x` (755)
- **Executable:** yes
- **Purpose:** Orchestrated multi-step deployment: validates environment, runs `prism_complete_branding.py`, clears Frappe cache, rebuilds assets, runs migrations, syncs fixtures, flushes Redis, restarts backend, and verifies.
- **What it touches:** Docker containers (backend, redis), Redis (FLUSHALL), Frappe DB (via bench console), site assets, bench build output, docker-compose services.
- **Risk analysis:** **Critical.** Combines the risks of `prism_complete_branding.py` with service restarts, asset rebuilds, and `redis-cli FLUSHALL`. Uses `docker-compose` (v1 syntax) instead of `docker compose` (v2). References old container naming. Restarting the backend mid-deployment could interrupt active users.
- **Still relevant:** **Superseded.** The Docker image build process (`prismerp:erpnext-16.15.1-frappe-16.16.0-branding-002`) already includes the branding app. The `after_migrate` hook handles runtime branding application. No manual deployment orchestration is needed.
- **Recommendation:** **Do not run.** Archive.

### `prismerp-utils.sh`

- **Path:** `/opt/prismerp/scripts/prismerp-utils.sh`
- **Size:** 9,373 bytes
- **Permissions:** `-rw-rw-r--` (664)
- **Executable:** no (but can be sourced)
- **Purpose:** Interactive shell utility library providing functions: `prismerp-status`, `prismerp-restore-symlinks`, `prismerp-force-identity`, `prismerp-verify-assets`, `prismerp-clear-cache`, `prismerp-restart`, `prismerp-logs`, `prismerp-console`, `prismerp-help`.
- **What it touches:** Docker containers, Redis, Frappe DB, symlinks, bench, HTTP endpoints.
- **Risk analysis:** Several functions are safe diagnostics (`prismerp-status`, `prismerp-logs`, `prismerp-help`), but others invoke the obsolete/dangerous scripts above (`prismerp-restore-symlinks`, `prismerp-force-identity`, `prismerp-clear-cache` which flushes Redis, `prismerp-restart` which does `docker-compose down` then `up`).
- **Still relevant:** **Partially.** The diagnostic functions (`prismerp-status`, `prismerp-logs`, `prismerp-verify-assets`, `prismerp-console`) are still useful for quick checks. The destructive functions should be removed or deprecated.
- **Recommendation:** Keep documented. Extract the diagnostic functions into a canonical utility script in `prism-erp/deploy/scripts`. Deprecate or remove the destructive functions. Do not source casually.

## Global conclusions

### Obsolete scripts (should not be run)
- `restore_symlinks.sh` — Reverses the symlink-trap fix that the current architecture depends on.
- `force_prismerp_identity.py` — Functionality replaced by `prism_brand/branding/setup.py` hooks.
- `prism_complete_branding.py` — Functionality replaced by `prism_brand/branding/setup.py` hooks.
- `deploy_prism_branding.sh` — Functionality replaced by Docker image build + migration hooks.

### Partially useful (preserve for reference)
- `prismerp-utils.sh` — Contains useful diagnostic functions that could be extracted into a canonical utility script.

### Scripts that should be preserved
- `prismerp-utils.sh` (diagnostic functions only) — could be promoted to `/opt/prismerp/src/prism-erp/deploy/scripts/prismerp-utils.sh` after removing destructive functions.

### Scripts that should be archived later
All five scripts should eventually be moved to `/opt/prismerp/archive/scripts/` after user approval. The `prismerp-utils.sh` diagnostic functions should be extracted first.

### Scripts that should be moved to canonical location later
None directly, but concepts from `prismerp-utils.sh` (status check, log viewer, console access) are worth rewriting as canonical scripts in `prism-erp/deploy/scripts`.

### Scripts requiring manual review
None beyond what is already documented. All scripts have been fully analyzed.

## Rules for future agents

1. **Do not run loose scripts without explicit approval.** The scripts in `/opt/prismerp/scripts` are historical and may be incompatible with the current architecture.
2. **Do not treat `/opt/prismerp/scripts` as canonical automation.** This directory contains emergency/recovery scripts, not production deployment tooling.
3. **Prefer scripts committed under `/opt/prismerp/src/prism-erp/deploy/scripts`.** Only scripts in the repository have been reviewed and tested.
4. **Prefer branding logic committed under `/opt/prismerp/src/prism-brand`.** The `prism_brand/branding/setup.py` handles all branding automatically on install/migrate.
5. **Do not edit Docker apps volume as source of truth.** The apps volume is a runtime artifact. Source of truth is `/opt/prismerp/src/prism-brand`.
6. **Do not run scripts that alter `site_config.json`, symlinks, assets, or Redis cache without understanding their effect.** Scripts like `restore_symlinks.sh` can undo architectural fixes. Scripts that flush Redis can disrupt active sessions.
