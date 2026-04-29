# Azure Docker Phase 1 Runbook

## Purpose

This runbook documents the Phase 1 PrismERP Docker foundation on Azure.

## Server

- Host: erp-dev-server
- Cloud: Azure
- Region: South Africa North
- OS: Ubuntu 24.04 LTS
- Runtime: Docker Engine + Docker Compose

## Project paths

- Source repos: `/opt/prismerp/src`
- Frappe Docker: `/opt/prismerp/docker/frappe_docker`
- Generated Compose: `/opt/prismerp/gitops/prism-dev/docker-compose.yml`

## Docker image

- Image: `prismerp`
- Tag: `16.15.1-phase1`

## Apps

- `frappe`
- `erpnext`
- `prism_brand`
- `prism_saas`

## Sites

- `dev-erp.prismtechco.com`
- `tenant1-dev-erp.prismtechco.com`

## Start stack

```bash
docker compose \
  --project-name prism-dev \
  -f /opt/prismerp/gitops/prism-dev/docker-compose.yml \
  up -d
```

## Stop stack

```bash
docker compose \
  --project-name prism-dev \
  -f /opt/prismerp/gitops/prism-dev/docker-compose.yml \
  down
```

## Check containers

```bash
docker compose \
  --project-name prism-dev \
  -f /opt/prismerp/gitops/prism-dev/docker-compose.yml \
  ps
```

## Enter backend

```bash
docker compose \
  --project-name prism-dev \
  -f /opt/prismerp/gitops/prism-dev/docker-compose.yml \
  exec backend bash
```

## Check installed apps

Run inside the backend container:

```bash
bench --site dev-erp.prismtechco.com list-apps
bench --site tenant1-dev-erp.prismtechco.com list-apps
```

## Access through SSH tunnel

Run on local laptop:

```bash
ssh -L 8080:localhost:8080 azure-prism-erp
```

Add these to the Windows hosts file:

```text
127.0.0.1  dev-erp.prismtechco.com
127.0.0.1  tenant1-dev-erp.prismtechco.com
```

Open:

```text
http://dev-erp.prismtechco.com:8080
http://tenant1-dev-erp.prismtechco.com:8080
```

## Login

```text
Username: Administrator
Password: admin
```
