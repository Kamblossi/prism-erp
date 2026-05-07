# PrismERP Operating Model

## 1. Purpose

This document defines the operational model, rules, and boundaries for agents and operators working on the PrismERP project.

## 2. Project Intent

PrismERP is a hosted ERP SaaS platform built on Frappe Framework + ERPNext.
PrismERP-specific value lives in custom apps (`prism_brand`, `prism_saas`), deployment orchestration, and infrastructure.
ERPNext and Frappe remain upstream dependencies and are not forked.

## 3. Current Environment

- Cloud: Azure (South Africa North)
- VM: erp-dev-server (Ubuntu 24.04 LTS)
- DNS/Edge: Cloudflare
- Runtime: Docker Engine + Docker Compose
- Stack name: `prism-dev`
- Compose file: `/opt/prismerp/gitops/prism-dev/docker-compose.yml`
- Live sites:
  - `dev-erp.prismtechco.com`
  - `tenant1-dev-erp.prismtechco.com`

## 4. Repository Responsibilities

| Repository | Responsibility |
|-----------|----------------|
| `prism-erp` | Platform docs, decisions, runbooks, orchestration notes, CI/CD |
| `prism-brand` | Frappe/Python app for PrismERP branding and identity (`prism_brand`) |
| `prism_saas` | Frappe/Python app for SaaS control-plane (provisioning, subscriptions) |
| `prism_infra` | Azure infrastructure (Terraform, Ansible) and operations |

## 5. Source of Truth Rules

- **Branding source of truth:** `/opt/prismerp/src/prism-brand`
- **Canonical automation:** `/opt/prismerp/src/prism-erp/deploy/scripts`
- **Generated Compose files:** runtime artifacts, not source-of-truth
- **Docker apps volume:** runtime artifact, not source-of-truth
- **Site config files:** runtime artifacts containing per-site credentials

## 6. Agent Command Boundaries

**Allowed without approval:**
- read-only inspection (`ls`, `stat`, `find`)
- `git status`, `git diff`, `git log`
- `docker ps`, `docker logs`, `docker compose ps`
- metadata-only permission checks
- non-secret grep yes/no scans (`grep -Eiq`)

**Conditional / requires explicit approval:**
- `bench migrate`
- `bench build`
- `bench clear-cache`
- Docker stack restart
- image rebuild
- backup run
- editing site settings
- applying branding to live sites
- committing/pushing changes

**Forbidden:**
- `bench drop-site`
- `bench reinstall`
- `bench uninstall-app`
- `docker compose down -v`
- `docker volume rm`
- broad `rm -rf`
- `git reset --hard`
- `git push --force`
- printing secrets
- printing full `site_config.json`
- editing Frappe/ERPNext core for branding

## 7. Secret Handling and Generated Files

- Agents must not read or print `/opt/prismerp/secrets/*` unless explicitly instructed.
- Agents must not print full `site_config.json` files because they contain database credentials and encryption keys.
- Agents must not print full generated Docker Compose files if they contain inlined environment variables.
- Generated Compose files are runtime artifacts, not source-of-truth documentation.
- `site_config.json` is expected to contain per-site credentials in Frappe and must be treated as sensitive.
- `.env`, `*.env`, `*secret*`, `*password*`, `*key*`, and private key files must not be committed.
- Safe discovery means metadata-only inspection unless the user explicitly authorizes secret access.

**Sensitive paths:**
- `/opt/prismerp/secrets/`
- `/opt/prismerp/docker/frappe_docker/prismerp-dev.env`
- Docker volume site configs under `frappe_docker_sites`

## 8. Branding Workflow Rules

- Branding source of truth is `/opt/prismerp/src/prism-brand` (`prism_brand` package).
- Branding automation is handled by `prism_brand/branding/setup.py` hooks (`after_install`, `after_migrate`).
- Branding must never modify Frappe/ERPNext core code.
- Assets are physically copied to `sites/assets/prism_brand/` because Nginx cannot follow symlinks across Docker volume boundaries.
- Loose branding scripts in `/opt/prismerp/scripts` have been retired.

## 9. Tenant Domain Rules

- First-level subdomains only: `tenantname-erp.prismtechco.com`
- NOT nested second-level: `tenantname.erp.prismtechco.com`
- Rationale: Cloudflare Free Universal SSL covers first-level subdomains only.

## 10. Port Exposure Policy

- Dev stack should be accessed through SSH tunnel only.
- Raw port 8080 should not be reachable from the public internet.
- UFW should explicitly deny 8080/tcp.
- MariaDB 3306 and Redis 6379 must remain inaccessible publicly.
- Future production public access should use proper HTTPS reverse proxy.

## 11. Backup Policy

- Manual backup script: `/opt/prismerp/src/prism-erp/deploy/scripts/backup-prism-dev-sites.sh`
- Backup destination: `/opt/prismerp/backups/manual/<timestamp>/<site>/`
- Logs: `/opt/prismerp/backups/logs/`
- No offsite sync, scheduled timer, or restore automation yet.
- Production must later use encrypted offsite storage (Azure Blob Storage).

## 12. Loose Operational Scripts Policy

- Loose scripts in `/opt/prismerp/scripts` have been retired and archived under `/opt/prismerp/archive/scripts/`.
- `/opt/prismerp/scripts` is not a canonical automation directory. It now contains only a `README.md` explaining retirement.
- New operational scripts must be committed under `/opt/prismerp/src/prism-erp/deploy/scripts`.
- Archived scripts must not be executed unless explicitly approved.

## 13. Versioning and Image Tag Policy

- PrismERP uses Semantic Versioning (MAJOR.MINOR.PATCH). Current product version: `0.1.0`.
- Docker image tags must include PrismERP product version, environment, build number, and actual upstream versions (ERPNext, Frappe).
- Format: `prismerp:<prismerp-version>-<environment>.<build-number>-erpnext<erpnext-version>-frappe<frappe-version>`
- See `/opt/prismerp/src/prism-erp/docs/architecture/versioning-and-image-tags.md` for full policy.

## 14. Source-Code vs Runtime Issue Diagnosis

- When diagnosing issues, check source repos first (`/opt/prismerp/src/`).
- If source is correct but runtime behaves differently, check Docker apps volume for drift.
- Do not treat Docker apps volume as long-term source of truth.
- If volume drift is found, fix the source repo and rebuild the image.

## 15. Rules for Future Agents

- Read AGENTS.md first.
- Do not run loose scripts without explicit approval.
- Do not edit Frappe/ERPNext source code.
- Do not print secrets or full config files.
- If live system evidence contradicts documentation, report the mismatch.
- Commit changes only to the appropriate repository.
