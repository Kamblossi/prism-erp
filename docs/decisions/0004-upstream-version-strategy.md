# ADR 0004: Upstream version strategy

## Status

Accepted

## Decision

PrismERP will not maintain a heavy ERPNext fork.

ERPNext and Frappe will be consumed as pinned upstream dependencies.

Initial target:

- ERPNext: v16.15.1
- Frappe: version-16, exact compatible tag to be validated during image build and runtime testing

PrismERP-specific code will live in:

- prism_brand
- prism_saas
- prism_infra
- prism-erp orchestration/configuration

## Rationale

This reduces upgrade pain, avoids unnecessary divergence, and keeps PrismERP-specific value isolated in Prism-owned repositories.
