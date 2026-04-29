# Phase 3 Branding Runbook

## Purpose

This runbook explains how PrismERP branding is implemented without editing ERPNext or Frappe core source code.

## Repositories involved

- `prism-brand`: branding assets, CSS, hooks
- `prism-erp`: documentation, image tags, orchestration notes

## Active branding files

```text
/opt/prismerp/src/prism-brand/prism_brand/hooks.py
/opt/prismerp/src/prism-brand/prism_brand/public/css/prism_brand.css
/opt/prismerp/src/prism-brand/prism_brand/public/images/prismerp-logo.svg
/opt/prismerp/src/prism-brand/prism_brand/public/images/favicon.svg
```

## Docker image

Current branding image:

```text
prismerp:16.15.1-phase3-branding-001
```

## Rebuild image

```bash
cd /opt/prismerp/docker/frappe_docker

docker build \
  --no-cache \
  --build-arg=FRAPPE_PATH=https://github.com/frappe/frappe \
  --build-arg=FRAPPE_BRANCH=version-16 \
  --build-arg=PYTHON_VERSION=3.14 \
  --build-arg=NODE_VERSION=24 \
  --secret=id=apps_json,src=apps.json \
  --tag prismerp:16.15.1-phase3-branding-001 \
  --file=images/layered/Containerfile .
```

## Apply changes to sites

```bash
docker compose \
  --project-name prism-dev \
  -f /opt/prismerp/gitops/prism-dev/docker-compose.yml \
  exec backend bash
```

Inside backend:

```bash
bench --site dev-erp.prismtechco.com migrate
bench --site tenant1-dev-erp.prismtechco.com migrate
bench build --app prism_brand
bench --site dev-erp.prismtechco.com clear-cache
bench --site tenant1-dev-erp.prismtechco.com clear-cache
```

## Test URLs

```text
http://dev-erp.prismtechco.com:8080
http://tenant1-dev-erp.prismtechco.com:8080
```

## Rule

Do not edit ERPNext or Frappe core files for surface-level branding.
