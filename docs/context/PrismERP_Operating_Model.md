# PrismERP Operating Model

## Secret Handling and Generated Files

### Core Principles
- Agents must not read or print `/opt/prismerp/secrets/*` unless explicitly instructed.
- Agents must not print full `site_config.json` files because they contain database credentials and encryption keys.
- Agents must not print full generated Docker Compose files if they contain inlined environment variables.
- Agents may inspect sensitive files only by path, owner, group, permission mode, and yes/no presence of sensitive-looking keys.
- Generated Compose files are runtime artifacts, not source-of-truth documentation.
- Source-of-truth configuration belongs in documented templates and repos, not in generated files with secrets.
- `site_config.json` is expected to contain per-site credentials in Frappe and must be treated as sensitive.
- `.env`, `*.env`, `*secret*`, `*password*`, `*key*`, and private key files must not be committed.
- Safe discovery means metadata-only inspection unless the user explicitly authorizes secret access.

### Current staging sensitive paths
- `/opt/prismerp/secrets/`
- `/opt/prismerp/secrets/prism-dev-db-root-password.txt`
- `/opt/prismerp/gitops/prism-dev/docker-compose.yml`
- `/opt/prismerp/docker/frappe_docker/prismerp-dev.env`
- Docker volume site configs under `frappe_docker_sites`

### Command Policy

**Allowed without approval:**
- `ls`, `stat`, `find` for metadata
- `grep -Eiq` yes/no scans for sensitive token presence
- `git status`, `git diff`, `git log`

**Conditional / requires explicit approval:**
- Reading secret files
- Printing generated Compose files
- Printing `site_config.json`
- Rotating passwords
- Changing database users
- Restarting Docker stack

**Forbidden:**
- Publishing secrets
- Committing secrets
- Printing database passwords
- Printing private keys
