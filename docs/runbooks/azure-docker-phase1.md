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

- Source repos: /opt/prismerp/src
- Frappe Docker: /opt/prismerp/docker/frappe_docker
- Generated Compose: /opt/prismerp/gitops/prism-dev/docker-compose.yml

## Docker image

- Image: prismerp
- Tag: 16.15.1-phase1

## Apps

- frappe
- erpnext
- prism_brand
- prism_saas

## Sites

- dev-erp.prismtechco.com
- tenant1-dev-erp.prismtechco.com

## Start stack

```bash
docker compose \
  --project-name prism-dev \
  -f /opt/prismerp/gitops/prism-dev/docker-compose.yml \
  up -d

#Stop Stack
docker compose \
  --project-name prism-dev \
  -f /opt/prismerp/gitops/prism-dev/docker-compose.yml \
  down

#Check Containers
docker compose \
  --project-name prism-dev \
  -f /opt/prismerp/gitops/prism-dev/docker-compose.yml \
  ps

#Enter backend
docker compose \
  --project-name prism-dev \
  -f /opt/prismerp/gitops/prism-dev/docker-compose.yml \
  exec backend bash

#Check installed apps
bench --site dev-erp.prismtechco.com list-apps
bench --site tenant1-dev-erp.prismtechco.com list-apps

#Access through SSH tunnel (Run on local laptop)
### Step A: Establish the Tunnel
Run this in Git Bash or PowerShell on your laptop:
ssh -L 8080:localhost:8080 azure-prism-erp

### Step B: Map the Hostnames (Windows)
Because Frappe uses Host-Header routing, you MUST map these domains in your Windows hosts file (C:\Windows\System32\drivers\etc\hosts):
127.0.0.1  dev-erp.prismtechco.com
127.0.0.1  tenant1-dev-erp.prismtechco.com

### Step C: Browser Access
Open your browser and navigate to:
- Control Site: http://dev-erp.prismtechco.com:8080
- Tenant Site: http://tenant1-dev-erp.prismtechco.com:8080

#Login: Administrator / admin

