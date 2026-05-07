# PrismERP Versioning and Image Tag Policy

## Purpose

Explain how PrismERP product versions and Docker image tags should be named.

## Product versioning

PrismERP uses Semantic Versioning:

`MAJOR.MINOR.PATCH`

Initial formal version:

`0.1.0`

Reason: PrismERP is still in staging/development and not yet production-ready for paying tenants.

## Version increment rules

### Major

Increment when PrismERP introduces incompatible/breaking changes.

### Minor

Increment when PrismERP adds functionality in a backward-compatible way (e.g. SaaS tenant provisioning).

### Patch

Increment when PrismERP makes backward-compatible bug fixes (e.g. branding persistence fix).

## Production readiness rule

`1.0.0` is reserved for the first production-ready PrismERP release for real tenants.

## Docker image tag format

Use:

`prismerp:<prismerp-version>-<environment>.<build-number>-erpnext<erpnext-version>-frappe<frappe-version>`

Example:

`prismerp:0.1.0-staging.1-erpnext16.15.1-frappe16.17.5`

## Why image tags must include upstream versions

Frappe and ERPNext are upstream dependencies. Since Frappe can drift when using a moving branch such as `version-16`, the actual Frappe version must be visible in the tag or version manifest.

## Current known image mismatch

Current image:

`prismerp:erpnext-16.15.1-frappe-16.16.0-branding-002`

Actual contents:

- ERPNext: `16.15.1`
- Frappe: `16.17.5`

Conclusion: The image is functional, but the tag is misleading. The next image rebuild should use the new convention.

## Future image tag recommendation

Next image should be named:

`prismerp:0.1.0-staging.1-erpnext16.15.1-frappe16.17.5`

Only use this tag if the image actually contains:

- PrismERP product version: `0.1.0`
- ERPNext: `16.15.1`
- Frappe: `16.17.5`

## Build metadata

Each release should record:

- PrismERP product version
- environment
- build number
- ERPNext version
- Frappe version
- prism_brand commit
- prism_saas commit
- image ID
- build date
