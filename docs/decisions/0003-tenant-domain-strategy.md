# ADR 0003: Tenant domain strategy

## Status

Accepted

## Decision

PrismERP will use first-level subdomains under `prismtechco.com` for tenant sites.

## Production pattern

- erp.prismtechco.com
- acme-erp.prismtechco.com
- tenantname-erp.prismtechco.com

## Development pattern

- dev-erp.prismtechco.com
- tenant1-dev-erp.prismtechco.com

## Rejected pattern

- tenant1.erp.prismtechco.com

## Rationale

Cloudflare Free Universal SSL covers first-level subdomains such as `tenant1-erp.prismtechco.com`, but not nested second-level tenant domains such as `tenant1.erp.prismtechco.com`.

The flattened naming strategy avoids certificate errors while keeping tenant names readable.
