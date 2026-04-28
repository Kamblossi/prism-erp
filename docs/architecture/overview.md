# PrismERP Architecture Overview

## Current foundation

PrismERP is being prepared as a hosted ERP SaaS platform for the Kenyan market.

The current foundation is an Azure-hosted Docker development/staging node.

## Current infrastructure

- Cloud: Azure
- Region: South Africa North
- VM: erp-dev-server
- OS: Ubuntu 24.04 LTS
- Edge/DNS: Cloudflare
- Runtime: Docker Engine + Docker Compose
- Initial database: containerized MariaDB for Phase 1 testing
- Future database: dedicated MariaDB VM

## Product model

PrismERP is built on:

- Frappe Framework
- ERPNext
- prism_brand
- prism_saas

## Tenancy model

Each customer should eventually have:

- one Frappe site
- one database
- one site folder
- one domain
- isolated files and backups

## Domain model

Production:

- erp.prismtechco.com
- tenantname-erp.prismtechco.com

Development:

- dev-erp.prismtechco.com
- tenant1-dev-erp.prismtechco.com

## Repository model

- prism-erp: platform/orchestration/docs/CI/CD
- prism-brand: Frappe app for branding
- prism_saas: Frappe app for SaaS control-plane logic
- prism_infra: Azure infrastructure and operations

## Principle

ERPNext and Frappe stay upstream. PrismERP value lives in custom apps, deployment orchestration, infrastructure, and operational systems.
