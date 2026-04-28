# ADR 0002: Cloud and edge architecture

## Status

Accepted

## Decision

PrismERP will initially run on Microsoft Azure in the South Africa North region, targeting Kenya as the first market.

Cloudflare will be used for DNS, edge SSL, basic WAF/security controls, and selective static asset caching.

## Current foundation

- Cloud: Microsoft Azure
- Region: South Africa North
- VM: erp-dev-server
- OS: Ubuntu 24.04 LTS
- Runtime: Docker Engine and Docker Compose
- DNS/Edge: Cloudflare

## Current role of the VM

The current VM is a cloud development/staging foundation. It is not yet the final production architecture for paying tenants.

## Future production direction

Production should split the workload into at least:

- application/Docker node
- dedicated MariaDB database node
- backup storage
- monitoring/logging
- CI/CD automation
