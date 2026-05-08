# PrismERP Dev Asset Restoration Runbook

## Problem

Login page rendered as raw HTML because Frappe/ERPNext compiled CSS/JS asset bundles returned 404.

## Symptoms

- Missing `/assets/frappe/dist/css/website.bundle...css`
- Missing `/assets/erpnext/dist/css/erpnext-web.bundle...css`
- Missing `/assets/frappe/dist/css/login.bundle...css`
- Missing `/assets/frappe/dist/js/file_uploader.bundle...js`

## Root cause

The shared `sites/assets` volume contained symlinks for `frappe` and `erpnext` pointing to `/home/frappe/frappe-bench/apps/*/public`. These symlinks work inside the **backend** container (which has the `apps` volume mounted) but are **broken in the frontend container** (which only has the `sites` volume mounted and no access to the `apps` directory).

Additionally, the `assets.json` manifest contained stale file hashes from a previous build, mismatching the actual bundled files in the current image.

## Fix used

1. Replaced the broken symlinks in `sites/assets/` with actual copies of the `frappe/public` and `erpnext/public` directories from the running backend container.
2. Updated `assets.json` to reference the correct hashed filenames that actually exist on disk.
3. Cleared Frappe cache and flushed Redis.

## Safety notes

- Do not edit Frappe/ERPNext source.
- Do not delete `sites/assets`.
- Do not run `restore_symlinks.sh`; that script was retired because it reverses the current physical asset-materialization fix.
- Re-run this restoration after image rebuilds if the shared sites volume loses built assets.

## Commands

```bash
# 1. Replace symlinks with actual directories
docker exec prism-dev-backend-1 bash -c "
  cd /home/frappe/frappe-bench
  rm -f sites/assets/frappe sites/assets/erpnext
  cp -r apps/frappe/frappe/public sites/assets/frappe
  cp -r apps/erpnext/erpnext/public sites/assets/erpnext
"

# 2. Fix assets.json hash mismatch
docker exec prism-dev-backend-1 bash -lc '
cd /home/frappe/frappe-bench
python3 << PYEOF
import json, os, re
assets_path = "sites/assets/assets.json"
with open(assets_path) as f:
    assets = json.load(f)
dist_dirs = ["sites/assets/frappe/dist", "sites/assets/erpnext/dist"]
file_map = {}
for ddir in dist_dirs:
    if not os.path.isdir(ddir): continue
    for root, dirs, files in os.walk(ddir):
        for fname in files:
            if fname.endswith(".map"): continue
            fpath = os.path.join(root, fname)
            rel = os.path.relpath(fpath, "sites/assets")
            m = re.match(r"(.+?)\.[A-Z0-9]+\.(css|js)$", fname)
            if m:
                key = f"{m.group(1)}.{m.group(2)}"
                file_map[key] = "/assets/" + rel
changed = 0
for key, val in assets.items():
    if key in file_map and file_map[key] != val:
        assets[key] = file_map[key]
        changed += 1
if changed:
    with open(assets_path, "w") as f:
        json.dump(assets, f, indent=2)
        f.write("\n")
    print(f"Updated {changed} entries")
PYEOF
'

# 3. Clear caches
docker compose --project-name prism-dev -f /opt/prismerp/gitops/prism-dev/docker-compose.yml exec backend bash -lc "
  bench --site dev-erp.prismtechco.com clear-cache
  bench --site tenant1-dev-erp.prismtechco.com clear-cache
"

# 4. Flush Redis
docker exec prism-dev-redis-cache-1 redis-cli flushall
```

## Prevention

The Docker image build should include a step that materializes app assets into `sites/assets/` instead of relying on symlinks, or the frontend compose config should also mount the `apps` volume read-only.
